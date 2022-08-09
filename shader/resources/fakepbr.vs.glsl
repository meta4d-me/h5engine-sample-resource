#version 300 es

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 4) in mediump vec2 _glesMultiTexCoord0;
layout(location = 2) in highp vec3    _glesTangent;
layout(location = 1) in highp vec3    _glesNormal;
uniform highp mat4 glstate_matrix_model;
uniform highp mat4 glstate_matrix_mvp;
uniform mediump vec4 _MainTex_ST; 

out mediump vec2 xlv_TEXCOORD0;
out highp vec3 posWorld;
out lowp vec3 normalDir;
out lowp vec3 tangentDir;
out lowp vec3 bitangentDir;
void main()
{
    vec4 pos = vec4(_glesVertex.xyz,1.0);
    xlv_TEXCOORD0 = _glesMultiTexCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw; 
    posWorld = (glstate_matrix_model * pos).xyz;
    highp mat3 normalmat = mat3(glstate_matrix_model);

    normalDir = normalize(normalmat*_glesNormal);
    tangentDir = normalize(normalmat*_glesTangent);
    bitangentDir = cross(normalDir,tangentDir);

    gl_Position = (glstate_matrix_mvp * pos);
}