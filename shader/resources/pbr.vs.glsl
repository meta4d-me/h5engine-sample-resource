#version    300 es

in highp vec3    _glesVertex;
in mediump vec2    _glesMultiTexCoord0;
in highp vec3    _glesNormal;
in highp vec3    _glesTangent;	//w 被乘到了分量里 x = x*w , y = y*w , z = z*w , 且 w 被做了 +2 的偏移映射。
in highp vec3    _glesColor;

uniform highp mat4      glstate_matrix_mvp;
uniform highp mat4      glstate_matrix_model;
uniform highp mat4      glstate_matrix_it_modelview;

out highp vec3      v_pos;
out highp vec2      xlv_TEXCOORD0;
out highp mat3		TBN;

#ifdef LIGHTMAP
in mediump vec2 _glesMultiTexCoord1;
uniform lowp float glstate_lightmapUV;
uniform mediump vec4 glstate_lightmapOffset;
out mediump vec2 lightmap_TEXCOORD;
#endif

#ifdef FOG
uniform lowp float glstate_fog_start;
uniform lowp float glstate_fog_end;
out lowp float factor;
#endif

#ifdef SKIN
mat4 blendMat ;
in lowp vec4 _glesBlendIndex4;
in lowp vec4 _glesBlendWeight4;
uniform highp vec4 glstate_vec4_bones[110];
mat4 buildMat4(int index)
{
	vec4 quat = glstate_vec4_bones[index * 2 + 0];
	vec4 translation = glstate_vec4_bones[index * 2 + 1];
	float xy = 2.0 * quat.x * quat.y;
	float xz = 2.0 * quat.x * quat.z;
	float xw = 2.0 * quat.x * quat.w;
	float yz = 2.0 * quat.y * quat.z;
	float yw = 2.0 * quat.y * quat.w;
	float zw = 2.0 * quat.z * quat.w;
	float xx = 2.0*quat.x * quat.x;
	float yy = 2.0*quat.y * quat.y;
	float zz = 2.0*quat.z * quat.z;
	float ww = 2.0*quat.w * quat.w;
	float s = translation.w;
	mat4 matrix = mat4(
	(1.0-yy-zz)*s, (xy+zw)*s, (xz-yw)*s, 0,
	(xy-zw)*s, (1.0-xx-zz)*s, (yz + xw)*s, 0,
	(xz + yw)*s, (yz - xw)*s, (1.0-xx-yy)*s, 0,
	translation.x, translation.y, translation.z, 1);
	return matrix;
}

highp vec4 calcVertex(highp vec4 srcVertex,lowp vec4 blendIndex,lowp vec4 blendWeight)
{
	int i = int(blendIndex.x);
    int i2 =int(blendIndex.y);
	int i3 =int(blendIndex.z);
	int i4 =int(blendIndex.w);

    blendMat = buildMat4(i)*blendWeight.x
			 + buildMat4(i2)*blendWeight.y
			 + buildMat4(i3)*blendWeight.z
			 + buildMat4(i4)*blendWeight.w;
	return blendMat* srcVertex;
}
#endif

//获取 tangent 的 W 值
lowp float tangentW(lowp vec3 _tangent){
	return sqrt(_tangent.x * _tangent.x + _tangent.y * _tangent.y + _tangent.z * _tangent.z) - 2.0;
}

//计算 TBN 矩阵-----------------
mat3 calTBNMatrix(highp mat4 _m_mat,lowp vec3 _normal,lowp vec3 _tangent)
{

    vec3 normal = normalize(mat3(_m_mat) * normalize(_normal));
    vec3 tangent = normalize(mat3(_m_mat) * normalize(_tangent));
    vec3 binormal = cross( normal , tangent) * tangentW(_tangent);
  	return mat3(tangent,binormal,normal);
}
//-----------------------------

void calcNormal(highp vec4 pos){
    //求世界空间法线
#ifdef SKIN
    vec3 _n = normalize(mat3(blendMat) * _glesNormal);
#else
    vec3 _n = _glesNormal;
#endif
	TBN = calTBNMatrix(glstate_matrix_it_modelview , _n , _glesTangent);
}

void main () {
    highp vec4 position = vec4(_glesVertex,1.0);

#ifdef LIGHTMAP
    mediump vec2 beforelightUV = (1.0 - glstate_lightmapUV) * _glesMultiTexCoord0  + glstate_lightmapUV * _glesMultiTexCoord1;	//unity lightMap UV ,优先使用UV1,次之UV0 
    lowp float u = beforelightUV.x * glstate_lightmapOffset.x + glstate_lightmapOffset.z;
    lowp float v = beforelightUV.y * glstate_lightmapOffset.y + glstate_lightmapOffset.w;
    lightmap_TEXCOORD = vec2(u,v);
#endif

#ifdef SKIN
    position = calcVertex(position,_glesBlendIndex4,_glesBlendWeight4);
#endif
	//normal
	calcNormal(position);
	//world pos
    vec4 wpos		= (glstate_matrix_model * position);
	v_pos			= wpos.xyz / wpos.w;
    //texcoord
	xlv_TEXCOORD0   = _glesMultiTexCoord0;

	// // TBN
    // vec3 N        	= normalize((glstate_matrix_it_modelview * vec4(_glesNormal, 0.0)).xyz);
	// vec3 tangent 	= normalize((glstate_matrix_it_modelview * vec4(_glesTangent, 0.0)).xyz);
	// vec3 bitangent 	= cross(N, tangent) * tangentW(_glesTangent);// * _glesTangent.w;
	// TBN = mat3(tangent, bitangent, N);
	// TBN = calTBNMatrix(glstate_matrix_it_modelview , _glesNormal , _glesTangent);

	position = glstate_matrix_mvp * position;

#ifdef FOG
    factor = (glstate_fog_end - abs(position.z))/(glstate_fog_end - glstate_fog_start);
    factor = clamp(factor, 0.0, 1.0);
#endif

    gl_Position	= position;
}