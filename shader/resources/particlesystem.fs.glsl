
precision mediump float;

varying vec2 v_uv;

uniform vec4 _TintColor;
uniform sampler2D _MainTex;

varying vec4 v_color;

#ifdef FOG
uniform lowp vec4 glstate_fog_color; 
varying lowp float factor;
#endif

void main()
{
    vec4 color = 2.0 * v_color * _TintColor * texture2D(_MainTex, v_uv);

    #ifdef FOG
        color.xyz = mix(glstate_fog_color.rgb, color.rgb, factor);
    #endif
    
    gl_FragColor = color;
}