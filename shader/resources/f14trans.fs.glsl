#version 300 es

precision mediump float;

uniform mediump sampler2D _Main_Tex;

in lowp vec4 xlv_COLOR;
in mediump vec2 xlv_TEXCOORD0;       
//texture2DEtC1Mark
   
out vec4 color; 
void main() 
{
    lowp vec4 basecolor = texture(_Main_Tex, xlv_TEXCOORD0);
    color =basecolor*xlv_COLOR;
    //color =vec4(1,0,0,1);
}