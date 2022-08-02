#version 300 es

precision mediump float;

uniform lowp sampler2D _MainTex;                                                 
in lowp vec4 xlv_COLOR;                                                 
in mediump vec2 xlv_TEXCOORD0;   
//texture2DEtC1Mark

out vec4 color; 
void main() 
{
    lowp vec4 tmpvar_3= (xlv_COLOR * texture(_MainTex, xlv_TEXCOORD0));
    lowp vec4 tmpvar_4 = mix(vec4(1.0, 1.0, 1.0, 1.0), tmpvar_3, tmpvar_3.wwww);
    color = tmpvar_4;
}