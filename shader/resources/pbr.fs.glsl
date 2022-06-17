#extension GL_OES_standard_derivatives : enable
#ifdef TEXTURE_LOD
#extension GL_EXT_shader_texture_lod : enable
#endif
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

#define PI          3.141592653589
#define GAMMA 2.2

// uniform vec4 light_1;
// uniform vec4 light_2;

uniform float diffuseIntensity;
uniform float specularIntensity;
uniform float uvRepeat;

uniform lowp float glstate_lightcount;
// uniform lowp vec4 glstate_vec4_lightposs[8];
uniform lowp vec4 glstate_vec4_lightdirs[8];
// uniform lowp float glstate_float_spotangelcoss[8];
uniform lowp vec4 glstate_vec4_lightcolors[8];
// uniform lowp float glstate_float_lightrange[8];
uniform lowp float glstate_float_lightintensity[8];

uniform samplerCube u_env;      // IBL
uniform samplerCube u_diffuse;  // diffuse
uniform float u_Exposure;
// uniform sampler2D brdf;       // BRDF LUT
uniform vec4 glstate_eyepos;

// PBR 材质贴图
uniform sampler2D uv_Normal;
uniform sampler2D uv_Basecolor;
uniform sampler2D uv_MetallicRoughness;
uniform sampler2D uv_AO;
uniform sampler2D uv_Emissive;

// Customize value
uniform vec4 CustomBasecolor;
uniform float CustomMetallic;
uniform float CustomRoughness;

#define TEX_FORMAT_METALLIC     rgb
#define TEX_FORMAT_ROUGHNESS    a

varying vec3 v_normal;
varying vec3 v_pos;
varying vec2 xlv_TEXCOORD0;
varying mat3 TBN;

#ifdef LIGHTMAP
uniform lowp float glstate_lightmapRGBAF16;
uniform lowp sampler2D _LightmapTex;
varying mediump vec2 lightmap_TEXCOORD;
lowp vec3 decode_hdr(lowp vec4 data)
{
    lowp float power =pow( 2.0 ,data.a * 255.0 - 128.0);
    return data.rgb * power * 2.0 ;
}
#endif

#ifdef FOG
uniform lowp vec4 glstate_fog_color;
varying lowp float factor;
#endif

vec4 sRGBtoLINEAR(vec4 color) {
    return vec4(pow(color.rgb, vec3(GAMMA)), color.a);
}
vec4 LINEARtoSRGB(vec4 color) {
    return vec4(pow(color.rgb, vec3(1.0 / GAMMA)), color.a);
}

vec3 toneMapACES(vec3 color) {
    const float A = 2.51;
    const float B = 0.03;
    const float C = 2.43;
    const float D = 0.59;
    const float E = 0.14;
    return pow(clamp((color * (A * color + B)) / (color * (C * color + D) + E), 0.0, 1.0), vec3(1.0 / GAMMA));
}

vec2 DFGApprox(float NoV, float roughness) {
    float dotNV = clamp(NoV, 0., 1.);
    vec4 c0 = vec4(-1, -0.0275, -0.572, 0.022);
    vec4 c1 = vec4(1, 0.0425, 1.04, -0.04);
    vec4 r = roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * dotNV)) * r.x + r.y;
    return vec2(-1.04, 1.04) * a004 + r.zw;
}

// Fresnel - F0 = Metalness
vec3 F_Schlick(float VoH, vec3 F0) {
    return F0 + (vec3(1) - F0) * pow(1.0 - VoH, 5.0);
}

// Geometric
// >    Schlick with k = α/2 matches Smith very closely
float G_UE4(float NoV, float NoH, float VoH, float NoL, float roughness) {
    float k = (roughness + 1.0) * (roughness + 1.0) / 8.0;
    float l = NoL / (NoL * (1.0 - k) + k);  // There are another version which use NoH & LoH
    float v = NoV / (NoV * (1.0 - k) + k);
    return l * v;
}

// a (alphaRoughness) = Roughness
// Distribution AKA normal distribution function (NDF)
// Trowbridge-Reitz
float D_GGX(float a, float NoH) {
    a = a * a;
    // float f = (NoH * a - NoH) * NoH + 1.0;  // NoH * NoH * (a - 1.0) + 1.0;
    float f = NoH * NoH * (a - 1.0) + 1.0;
    return a / (PI * f * f);
}

// mat3 cotangent_frame(vec3 N, vec3 p, vec2 uv){
//     // get edge vectors of the pixel triangle
//     vec3 dp1 = dFdx( p );
//     vec3 dp2 = dFdy( p );
//     vec2 duv1 = dFdx( uv );
//     vec2 duv2 = dFdy( uv );

//     // solve the linear system
//     vec3 dp2perp = cross( dp2, N );
//     vec3 dp1perp = cross( N, dp1 );
//     vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
//     vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;

//     // construct a scale-invariant frame
//     float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
//     return mat3( T * invmax, B * invmax, N );
// }

// decode RGBE data after LOD due to RGB32F mipmap issue
vec3 decoRGBE(vec4 r) {
    if(r.a != 0.) {
        float e = exp2(r.a * 255. - 128.);
        return vec3(r.r * e, r.g * e, r.b * e);
    }
    return vec3(0);
}

struct st_core {
    vec4 diffuse;
    vec3 f0;
    vec3 N;
    vec3 V;
    vec3 R;
    float NoV;
    float metallic;
    float roughness;
    float alphaRoughness;
};

