#version 300 es

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform sampler2D _MainTex;
uniform lowp float _FilterType;
uniform lowp float _Step;
in highp vec2 xlv_TEXCOORD0;
//texture2DEtC1Mark

out vec4 color; 
void main()
{
    vec2 tcOffset[25];
    lowp float xInc = _Step / 1024.0;
    lowp float yInc = _Step / 1024.0;
    for (int i = 0; i < 5; i++)
    {
        for (int j = 0; j < 5; j++)
        {
            tcOffset[(((i * 5) + j) * 2)] = vec2((-2.0 * xInc) + (float(i) * xInc), (-2.0 * yInc) + (float(j) * yInc));
        }
    }

    // 灰度图
    if (_FilterType == 1.)
    {
        float gray = dot(texture(_MainTex, xlv_TEXCOORD0.xy).rgb, vec3(0.299, 0.587, 0.114));
        color = vec4(gray, gray, gray, 1.0);
    }

    // 棕褐色调
    else if (_FilterType == 2.)
    {
        float gray = dot(texture(_MainTex, xlv_TEXCOORD0.xy).rgb, vec3(0.299, 0.587, 0.114));
        color = vec4(gray * vec3(1.2, 1.0, 0.8), 1.0);
    }

    // 反色
    else if (_FilterType == 3.)
    {
        vec4 color = texture(_MainTex, xlv_TEXCOORD0.xy);
        color = vec4(1.0 - color.rgb, 1.0);
    }

    // 高斯滤波
    else if (_FilterType == 4.)
    {
        vec4 _sample[25];
        for (int i = 0; i < 25; i++)
        {
            _sample[i] = texture(_MainTex, xlv_TEXCOORD0.xy + tcOffset[i]);
        }

        // 1  4  7  4 1
        // 4 16 26 16 4
        // 7 26 41 26 7 / 273 (除权重总和)
        // 4 16 26 16 4
        // 1  4  7  4 1
        color = (
                            (1.0  * (_sample[0] + _sample[4]  + _sample[20] + _sample[24])) +
                            (4.0  * (_sample[1] + _sample[3]  + _sample[5]  + _sample[9] + _sample[15] + _sample[19] + _sample[21] + _sample[23])) +
                            (7.0  * (_sample[2] + _sample[10] + _sample[14] + _sample[22])) +
                            (16.0 * (_sample[6] + _sample[8]  + _sample[16] + _sample[18])) +
                            (26.0 * (_sample[7] + _sample[11] + _sample[13] + _sample[17])) +
                            (41.0 * _sample[12])
                         ) / 273.0;
    }

    // 均值滤波
    else if (_FilterType == 5.)
    {
        vec4 _sample[25];
        for (int i = 0; i < 25; i++)
        {
            _sample[i] = texture(_MainTex, xlv_TEXCOORD0.xy + tcOffset[i]);
        }

        vec4 color;
        for (int i = 0; i < 25; i++)
        {
            color += _sample[i];
        }

        color = color / 25.0;
    }

    // 锐化
    else if (_FilterType == 6.)
    {
        vec4 _sample[25];
        for (int i = 0; i < 25; i++)
        {
            _sample[i] = texture(_MainTex, xlv_TEXCOORD0.xy + tcOffset[i]);
        }

        // -1 -1 -1 -1 -1
        // -1 -1 -1 -1 -1
        // -1 -1 25 -1 -1
        // -1 -1 -1 -1 -1
        // -1 -1 -1 -1 -1
        vec4 color = _sample[12] * 25.0;
        for (int i = 0; i < 25; i++)
        {
            if (i != 12)
            {
                color -= _sample[i];
            }
        }

        color = color;
    }

    // 膨胀
    else if (_FilterType == 7.)
    {
        vec4 _sample[25];
        vec4 maxValue = vec4(0.0);
        for (int i = 0; i < 25; i++)
        {
            _sample[i] = texture(_MainTex, xlv_TEXCOORD0.xy + tcOffset[i]);
            maxValue = max(_sample[i], maxValue);
        }

        color = maxValue;
    }

    // 腐蚀
    else if (_FilterType == 8.)
    {
        vec4 _sample[25];
        vec4 minValue = vec4(1.0);
        for (int i = 0; i < 25; i++)
        {
            _sample[i] = texture(_MainTex, xlv_TEXCOORD0.xy + tcOffset[i]);
            minValue = min(_sample[i], minValue);
        }
        color = minValue;
    }

    // 标准
    else
    {
        color = texture(_MainTex, xlv_TEXCOORD0.xy);
    }
}