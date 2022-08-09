#version 300 es

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 3) in vec4 _glesColor;

#ifdef INSTANCE
in vec4 a_particle_color;
in highp vec4 instance_offset_matrix_0;
in highp vec4 instance_offset_matrix_1;
in highp vec4 instance_offset_matrix_2;
in highp vec4 instance_offset_matrix_3;
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
        highp mat4 instance_offset_matrix = mat4(instance_offset_matrix_0,instance_offset_matrix_1,instance_offset_matrix_2,instance_offset_matrix_3);
        tmpvar_1 = instance_offset_matrix * tmpvar_1;
    // #else
    //     xlv_COLOR = _glesColor - a_particle_color;
    #endif

    xlv_COLOR = a_particle_color;

    gl_Position = (glstate_matrix_mvp * tmpvar_1);
}