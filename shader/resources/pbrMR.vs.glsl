#version 300 es

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 4) in mediump vec4    _glesMultiTexCoord0;

uniform mediump vec4 _MainTex_ST;
out mediump vec2 xlv_TEXCOORD0;

layout(location = 1) in highp vec3    _glesNormal;
layout(location = 2) in highp vec3    _glesTangent;

uniform highp mat4      glstate_matrix_mvp;
uniform highp mat4      glstate_matrix_model;
uniform highp mat4      glstate_matrix_world2object;

out highp vec3 v_N;
out mat3 TBN;

#ifdef FOG
out lowp float factor;
#endif

uniform highp vec4 OFFSET;

layout(location = 3) in vec4 _glesColor;
out highp vec4 v_color;

out vec3 v_pos;

#define DIST	20.0
#define FOG_far	100.0


lowp mat3 calBTNMatrix(lowp mat3 NormalMatToWorld,lowp vec3 _normal,lowp vec3 _tangent)
{
    lowp vec3 normal=normalize(NormalMatToWorld*_normal);
    lowp vec3 tangent=normalize(NormalMatToWorld*_tangent);
    lowp vec3 binormal=cross(normal,tangent);
  	return (mat3(tangent,binormal,normal));

}

void main()
{
    xlv_TEXCOORD0 = _glesMultiTexCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    highp vec4 position=vec4(_glesVertex.xyz,1.0);

    mat3 normalmat = mat3(glstate_matrix_model);
   	TBN=calBTNMatrix(normalmat,_glesNormal,_glesTangent);


    v_N = _glesNormal;
    // // v_N = normalize(glstate_matrix_world2object*vec4(v_N, 1)).xyz;
    // v_N = normalize(glstate_matrix_model*vec4(v_N, 1)).xyz;

    // vec3 tangent = normalize(vec3(glstate_matrix_model * vec4(_glesTangent.xyz, 0)));
    // vec3 bitangent = cross(v_N, tangent) * 1.0;
    // TBN = mat3(tangent, bitangent, v_N);

    position = (glstate_matrix_mvp * position);

	highp float zOff = position.z / DIST;
	position += OFFSET * zOff * zOff;

    v_pos = (glstate_matrix_model * vec4(_glesVertex.xyz,1.0)).xyz;
    // v_pos = _glesVertex.xyz;

    #ifdef FOG
    highp float x = position.z;
    x = clamp(x,0.0,FOG_far);
    highp float a = 2.0*FOG_far/x -1.0;
    factor = 1.0 - 1.0/a;
    #endif
	v_color = _glesColor;
    gl_Position =position;
}