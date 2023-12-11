Shader "Custom/BlockerOutline"
{
    Properties
    {
        _MainTex ("Albedo Texture", 2D) = "white" {}
        [Enum(UnityEngine.Rendering.BlendMode)][Header(Blend)]_BlendSrc("Blend Src", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest", Float) = 4
    }
    SubShader
    {
        Tags {"RenderType"="Opaque" }
        LOD 0
        Pass
        {
            
            ZWrite On
            ZTest [_ZTest]
            Blend [_BlendSrc] [_BlendDst]
            Cull back
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            TEXTURE2D(_MainTex);  SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 normalWS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varying
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            };

            Varying vert(Attributes input)
            {
                Varying output = (Varying)0;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normalWS = input.normalWS;
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.uv = input.uv;
                return output;
            }
            half4 frag(Varying input) : SV_Target
            {
                half4 finalColor = 0;
                float3 sceneToView = _WorldSpaceCameraPos - input.positionWS;
                float anger = dot(sceneToView, input.normalWS) / (length(sceneToView) * length(input.normalWS));
                finalColor.xyz = 1 - anger;
                finalColor.a = 1;
                return finalColor;
            }
            ENDHLSL
        }
    }
}
