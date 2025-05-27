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

return Shaders