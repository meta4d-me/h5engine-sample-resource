#version 300 es

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 4) in mediump vec2 _glesMultiTexCoord0;

uniform highp mat4 glstate_matrix_mvp;
uniform mediump vec4 _MainTex_ST;
out mediump vec2 xlv_TEXCOORD0;
//light
lowp mat4 blendMat ;
layout(location = 1) in highp vec3    _glesNormal;
uniform highp mat4 glstate_matrix_model;
uniform lowp float glstate_lightcount;

out highp vec3 v_N;
out highp vec3 v_Mpos;

#ifdef INSTANCE
//instance_matrix 固定地址
layout(location = 12) in highp mat4 instance_matrix;
#endif

#ifdef LIGHTMAP
layout(location = 5) in mediump vec2 _glesMultiTexCoord1;
uniform mediump vec4 glstate_lightmapOffset;
uniform lowp float glstate_lightmapUV;
out mediump vec2 lightmap_TEXCOORD;
#endif

#ifdef FOG
uniform lowp float glstate_fog_start;
uniform lowp float glstate_fog_end;
out lowp float factor;
#endif

#ifdef SKIN
layout(location = 6) in lowp vec4    _glesBlendIndex4;
layout(location = 7) in mediump vec4    _glesBlendWeight4;

#ifdef SKIN_BONE_ARR
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
	return blendMat * srcVertex;
}
#endif

#ifdef SKIN_BONE_TEX
uniform highp sampler2D _SkinTex;
uniform highp sampler2D _SkinTexCrossFrom;
uniform highp float _SkinTexMeta[6];//bonecount,frameid,framecount

mat4 skinTexBuildMat4(int index)
{
	vec4 quat = texture(_SkinTex, vec2((float(index*2) + 0.5)/(_SkinTexMeta[0]*2.0), (0.5+_SkinTexMeta[1])/_SkinTexMeta[2]));
	vec4 translation =texture(_SkinTex, vec2((float(index*2) + 1.5)/(_SkinTexMeta[0]*2.0), (0.5+_SkinTexMeta[1])/_SkinTexMeta[2]));

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

vec4 quatLerp(vec4 srca,vec4 srcb,float t)
{
	if (dot(srca,srcb)< 0.0) {
		srcb=-1.0*srcb;
	}
	vec4 lerp=mix(srca,srcb,t);
	float len =1.0/length(lerp);
	return lerp * len;
}

mat4 crossSkinTexBuildMat4(int index)
{
	vec4 toQuat = texture(_SkinTex, vec2((float(index*2) + 0.5)/(_SkinTexMeta[0]*2.0), (0.5+_SkinTexMeta[1])/_SkinTexMeta[2]));
	vec4 toTranslation =texture(_SkinTex, vec2((float(index*2) + 1.5)/(_SkinTexMeta[0]*2.0), (0.5+_SkinTexMeta[1])/_SkinTexMeta[2]));

	vec4 fromQuat=texture(_SkinTexCrossFrom, vec2((float(index*2) + 0.5)/(_SkinTexMeta[0]*2.0), (0.5+_SkinTexMeta[4])/_SkinTexMeta[5]));
	vec4 fromTranslation=texture(_SkinTexCrossFrom, vec2((float(index*2) + 1.5)/(_SkinTexMeta[0]*2.0), (0.5+_SkinTexMeta[4])/_SkinTexMeta[5]));

	vec4 quat= quatLerp(fromQuat,toQuat,_SkinTexMeta[3]);
	vec4 translation=mix(fromTranslation,toTranslation,_SkinTexMeta[3]);

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

highp vec4 skinTexCalcVertex(highp vec4 srcVertex,lowp vec4 blendIndex,lowp vec4 blendWeight)
{
	int i = int(blendIndex.x);
    int i2 =int(blendIndex.y);
	int i3 =int(blendIndex.z);
	int i4 =int(blendIndex.w);

	if(_SkinTexMeta[3]==1.0){
		blendMat = skinTexBuildMat4(i)*blendWeight.x
				+ skinTexBuildMat4(i2)*blendWeight.y
				+ skinTexBuildMat4(i3)*blendWeight.z
				+ skinTexBuildMat4(i4)*blendWeight.w;
		return blendMat * srcVertex;
	}else{
		blendMat = crossSkinTexBuildMat4(i)*blendWeight.x
				+ crossSkinTexBuildMat4(i2)*blendWeight.y
				+ crossSkinTexBuildMat4(i3)*blendWeight.z
				+ crossSkinTexBuildMat4(i4)*blendWeight.w;
		return blendMat * srcVertex;
	}
}
#endif

#endif

void calcNormal(highp vec4 pos){
	int c =int(glstate_lightcount);
	if(c>0){
		//求世界空间法线
		#ifdef SKIN
		v_N = normalize(mat3(blendMat) * _glesNormal);
		#else
		v_N = _glesNormal;
		#endif
		lowp mat3 normalmat = mat3(glstate_matrix_model);
		v_N =normalize(normalmat*v_N);
		v_Mpos =(glstate_matrix_model * pos).xyz;
	}
}

void main()
{
    xlv_TEXCOORD0 = _glesMultiTexCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    highp vec4 position=vec4(_glesVertex.xyz,1.0);

    //----------------------------------------------------------
    #ifdef LIGHTMAP
    mediump vec2 beforelightUV = (1.0 - glstate_lightmapUV) * _glesMultiTexCoord0  + glstate_lightmapUV * _glesMultiTexCoord1;	//unity lightMap UV ,优先使用UV1,次之UV0 
    lowp float u = beforelightUV.x * glstate_lightmapOffset.x + glstate_lightmapOffset.z;
    lowp float v = beforelightUV.y * glstate_lightmapOffset.y + glstate_lightmapOffset.w;
    lightmap_TEXCOORD = vec2(u,v);
    #endif

    #ifdef SKIN
		#ifdef SKIN_BONE_ARR
		position =calcVertex(position,_glesBlendIndex4,_glesBlendWeight4);
		#endif
		#ifdef SKIN_BONE_TEX
		position =skinTexCalcVertex(position,_glesBlendIndex4,_glesBlendWeight4);
		#endif
	#endif
	//light
    calcNormal(position);

	#ifdef INSTANCE
        position = instance_matrix * position;
    #endif
	
    position = (glstate_matrix_mvp * position);

    #ifdef FOG
    factor = (glstate_fog_end - abs(position.z))/(glstate_fog_end - glstate_fog_start);
    factor = clamp(factor, 0.0, 1.0);
    #endif


    gl_Position =position;
}