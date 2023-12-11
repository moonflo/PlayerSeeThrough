Shader "Custom/BlockerDither"
{
    Properties
    {
        _MainTex ("Albedo Texture", 2D) = "white" {}
        _RowAccess1("Dither Matrix 1", Vector) = (1, 0, 0, 0)
        _RowAccess2("Dither Matrix 2", Vector) = (0, 1, 0, 0)
        _RowAccess3("Dither Matrix 3", Vector) = (0, 0, 1, 0)
        
//        [HiddenInInspector]_TargetSeeThrough ("TargetSeeThroughPosition", Vector) = (0, 0, 0)
        
        [Toggle(_ENABLEBLOCKDITHER_ON)] _EnableBlockDither("Enable Block Dither", Float) = 0
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
            #pragma multi_compile_local __ _ENABLEBLOCKDITHER_ON
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            TEXTURE2D(_MainTex);  SAMPLER(sampler_MainTex);
            TEXTURE2D(_DissolveTex);  SAMPLER(sampler_DissolveTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _TargetSeeThrough;
            float4 _RowAccess1;
            float4 _RowAccess2;
            float4 _RowAccess3;
            
            float _TargetSeeThroughRadius;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct Varying
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 positionSS : TEXCOORD1;
            };

            Varying vert(Attributes input)
            {
                Varying output = (Varying)0;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionSS = ComputeScreenPos(output.positionCS);
                // ComputeScreenPos()
                // output.positionSS.y *= _ProjectionParams.x;
                output.uv = input.uv;
                return output;
            }
            half4 frag(Varying input) : SV_Target
            {
                half4 finalColor = 0;
                
                #ifdef _ENABLEBLOCKDITHER_ON
                float4x4 rawAccess = {_RowAccess1, _RowAccess2, _RowAccess3, float4(0, 0, 0, 1)};
                float2 pixelAlignSceneSpacePos = (input.positionSS.xy / input.positionSS.w) * _ScreenParams;
                // float2 pixelAlignSceneSpacePos = input.positionCS.xy;
                
                clip(0.9 - rawAccess[floor(fmod(pixelAlignSceneSpacePos.x, 4))][floor(fmod(pixelAlignSceneSpacePos.y, 4))]);
                #endif
                finalColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy);
                finalColor.a = 1;
                return finalColor;
            }
            ENDHLSL
        }
    }
}
