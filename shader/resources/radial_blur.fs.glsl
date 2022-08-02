#version 300 es

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform sampler2D _MainTex;
uniform lowp float _Level;
uniform lowp float _CenterX;
uniform lowp float _CenterY;
in highp vec2 xlv_TEXCOORD0;
//texture2DEtC1Mark

out vec4 color; 
void main()
{
    lowp vec2 center = vec2(_CenterX, _CenterY);// 这里为什么要加1.0？？？
    lowp vec2 uv = xlv_TEXCOORD0 - center;
    lowp vec3 tmp = vec3(0, 0, 0);
    for (lowp float i = 0.0; i < 100.0; i++)// for循环只能用i与常量比较
    {
        if (i >= _Level) break;// 在这里跳出循环
        tmp += texture(_MainTex, uv * (1.0 - 0.002 * i) + center).xyz;
    }
    lowp vec4 col = vec4(tmp.xyz / _Level, 1);
    color = col;
}