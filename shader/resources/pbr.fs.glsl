#version 300 es

// #ifdef TEXTURE_LOD
// #extension GL_EXT_shader_texture_lod : enable
// #endif

#define TEXTURE_LOD
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
uniform float alphaCutoff;      //alphaCutoff

uniform lowp float glstate_lightcount;
uniform lowp vec4 glstate_vec4_lightposs[8];
uniform lowp vec4 glstate_vec4_lightdirs[8];
uniform lowp float glstate_float_spotangelcoss[8];
uniform lowp vec4 glstate_vec4_lightcolors[8];
uniform lowp float glstate_float_lightrange[8];
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
uniform vec4 CustomEmissiveColor;

#define TEX_FORMAT_METALLIC     rgb
#define TEX_FORMAT_ROUGHNESS    a

in vec3 v_pos;
in vec2 xlv_TEXCOORD0;
in mat3 TBN;

#ifdef LIGHTMAP
uniform lowp float glstate_lightmapRGBAF16;
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
    vec4 c0 = vec4(-1.0, -0.0275, -0.572, 0.022);
    vec4 c1 = vec4(1.0, 0.0425, 1.04, -0.04);
    vec4 r = roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * dotNV)) * r.x + r.y;
    return vec2(-1.04, 1.04) * a004 + r.zw;
}

