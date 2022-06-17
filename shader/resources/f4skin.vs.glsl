precision highp float;

attribute highp vec4 _glesVertex;
attribute mediump vec4 _glesMultiTexCoord0;
attribute highp vec4 _glesColor;

uniform highp mat4 glstate_matrix_mvp;
uniform mediump vec4 _MainTex_ST;
// varying mediump vec2 xlv_TEXCOORD0;

// #ifdef LIGHTMAP
// attribute mediump vec4 _glesMultiTexCoord1;
// uniform mediump vec4 glstate_lightmapOffset;
// // uniform mediump float glstate_lightmapUV;
// varying mediump vec2 lightmap_TEXCOORD;
// #endif


// NOTE: diffuse cap
varying lowp vec3 v_N;
varying lowp vec3 v_Mpos;
varying mediump vec2 xlv_TEXCOORD0;
varying mediump vec2 lightmap_TEXCOORD;


//texture2DEtC1Mark


#ifdef FOG
uniform lowp float glstate_fog_start;
uniform lowp float glstate_fog_end;
varying lowp float factor;
#endif

#define SKIN2

#define SKIN
#ifdef SKIN
attribute lowp vec4 _glesBlendIndex4;
attribute lowp vec4 _glesBlendWeight4;
uniform highp vec4 glstate_vec4_bones[110];

#ifdef SKIN2
// uniform highp mat4 glstate_matrix_bones[24];
uniform highp sampler2D boneSampler;
uniform highp float boneSamplerTexelSize;
uniform highp vec4 boneSampler_TexelSize;

mat4 readMatrixSampler(sampler2D smp, float index) {
    float offset = index * 4.;
    return mat4(
		texture2D(smp, vec2(boneSamplerTexelSize * (offset + 0.5), 0)),
		texture2D(smp, vec2(boneSamplerTexelSize * (offset + 1.5), 0)),
		texture2D(smp, vec2(boneSamplerTexelSize * (offset + 2.5), 0)),
		texture2D(smp, vec2(boneSamplerTexelSize * (offset + 3.5), 0))
		);
}
highp vec4 calcVertexF4(highp vec4 srcVertex) {
	mat4 mat = _glesBlendWeight4[0] * readMatrixSampler(boneSampler, _glesBlendIndex4[0])
			+ _glesBlendWeight4[1] * readMatrixSampler(boneSampler, _glesBlendIndex4[1])
			+ _glesBlendWeight4[2] * readMatrixSampler(boneSampler, _glesBlendIndex4[2])
			+ _glesBlendWeight4[3] * readMatrixSampler(boneSampler, _glesBlendIndex4[3]);
	return mat * srcVertex;
}
#endif

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
	mat4 matrix = mat4(
	1.0-yy-zz, xy+zw, xz-yw, 0,
	xy-zw, 1.0-xx-zz, yz + xw, 0,
	xz + yw, yz - xw, 1.0-xx-yy, 0,
	translation.x, translation.y, translation.z, 1);
	return matrix;
}

highp vec4 calcVertex(highp vec4 srcVertex,lowp vec4 blendIndex,lowp vec4 blendWeight)
{
	int i = int(blendIndex.x);
    int i2 =int(blendIndex.y);
	int i3 =int(blendIndex.z);
	int i4 =int(blendIndex.w);

	lowp mat4 blendMat = buildMat4(i)*blendWeight.x
			 + buildMat4(i2)*blendWeight.y
			 + buildMat4(i3)*blendWeight.z
			 + buildMat4(i4)*blendWeight.w;
	return blendMat * srcVertex;
}

#endif

varying highp vec4 vcolor;


void main()
{
    xlv_TEXCOORD0 = _glesMultiTexCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;

	mat4 mat = _glesBlendWeight4[0] * readMatrixSampler(boneSampler, _glesBlendIndex4[0])
			+ _glesBlendWeight4[1] * readMatrixSampler(boneSampler, _glesBlendIndex4[1])
			+ _glesBlendWeight4[2] * readMatrixSampler(boneSampler, _glesBlendIndex4[2])
			+ _glesBlendWeight4[3] * readMatrixSampler(boneSampler, _glesBlendIndex4[3]);
	// mat = mat4(
	// 	vec4(1, 0, 0, 0),
	// 	vec4(0, 1, 0, 0),
	// 	vec4(0, 0, 1, 0),
	// 	vec4(0, 0, 0, 1)
	// 	);
	// mat = _glesBlendWeight4.x * glstate_matrix_bones[int(_glesBlendIndex4.x)]
	// 		+ _glesBlendWeight4.y * glstate_matrix_bones[int(_glesBlendIndex4.y)]
	// 		+ _glesBlendWeight4.z * glstate_matrix_bones[int(_glesBlendIndex4.z)]
	// 		+ _glesBlendWeight4.w * glstate_matrix_bones[int(_glesBlendIndex4.w)];
	vcolor = vec4(texture2D(boneSampler, _glesVertex.xz / vec2(8., 0)/ 3.).rgb, 1);
    // xlv_TEXCOORD0 = _glesMultiTexCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    highp vec4 position=vec4(_glesVertex.xyz,1.0);

    // //----------------------------------------------------------
    // #ifdef LIGHTMAP
    // mediump vec2 beforelightUV = _glesMultiTexCoord1.xy;
    // lowp float u = beforelightUV.x * glstate_lightmapOffset.x + glstate_lightmapOffset.z;
    // lowp float v = beforelightUV.y * glstate_lightmapOffset.y + glstate_lightmapOffset.w;
    // lightmap_TEXCOORD = vec2(u,v);
    // #endif

    #ifdef SKIN
    // position =calcVertex(position,_glesBlendIndex4,_glesBlendWeight4);
	position = mat * position;
    #endif

    position = (glstate_matrix_mvp * position);

    #ifdef FOG
    factor = (glstate_fog_end - abs(position.z))/(glstate_fog_end - glstate_fog_start);
    factor = clamp(factor, 0.0, 1.0);
    #endif


    gl_Position =position;
}