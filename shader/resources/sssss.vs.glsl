#version 300 es

precision mediump float;

in highp vec3    _glesVertex;
in highp vec2    _glesMultiTexCoord0;
in highp vec3    _glesNormal;

uniform highp mat4      glstate_matrix_mvp;
uniform highp mat4      glstate_matrix_model;
uniform highp mat4      glstate_matrix_world2object;

out highp vec2      xlv_TEXCOORD0;

void main () {
    v_pos           = (glstate_matrix_model * vec4(_glesVertex, 1.0)).xyz;
    v_normal        = normalize((glstate_matrix_world2object * vec4(_glesNormal, 0.0)).xyz);
    xlv_TEXCOORD0   = _glesMultiTexCoord0;

    gl_Position     = glstate_matrix_mvp * vec4(_glesVertex, 1.0);
}