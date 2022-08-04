#version 300 es

precision mediump float;

in lowp vec4 xlv_COLOR;

out vec4 color; 
void main()
{
    color = xlv_COLOR;
}