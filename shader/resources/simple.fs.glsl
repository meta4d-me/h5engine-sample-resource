#version 300 es

precision highp float;

uniform sampler2D _MainTex;
uniform float _AlphaCut;
uniform vec4 _MainColor;

in vec2 xlv_TEXCOORD0;    

#ifdef FOG
uniform lowp vec4 glstate_fog_color;
in lowp float factor;
#endif

out vec4 color; 
void main() 
{
    vec4 basecolor = texture(_MainTex, xlv_TEXCOORD0);

    if(basecolor.a < _AlphaCut)
        discard;

    basecolor = basecolor * _MainColor;

    #ifdef FOG
    basecolor.xyz = mix(glstate_fog_color.rgb, basecolor.rgb, factor);
    #endif
        
    color = basecolor;
}