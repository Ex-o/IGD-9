Shader "Custom/Lambert Shader"
{
	 Properties
    {
        [MainTexture]
        _BaseMap("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _SpecularPower("Specular Power", float) = 1
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
                float3 positionWS : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _Color;
            float _SpecularPower;

            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.positionWS = TransformObjectToWorld(v.vertex.xyz);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _Color;
                Light light = GetMainLight();
                i.normalWS = normalize(i.normalWS);
                float nDotL = dot(i.normalWS, light.direction);
                float3 dir = normalize(GetWorldSpaceViewDir(i.positionWS));;
                float3 h = normalize(light.direction + dir);
                float nDotH = dot(i.normalWS, h);
                float specularity = pow(saturate(nDotH), _SpecularPower);
                float3 specular = specularity * light.color;
                return saturate(nDotL * albedo * float4(light.color, 1) + float4(specular, 1));
            }
            ENDHLSL
        }
    }
}