// Based on https://gist.github.com/chardskarth/95874c54e29da6b5a36ab7b50ae2d088
float ease(float x) {
    return pow(1.0 - x, 10.0);
}

float sdBox(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}
// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching
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

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float blend(float t)
{
    float sqr = t * t;
    return sqr / (2.0 * (sqr - t) + 1.0);
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    // Conditions using step
    float condition1 = step(b.x, a.x) * step(a.y, b.y); // a.x < b.x && a.y > b.y
    float condition2 = step(a.x, b.x) * step(b.y, a.y); // a.x > b.x && a.y < b.y

    // If neither condition is met, return 1 (else case)
    return 1.0 - max(condition1, condition2);
}
vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

const vec4 TRAIL_COLOR = vec4(1.0, 0.725, 0.161, 1.0); // yellow
const vec4 CURRENT_CURSOR_COLOR = TRAIL_COLOR;
const vec4 PREVIOUS_CURSOR_COLOR = TRAIL_COLOR;
const vec4 TRAIL_COLOR_ACCENT = vec4(1.0, 0., 0., 1.0); // red-orange
const float DURATION = .5;
const float OPACITY = .2;
// Don't draw trail within that distance * cursor size.
// This prevents trails from appearing when typing.
const float DRAW_THRESHOLD = 1.5;
// Don't draw trails within the same line: same line jumps are usually where
// people expect them.
const bool HIDE_TRAILS_ON_THE_SAME_LINE = false;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    //Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    //Normalization for cursor position and size;
    //cursor xy has the postion in a space of -1 to 1;
    //zw has the width and height
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    //When drawing a parellelogram between cursors for the trail i need to determine where to start at the top-left or top-right vertex of the cursor
    float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invertedVertexFactor = 1.0 - vertexFactor;

    //Set every vertex of my parellogram
    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor, previousCursor.y);
    vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);

    vec4 newColor = vec4(fragColor);

    float progress = blend(clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1));
    float easedProgress = ease(progress);

    //Distance between cursors determine the total length of the parallelogram;
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float cursorSize = max(currentCursor.z, currentCursor.w);
    float trailThreshold = DRAW_THRESHOLD * cursorSize;
    float lineLength = distance(centerCC, centerCP);
    
    // Always calculate cursor SDF for the pulse effect
    float sdfCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);

    // Pulse Effect
    float timeSinceChange = iTime - iTimeCursorChange;
    float pulse = exp(-10.0 * timeSinceChange); // Sharp decay
    float glowIntensity = smoothstep(0.05, 0.0, abs(sdfCursor)) * pulse * 0.8; 
    // Outer glow
    float outerGlow = exp(-abs(sdfCursor) * 10.0) * pulse * 0.5;
    
    vec4 glowColor = mix(TRAIL_COLOR, TRAIL_COLOR_ACCENT, 0.5);
    
    // Apply Glow (additive or mix)
    // We add the glow to the existing color.
    newColor = newColor + (glowColor * (glowIntensity + outerGlow));

    // Trail Logic
    bool isFarEnough = lineLength > trailThreshold;
    bool isOnSeparateLine = HIDE_TRAILS_ON_THE_SAME_LINE ? currentCursor.y != previousCursor.y : true;
    if (isFarEnough && isOnSeparateLine) {
        float distanceToEnd = distance(vu.xy, centerCC);
        float alphaModifier = distanceToEnd / (lineLength * (easedProgress));

        if (alphaModifier > 1.0) { // this change fixed it for me.
            alphaModifier = 1.0;
        }

        // float sdfCursor = ... (moved up)
        float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

        vec4 trailColor = newColor; // Start with current state (with glow)
        trailColor = mix(trailColor, TRAIL_COLOR_ACCENT, 1.0 - smoothstep(sdfTrail, -0.01, 0.001));
        trailColor = mix(trailColor, TRAIL_COLOR, antialising(sdfTrail));
        
        // Blend trail into background
        newColor = mix(fragColor, trailColor, 1.0 - alphaModifier);
        
        // Re-apply cursor mask to ensure text is visible if needed, 
        // though standard behavior usually draws cursor *over* text? 
        // The original code did: fragColor = mix(newColor, fragColor, step(sdfCursor, 0));
        // which means "If inside cursor (sdf < 0), show original fragColor (text)".
        // We want to keep that behavior for the trail.
    }
    
    // Final mix:
    // If inside cursor (sdfCursor < 0), we normally show the text (fragColor).
    // But we might want the pulse to show ON TOP of the text or around it.
    // The original code masked the cursor area strictly: 
    // fragColor = mix(newColor, fragColor, step(sdfCursor, 0));
    
    // Let's apply the trail mix first if it happened.
    // If not, newColor is just fragColor + glow.
    
    if (isFarEnough && isOnSeparateLine) {
         // The trail logic mixed 'newColor' (trail) with 'fragColor' (bg).
         // The original code replaced 'newColor' entirely in the if block.
         // Let's respect the original composition order.
    } else {
        // If no trail, newColor is fragColor + Glow.
    }

    // Final composition:
    // 1. Trail is calculated (modifies newColor potentially).
    // 2. Pulse/Glow is calculated (modifies newColor).
    // 3. Cursor mask is applied.
    
    // Let's re-order to be cleaner.
    
    // 1. Calculate Trail (Background layer)
    vec4 layerTrail = fragColor;
    if (isFarEnough && isOnSeparateLine) {
        float distanceToEnd = distance(vu.xy, centerCC);
        float alphaModifier = distanceToEnd / (lineLength * (easedProgress));
        if (alphaModifier > 1.0) alphaModifier = 1.0;
        
        float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);
        
        vec4 tColor = mix(layerTrail, TRAIL_COLOR_ACCENT, 1.0 - smoothstep(sdfTrail, -0.01, 0.001));
        tColor = mix(tColor, TRAIL_COLOR, antialising(sdfTrail));
        layerTrail = mix(fragColor, tColor, 1.0 - alphaModifier);
    }
    
    // 2. Calculate Glow (Overlay layer)
    vec4 layerGlow = vec4(0.0);
    layerGlow = glowColor * (outerGlow); // Additive glow
    
    // 3. Combine
    // Start with Trail Layer
    vec4 finalColor = layerTrail + layerGlow;
    
    // 4. Mask Cursor Content (Text)
    // The original code: fragColor = mix(newColor, fragColor, step(sdfCursor, 0));
    // This puts the original text *on top* of the trail/glow.
    // If we want the cursor to "pulse", maybe we want to tint the text too?
    // User said "make it glow and pulse".
    // If we simply add the glow, it might wash out the text if we don't mask.
    // But 'outerGlow' is outside. 
    // Let's keep the original masking for the *inside* of the cursor so text remains readable,
    // but maybe allow some transparency or tint if desired. 
    // For now, sticking to the pattern: Text on top of effects.
    
    fragColor = mix(finalColor, fragColor, step(sdfCursor, 0));

}