// Fresnel - F0 = Metalness
vec3 F_Schlick(float VoH, vec3 F0) {
    return F0 + (vec3(1.0) - F0) * pow(1.0 - VoH, 5.0);
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
    if(r.a != 0. && r.a <= 0.7372549019607844) {    //判读 0.7372 避免 expVal > 60 后出现问题。 
        float expVal = r.a * 255. - 128.;
        float e = exp2(expVal);
        return vec3(r.r * e, r.g * e, r.b * e);
    }
    return  vec3(0.0);
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

struct lightData{
    vec3 L;
    float rVal;
};

st_core init() {
    st_core temp;

    // PBR Material
    temp.diffuse = (sRGBtoLINEAR(texture(uv_Basecolor, xlv_TEXCOORD0 * uvRepeat)) * CustomBasecolor);

    vec3 rm = texture(uv_MetallicRoughness, xlv_TEXCOORD0 * uvRepeat).rgb;
    temp.roughness = clamp(rm.g, 0.04, 1.0) * CustomRoughness;
    temp.alphaRoughness = temp.roughness * temp.roughness;
    temp.metallic = clamp(rm.b, 0.0, 1.0) * CustomMetallic;

    // vec4 AO = sRGBtoLINEAR(texture(uv_AO, xlv_TEXCOORD0 * uvRepeat));

    vec3 f0 = vec3(0.04);
    temp.f0 = mix(f0, temp.diffuse.xyz, temp.metallic);

    temp.diffuse.rgb = temp.diffuse.rgb * (vec3(1.) - f0) * (1. - temp.metallic);
    // temp.diffuse/=PI;

    temp.V = normalize(glstate_eyepos.xyz - v_pos);
    // mat3 TBN = cotangent_frame(temp.N, temp.V, xlv_TEXCOORD0 * uvRepeat);
    vec3 normalAddation = texture(uv_Normal, xlv_TEXCOORD0 * uvRepeat).rgb * 2. - 1.;
    temp.N = normalize(TBN * normalAddation);

    temp.NoV = clamp(abs(dot(temp.N, temp.V)), 0.001, 1.0);
    temp.R = -normalize(reflect(temp.V, temp.N));

    return temp;
}

vec3 lightBRDF(lightData ld, st_core core) {
    vec3 L = normalize(ld.L);
    vec3 H = normalize(core.V + L);

    float NoL = clamp(dot(core.N, L), 0.001, 1.0);
    float NoH = clamp(dot(core.N, H), 0.0, 1.0);
    // float LoH = clamp(dot(L, H), 0.0, 1.0);
    float VoH = clamp(dot(core.V, H), 0.0, 1.0);

    // vec3 diffuse = core.Basecolor.rgb * NoL / PI;

    vec3 F = F_Schlick(VoH, core.f0);
    float G = G_UE4(core.NoV, NoH, VoH, NoL, core.roughness);
    float D = D_GGX(core.alphaRoughness, NoH);
    
    //直接光照(镜面反射)
    vec3 specContrib = F * G * D / (4.0 * NoL * core.NoV);
    //间接光照(漫反射)
    vec3 diffuseContrib = (1.0 - F) * core.diffuse.rgb / PI;

    // vec3 color = NoL * (diffuseContrib + specContrib);
    vec3 color = ld.rVal * (diffuseContrib + specContrib);

    return color;
}

//calcLight 计算灯光数据函数
//统一三种光源的传参方式，在函数内混合，方便就不高效
//只需要方向光时另写
//N 世界空间法线
//worldpos 世界空间pos
//lightPos 光源位置,w=0 表示方向光
//lightDir 光源方向，W=0 表示点光源，和楼上的w一起为1 表示 探照灯 spot
//cosspot cos(a) a为spot的半径 a取值0到90度，算好cos再传进来
lightData calcLight(vec3 N,vec3 worldpos,vec4 lightPos,vec4 lightDir,float cosspot,float range)
{
    lightData ld;

    vec3 v3 = lightPos.xyz - worldpos;
    float len = length(v3);
    len = len > range ? range : len;
    //求入射角，点光源&聚光灯
    vec3 L = normalize(v3); 
    //求张角 聚光灯 也是方向光入射角
    vec3 L2 = -lightDir.xyz;
    float dotSpot = dot(L,L2);
    float spotVal = smoothstep(cosspot , 1.0 , dotSpot);
    float atten = pow(1.0 - len/range , 3.0);

    //光方向
    ld.L = mix(L2 , L , lightPos.w);
    float NoL = clamp(dot(N , ld.L) , 0.0 , 1.0);

    //反射度
    float r = NoL * atten;                       //点光 和 射灯
    r *= mix(1.0 , spotVal , lightDir.w);        // lightDir.w = 0 点光, w = 1 射灯 (有角度约束)
    float rDir = NoL;                            //方向光
    ld.rVal = mix(rDir , r , lightPos.w);        //lightPos.w = 0 方向光 ，w = 1 点光 和 射灯

    return ld;
}

out vec4 color; 
void main() {
    //alpha Test
    vec4 baseTex = texture(uv_Basecolor, xlv_TEXCOORD0 * uvRepeat);
    if(baseTex.a < alphaCutoff){
        discard;
    }

    st_core c = init();
    float lod = clamp(c.roughness * 10.0, 0.0, 11.0);
    vec3 directL;

    //实时灯光 直接光照 照明贡献计算----------------------------
    // vec2 envBRDF    = texture(brdf, vec2(clamp(c.NoV, 0.0, 0.9999999), clamp(1.0-c.Roughness, 0.0, 0.9999999))).rg;
    // int lightCount = int(min(3., glstate_lightcount));
    int lightCount = int(glstate_lightcount);
    if (lightCount > 0) {
        for (int i = 0; i < 8; i++) {
            if (i >= lightCount) break;
            lightData ld = calcLight(c.N,v_pos,glstate_vec4_lightposs[i],glstate_vec4_lightdirs[i],glstate_float_spotangelcoss[i],glstate_float_lightrange[i]);
            directL += lightBRDF(ld , c) * glstate_vec4_lightcolors[i].rgb * glstate_float_lightintensity[i];
        }
    }

    //环境 间接光照 照明贡献计算----------------------------
    vec2 brdf = DFGApprox(c.NoV, c.roughness);
    //镜面反射
    #ifdef TEXTURE_LOD
        // vec3 IBLColor = decoRGBE(textureCubeLodEXT(u_env, c.R, lod));
        vec3 IBLColor = decoRGBE(textureLod(u_env, c.R, lod));
    #else
        vec3 IBLColor = decoRGBE(texture(u_env, c.R));
    #endif
    vec3 IBLspecular = 1.0 * IBLColor * (c.f0 * brdf.x + brdf.y);
    vec3 indirectSpec = IBLspecular * specularIntensity;

    //漫反射
    #ifdef TEXTURE_LOD
        // vec3 indirectDiff = c.diffuse.rgb * decoRGBE(textureCubeLodEXT(u_diffuse, c.R, lod)) * diffuseIntensity;
        vec3 indirectDiff = c.diffuse.rgb * decoRGBE(textureLod(u_diffuse, c.R, lod)) * diffuseIntensity;
    #else
        vec3 indirectDiff = c.diffuse.rgb * decoRGBE(texture(u_diffuse, c.R)) * diffuseIntensity;
    #endif

    //照明合并
    vec3 finalColor = directL + indirectSpec + indirectDiff;
    // vec3 finalColor = c.N;

#ifdef LIGHTMAP
    //有lightMap 时，用lightmap 贡献一部分 间接光照
    vec4 lightmap = texture(_LightmapTex, lightmap_TEXCOORD);
    vec3 lightMapColor;
    if(glstate_lightmapRGBAF16 == 1.0){
        // finalColor.xyz *= lightmap.xyz;
        lightMapColor = sRGBtoLINEAR(lightmap).rgb;
    }else{
        // finalColor.xyz *= decode_hdr(lightmap);
        lightMapColor = decode_hdr(lightmap);
    }

    // finalColor += c.diffuse.rgb * lightMapColor;
    finalColor += c.diffuse.rgb * lightMapColor * diffuseIntensity;
#endif

    //emission
    finalColor += sRGBtoLINEAR(texture(uv_Emissive, xlv_TEXCOORD0 * uvRepeat)).rgb * CustomEmissiveColor.rgb;
    
    //AO + Exposure
    finalColor *= u_Exposure * texture(uv_AO, xlv_TEXCOORD0 * uvRepeat).r;


    //色调映射 （HDR -> LDR）
    finalColor = toneMapACES(finalColor);

#ifdef FOG
    finalColor.xyz = mix(glstate_fog_color.rgb, finalColor.rgb, factor);
#endif

    // color = vec4(finalColor, c.diffuse.a);
    color = vec4(finalColor, c.diffuse.a);
}