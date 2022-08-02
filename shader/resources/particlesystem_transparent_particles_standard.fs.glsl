#version 300 es

precision mediump float;

uniform sampler2D _MainTex;

uniform vec4 u_color;

uniform float EXTENDED_PARTICLES;
uniform float _EmissionSaturation;
uniform float _OpacitySaturation;
uniform float _ColorMultiplier;

uniform float COLOR_RAMP;
uniform sampler2D _ColorRamp;
uniform vec4 _ColorRamp_ST;
uniform float COLOR_TINT;
uniform vec4 _BasicColor;
uniform vec4 _SaturatedColor;

uniform float DISSOLVE_ENABLED;
uniform vec4 _DissolveStep;

uniform float NOISE_TEXTURE;
uniform sampler2D _NoiseTex;
uniform vec4 _TintColor;

uniform float EMISSIVEPOWER;
uniform float _EmissivePower;

uniform float _ABOffset;

uniform float _GlobalAlpha;

in vec2 v_uv;
in vec4 v_color;

in vec2 v_particledata;
in vec2 v_noiseuv;

uniform float APPLY_RGB_COLOR_VERTEX;
uniform float NOISE_TEXTURE_EMISSION;
uniform float NOISE_TEXTURE_ALPHA;
uniform float NOISE_TEXTURE_DISSOLVE;

uniform float BlendMode;

out vec4 color; 
void main() 
{
    vec4 tex = texture(_MainTex, v_uv);

    vec4 col = vec4(1.0, 1.0, 1.0, 1.0);

    vec4 vcolor = vec4(1.0, 1.0, 1.0, v_color.w);

    if( EXTENDED_PARTICLES > 0.5 )
    {
        if( APPLY_RGB_COLOR_VERTEX > 0.5)
        {
            vcolor = v_color;
        }

        float nEmission = 1.0;
        float nAlpha = 1.0;
        float nDissolve = 1.0;
        
        if( NOISE_TEXTURE > 0.5)
        {
            vec3 noise = texture(_NoiseTex, v_noiseuv).xyz;
        
            if( NOISE_TEXTURE_EMISSION > 0.5)
            {
                nEmission = noise.x;
            }
            else
            {
                nEmission = 1.0;
            }
            
            if( NOISE_TEXTURE_ALPHA > 0.5)
            {
                nAlpha = noise.y;
            }
            else
            {
                nAlpha = 1.0;
            }
            
            if( NOISE_TEXTURE_DISSOLVE > 0.5)
            {
                nDissolve = noise.z;
            }
            else
            {
                nDissolve = 1.0;
            }
        }
    
        if( DISSOLVE_ENABLED > 0.5)
        {
            float ramp = -1.0 + (v_particledata.x * 2.0);
            col.a = clamp(tex.g * smoothstep(_DissolveStep.x, _DissolveStep.y, (tex.b + ramp) * nDissolve) * _OpacitySaturation * vcolor.w * nAlpha, 0.0, 1.0);
        }
        else
        {
            col.a = clamp(tex.g * _OpacitySaturation * vcolor.w, 0.0, 1.0) * nAlpha;
        }
    
        float lerpValue = 0.0;
        if(COLOR_TINT < 0.5)
        {
            lerpValue = clamp(tex.r * v_particledata.y * _ColorMultiplier * nEmission, 0.0, 1.0);
        }
    
        if( 2.5 < BlendMode && BlendMode < 3.5 ) //3
        {
            if( COLOR_RAMP > 0.5)
            {
                col.xyz = texture(_ColorRamp, vec2((1.0 - lerpValue), 0.0)).xyz * vcolor.xyz * _EmissionSaturation;
            }
            else
            {
                if( COLOR_TINT > 0.5)
                {
                    col.xyz = tex.x * _BasicColor.xyz * vcolor.xyz * nEmission * _EmissionSaturation;
                }
                else
                {
                    col.xyz = mix(_BasicColor.xyz * vcolor.xyz, _SaturatedColor.xyz, lerpValue) * _EmissionSaturation;
                }
            }
            col.a *= _GlobalAlpha;
        }
        else
        {
            if( COLOR_RAMP > 0.5)
            {
                col.xyz = texture(_ColorRamp, vec2((1.0 - lerpValue), 0.0)).xyz * vcolor.xyz * col.a * _EmissionSaturation;
            }
            else
            {
                if( COLOR_TINT > 0.5 )
                {
                    col.xyz = tex.x * _BasicColor.xyz * vcolor.xyz * nEmission * _EmissionSaturation * col.a;
                }
                else
                {
                    col.xyz = mix(_BasicColor.xyz * vcolor.xyz, _SaturatedColor.xyz, lerpValue) * col.a * _EmissionSaturation;
                }
            }
            col *= _GlobalAlpha;
        }
    }
    else
    {
        if( 3.5 < BlendMode && BlendMode < 4.5 ) //4
        {
            tex *= _TintColor;
            float luminance = clamp(dot(tex, vec4(0.2126, 0.7152, 0.0722, 0.0)) * tex.a * _ABOffset, 0.0, 1.0);
            vec4 one = vec4(1, 1, 1, 1);
            col = mix(2.0 * (v_color * tex), one - 2.0 * (one - v_color) * (one - tex), luminance);
        }
        else
        {
            col = v_color * tex;
            col *= _TintColor;
        
            if( EMISSIVEPOWER > 0.5)
            {
                col *= _EmissivePower;
            }
            
            if( 0.5 < BlendMode && BlendMode < 1.5 ) //1
            {
                col.rgb *= col.a;
            }
            else
            {
                if( 2.5 < BlendMode && BlendMode < 3.5 ) //3
                {
                    col *= 2.0;
                }
                else
                {
                    if( 1.5 < BlendMode && BlendMode < 2.5 ) //2
                    {
                        col *= 4.0;
                    }
                }
            }
        }
    
        col *= _GlobalAlpha;

    }

    color = col;
}