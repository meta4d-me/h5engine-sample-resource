#version 300 es

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 4) in vec4 _glesMultiTexCoord0;

uniform highp vec4 _MainTex_TexelSize;
uniform highp vec4 sample_offsets;//采样偏移

out highp vec2 uv;
out highp vec4 uv01;
out highp vec4 uv23;
out highp vec4 uv45;


void main()
{
    highp vec4 offset=sample_offsets*_MainTex_TexelSize.xyxy;

    uv =vec2(_glesMultiTexCoord0.x,_glesMultiTexCoord0.y);

    uv01=uv.xyxy+offset.xyxy*vec4(1,1,-1,-1);
    uv23=uv.xyxy+offset.xyxy*vec4(1,1,-1,-1)*2.0;
    uv45=uv.xyxy+offset.xyxy*vec4(1,1,-1,-1)*3.0;

    gl_Position = vec4(_glesVertex.xy*2.0,_glesVertex.z,1.0);
}