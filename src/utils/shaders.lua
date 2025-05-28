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
    extern number frequency = 0.1; // plus petit = plus étendu

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texColor = Texel(texture, texture_coords);
        if (texColor.a == 0.0) {
            return vec4(0.0); // transparence
        }

        // Multiplie les coordonnées pour étendre l'effet spatialement
        number hue = mod(time + (texture_coords.x + texture_coords.y) * frequency, 1.0);

        vec3 rgb = vec3(
            abs(hue * 6.0 - 3.0) - 1.0,
            2.0 - abs(hue * 6.0 - 2.0),
            2.0 - abs(hue * 6.0 - 4.0)
        );
        rgb = clamp(rgb, 0.0, 1.0);

        return vec4(rgb, 1.0) * texColor;
    }
]])

Shaders.crt = love.graphics.newShader([[
    extern vec2 iResolution;
    extern number warp = 0.60;
    extern number scan = 0.3;

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


return Shaders