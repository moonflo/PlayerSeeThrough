Shader "Custom/BlockerDissolve"
{
    Properties
    {
        _MainTex ("Albedo Texture", 2D) = "white" {}
        _DissolveTex("Dissolve Texture", 2D) = "white" {}
//        [HiddenInInspector]_TargetSeeThrough ("TargetSeeThroughPosition", Vector) = (0, 0, 0)
        
        [Tooltips(Radius that relatived with How big your player are)]
        _TargetSeeThroughRadius("TargetSeeThroughRadius", Float) = 1 
        
        [Toggle(_ENABLEBLOCKDISSOLVE_ON)] _EnableBlockDissolve("Enable Block Dissolve", Float) = 0
        
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
            #pragma multi_compile_local __ _ENABLEBLOCKDISSOLVE_ON
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            TEXTURE2D(_MainTex);  SAMPLER(sampler_MainTex);
            TEXTURE2D(_DissolveTex);  SAMPLER(sampler_DissolveTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _DissolveTex_ST;
            float4 _TargetSeeThrough;
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
                float3 positionVS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            Varying vert(Attributes input)
            {
                Varying output = (Varying)0;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.uv = input.uv;
                return output;
            }

            half4 frag(Varying input) : SV_Target
            {
                half4 finalColor = 0;
                float transparentFactor = 1;

                #ifdef _ENABLEBLOCKDISSOLVE_ON
                const float3 viewToFragment = input.positionWS - _WorldSpaceCameraPos;
                const float3 viewToSeeThrough = _TargetSeeThrough - _WorldSpaceCameraPos;
                if(length(viewToSeeThrough) > length(viewToFragment))
                {
                    // Fragment is closer, it Block our Player!
                    const float3 viewToBlockFragment =
                        dot(viewToFragment, viewToSeeThrough) / length(viewToSeeThrough) * normalize(viewToSeeThrough);
                    float blockIntensity = length(viewToFragment - viewToBlockFragment);

                    float2 uvDissolve = TRANSFORM_TEX(input.uv.xy, _DissolveTex);
                    half dissolveValue = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, uvDissolve).r;

                    // dissolveValue + l/r - 1/2 = dissolveFactor, it should bigger than 1/2 or will dissolve
                    transparentFactor = saturate(dissolveValue - 0.5 + blockIntensity / _TargetSeeThroughRadius);
                }
                #endif
                half4 mainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy);
                
                half alpha = mainColor.a;
                alpha = alpha * transparentFactor - 0.5;
                if(alpha < 0)
                {
                    discard;
                }
                
                finalColor.rgb = mainColor.xyz;
                finalColor.a = 1;
                return finalColor;
            }
            ENDHLSL
        }
    }
}