st_core init() {
    st_core temp;

    // PBR Material
    temp.diffuse = (sRGBtoLINEAR(texture2D(uv_Basecolor, xlv_TEXCOORD0 * uvRepeat)) * CustomBasecolor);

    vec3 rm = texture2D(uv_MetallicRoughness, xlv_TEXCOORD0 * uvRepeat).rgb;
    temp.roughness = clamp(rm.g, 0.04, 1.0) * CustomRoughness;
    temp.alphaRoughness = temp.roughness * temp.roughness;
    temp.metallic = clamp(rm.b, 0.0, 1.0) * CustomMetallic;

    // vec4 AO = sRGBtoLINEAR(texture2D(uv_AO, xlv_TEXCOORD0 * uvRepeat));

    vec3 f0 = vec3(0.04);
    temp.f0 = mix(f0, temp.diffuse.xyz, temp.metallic);

    temp.diffuse.rgb = temp.diffuse.rgb * (vec3(1) - f0) * (1. - temp.metallic);
    // temp.diffuse/=PI;

    temp.V = normalize(glstate_eyepos.xyz - v_pos);
    // mat3 TBN = cotangent_frame(temp.N, temp.V, xlv_TEXCOORD0 * uvRepeat);
    vec3 normalAddation = texture2D(uv_Normal, xlv_TEXCOORD0 * uvRepeat).rgb * 2. - 1.;
    temp.N = normalize(TBN * normalAddation);

    temp.NoV = clamp(abs(dot(temp.N, temp.V)), 0.001, 1.0);
    temp.R = -normalize(reflect(temp.V, temp.N));

    return temp;
}

vec3 lightBRDF(vec3 L, st_core core) {
    L = normalize(L);
    vec3 H = normalize(core.V + L);

    float NoL = clamp(dot(core.N, L), 0.001, 1.0);
    float NoH = clamp(dot(core.N, H), 0.0, 1.0);
    // float LoH = clamp(dot(L, H), 0.0, 1.0);
    float VoH = clamp(dot(core.V, H), 0.0, 1.0);

    // vec3 diffuse = core.Basecolor.rgb * NoL / PI;

    vec3 F = F_Schlick(VoH, core.f0);
    float G = G_UE4(core.NoV, NoH, VoH, NoL, core.roughness);
    float D = D_GGX(core.alphaRoughness, NoH);

    vec3 specContrib = F * G * D / (4.0 * NoL * core.NoV);
    vec3 diffuseContrib = (1.0 - F) * core.diffuse.rgb / PI;
    vec3 color = NoL * (diffuseContrib + specContrib);

    return color;
}

void main() {
    st_core c = init();
    float lod = clamp(c.roughness * 10.0, 0.0, 11.0);
    vec3 finalColor;

    // vec2 envBRDF    = texture2D(brdf, vec2(clamp(c.NoV, 0.0, 0.9999999), clamp(1.0-c.Roughness, 0.0, 0.9999999))).rg;
    int lightCount = int(min(3., glstate_lightcount));
    if (lightCount > 0) {
        for (int i = 0; i < 8; i++) {
            if (i >= lightCount) break;
            finalColor += lightBRDF(glstate_vec4_lightdirs[i].xyz, c) * glstate_vec4_lightcolors[i].rgb * glstate_float_lightintensity[i];
        }
    }
    // finalColor += lightBRDF(light_1.xyz, c) * vec3(0.6, 0.4, 0.6) * 3.0;
    // finalColor += lightBRDF(light_2.xyz - v_pos, c) * vec3(0.6, 0.6, 0.4);
    // finalColor += ((1.0 - F) * (1.0 - c.Metallic) * c.Basecolor.rgb + indirectSpecular) * c.AO.rgb; // IBL+PBR

    // vec3 brdf = sRGBtoLINEAR(texture2D(brdf, clamp(vec2(c.NoV, 1. - c.roughness), vec2(0), vec2(1)))).rgb;
    vec2 brdf = DFGApprox(c.NoV, c.roughness);
    #ifdef TEXTURE_LOD
        vec3 IBLColor = decoRGBE(textureCubeLodEXT(u_env, c.R, lod));
    #else
        vec3 IBLColor = decoRGBE(textureCube(u_env, c.R));
    #endif
    vec3 IBLspecular = 1.0 * IBLColor * (c.f0 * brdf.x + brdf.y);
    finalColor += IBLspecular * specularIntensity;

    #ifdef TEXTURE_LOD
        finalColor += c.diffuse.rgb * decoRGBE(textureCubeLodEXT(u_diffuse, c.R, lod)) * diffuseIntensity;
    #else
        finalColor += c.diffuse.rgb * decoRGBE(textureCube(u_diffuse, c.R)) * diffuseIntensity;
    #endif

#ifdef LIGHTMAP
    //有lightMap 时，用lightmap 贡献一部分 间接光照
    vec4 lightmap = texture2D(_LightmapTex, lightmap_TEXCOORD);
    vec3 lightMapColor;
    if(glstate_lightmapRGBAF16 == 1.0){
        // finalColor.xyz *= lightmap.xyz;
        lightMapColor = sRGBtoLINEAR(lightmap).rgb;
    }else{
        // finalColor.xyz *= decode_hdr(lightmap);
        lightMapColor = decode_hdr(lightmap);
    }

    // finalColor += c.diffuse.rgb * lightMapColor;
    finalColor += c.diffuse.rgb * lightMapColor * diffuseIntensity;;
#endif

    // finalColor += sRGBtoLINEAR(texture2D(uv_Emissive, xlv_TEXCOORD0 * uvRepeat)).rgb;
    finalColor *= u_Exposure * texture2D(uv_AO, xlv_TEXCOORD0 * uvRepeat).r;

    finalColor = toneMapACES(finalColor);

#ifdef FOG
    finalColor.xyz = mix(glstate_fog_color.rgb, finalColor.rgb, factor);
#endif
    gl_FragColor = vec4(finalColor, c.diffuse.a);
}