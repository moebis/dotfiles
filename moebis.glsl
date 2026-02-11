// --- CONFIGURATION ---
#define ZOOM_DURATION 0.5
#define MAX_SCALE 3.0
const float BLAZE_DURATION = 0.5;
const float BLAZE_OPACITY = 0.2;

const vec4 TRAIL_COLOR = vec4(1.0, 0.725, 0.161, 1.0);
const vec4 TRAIL_COLOR_ACCENT = vec4(1.0, 0., 0., 1.0); // red-orange

// --- HELPERS ---

float easeOutQuad(float t) {
    return t * (2.0 - t);
}

float blaze_ease(float x) {
    return pow(1.0 - x, 10.0);
}

float sdBox(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Renamed from normalize to avoid conflict with built-in
vec2 normCoord(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float blaze_blend(float t)
{
    float sqr = t * t;
    return sqr / (2.0 * (sqr - t) + 1.0);
}

float antialising(float distance) {
    return 1. - smoothstep(0., normCoord(vec2(2., 2.), 0.).x, distance);
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

float determineStartVertexFactor(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y); 
    float condition2 = step(a.x, b.x) * step(b.y, a.y); 
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

// --- MAIN ---

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    // Initial color from texture
    fragColor = texture(iChannel0, uv);
    
    float timeSinceChange = iTime - iTimeCursorChange;

    // 1. LAST LETTER ZOOM EFFECT
    if (timeSinceChange >= 0.0 && timeSinceChange <= ZOOM_DURATION) {
        float moveX = iCurrentCursor.x - iPreviousCursor.x;
        float moveY = iCurrentCursor.y - iPreviousCursor.y;
        
        // Must be on the same line (approximate check for y movement)
        if (abs(moveY) <= 1.0) {
            float charWidth = abs(moveX);
            // Filter out tiny movements or large jumps
            if (charWidth >= 2.0 && charWidth <= 200.0) {
                float progressZ = timeSinceChange / ZOOM_DURATION;
                
                float centerX = (iPreviousCursor.x + iCurrentCursor.x) * 0.5;
                float centerY = iPreviousCursor.y - iPreviousCursor.w * 0.5; 
                vec2 centerPos = vec2(centerX, centerY);
                
                vec2 targetSize = vec2(charWidth, iPreviousCursor.w);
                vec2 zoomSize = targetSize * 0.9;
                
                vec2 cursorUVMin = (centerPos - zoomSize * 0.5) / iResolution.xy;
                vec2 cursorUVMax = (centerPos + zoomSize * 0.5) / iResolution.xy;
                vec2 cursorCenter = (cursorUVMin + cursorUVMax) * 0.5;
                
                float scale = 1.0 + easeOutQuad(progressZ) * (MAX_SCALE - 1.0);
                vec2 sourceUV = cursorCenter + (uv - cursorCenter) / scale;
                
                bool insideLens = sourceUV.x >= cursorUVMin.x && sourceUV.x <= cursorUVMax.x &&
                                  sourceUV.y >= cursorUVMin.y && sourceUV.y <= cursorUVMax.y;
                                    
                if (insideLens) {
                    vec4 zoomedColor = texture(iChannel0, sourceUV);
                    float alphaZ = 1.0 - easeOutQuad(progressZ); 
                    fragColor = mix(fragColor, zoomedColor, alphaZ);
                }
            }
        }
    }

    // 2. CURSOR BLAZE EFFECT
    {
        vec2 vu = normCoord(fragCoord, 1.);
        vec2 offsetFactor = vec2(-.5, 0.5);

        vec4 currentCursor = vec4(normCoord(iCurrentCursor.xy, 1.), normCoord(iCurrentCursor.zw, 0.));
        vec4 previousCursor = vec4(normCoord(iPreviousCursor.xy, 1.), normCoord(iPreviousCursor.zw, 0.));

        float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
        float invertedVertexFactor = 1.0 - vertexFactor;

        vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
        vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
        vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor, previousCursor.y);
        vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);

        vec4 blazeColor = vec4(fragColor);

        float progressB = blaze_blend(clamp(timeSinceChange / BLAZE_DURATION, 0.0, 1.0));
        float easedProgressB = blaze_ease(progressB);

        vec2 centerCC = getRectangleCenter(currentCursor);
        vec2 centerCP = getRectangleCenter(previousCursor);
        float lineLength = distance(centerCC, centerCP);
        float distanceToEnd = distance(vu.xy, centerCC);
        float alphaModifier = distanceToEnd / (lineLength * (easedProgressB + 0.001)); // Avoid div by zero

        if (alphaModifier > 1.0) {
            alphaModifier = 1.0;
        }

        float sdfCursor = sdBox(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
        float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

        blazeColor = mix(blazeColor, TRAIL_COLOR_ACCENT, 1.0 - smoothstep(sdfTrail, -0.01, 0.001));
        blazeColor = mix(blazeColor, TRAIL_COLOR, antialising(sdfTrail));

        blazeColor = mix(fragColor, blazeColor, 1.0 - alphaModifier);
        fragColor = mix(blazeColor, fragColor, step(sdfCursor, 0.0));
    }
}
