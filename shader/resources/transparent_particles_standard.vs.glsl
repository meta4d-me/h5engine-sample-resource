#version 300 es


precision mediump float;

layout(location = 0) in highp vec3    _glesVertex;
layout(location = 4) in vec2 _glesMultiTexCoord0;
layout(location = 3) in vec4 _glesColor;

uniform vec4 _MainTex_ST;

uniform vec4 _Panning;
uniform float glstate_timer;

uniform vec4 _NoiseTex_ST;
uniform vec4 _NoisePanning;

uniform mat4 glstate_matrix_mvp;

out vec2 v_uv;
out vec4 v_color;

uniform float EXTENDED_PARTICLES;
out vec2 v_particledata;

uniform float NOISE_TEXTURE;
uniform float NOISEUV;
out vec2 v_noiseuv;

void main() 
{
    vec3 position = _glesVertex;
    gl_Position = glstate_matrix_mvp * vec4(position, 1.0);
    v_uv = _glesMultiTexCoord0 * _MainTex_ST.xy + _MainTex_ST.zw + (_Panning.xy * glstate_timer);
    v_color = _glesColor;
    // v_color = vec4(1.0,1.0,1.0,1.0);

    if(EXTENDED_PARTICLES > 0.5)
    {
        if( NOISE_TEXTURE > 0.5)
        {
            if( NOISEUV > 0.5)
            {
                v_noiseuv = _glesMultiTexCoord0 * _NoiseTex_ST.xy + _NoiseTex_ST.zw + (_NoisePanning.xy * glstate_timer);
            }
            else
            {
                v_noiseuv = _glesMultiTexCoord0 * _MainTex_ST.xy + _MainTex_ST.zw + (_NoisePanning.xy * glstate_timer);
            }
        }
    }
    else
    {
        // v_particledata = _glesMultiTexCoord0.zw;
        v_particledata = _glesMultiTexCoord0;
    }
}