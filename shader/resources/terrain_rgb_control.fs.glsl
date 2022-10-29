#version 300 es

precision highp float;

uniform lowp sampler2D _Splat0;
uniform lowp sampler2D _Splat1;
uniform lowp sampler2D _Splat2;
uniform lowp sampler2D _Splat3;
uniform lowp sampler2D _Control;
uniform lowp vec4 v_useTextureOrGPU;
uniform lowp float lineVertex[100];

in lowp vec2 xlv_TEXCOORD0;
in lowp vec2 normalDir;
in lowp vec2 v_texcoord1;

in lowp vec2 uv_Splat0;
in lowp vec2 uv_Splat1;
in lowp vec2 uv_Splat2;
in lowp vec2 uv_Splat3;

in highp vec2 holdX;

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
	lowp vec3 lay1 = texture(_Splat0,uv_Splat0).xyz;
    lowp vec3 lay2 = texture(_Splat1,uv_Splat1).xyz;
    lowp vec3 lay3 = texture(_Splat2,uv_Splat2).xyz;
    lowp vec3 lay4 = texture(_Splat3,uv_Splat3).xyz;

	lowp vec2 height1DLookup = vec2(xlv_TEXCOORD0.x, 0.5);
	lowp vec2 layer1Lookup = vec2(xlv_TEXCOORD0.x, 0.21);
	lowp vec2 layer2Lookup = vec2(xlv_TEXCOORD0.x, 0.42);
	lowp vec2 layer3Lookup = vec2(xlv_TEXCOORD0.x, 0.63);
	lowp vec2 layer4Lookup = vec2(xlv_TEXCOORD0.x, 0.84);

    lowp vec4 control1;
	lowp vec4 emission;
	lowp vec4 factor1;
	lowp vec4 layer1;
	lowp vec4 layer2;
	lowp vec4 layer3;
	lowp vec4 layer4;

	if(v_useTextureOrGPU.x < 1.0)
	{
		control1 = texture(_Control, xlv_TEXCOORD0);
		emission = vec4(lay1*control1.r + lay2*control1.g + lay3*control1.b + lay4*(1.0-length(control1.xyz)),1.0); 
	}
	else
	{
		factor1 = texture(_Control, height1DLookup);
		layer1 = texture(_Control, layer1Lookup);
		layer1 = layer1 * 2.0 - 1.0;
		layer2 = texture(_Control, layer2Lookup);
		layer2 = layer2 * 2.0 - 1.0;
		layer3 = texture(_Control, layer3Lookup);
		layer3 = layer3 * 2.0 - 1.0;
		layer4 = texture(_Control, layer4Lookup);
		layer4 = layer4 * 2.0 - 1.0;

		control1 = vec4(0, 0, 0, 0);

		//drop in this segment
		//float currentY = (v1.y - v0.y)/(v1.x - v0.x) * deltaX;
		if(v_texcoord1.x < (0.21 + layer1.x * 0.01 +  factor1.x * v_useTextureOrGPU.z)* 0.7)
		{
			control1.x = 1.0f;
		}
		else if(v_texcoord1.x < (0.21 + layer1.x * 0.01 +  factor1.x * v_useTextureOrGPU.z))
		{
			control1.x = 1.0 - (v_texcoord1.x - (0.21 + layer1.x * 0.01 +  factor1.x * v_useTextureOrGPU.z) * 0.7)/((0.21 + layer1.x * 0.01 +  factor1.x * v_useTextureOrGPU.z) * 0.3);
			control1.y = (v_texcoord1.x - (0.21 + layer1.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.7)/((0.21 + layer1.x * 0.01 +  factor1.x * v_useTextureOrGPU.z) * 0.3);
		}
		else if(v_texcoord1.x < (0.21 + 0.21 + layer2.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.7)
		{
			control1.y = 1.0;
		}
		else if(v_texcoord1.x < (0.21 + 0.21 + layer2.x* 0.01 + factor1.x * v_useTextureOrGPU.z))
		{
			control1.y = 1.0 - (v_texcoord1.x - (0.21 + 0.21 + layer2.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.7)/((0.21 + 0.21 + layer2.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.3);
			control1.z = (v_texcoord1.x - (0.21 + 0.21 + layer2.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.7)/((0.21 + 0.21 + layer2.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.3);
		}
		else if(v_texcoord1.x < (0.21 + 0.21 + 0.21 + layer3.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.7)
		{
			control1.z = 1.0;
		}
		else if(v_texcoord1.x < (0.21 + 0.21 + 0.21 + layer3.x* 0.01 + factor1.x * v_useTextureOrGPU.z))
		{
			control1.z = 1.0 - (v_texcoord1.x - ((0.21 + 0.21 + 0.21 + layer3.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.7))/((0.21 + 0.21 + 0.21 + layer3.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.3);
			control1.w = (v_texcoord1.x - ((0.21 + 0.21 + 0.21 + layer3.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.7))/((0.21 + 0.21 + 0.21 + layer3.x * 0.01 + factor1.x * v_useTextureOrGPU.z) * 0.3);
		}
		else
		{
			control1.w = 1.0;
		}
		float lengthPow = sqrt(control1.x * control1.x + control1.y * control1.y + control1.z * control1.z + control1.w * control1.w);
		control1.x /=lengthPow;
		control1.y /=lengthPow;
		control1.z /=lengthPow;
		control1.w /=lengthPow;
		emission = vec4(lay1.xyz*control1.x + lay2.xyz*control1.y + lay3.xyz*control1.z + lay4.xyz*control1.w, 1.0); 
	}

	
	#ifdef LIGHTMAP
    lowp vec4 lightmap = texture(_LightmapTex, lightmap_TEXCOORD);
    emission.xyz *= decode_hdr(lightmap);
    #endif

    #ifdef FOG
    emission.xyz = mix(glstate_fog_color.rgb, emission.rgb, factor);
    #endif

    color = emission;
}