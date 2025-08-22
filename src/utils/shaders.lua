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

Shaders.glitteryRainbow = love.graphics.newShader([[
    extern number time;
    extern number frequency;
    extern number intensity; // 0 = pas d'effet, 1 = effet complet
    extern number gridSize;  // taille de la grille (ex: 20.0)

    float hash(vec2 p) {
        return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
    }

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texColor = Texel(texture, texture_coords);
        if (texColor.a == 0.0) {
            return vec4(0.0);
        }

        // grille de base
        vec2 gridUV = texture_coords * gridSize;

        // offset horizontal sur une ligne sur deux (effet "briques")
        float row = floor(gridUV.y);
        if (mod(row, 2.0) == 1.0) {
            gridUV.x += 0.5; // décale d’une demi-cellule
        }

        // identifiant de cellule
        vec2 cell = floor(gridUV);

        // décalage unique par cellule
        float rnd = hash(cell);
        float offset = (rnd - 0.5) * 0.3;

        // calcul du hue avec ce décalage
        number hue = mod(time + (texture_coords.x + texture_coords.y) * frequency + offset, 1.0);

        // rainbow -> RGB
        vec3 rainbowColor = vec3(
            abs(hue * 6.0 - 3.0) - 1.0,
            2.0 - abs(hue * 6.0 - 2.0),
            2.0 - abs(hue * 6.0 - 4.0)
        );
        rainbowColor = clamp(rainbowColor, 0.0, 1.0);

        vec3 finalColor = mix(texColor.rgb, rainbowColor, intensity);

        return vec4(finalColor, texColor.a);
    }
]])

Shaders.holoDice = love.graphics.newShader([[
    extern number time;
    extern number intensity; // force de l’effet holographique (0-1)
    extern number scale;     // taille des fragments (ex: 40.0)

    // simple hash pour pseudo bruit
    float hash(vec2 p) {
        return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
    }

    vec4 effect(vec4 color, Image texture, vec2 uv, vec2 sc) {
        vec4 texColor = Texel(texture, uv);
        if (texColor.a == 0.0) return vec4(0.0);

        // coordonnées fragmentées façon carreaux
        vec2 grid = floor(uv * scale);

        // offset unique par carreau
        float rnd = hash(grid);
        float shift = rnd * 2.0 - 1.0; // entre -1 et 1

        // créer un "hue" arc-en-ciel avec variation par fragment
        float hue = mod(time * 0.2 + (uv.x + uv.y) * 0.5 + shift, 1.0);

        // conversion hue -> arc-en-ciel RGB
        vec3 rainbow = vec3(
            abs(hue * 6.0 - 3.0) - 1.0,
            2.0 - abs(hue * 6.0 - 2.0),
            2.0 - abs(hue * 6.0 - 4.0)
        );
        rainbow = clamp(rainbow, 0.0, 1.0);

        // ajouter un peu de "scintillement" (comme sur tes dés)
        float sparkle = hash(grid + floor(time * 10.0));
        rainbow *= mix(0.8, 1.3, sparkle);

        // mélange texture originale + effet holographique
        vec3 finalColor = mix(texColor.rgb, rainbow, intensity);

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
        
        // Coordonnées avec ratio d'aspect
        vec2 uv = texture_coords;
        uv.x *= love_ScreenSize.x / love_ScreenSize.y;
        
        // Animation diagonale
        vec2 movement = vec2(time * speed, time * speed * 0.7);
        vec2 animatedUV = uv + movement;
        
        // Grille de répétition
        vec2 grid = mod(animatedUV, spacing);
        
        // Distance au centre de chaque cellule
        vec2 cellCenter = vec2(spacing * 0.5);
        float dist = distance(grid, cellCenter);
        
        // Création du rond avec bords lisses
        float circle = 1.0 - smoothstep(circle_size * 0.8, circle_size, dist);
        
        // Application de l'assombrissement
        vec3 darkenedColor = texColor.rgb * (1.0 - circle * darkness);
        
        return vec4(darkenedColor, texColor.a);
    }
]])

-- Dynamic CRT with wobbling scanlines and configurable parameters
Shaders.dynamicCRT = love.graphics.newShader([[
    extern number time;
    extern vec2  screenSize;
    extern number warp;               // barrel/pincushion distortion strength
    extern number scanIntensity;      // overall darkness of scanlines (0..1)
    extern number scanFreq;           // number of scanlines (in cycles per screen height)
    extern number wobbleAmp;          // wobble amplitude (how much each scanline bends)
    extern number wobbleSpeed;        // wobble speed
    extern number lineThickness;      // thickness of scan line edge (0..0.5)
    extern number vignette;           // vignette intensity (0..1)
    extern number chroma;             // chromatic aberration amount (0..1)

    float hash(float x) {
        return fract(sin(x) * 43758.5453);
    }

    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc) {
        // tc = [0..1] texture coords, sc = screen coords in pixels
        vec2 c = tc - 0.5;

        // radial distortion
        float r2 = dot(c, c);
        c *= 1.0 + warp * r2;
        vec2 uv = c + 0.5;

        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
            return vec4(0.0, 0.0, 0.0, 1.0);
        }

        // per-scanline wobble based on screen Y (so it stays aligned to pixels)
        float y = sc.y;
        float base = sin(y * (scanFreq / screenSize.y * 6.2831853));
        float wob = sin((uv.x * 50.0) + time * wobbleSpeed + hash(floor(y)) * 6.2831853) * wobbleAmp;

        float scanShift = wob * (1.0 / screenSize.x);
        vec2 sampleUV = uv + vec2(scanShift, 0.0);

        float ca = chroma * 0.003;
        vec4 colR = Texel(texture, sampleUV + vec2(-ca, 0.0));
        vec4 colG = Texel(texture, sampleUV);
        vec4 colB = Texel(texture, sampleUV + vec2(ca, 0.0));
        vec3 tex = vec3(colR.r, colG.g, colB.b);

        float line = 0.5 + 0.5 * base;
        float edge = smoothstep(0.5 - lineThickness, 0.5 + lineThickness, line);
        float scanAtt = mix(1.0, edge, scanIntensity);

        float vig = 1.0 - vignette * smoothstep(0.5, 0.9, length(c));

        vec3 finalColor = tex * scanAtt * vig;
        return vec4(finalColor, 1.0) * color;
    }
]])

return Shaders