#version 300 es

precision mediump float;

in highp vec4 _glesVertex;
in mediump vec2 _glesMultiTexCoord0;
in lowp vec3 _glesTangent;
in lowp vec3 _glesNormal;
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
    xlv_TEXCOORD0 = _glesMultiTexCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw; 
    posWorld = (glstate_matrix_model * _glesVertex).xyz;
    highp mat3 normalmat = mat3(glstate_matrix_model);

    normalDir = normalize(normalmat*_glesNormal);
    tangentDir = normalize(normalmat*_glesTangent);
    bitangentDir = cross(normalDir,tangentDir);

    gl_Position = (glstate_matrix_mvp * _glesVertex);
}