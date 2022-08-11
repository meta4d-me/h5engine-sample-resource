#version 300 es

precision mediump float;  

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 4) in vec2 _glesMultiTexCoord0;
layout(location = 3) in vec4 _glesColor;

uniform mat4 glstate_matrix_mvp;

out vec2 v_uv;

void main() 
{
    vec4 position = vec4(_glesVertex.xyz, 1.0);
    //输出uv
    v_uv = _glesMultiTexCoord0.xy;

    //计算投影坐标
    gl_Position = glstate_matrix_mvp * position;
}