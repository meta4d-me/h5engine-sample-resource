#version 300 es

precision mediump float;

uniform lowp sampler2D _MainTex;                                                                                                
in highp vec2 xlv_TEXCOORD0;
uniform lowp float _Alpha;
uniform lowp float _Superimposition;

#ifdef FOG
uniform lowp vec4 glstate_fog_color; 
in lowp float factor;
#endif

//texture2DEtC1Mark

out vec4 color; 
void main() 
{
    lowp vec4 emission = texture(_MainTex, xlv_TEXCOORD0);
    emission.a=emission.a*_Alpha;
    emission.xyz *= _Superimposition;
    //----------------------------------------------------------
    #ifdef FOG
    emission.xyz= mix(glstate_fog_color.xyz, emission.xyz, factor);
    #endif
    color = emission;

}