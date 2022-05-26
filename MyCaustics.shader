Shader "Custom/MyCaustics"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Wavelength("Wavelength", float) = 1
        _Amplitude("Amplitude", float) = 1
        _Speed("Speed", float) = 1
        _CubeMap("CubeMap", CUBE) = "" {}
    }
    // SubShader
    // {
    //     Tags { "RenderType"="Opaque" }

    //     Pass
    //     {
    //         CGPROGRAM
    //         #pragma vertex vert
    //         #pragma fragment frag

    //         #include "UnityCG.cginc"

    //         struct appdata
    //         {
    //             float4 vertex : POSITION;
    //             float2 uv : TEXCOORD0;
    //         };

    //         struct v2f
    //         {
    //             float2 uv : TEXCOORD0;
    //             float4 vertex : SV_POSITION;
    //             float3 normal : NORMAL;
    //         };

    //         float _Wavelength;
    //         float _Amplitude;
    //         float _Speed;

    //         sampler2D _MainTex;
    //         float4 _MainTex_ST;

    //         float calWaveHeight(float x, float y)
    //         {
    //             float k = 2 * UNITY_PI / _Wavelength;
    //             float f = k * (x + _Speed * _Time.y);
    //             y = _Amplitude * sin(f);
    //             return y;
    //         }

    //         v2f vert (appdata v)
    //         {
    //             v2f o;
    //             v.vertex.y = calWaveHeight(v.vertex.x, v.vertex.y);
    //             o.vertex = UnityObjectToClipPos(v.vertex);
    //             o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    //             return o;
    //         }

    //         fixed4 frag (v2f i) : SV_Target
    //         {
    //             // sample the texture
    //             fixed4 col = tex2D(_MainTex, i.uv);
    //             return col;
    //         }
    //         ENDCG
    //     }

    // }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
                float3 normal : TEXCOORD1;
            };

            float _Wavelength;
            float _Amplitude;
            float _Speed;

            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE _CubeMap;

            float calWaveHeight(float x)
            {
                float k = 2 * UNITY_PI / _Wavelength;
                float f = k * (x + _Speed * _Time.y);
                float y = _Amplitude * sin(f);
                return y;
            }

            float3 calWaveNormal(float x)
            {
                float k = 2 * UNITY_PI / _Wavelength;
                float f = k * (x + _Speed * _Time.y);
                float3 tangent = float3(1, _Amplitude * k * cos(f), 0);
                float3 binormal = float3(0, 0, 1);
                float3 normal = cross(binormal, tangent);
                return normal;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float y = calWaveHeight(v.vertex.x);
                float3 n = calWaveNormal(v.vertex.x);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = n;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                i.normal = normalize(i.normal);
                fixed4 col = texCUBE(_CubeMap, i.normal);
                return col;
            }
            ENDCG
        }
    }
}
