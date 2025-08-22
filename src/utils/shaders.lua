local Shaders = {}

--Gray scale
Shaders.grayscaleShader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texcolor = Texel(texture, texture_coords);
        float gray = dot(texcolor.rgb, vec3(0.299, 0.587, 0.114)); // Luminance
        return vec4(gray, gray, gray, texcolor.a);
    }
]])


Shaders.rainbowShader = love.graphics.newShader([[
    extern number time;
    extern number frequency;
    extern number intensity; // 0 = pas d'effet, 1 = effet complet

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texColor = Texel(texture, texture_coords);
        if (texColor.a == 0.0) {
            return vec4(0.0);
        }

        number hue = mod(time + (texture_coords.x + texture_coords.y) * frequency, 1.0);

        vec3 rainbowColor = vec3(
            abs(hue * 6.0 - 3.0) - 1.0,
            2.0 - abs(hue * 6.0 - 2.0),
            2.0 - abs(hue * 6.0 - 4.0)
        );
        rainbowColor = clamp(rainbowColor, 0.0, 1.0);

        // Mélange entre la couleur de la texture et l'effet arc-en-ciel
        vec3 finalColor = mix(texColor.rgb, rainbowColor, intensity);

        return vec4(finalColor, texColor.a);
    }
]])

Shaders.aChrom = love.graphics.newShader([[
extern number amount;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Décalages individuels des canaux RVB
    float offset = amount / love_ScreenSize.x;

    float r = Texel(texture, texture_coords + vec2(-offset, 0.0)).r;
    float g = Texel(texture, texture_coords).g;
    float b = Texel(texture, texture_coords + vec2(offset, 0.0)).b;
    float a = Texel(texture, texture_coords).a;

    return vec4(r, g, b, a) * color;
}
]])

Shaders.grayRainbowShader = love.graphics.newShader([[
    extern number time;
    extern number frequency;
    extern number intensity; // 0 = pas d'effet, 1 = effet complet

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texColor = Texel(texture, texture_coords);
        if (texColor.a == 0.0) {
            return vec4(0.0);
        }

        number hue = mod(time + (texture_coords.x + texture_coords.y) * frequency, 1.0);

        // Couleur arc-en-ciel
        vec3 rainbowColor = vec3(
            abs(hue * 6.0 - 3.0) - 1.0,
            2.0 - abs(hue * 6.0 - 2.0),
            2.0 - abs(hue * 6.0 - 4.0)
        );
        rainbowColor = clamp(rainbowColor, 0.0, 1.0);

        // Convertir en niveau de gris (luminance approx.)
        number gray = dot(rainbowColor, vec3(0.299, 0.587, 0.114));
        vec3 grayColor = vec3(gray);

        // Mélange entre la couleur d'origine et l'effet en niveaux de gris
        vec3 finalColor = mix(texColor.rgb, grayColor, intensity);

        return vec4(finalColor, texColor.a);
    }
]])

Shaders.crt = love.graphics.newShader([[
    extern vec2 iResolution;
    extern number warp;
    extern number scan;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec2 uv = texture_coords;
        vec2 dc = abs(0.5 - uv);
        dc *= dc;

        // Courbure
        uv.x -= 0.5;
        uv.x *= 1.0 + (dc.y * (0.3 * warp));
        uv.x += 0.5;

        uv.y -= 0.5;
        uv.y *= 1.0 + (dc.x * (0.4 * warp));
        uv.y += 0.5;

        // Hors limites
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
            return vec4(0.0, 0.0, 0.0, 1.0);
        }

        // Scanlines
        float apply = abs(sin(screen_coords.y) * 0.5 * scan);
        vec4 texColor = Texel(texture, uv);
        vec3 finalColor = mix(texColor.rgb, vec3(0.0), apply);

        return vec4(finalColor, texColor.a) * color;
    }
]])

