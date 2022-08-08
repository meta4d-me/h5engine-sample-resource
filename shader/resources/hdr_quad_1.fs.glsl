#version 300 es

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform sampler2D _MainTex;
uniform float _K;
in highp vec2 xlv_TEXCOORD0;

//texture2DEtC1Mark

vec4 xposure(vec4 color, float gray, float ex)
{
    float b = (4. * ex - 1.);
    float a = 1. - b;
    float f = gray * (a * gray + b);
    return color * f;
}

out vec4 color; 
void main()
{
    vec4 _color = texture(_MainTex, xlv_TEXCOORD0);
    float lum = .3 * _color.x + .59 * _color.y + .11 * _color.z;
    color = xposure(_color, lum, _K);
}