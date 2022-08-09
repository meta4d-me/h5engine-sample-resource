#version 300 es

//参考 https://learnopengl-cn.github.io/04%20Advanced%20OpenGL/06%20Cubemaps/

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;

uniform highp mat4      glstate_matrix_view;
uniform highp mat4      glstate_matrix_project;

out highp vec3      TexCoords;

void main () {
    vec3 cubePos = _glesVertex * -2.0;  //因我们的 默认box mesh size为1, 需要加系数 -2.0
    TexCoords   = cubePos;
    vec4 pos =  glstate_matrix_project * mat4(mat3(glstate_matrix_view))  * vec4(cubePos, 1.0);
    gl_Position = pos.xyww;
}