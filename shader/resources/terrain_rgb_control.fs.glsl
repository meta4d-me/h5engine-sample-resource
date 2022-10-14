#version 300 es

precision highp float;

uniform lowp sampler2D _Splat0;
uniform lowp sampler2D _Splat1;
uniform lowp sampler2D _Splat2;
uniform lowp sampler2D _Splat3;
uniform lowp sampler2D _Control;

in lowp vec2 xlv_TEXCOORD0;
in lowp vec2 v_texcoord1;
in lowp vec2 uv_Splat0;
in lowp vec2 uv_Splat1;
in lowp vec2 uv_Splat2;
in lowp vec2 uv_Splat3;

#ifdef LIGHTMAP
uniform lowp sampler2D _LightmapTex;
in mediump vec2 lightmap_TEXCOORD;
lowp vec3 decode_hdr(lowp vec4 data)
{
    lowp float power =pow( 2.0 ,data.a * 255.0 - 128.0);
    return data.rgb * power * 2.0 ;
}
#endif

#ifdef FOG
uniform lowp vec4 glstate_fog_color; 
in lowp float factor;
#endif

//texture2DEtC1Mark

out vec4 color; 
void main() 
{
    //lowp vec4 control = texture(_Control, xlv_TEXCOORD0);
    lowp vec4 control = vec4(0, 0, 0, 0);

    lowp vec3 lay1 = texture(_Splat0,uv_Splat0).xyz;
    lowp vec3 lay2 = texture(_Splat1,uv_Splat1).xyz;
    lowp vec3 lay3 = texture(_Splat2,uv_Splat2).xyz;
    lowp vec3 lay4 = texture(_Splat3,uv_Splat3).xyz;
    //第四个Splat 不用alpha 控制 ，用 1.0-length(control.xyz)
    //lowp vec4 emission = vec4(lay1*control.r + lay2*control.g + lay3*control.b + lay4*(1.0-length(control.xyz)),1.0); 
    if(v_texcoord1.x < 0.21 * 0.7)
	{
		control.x = 1.0f;
	}
	else if(v_texcoord1.x < 0.21)
	{
		control.x = 1.0 - (v_texcoord1.x - 0.21 * 0.7)/(0.21 * 0.3);
		control.y = (v_texcoord1.x - 0.21 * 0.7)/(0.21 * 0.3);
	}
	else if(v_texcoord1.x < 0.21 + 0.21 * 0.7)
	{
		control.y = 1.0;
	}
	else if(v_texcoord1.x < 0.21 + 0.21)
	{
		control.y = 1.0 - (v_texcoord1.x - (0.21 + 0.21 * 0.7))/(0.21 * 0.3);
		control.z = (v_texcoord1.x - (0.21 + 0.21 * 0.7))/(0.21 * 0.3);
	}
	else if(v_texcoord1.x < 0.21 + 0.21 + 0.21 * 0.7)
	{
		control.z = 1.0;
	}
	else if(v_texcoord1.x < 0.21 + 0.21 + 0.21)
	{
		control.z = 1.0 - (v_texcoord1.x - (0.21 + 0.21 + 0.21 * 0.7))/(0.21 * 0.3);
		control.w = (v_texcoord1.x - (0.21 + 0.21 + 0.21 * 0.7))/(0.21 * 0.3);
	}
	else
	{
		control.w = 1.0;
	}
	float lengthPow = sqrt(control.x * control.x + control.y * control.y + control.z * control.z + control.w * control.w);
	control.x /=lengthPow;
	control.y /=lengthPow;
	control.z /=lengthPow;
	control.w /=lengthPow;

	lowp vec4 emission = vec4(lay1.xyz*control.x + lay2.xyz*control.y + lay3.xyz*control.z + lay4.xyz*control.w, 1.0); 

    #ifdef LIGHTMAP
    lowp vec4 lightmap = texture(_LightmapTex, lightmap_TEXCOORD);
    emission.xyz *= decode_hdr(lightmap);
    #endif

    #ifdef FOG
    emission.xyz = mix(glstate_fog_color.rgb, emission.rgb, factor);
    #endif

    color = emission;
}