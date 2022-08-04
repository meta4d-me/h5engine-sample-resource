#version 300 es

precision mediump float;

in vec2 v_uv;

uniform vec4 _TintColor;
uniform sampler2D _MainTex;
uniform vec4 _MainTex_ST;

out vec4 color; 
void main()
{
    vec4 finalColor = vec4(1.0, 1.0, 1.0, 1.0);

    vec2 uv = v_uv;
    uv = uv * _MainTex_ST.xy + _MainTex_ST.zw;
    finalColor = finalColor * _TintColor * texture(_MainTex, uv);

    color = finalColor;
}