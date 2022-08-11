#version 300 es

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 3) in vec4 _glesColor;

#ifdef INSTANCE
//instance_matrix 固定地址
layout(location = 12) in highp mat4 instance_matrix;
//其他自定义字段
in vec4 a_particle_color;
#else
uniform vec4 a_particle_color;
#endif

uniform highp mat4 glstate_matrix_mvp;
out lowp vec4 xlv_COLOR;
void main()
{
    highp vec4 tmpvar_1;
    tmpvar_1.xyz = _glesVertex.xyz;
    tmpvar_1.w = 1.0;
    #ifdef INSTANCE
        tmpvar_1 = instance_matrix * tmpvar_1;
    #endif

    xlv_COLOR = a_particle_color;

    gl_Position = (glstate_matrix_mvp * tmpvar_1);
}