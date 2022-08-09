#version 300 es

precision mediump float;

// in  ins from our SpriteBatch
layout(location = 0) in highp vec3    _glesVertex;
layout(location = 4) in mediump vec2 _glesMultiTexCoord0;
layout(location = 3) in highp vec4    _glesColor;
layout(location = 1) in highp vec3    _glesNormal;
layout(location = 2) in highp vec3    _glesTangent;  

uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_model;
uniform highp mat4 glstate_matrix_modelview;
uniform highp vec4 glstate_eyepos;

uniform lowp vec4 glstate_vec4_lightposs[8];
uniform lowp vec4 glstate_vec4_lightdirs[8];
uniform lowp float glstate_float_spotangelcoss[8];
uniform lowp float glstate_lightcount;


// out  outs to our fragment shader
out lowp vec4 xlv_COLOR;
out highp vec3 xlv_Position;      
out mediump vec2 xlv_TEXCOORD0;

out lowp mat3 TBNmat;
out lowp vec3 worldpos;


lowp mat3 calBTNMatrix(lowp mat3 NormalMatToWorld,lowp vec3 _normal,lowp vec3 _tangent)
{
    lowp vec3 normal=normalize(NormalMatToWorld*_normal);
    lowp vec3 tangent=normalize(NormalMatToWorld*_tangent);
    lowp vec3 binormal=cross(normal,tangent);
  	return (mat3(tangent,binormal,normal));

}
void main()
{
	//求世界空间法线
    mat3 normalmat = mat3(glstate_matrix_model);
	//normalmat[3] =vec4(0,0,0,1);

   	TBNmat=calBTNMatrix(normalmat,_glesNormal,_glesTangent);

    worldpos =(glstate_matrix_model * vec4(_glesVertex.xyz, 1.0)).xyz;
	//eyedir = glstate_eyepos - worldpos;

	xlv_COLOR = _glesColor;
	xlv_Position = _glesVertex.xyz;
	xlv_TEXCOORD0 = _glesMultiTexCoord0.xy;
	gl_Position = (glstate_matrix_mvp * vec4(_glesVertex.xyz, 1.0));
}




