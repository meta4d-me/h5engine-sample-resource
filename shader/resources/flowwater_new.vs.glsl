#version 300 es

precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 4) in mediump vec2 _glesMultiTexCoord0;
layout(location = 3) in highp vec4    _glesColor;

uniform lowp vec4 _MainColor;
uniform lowp float _alphaRate;
uniform lowp float _colorRate;

uniform highp mat4 glstate_matrix_mvp;
uniform mediump vec4 _MainTex_ST;
uniform lowp float _speedu;
uniform lowp float _speedv;
uniform lowp float glstate_timer;

out mediump vec2 _base_uv;
out lowp vec4 attcolor;


#ifdef FOG
uniform lowp float glstate_fog_start;
uniform lowp float glstate_fog_end;
out lowp float factor;
#endif

void main()
{
	highp vec4 position=vec4(_glesVertex.xyz,1.0);

    lowp vec2 _speed= vec2(_speedu,_speedv);
	_base_uv = _glesMultiTexCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw+ _speed * glstate_timer;
	attcolor= _MainColor;
	attcolor.rgb=attcolor.rgb*_colorRate;
	attcolor.a=attcolor.a*_alphaRate;
	
    #ifdef FOG
    factor = (glstate_fog_end - abs(position.z))/(glstate_fog_end - glstate_fog_start); 
    factor = clamp(factor, 0.0, 1.0);  
    #endif

	position = (glstate_matrix_mvp * position);
	gl_Position = position;
}

