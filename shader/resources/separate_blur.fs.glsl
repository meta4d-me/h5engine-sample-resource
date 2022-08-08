#version 300 es

precision mediump float;

uniform sampler2D _MainTex;

in highp vec2 uv;
in highp vec4 uv01;
in highp vec4 uv23;
in highp vec4 uv45;

//texture2DEtC1Mark

out vec4 color; 
void main() 
{
    lowp vec4 _color=vec4(0,0,0,0);
    _color+=0.4*texture(_MainTex, uv.xy);
    _color+=0.15*texture(_MainTex, uv01.xy);
    _color+=0.15*texture(_MainTex, uv01.zw);
    _color+=0.10*texture(_MainTex, uv23.xy);
    _color+=0.10*texture(_MainTex, uv23.zw);
    _color+=0.05*texture(_MainTex, uv45.xy);
    _color+=0.05*texture(_MainTex, uv45.zw);

    color = _color;
}
