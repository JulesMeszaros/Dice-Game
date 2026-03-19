// Author:
// Title:

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float circle(vec2 st, float r){
    float d = distance(st, vec2(0.5));
    float pct = step(d, r);

    return pct;
}

float random (in vec2 _st, float i, float j) {
    return fract(sin(dot(_st.xy,
                         vec2(0.0003*i,.100*j)))*
        43758.257);
}

mat3 yuv2rgb = mat3(1.0, 0.0, 1.13983,
                    1.0, -0.883, -0.58060,
                    1.0, 2.03211, 0.0);

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
;
    
    vec3 color = vec3(0.);
    color =vec3(random(st, sin(u_time/2000.)/3., cos(u_time/2000.)/3.), random(st, sin(u_time/2.)/3., cos(u_time/200.)/3.), 1);

    gl_FragColor = vec4(color,1.0);
}