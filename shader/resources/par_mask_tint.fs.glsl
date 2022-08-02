#version 300 es

precision mediump float;

uniform sampler2D _Main_Tex; 
uniform sampler2D _Mask; 

in mediump vec2 _maintex_uv;
in mediump vec2 _mask_uv;

in mediump vec4 v_color;

//texture2DEtC1Mark

out vec4 color; 
void main()    
{
    highp vec4 basecolor=texture(_Main_Tex,_maintex_uv);
    highp vec4 maskcolor=texture(_Mask,_mask_uv);

    mediump vec3 tempcolor=v_color.rgb*basecolor.rgb*maskcolor.rgb;
    mediump float tempAlpha=v_color.a*basecolor.a*maskcolor.a;
    mediump vec4 emission=vec4(tempcolor,tempAlpha);
    
    color = emission;
}
