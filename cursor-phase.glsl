// cursor-phase.glsl - A vibrant, multi-phase cursor shader for Ghostty.
// Created by Gemini CLI.

float ease(float x) {
    return pow(1.0 - x, 4.0);
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);
    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);
    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);
    return s * sqrt(d);
}

vec2 normalizeCoords(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float blend(float t) {
    float sqr = t * t;
    return sqr / (2.0 * (sqr - t) + 1.0);
}

float antialiasing(float distance) {
    return 1.0 - smoothstep(0.0, 0.005, distance);
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y);
    float condition2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.0), rectangle.y - (rectangle.w / 2.0));
}

const float DURATION = 0.45;
const float DRAW_THRESHOLD = 1.1;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    vec2 vu = normalizeCoords(fragCoord, 1.0);
    vec4 currentCursor = vec4(normalizeCoords(iCurrentCursor.xy, 1.0), normalizeCoords(iCurrentCursor.zw, 0.0));
    vec4 previousCursor = vec4(normalizeCoords(iPreviousCursor.xy, 1.0), normalizeCoords(iPreviousCursor.zw, 0.0));

    float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invVF = 1.0 - vertexFactor;

    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * invVF, currentCursor.y);
    vec2 v2 = vec2(previousCursor.x + currentCursor.z * invVF, previousCursor.y);
    vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);

    float timeSinceChange = iTime - iTimeCursorChange;
    float progress = blend(clamp(timeSinceChange / DURATION, 0.0, 1.0));
    float easedProgress = ease(progress);

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float cursorSize = max(currentCursor.z, currentCursor.w);
    float trailThreshold = DRAW_THRESHOLD * cursorSize;
    float lineLength = distance(centerCC, centerCP);

    float sdfCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * vec2(-0.5, 0.5)), currentCursor.zw * 0.5);
    
    // Colorful Phase Pulse around the cursor
    float pulse = exp(-8.0 * timeSinceChange);
    float cursorGlow = exp(-25.0 * abs(sdfCursor)) * pulse;
    vec3 pulseColor = hsv2rgb(vec3(fract(iTime * 0.6), 0.7, 1.0));
    
    vec4 finalColor = fragColor;
    finalColor.rgb += pulseColor * cursorGlow * 0.6;

    bool isFarEnough = lineLength > trailThreshold;
    if (isFarEnough) {
        float distanceToEnd = distance(vu.xy, centerCC);
        float alphaModifier = clamp(distanceToEnd / (lineLength * (easedProgress + 0.001)), 0.0, 1.0);

        float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);
        float trailMask = 1.0 - smoothstep(-0.005, 0.005, sdfTrail);
        
        // Multi-color Phase Trail
        float trailPhase = fract(distanceToEnd * 5.0 - iTime * 2.0);
        vec3 color1 = hsv2rgb(vec3(fract(iTime * 0.2), 0.8, 1.0));
        vec3 color2 = hsv2rgb(vec3(fract(iTime * 0.2 + 0.3), 0.8, 1.0));
        vec3 trailColor = mix(color1, color2, trailPhase);
        
        // Add a "sparkle" or intensity wave
        float wave = sin(distanceToEnd * 20.0 - iTime * 10.0) * 0.5 + 0.5;
        trailColor *= (1.0 + wave * 0.4);
        
        float trailGlow = exp(-15.0 * max(0.0, sdfTrail)) * (1.0 - alphaModifier);
        
        vec4 trailLayer = vec4(trailColor, (1.0 - alphaModifier) * 0.9);
        finalColor.rgb = mix(finalColor.rgb, trailColor, trailMask * (1.0 - alphaModifier));
        finalColor.rgb += trailColor * trailGlow * 0.5;
    }

    // Mask text
    fragColor = mix(finalColor, fragColor, step(sdfCursor, 0.0));
}
