Shader "Custom/MyCaustics"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Octaves("Octaves", range(1, 10)) = 1
        _Freq("Freq", float) = 1
        _Amp("Amp", float) = 1
        _Speed("Speed", float) = 1
    }
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            int _Octaves;
            float _Freq;
            float _Amp;
            float _Speed;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                float x = v.vertex.x;
                float z = v.vertex.z;
                v.vertex.y = sqrt(x * x + z * z) * _Amp * cos(_Freq + 2 * _Speed * x * z * _Time.y) / 2;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
