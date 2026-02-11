// sparks.glsl - A reactive spark shader for Ghostty.
// Sparks fly off the cursor, affected by gravity and movement intensity.
// Created by Gemini CLI.

// --- Utilities ---

float hash11(float p) {
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash12(vec2 p) {
    vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash21(float p) {
	vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.xx + p3.yz) * p3.zy);
}

vec3 fireColor(float t) {
    // Transition from white-hot to orange to red to ash
    vec3 c1 = vec3(1.0, 1.0, 0.8); // White-yellow
    vec3 c2 = vec3(1.0, 0.5, 0.1); // Orange
    vec3 c3 = vec3(0.8, 0.1, 0.0); // Red
    vec3 c4 = vec3(0.2, 0.2, 0.2); // Ash
    
    if (t < 0.2) return mix(c1, c2, t / 0.2);
    if (t < 0.6) return mix(c2, c3, (t - 0.2) / 0.4);
    return mix(c3, c4, (t - 0.6) / 0.4);
}

vec2 normalizeCoords(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

// --- Particle Simulation ---

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // 1. Get Terminal Color
    #if !defined(WEB)
    vec4 terminalColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #else
    vec4 terminalColor = vec4(0.0, 0.0, 0.0, 1.0);
    #endif

    vec2 uv = normalizeCoords(fragCoord, 1.0);
    
    // 2. Cursor Data
    vec4 cur = vec4(normalizeCoords(iCurrentCursor.xy, 1.0), normalizeCoords(iCurrentCursor.zw, 0.0));
    vec4 prev = vec4(normalizeCoords(iPreviousCursor.xy, 1.0), normalizeCoords(iPreviousCursor.zw, 0.0));
    
    vec2 cCenter = cur.xy + vec2(cur.z, -cur.w) * 0.5;
    vec2 pCenter = prev.xy + vec2(prev.z, -prev.w) * 0.5;
    
    // Velocity approximation
    vec2 cursorVel = (cCenter - pCenter) * 10.0;
    float speed = length(cursorVel);
    
    // Intensity based on movement and recent changes
    float timeSinceChange = iTime - iTimeCursorChange;
    float movementIntensity = smoothstep(0.0, 1.0, speed * 0.5) + exp(-timeSinceChange * 2.0);
    movementIntensity = clamp(movementIntensity, 0.2, 2.0);

    vec3 sparkField = vec3(0.0);
    
    // 3. Procedural Sparks
    // We simulate a fixed number of particles. Each has a cyclic life.
    const int NUM_SPARKS = 60;
    for (int i = 0; i < NUM_SPARKS; i++) {
        float f = float(i);
        float rand = hash11(f * 123.456);
        
        // Cycle duration: 0.4 to 1.2 seconds
        float duration = 0.4 + rand * 0.8; 
        // Staggered start times
        float t_cycle = fract((iTime + rand * 100.0) / duration);
        float age = t_cycle * duration;
        
        // Spawn point: somewhere along the path from prev to current cursor
        float spawnT = hash11(f * 987.654 + floor((iTime + rand * 100.0) / duration));
        vec2 spawnPos = mix(pCenter, cCenter, spawnT);
        
        // Initial velocity: Random upward-biased direction + cursor velocity influence
        float angle = (rand - 0.5) * 3.14159 * 1.5; // Mostly upwards/sideways
        vec2 angleVec = vec2(sin(angle), cos(angle));
        vec2 v0 = angleVec * (0.3 + rand * 0.7) + cursorVel * 0.4;
        
        // Physics: P(t) = P0 + V0*t + 0.5*G*t^2
        // Gravity is slightly weaker for "floating" embers
        vec2 gravity = vec2(0.0, -1.2);
        vec2 pos = spawnPos + v0 * age + 0.5 * gravity * age * age;
        
        // Spark appearance
        float dist = length(uv - pos);
        
        // Size decays over time, starts slightly larger
        float size = 0.005 * (1.0 - t_cycle * 0.5);
        
        // Glow/Intensity
        float brightness = exp(-dist / size) * movementIntensity;
        
        // Stronger flicker for that "fire" look
        brightness *= 0.6 + 0.4 * sin(iTime * 30.0 + f * 10.0);
        
        // Fade in/out
        brightness *= smoothstep(0.0, 0.1, t_cycle) * smoothstep(1.0, 0.7, t_cycle);
        
        sparkField += fireColor(t_cycle) * brightness;
    }

    // 4. Composition
    vec3 finalCol = terminalColor.rgb + sparkField;
    
    // Add a slight bloom to the cursor itself
    float dCursor = length(uv - cCenter) - cur.z * 0.4;
    float cursorGlow = exp(-abs(dCursor) * 50.0) * 0.3 * movementIntensity;
    finalCol += vec3(1.0, 0.6, 0.2) * cursorGlow;

    fragColor = vec4(finalCol, terminalColor.a);
}
