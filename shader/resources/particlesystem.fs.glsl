#version 300 es


precision mediump float;

in vec2 v_uv;

uniform vec4 _TintColor;
uniform sampler2D _MainTex;

in vec4 v_color;

#ifdef FOG
uniform lowp vec4 glstate_fog_color; 
in lowp float factor;
#endif

out vec4 color; 
void main()
{
    vec4 _color = 2.0 * v_color * _TintColor * texture(_MainTex, v_uv);

    #ifdef FOG
        _color.xyz = mix(glstate_fog_color.rgb, color.rgb, factor);
    #endif
    
    color = _color;
}