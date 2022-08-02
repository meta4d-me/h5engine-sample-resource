#version 300 es

precision mediump float;

uniform sampler2D _MainTex;
uniform lowp float _BlurGap; //卷积每层间隔单位
uniform highp vec4 _MainTex_TexelSize;
in highp vec2 xlv_TEXCOORD0;
//texture2DEtC1Mark

out vec4 color; 
void main() 
{
	lowp float offset_x = _MainTex_TexelSize.x * _BlurGap;
	lowp float offset_y = _MainTex_TexelSize.y * _BlurGap;
    highp vec4 sample0,sample1,sample2,sample3;
	sample0=texture(_MainTex,vec2(xlv_TEXCOORD0.x-offset_x,xlv_TEXCOORD0.y-offset_y));
	sample1=texture(_MainTex,vec2(xlv_TEXCOORD0.x+offset_x,xlv_TEXCOORD0.y-offset_y));
	sample2=texture(_MainTex,vec2(xlv_TEXCOORD0.x+offset_x,xlv_TEXCOORD0.y+offset_y));
	sample3=texture(_MainTex,vec2(xlv_TEXCOORD0.x-offset_x,xlv_TEXCOORD0.y+offset_y));
	highp vec4 color=(sample0+sample1+sample2+sample3) / 4.0;
    color = color;
}