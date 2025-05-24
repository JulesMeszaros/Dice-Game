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


return Shaders