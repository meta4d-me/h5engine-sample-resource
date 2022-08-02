#version 300 es

precision mediump float;

uniform lowp sampler2D _MainTex;  
in mediump vec2 _base_uv;
in lowp vec4 attcolor;

#ifdef FOG
uniform lowp vec4 glstate_fog_color; 
in lowp float factor;
#endif

//texture2DEtC1Mark


out vec4 color; 
void main() 
{
    lowp vec4 basecolor = texture(_MainTex, _base_uv);
    lowp vec4 emission=basecolor*attcolor;

    #ifdef FOG
    //emission.xyz = mix(glstate_fog_color.rgb, emission.rgb, factor);
    emission= mix(vec4(0,0,0,0), emission, factor);
    #endif

    color =emission;
}