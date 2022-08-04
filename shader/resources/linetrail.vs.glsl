#version 300 es

precision mediump float;  

in vec3 _glesVertex;
in vec2 _glesMultiTexCoord0;
in vec4 _glesColor;

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