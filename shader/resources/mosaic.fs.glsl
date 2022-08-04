#version 300 es

precision mediump float;

uniform sampler2D _MainTex;
uniform lowp float _MosaicSize;
uniform highp vec4 _MainTex_TexelSize;
in highp vec2 xlv_TEXCOORD0;
//texture2DEtC1Mark

out vec4 color; 
void main() //马赛克效果
{
    // lowp vec4 tmpvar_3 = texture(_MainTex, xlv_TEXCOORD0);
    // color = tmpvar_3;
    highp vec2 uv = (xlv_TEXCOORD0*_MainTex_TexelSize.zw);
    uv = floor(uv/_MosaicSize)*_MosaicSize;
    uv = uv * _MainTex_TexelSize.xy;
    color = texture(_MainTex, uv);
    // highp vec4 color = texture(_MainTex,xlv_TEXCOORD0);
    // color = color * color;
}