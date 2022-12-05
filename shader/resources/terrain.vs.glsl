#version 300 es

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 1) in highp vec3    _glesNormal;
layout(location = 4) in mediump vec4    _glesMultiTexCoord0;

uniform highp mat4 glstate_matrix_mvp;

uniform lowp vec4 _Splat0_ST;
uniform lowp vec4 _Splat1_ST;
uniform lowp vec4 _Splat2_ST;
uniform lowp vec4 _Splat3_ST;

uniform lowp sampler2D _HeightMap;

uniform lowp vec4 _HeightScale;

out lowp vec2 xlv_TEXCOORD0;
out lowp vec2 normalDir;
out lowp vec2 uv_Splat0;
out lowp vec2 uv_Splat1;
out lowp vec2 uv_Splat2;
out lowp vec2 uv_Splat3;

out lowp vec2 v_texcoord1;

out highp vec2 holdX;


#ifdef LIGHTMAP
layout(location = 5) in mediump vec4    _glesMultiTexCoord1;
uniform mediump vec4 glstate_lightmapOffset;
out mediump vec2 lightmap_TEXCOORD;
#endif

#ifdef FOG
uniform lowp float glstate_fog_start;
uniform lowp float glstate_fog_end;
out lowp float factor;
#endif

void main()
{
    

    // heightmap lookup uv can not scale;
    mediump vec2 heightmapUV = _glesMultiTexCoord0.xy;
    heightmapUV.y = 1.0 - heightmapUV.y;

    lowp vec4 height = texture(_HeightMap, heightmapUV);
    highp vec4 vertex_ = vec4(_glesVertex, 1.0);
    vertex_.y = height.x * _HeightScale.x;
    highp vec4 position = vertex_;

	xlv_TEXCOORD0 = _glesMultiTexCoord0.xy;
    uv_Splat0 = _glesMultiTexCoord0.xy * _Splat0_ST.xy + _Splat0_ST.zw;
    uv_Splat1 = _glesMultiTexCoord0.xy * _Splat1_ST.xy + _Splat1_ST.zw;
    uv_Splat2 = _glesMultiTexCoord0.xy * _Splat2_ST.xy + _Splat2_ST.zw;
    uv_Splat3 = _glesMultiTexCoord0.xy * _Splat3_ST.xy + _Splat3_ST.zw;
    // now v_texcoord1 just send world y to pixel shader, 36 is height map scale
	v_texcoord1 = vec2(position.y/_HeightScale.x, position.y/_HeightScale.x);
    normalDir = vec2(_glesNormal.x, _glesNormal.z);

    holdX.x = _glesVertex.x;
    holdX.y = _glesVertex.x;

    //----------------------------------------------------------
    #ifdef LIGHTMAP
    mediump vec2 beforelightUV = _glesMultiTexCoord1.xy;
    lowp float u = beforelightUV.x * glstate_lightmapOffset.x + glstate_lightmapOffset.z;
    lowp float v = beforelightUV.y * glstate_lightmapOffset.y + glstate_lightmapOffset.w;
    lightmap_TEXCOORD = vec2(u,v);
    #endif

    position = (glstate_matrix_mvp * position);

    #ifdef FOG
    factor = (glstate_fog_end - abs(position.z))/(glstate_fog_end - glstate_fog_start); 
    factor = clamp(factor, 0.0, 1.0);  
    #endif

    gl_Position = position;
}