Shaders.silver = love.graphics.newShader([[extern number time;
extern number rotation; // Rotation en radians

vec3 hueShift(vec3 color, float shift) {
    const mat3 toYIQ = mat3(
        0.299,  0.587,  0.114,
        0.596, -0.274, -0.322,
        0.211, -0.523,  0.312
    );

    const mat3 toRGB = mat3(
        1.0,  0.956,  0.621,
        1.0, -0.272, -0.647,
        1.0, -1.106,  1.703
    );

    vec3 yiq = toYIQ * color;
    float hue = atan(yiq.z, yiq.y);
    float chroma = length(yiq.yz);

    hue += shift;
    yiq.y = chroma * cos(hue);
    yiq.z = chroma * sin(hue);

    return clamp(toRGB * yiq, 0.0, 1.0);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texColor = Texel(texture, texture_coords);

    // Variation avec le temps + rotation externe
    float hueOffset = sin(time + texture_coords.y * 10.0 + rotation) * 3.14;

    vec3 shifted = hueShift(texColor.rgb, hueOffset);
    return vec4(shifted, texColor.a) * color;
}]])

Shaders.glossy =  love.graphics.newShader([[
extern number scale;

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords) {
    vec4 texColor = Texel(texture, uv) * color;

    float glossPos = uv.x + uv.y;

    // Reflet fin
    float gloss = smoothstep(0.49 - 0.05 * scale, 0.5 - 0.05 * scale, glossPos) ;

    // Teinte rose personnalisée (RVB)
    vec3 pinkTint = vec3(1.0, 0.6, 0.8);

    // Mélange le reflet rose
    vec3 finalColor = texColor.rgb + pinkTint * gloss * 0.2 * scale*scale*scale;

    return vec4(finalColor, texColor.a);
}]])

Shaders.glowShader = love.graphics.newShader([[
    extern float glow_strength; // Intensité du glow
    extern vec3 glow_color;     // Couleur du glow

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texColor = Texel(texture, texture_coords);
        float brightness = dot(texColor.rgb, vec3(0.299, 0.587, 0.114)); // Luminance perceptive

        // Calcul du "glow" basé sur la luminance (les zones claires brillent plus)
        float glow = brightness * glow_strength;

        // Mélange entre la couleur d’origine et la lumière colorée
        vec3 finalColor = mix(texColor.rgb, glow_color, glow);

        return vec4(finalColor, texColor.a) * color;
    }
]])

Shaders.black = love.graphics.newShader([[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texColor = Texel(texture, texture_coords);
    return vec4(0.0, 0.0, 0.0, texColor.a) * color;
}
]])

Shaders.skew = love.graphics.newShader([[
    extern vec2 mouse_screen_pos;
    extern float hovering;
    extern float screen_scale;

    #ifdef VERTEX
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        if (hovering <= 0.){
            return transform_projection * vertex_position;
        }
        float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
        vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
        float scale = 0.2*(-0.03 - 0.3*max(0., 0.3-mid_dist))
                    *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);

        return transform_projection * vertex_position + vec4(0,0,0,scale);
    }
    #endif
]])

Shaders.diagonalCircles = love.graphics.newShader([[
    extern number time;
    extern number circle_size;    // Taille des ronds (0.01 à 0.1)
    extern number spacing;        // Espacement entre les ronds (0.1 à 0.5)
    extern number speed;          // Vitesse d'animation (0.1 à 2.0)
    extern number darkness;       // Intensité de l'assombrissement (0.1 à 0.8)

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texColor = Texel(texture, texture_coords);
        
        // Correct aspect-correct coordinates (scale around center) to keep circles round
        float aspect = love_ScreenSize.x / love_ScreenSize.y;
        vec2 uv = (texture_coords - 0.5) * vec2(aspect, 1.0) + 0.5;

        // Animation diagonale
        vec2 movement = vec2(time * speed, time * speed * 0.7);
        vec2 animatedUV = uv + movement;

        // Scale spacing on X to match aspect-correct coordinates
        vec2 spacingScaled = vec2(spacing * aspect, spacing);

        // Grid cell and center
        vec2 grid = mod(animatedUV, spacingScaled);
        vec2 cellCenter = spacingScaled * 0.5;

        // Distance in the same scaled space
        float dist = distance(grid, cellCenter);

        // Anti-aliased edge: compute screen-space derivative to adapt smoothing width
        float aa = fwidth(dist);
        // fallback tiny aa if fwidth returns 0 on some drivers
        aa = max(aa, 0.0005);

        // Circle with smooth/antialiased edge
        float circle = 1.0 - smoothstep(circle_size - aa, circle_size + aa, dist);
        
        // Application de l'assombrissement
        vec3 darkenedColor = texColor.rgb * (1.0 - circle * darkness);
        
        return vec4(darkenedColor, texColor.a);
    }
]])

return Shaders