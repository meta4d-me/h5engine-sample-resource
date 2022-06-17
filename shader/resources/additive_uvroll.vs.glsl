
precision mediump float;  

//坐标属性
attribute vec3 _glesVertex;
attribute vec2 _glesMultiTexCoord0;

uniform mat4 glstate_matrix_mvp;

uniform vec4 _MainTex_ST;

uniform float _UVSpeedX;
uniform float _UVSpeedY;
uniform float glstate_timer;

varying vec4 v_color;
varying vec2 v_uv;

void main() 
{
    vec4 position = vec4(_glesVertex.xyz, 1.0);
    //输出uv
    v_uv = _glesMultiTexCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw + vec2(_UVSpeedX,_UVSpeedY) * glstate_timer;

    //计算投影坐标
    gl_Position = glstate_matrix_mvp * position;
}