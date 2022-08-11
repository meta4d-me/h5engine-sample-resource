#version 300 es

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 4) in mediump vec4    _glesMultiTexCoord0;   
layout(location = 3) in highp vec4    _glesColor;

uniform lowp vec4 _Main_Color;
uniform highp mat4 glstate_matrix_mvp;
uniform mediump vec4 _Main_Tex_ST;


out lowp vec4 xlv_COLOR;
out mediump vec2 xlv_TEXCOORD0;                
void main()                                     
{                                               
    highp vec4 tmpvar_1=vec4(_glesVertex.xyz,1.0);
    xlv_COLOR = _Main_Color*_glesColor;
	xlv_TEXCOORD0 =_glesMultiTexCoord0.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
                
    gl_Position = (glstate_matrix_mvp *tmpvar_1);  
}