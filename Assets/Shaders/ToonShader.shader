Shader "Custom/Toon Shader"
{
    Properties
    {
        [MainTexture]
        _BaseMap("Texture", 2D) = "white" {} 
        _Color("Color", Color) = (1, 1, 1, 1)
        _ShadowColor("Shadow Color", Color) = (0, 0, 0, 1)
        _ShadowSmoothness("Shadow Smoothness", Range(0, 2)) = 1
        _DiffuseThreshold("Diffuse Threshold", Range(-1, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normalWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _Color;
            float4 _ShadowColor;
            float _ShadowSmoothness;
            float _DiffuseThreshold;
            
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _Color;
                Light light = GetMainLight();
                float nDotL = smoothstep(_DiffuseThreshold, _DiffuseThreshold + _ShadowSmoothness, dot(i.normalWS, light.direction));
                return lerp(_ShadowColor, _Color, nDotL);
            }
            ENDHLSL
        }
    }
}