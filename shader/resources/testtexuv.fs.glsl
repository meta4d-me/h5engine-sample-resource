#version 300 es

precision mediump float;

uniform sampler2D _MainTex;
uniform lowp float _AlphaCut;
in highp vec2 xlv_TEXCOORD0;
out vec4 color; 
void main() 
{
    lowp vec3 tmpvar_3 = vec3(xlv_TEXCOORD0.y);
    color = vec4(tmpvar_3,1.0);
}