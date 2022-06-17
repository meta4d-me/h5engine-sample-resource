
precision mediump float;

varying vec2 v_uv;

uniform vec4 _TintColor;
uniform sampler2D _MainTex;
uniform vec4 _MainTex_ST;

void main()
{
    vec4 finalColor = vec4(1.0, 1.0, 1.0, 1.0);

    vec2 uv = v_uv;
    uv = uv * _MainTex_ST.xy + _MainTex_ST.zw;
    finalColor = finalColor * _TintColor * texture2D(_MainTex, uv);

    gl_FragColor = finalColor;
}