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

--Outline d'un canvas
Shaders.outlineShader = love.graphics.newShader([[
    extern number thickness = 1.0;
    extern vec4 outlineColor = vec4(0.0, 0.0, 0.0, 1.0); // noir

    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc) {
        vec4 texColor = Texel(texture, tc);
        if (texColor.a == 0.0) {
            return vec4(0.0);
        }

        // Si on est au bord (pixel opaque avec un pixel transparent autour)
        bool isBorder = false;
        for (float x = -thickness; x <= thickness; x++) {
            for (float y = -thickness; y <= thickness; y++) {
                vec2 offset = vec2(x, y) / love_ScreenSize.xy;
                if (Texel(texture, tc + offset).a == 0.0) {
                    isBorder = true;
                }
            }
        }

        if (isBorder) {
            return outlineColor;
        }

        // Sinon on garde la couleur originale
        return texColor;
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