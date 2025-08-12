Shader "Unlit/musicGraph"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // Müzik verisi render texture için
        _Bands ("Bands", Float) = 30.0
        _Segments ("Segments", Float) = 40.0
        _Opacity ("Opacity", Float) = 1.0 // Opaklýk kontrolü
        _BloomIntensity ("Bloom Intensity", Float) = 2.0 // Bloom için parlaklýk yoðunluðu
        _BloomThreshold ("Bloom Threshold", Float) = 0.8 // Bloom etkinleþmesi için eþik
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha // Þeffaflýk için blending

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex; // Render texture burada
            float _Bands; 
            float _Segments; 
            float4 _MainTex_ST;
            float _Opacity; // Opaklýk kontrol parametresi
            float _BloomIntensity; // Bloom yoðunluðu
            float _BloomThreshold; // Bloom için eþik deðeri

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 p;
                p.x = floor(uv.x * _Bands) / _Bands;
                p.y = floor(uv.y * _Segments) / _Segments;

                float fft = frac(cos(dot(p, float2(1,21)) * _Time) *1);

                // Renk hesaplama
                float3 col = lerp(float3(2, 0.2, 0.2), float3(1.0, 2.2, 0.1), sqrt(uv.y));

                float mask = (p.y < fft) ? 1.0 : 0.0;

                float2 d = frac((uv - p) * float2(_Bands, _Segments)) - 0.5;
                float led = smoothstep(0.5, 0.35, abs(d.x)) * smoothstep(0.5, 0.35, abs(d.y));

                float3 ledColor = led * col * mask;

                float brightness = dot(ledColor, float3(0.2126, 0.7152, 0.0722)); // Luminance hesaplama
                if (brightness > _BloomThreshold)
                {
                    ledColor += (brightness - _BloomThreshold) * _BloomIntensity;
                }

                float alpha = mask * _Opacity;

                return float4(ledColor, alpha);
            }
            ENDCG
        }
    }
}
