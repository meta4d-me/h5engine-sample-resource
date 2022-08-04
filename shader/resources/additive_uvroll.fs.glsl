#version 300 es

precision mediump float;

in vec2 v_uv;

uniform vec4 _TintColor;
uniform sampler2D _MainTex;

out vec4 color; 
void main()
{
    color = 2.0 * _TintColor * texture(_MainTex, v_uv);
}