Shader "S_Water"
{
    Properties
    {
        _ReflectionSize("ReflectionSize", Float) = 1
        _Flowspeed1("Flowspeed1", Range(0, 5)) = 2
        _Flowspeed2("Flowspeed2", Range(0, 5)) = 2
        _FoamDist("FoamDist", Float) = 1
        _Foamspeed("Foamspeed", Range(-1, 3)) = 1
        _FoamGrainSize("FoamGrainSize", Float) = 30
        _WaterColor("WaterColor", Color) = (0.5235849, 0.9642166, 1, 0)
        _WaterSaturation("WaterSaturation", Range(0, 2)) = 1
        _WaterBrightness("WaterBrightness", Range(0, 2)) = 0.5
        _WaterOpacity("WaterOpacity", Range(0, 1)) = 0.5
        _WavesFrequency("WavesFrequency", Float) = 6
        _WavesIntensity("WavesIntensity", Float) = 1
        _HighlightWavesIntentisy("HighlightWavesIntentisy", Range(0, 1)) = 0
        _ScaleAll("ScaleAll", Float) = 1
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
        SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            "RenderType" = "Transparent"
            "BuiltInMaterialType" = "Lit"
            "Queue" = "Transparent"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "BuiltInLitSubTarget"
            "ForceNoShadowCasting" = "True"
        }
        Pass
        {
            Name "BuiltIn Forward"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdbase
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyzw = input.texCoord0;
            output.interp4.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz = input.sh;
            #endif
            output.interp7.xyzw = input.fogFactorAndVertexLight;
            output.interp8.xyzw = input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Flowspeed1;
        float _WaterOpacity;
        float _ReflectionSize;
        float _FoamDist;
        float4 _WaterColor;
        float _WaterSaturation;
        float _WaterBrightness;
        float _Flowspeed2;
        float _Foamspeed;
        float _FoamGrainSize;
        float _WavesFrequency;
        float _WavesIntensity;
        float _HighlightWavesIntentisy;
        float _ScaleAll;
        CBUFFER_END

            // Object and Global properties

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Includes
        // GraphIncludes: <None>

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if (d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Preview_float(float In, out float Out)
        {
            Out = In;
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Preview_float3(float3 In, out float3 Out)
        {
            Out = In;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float4 result2 = 2.0 * Base * Blend;
            float4 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
        {
            float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
            Out = luma.xxx + Saturation.xxx * (In - luma.xxx);
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
        {
            float2 delta = UV - Center;
            float angle = Strength * length(delta);
            float x = cos(angle) * delta.x - sin(angle) * delta.y;
            float y = sin(angle) * delta.x + cos(angle) * delta.y;
            Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Preview_float4(float4 In, out float4 Out)
        {
            Out = In;
        }

        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0 = _ScaleAll;
            float2 _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0 = float2(_Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0, _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0);
            float _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2);
            float2 _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0, (_Multiply_07528d03b0694f3192da7136a24c7ede_Out_2.xx), _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3);
            float _Property_a7ead8b7711341789beccb0469347376_Out_0 = _WavesFrequency;
            float _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3, _Property_a7ead8b7711341789beccb0469347376_Out_0, _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2);
            float _Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0 = _WavesIntensity;
            float _Multiply_061b9cf479f9430f8304394a06651e05_Out_2;
            Unity_Multiply_float_float(_Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0, 0.1, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
            float2 _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0 = float2(0, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
            float _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3;
            Unity_Remap_float(_GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2, float2 (0, 1), _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0, _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3);
            float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
            float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
            float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
            float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
            float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
            float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
            float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
            float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
            Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
            float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
            Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
            float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
            Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
            float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
            float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
            Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
            float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
            float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
            float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
            Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
            float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
            float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
            float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
            Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
            float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
            float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
            float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
            float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
            Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
            float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
            Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
            float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
            float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
            float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
            Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
            float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
            Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
            float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
            float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
            Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
            float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
            float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
            Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
            float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
            Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
            float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
            float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
            float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
            float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
            Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
            float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
            Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
            float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
            Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
            float _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1;
            Unity_Preview_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1);
            float _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0 = _HighlightWavesIntentisy;
            float _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3;
            Unity_Lerp_float(_Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1, _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0, _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3);
            float3 _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3.xxx), _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2);
            float3 _Add_dcb4d072333f430884ac2187cb03b851_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2, _Add_dcb4d072333f430884ac2187cb03b851_Out_2);
            float3 _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
            Unity_Preview_float3(_Add_dcb4d072333f430884ac2187cb03b851_Out_2, _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1);
            description.Position = _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 Color_c906eb65ab7a48859fe6e622ccfd9407 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
            float4 _Property_e06bf2151463465d888ff777d73f9b2c_Out_0 = _WaterColor;
            float4 Color_675a8e94075a4b6cbc38600b371d0430 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
            float _Property_1ddd793de35b42559e4ee175da0a8aee_Out_0 = _WaterBrightness;
            float4 _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3;
            Unity_Lerp_float4(_Property_e06bf2151463465d888ff777d73f9b2c_Out_0, Color_675a8e94075a4b6cbc38600b371d0430, (_Property_1ddd793de35b42559e4ee175da0a8aee_Out_0.xxxx), _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3);
            float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
            float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
            float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
            float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
            float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
            float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
            float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
            float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
            Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
            float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
            Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
            float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
            Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
            float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
            float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
            Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
            float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
            float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
            float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
            Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
            float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
            float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
            float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
            Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
            float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
            float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
            float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
            float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
            Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
            float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
            Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
            float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
            float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
            float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
            Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
            float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
            Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
            float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
            float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
            Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
            float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
            float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
            Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
            float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
            Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
            float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
            float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
            float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
            float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
            Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
            float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
            Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
            float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
            Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
            float _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3;
            Unity_Clamp_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, 0.09, 0.64, _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3);
            float4 _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2;
            Unity_Blend_Overlay_float4(_Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3, (_Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3.xxxx), _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2, 1);
            float _Property_a5f984dd09df4e9db5c03281dbe348b7_Out_0 = _WaterSaturation;
            float3 _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2;
            Unity_Saturation_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2.xyz), _Property_a5f984dd09df4e9db5c03281dbe348b7_Out_0, _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2);
            float4 _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float4 _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2;
            Unity_Add_float4(float4(0, 0, 0, 0), _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0, _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2);
            float _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1;
            Unity_SceneDepth_Eye_float(_Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2, _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1);
            float4 _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0 = IN.ScreenPosition;
            float _Split_60712163e709416ab973ae1098153d0b_R_1 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[0];
            float _Split_60712163e709416ab973ae1098153d0b_G_2 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[1];
            float _Split_60712163e709416ab973ae1098153d0b_B_3 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[2];
            float _Split_60712163e709416ab973ae1098153d0b_A_4 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[3];
            float _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2;
            Unity_Subtract_float(_SceneDepth_1db86451195940499820af4d9f81f51a_Out_1, _Split_60712163e709416ab973ae1098153d0b_A_4, _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2);
            float _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0 = _FoamDist;
            float _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2;
            Unity_Divide_float(_Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2, _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0, _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2);
            float _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1;
            Unity_Saturate_float(_Divide_0ad9107ae77e4ab0a52099430319a368_Out_2, _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1);
            float _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2);
            float _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1;
            Unity_Sine_float(_Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2, _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1);
            float _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2;
            Unity_Multiply_float_float(_Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1, 2, _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2);
            float2 _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4;
            Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0.59), _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2, float2 (0, 0), _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4);
            float _Property_7c2bb84d3f254093bc157a6f9326384e_Out_0 = _ScaleAll;
            float _Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0 = _Foamspeed;
            float _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2;
            Unity_Multiply_float_float(_Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0, 0.02, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2);
            float _Multiply_602038ad40634891891adf354011cff7_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2, _Multiply_602038ad40634891891adf354011cff7_Out_2);
            float2 _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3;
            Unity_TilingAndOffset_float(_Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4, (_Property_7c2bb84d3f254093bc157a6f9326384e_Out_0.xx), (_Multiply_602038ad40634891891adf354011cff7_Out_2.xx), _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3);
            float _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0 = _FoamGrainSize;
            float _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3, _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2);
            float _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3;
            Unity_Lerp_float(_Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2, 0.45, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3);
            float _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2;
            Unity_Step_float(0.5, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3, _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2);
            float _Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1;
            Unity_Preview_float(_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2, _Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1);
            float3 _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3;
            Unity_Lerp_float3((Color_c906eb65ab7a48859fe6e622ccfd9407.xyz), _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2, (_Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1.xxx), _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3);
            float _Remap_e1cf40a760a747a399255773e6323b2d_Out_3;
            Unity_Remap_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, float2 (0.09, 1.45), float2 (-0.11, 0.99), _Remap_e1cf40a760a747a399255773e6323b2d_Out_3);
            float4 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4;
            float3 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5;
            float2 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6;
            Unity_Combine_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, _Remap_e1cf40a760a747a399255773e6323b2d_Out_3, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6);
            float4 _Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1;
            Unity_Preview_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1);
            float _Property_c8a4e036104c4d60bd1416088f02ab81_Out_0 = _WaterOpacity;
            float4 _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2;
            Unity_Add_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, (_Property_c8a4e036104c4d60bd1416088f02ab81_Out_0.xxxx), _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2);
            float4 _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2;
            Unity_Divide_float4(_Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2, (_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2.xxxx), _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2);
            float4 _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1;
            Unity_Preview_float4(_Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2, _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1);
            surface.BaseColor = _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = (_Preview_28df349a152f4d13aea4acdb5949ca87_Out_1).x;
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal = input.normalOS;
            output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent = input.tangentOS.xyz;
            output.ObjectSpacePosition = input.positionOS;
            output.uv0 = input.uv0;
            output.TimeParameters = _TimeParameters.xyz;

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex = float4(attributes.positionOS, 1);
            result.tangent = attributes.tangentOS;
            result.normal = attributes.normalOS;
            result.texcoord = attributes.uv0;
            result.texcoord1 = attributes.uv1;
            result.vertex = float4(vertexDescription.Position, 1);
            result.normal = vertexDescription.Normal;
            result.tangent = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }

        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf

            result._ShadowCoord = varyings.shadowCoord;

            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif

            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }

        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;

            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif

            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn ForwardAdd"
            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            // Render State
            Blend SrcAlpha One
            ZWrite Off
            ColorMask RGB

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma multi_compile_fwdadd_fullshadows
            #pragma vertex vert
            #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD_ADD
            #define BUILTIN_TARGET_API 1
            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
            #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
            #endif
            #ifdef _BUILTIN_ALPHATEST_ON
            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
            #endif
            #ifdef _BUILTIN_AlphaClip
            #define _AlphaClip _BUILTIN_AlphaClip
            #endif
            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
            #endif


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                 float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 tangentWS;
                 float4 texCoord0;
                 float3 viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                 float2 lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                 float3 sh;
                #endif
                 float4 fogFactorAndVertexLight;
                 float4 shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float3 TangentSpaceNormal;
                 float3 WorldSpacePosition;
                 float4 ScreenPosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float3 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                 float4 interp3 : INTERP3;
                 float3 interp4 : INTERP4;
                 float2 interp5 : INTERP5;
                 float3 interp6 : INTERP6;
                 float4 interp7 : INTERP7;
                 float4 interp8 : INTERP8;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz = input.positionWS;
                output.interp1.xyz = input.normalWS;
                output.interp2.xyzw = input.tangentWS;
                output.interp3.xyzw = input.texCoord0;
                output.interp4.xyz = input.viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                output.interp5.xy = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp6.xyz = input.sh;
                #endif
                output.interp7.xyzw = input.fogFactorAndVertexLight;
                output.interp8.xyzw = input.shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.tangentWS = input.interp2.xyzw;
                output.texCoord0 = input.interp3.xyzw;
                output.viewDirectionWS = input.interp4.xyz;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.interp5.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp6.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp7.xyzw;
                output.shadowCoord = input.interp8.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }


            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float _Flowspeed1;
            float _WaterOpacity;
            float _ReflectionSize;
            float _FoamDist;
            float4 _WaterColor;
            float _WaterSaturation;
            float _WaterBrightness;
            float _Flowspeed2;
            float _Foamspeed;
            float _FoamGrainSize;
            float _WavesFrequency;
            float _WavesIntensity;
            float _HighlightWavesIntentisy;
            float _ScaleAll;
            CBUFFER_END

                // Object and Global properties

                // -- Property used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Includes
            // GraphIncludes: <None>

            // Graph Functions

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }


            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                // need full precision, otherwise half overflows when p > 1
                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            {
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }

            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_Sine_float(float In, out float Out)
            {
                Out = sin(In);
            }

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }


            inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                UV = frac(sin(mul(UV, m)));
                return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
            }

            void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float t = 8.0;
                float3 res = float3(8.0, 0.0, 0.0);

                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 lattice = float2(x,y);
                        float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);

                        if (d < res.x)
                        {
                            res = float3(d, offset.x, offset.y);
                            Out = res.x;
                            Cells = res.y;
                        }
                    }
                }
            }

            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }

            void Unity_Preview_float(float In, out float Out)
            {
                Out = In;
            }

            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }

            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }

            void Unity_Preview_float3(float3 In, out float3 Out)
            {
                Out = In;
            }

            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
            {
                Out = clamp(In, Min, Max);
            }

            void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
            {
                float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                float4 result2 = 2.0 * Base * Blend;
                float4 zeroOrOne = step(Base, 0.5);
                Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                Out = lerp(Base, Out, Opacity);
            }

            void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
            {
                float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
                Out = luma.xxx + Saturation.xxx * (In - luma.xxx);
            }

            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                if (unity_OrthoParams.w == 1.0)
                {
                    Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                }
                else
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
            }

            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }

            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }

            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }

            void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
            {
                float2 delta = UV - Center;
                float angle = Strength * length(delta);
                float x = cos(angle) * delta.x - sin(angle) * delta.y;
                float y = sin(angle) * delta.x + cos(angle) * delta.y;
                Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
            }

            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }

            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_Preview_float4(float4 In, out float4 Out)
            {
                Out = In;
            }

            void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A / B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0 = _ScaleAll;
                float2 _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0 = float2(_Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0, _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0);
                float _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2);
                float2 _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0, (_Multiply_07528d03b0694f3192da7136a24c7ede_Out_2.xx), _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3);
                float _Property_a7ead8b7711341789beccb0469347376_Out_0 = _WavesFrequency;
                float _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3, _Property_a7ead8b7711341789beccb0469347376_Out_0, _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2);
                float _Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0 = _WavesIntensity;
                float _Multiply_061b9cf479f9430f8304394a06651e05_Out_2;
                Unity_Multiply_float_float(_Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0, 0.1, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                float2 _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0 = float2(0, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                float _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3;
                Unity_Remap_float(_GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2, float2 (0, 1), _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0, _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3);
                float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                float _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1;
                Unity_Preview_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1);
                float _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0 = _HighlightWavesIntentisy;
                float _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3;
                Unity_Lerp_float(_Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1, _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0, _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3);
                float3 _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2;
                Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3.xxx), _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2);
                float3 _Add_dcb4d072333f430884ac2187cb03b851_Out_2;
                Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2, _Add_dcb4d072333f430884ac2187cb03b851_Out_2);
                float3 _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                Unity_Preview_float3(_Add_dcb4d072333f430884ac2187cb03b851_Out_2, _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1);
                description.Position = _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 Color_c906eb65ab7a48859fe6e622ccfd9407 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                float4 _Property_e06bf2151463465d888ff777d73f9b2c_Out_0 = _WaterColor;
                float4 Color_675a8e94075a4b6cbc38600b371d0430 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                float _Property_1ddd793de35b42559e4ee175da0a8aee_Out_0 = _WaterBrightness;
                float4 _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3;
                Unity_Lerp_float4(_Property_e06bf2151463465d888ff777d73f9b2c_Out_0, Color_675a8e94075a4b6cbc38600b371d0430, (_Property_1ddd793de35b42559e4ee175da0a8aee_Out_0.xxxx), _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3);
                float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                float _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3;
                Unity_Clamp_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, 0.09, 0.64, _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3);
                float4 _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2;
                Unity_Blend_Overlay_float4(_Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3, (_Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3.xxxx), _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2, 1);
                float _Property_a5f984dd09df4e9db5c03281dbe348b7_Out_0 = _WaterSaturation;
                float3 _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2;
                Unity_Saturation_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2.xyz), _Property_a5f984dd09df4e9db5c03281dbe348b7_Out_0, _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2);
                float4 _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float4 _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2;
                Unity_Add_float4(float4(0, 0, 0, 0), _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0, _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2);
                float _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1;
                Unity_SceneDepth_Eye_float(_Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2, _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1);
                float4 _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0 = IN.ScreenPosition;
                float _Split_60712163e709416ab973ae1098153d0b_R_1 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[0];
                float _Split_60712163e709416ab973ae1098153d0b_G_2 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[1];
                float _Split_60712163e709416ab973ae1098153d0b_B_3 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[2];
                float _Split_60712163e709416ab973ae1098153d0b_A_4 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[3];
                float _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2;
                Unity_Subtract_float(_SceneDepth_1db86451195940499820af4d9f81f51a_Out_1, _Split_60712163e709416ab973ae1098153d0b_A_4, _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2);
                float _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0 = _FoamDist;
                float _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2;
                Unity_Divide_float(_Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2, _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0, _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2);
                float _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1;
                Unity_Saturate_float(_Divide_0ad9107ae77e4ab0a52099430319a368_Out_2, _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1);
                float _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2);
                float _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1;
                Unity_Sine_float(_Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2, _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1);
                float _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2;
                Unity_Multiply_float_float(_Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1, 2, _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2);
                float2 _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4;
                Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0.59), _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2, float2 (0, 0), _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4);
                float _Property_7c2bb84d3f254093bc157a6f9326384e_Out_0 = _ScaleAll;
                float _Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0 = _Foamspeed;
                float _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2;
                Unity_Multiply_float_float(_Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0, 0.02, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2);
                float _Multiply_602038ad40634891891adf354011cff7_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2, _Multiply_602038ad40634891891adf354011cff7_Out_2);
                float2 _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3;
                Unity_TilingAndOffset_float(_Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4, (_Property_7c2bb84d3f254093bc157a6f9326384e_Out_0.xx), (_Multiply_602038ad40634891891adf354011cff7_Out_2.xx), _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3);
                float _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0 = _FoamGrainSize;
                float _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3, _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2);
                float _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3;
                Unity_Lerp_float(_Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2, 0.45, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3);
                float _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2;
                Unity_Step_float(0.5, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3, _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2);
                float _Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1;
                Unity_Preview_float(_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2, _Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1);
                float3 _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3;
                Unity_Lerp_float3((Color_c906eb65ab7a48859fe6e622ccfd9407.xyz), _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2, (_Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1.xxx), _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3);
                float _Remap_e1cf40a760a747a399255773e6323b2d_Out_3;
                Unity_Remap_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, float2 (0.09, 1.45), float2 (-0.11, 0.99), _Remap_e1cf40a760a747a399255773e6323b2d_Out_3);
                float4 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4;
                float3 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5;
                float2 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6;
                Unity_Combine_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, _Remap_e1cf40a760a747a399255773e6323b2d_Out_3, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6);
                float4 _Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1;
                Unity_Preview_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1);
                float _Property_c8a4e036104c4d60bd1416088f02ab81_Out_0 = _WaterOpacity;
                float4 _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2;
                Unity_Add_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, (_Property_c8a4e036104c4d60bd1416088f02ab81_Out_0.xxxx), _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2);
                float4 _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2;
                Unity_Divide_float4(_Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2, (_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2.xxxx), _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2);
                float4 _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1;
                Unity_Preview_float4(_Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2, _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1);
                surface.BaseColor = _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3;
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = (_Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1.xyz);
                surface.Metallic = 0;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.Alpha = (_Preview_28df349a152f4d13aea4acdb5949ca87_Out_1).x;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                output.uv0 = input.uv0;
                output.TimeParameters = _TimeParameters.xyz;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                output.uv0 = input.texCoord0;
                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
            {
                result.vertex = float4(attributes.positionOS, 1);
                result.tangent = attributes.tangentOS;
                result.normal = attributes.normalOS;
                result.texcoord = attributes.uv0;
                result.texcoord1 = attributes.uv1;
                result.vertex = float4(vertexDescription.Position, 1);
                result.normal = vertexDescription.Normal;
                result.tangent = float4(vertexDescription.Tangent, 0);
                #if UNITY_ANY_INSTANCING_ENABLED
                #endif
            }

            void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
            {
                result.pos = varyings.positionCS;
                result.worldPos = varyings.positionWS;
                result.worldNormal = varyings.normalWS;
                result.viewDir = varyings.viewDirectionWS;
                // World Tangent isn't an available input on v2f_surf

                result._ShadowCoord = varyings.shadowCoord;

                #if UNITY_ANY_INSTANCING_ENABLED
                #endif
                #if !defined(LIGHTMAP_ON)
                #if UNITY_SHOULD_SAMPLE_SH
                result.sh = varyings.sh;
                #endif
                #endif
                #if defined(LIGHTMAP_ON)
                result.lmap.xy = varyings.lightmapUV;
                #endif
                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                    result.fogCoord = varyings.fogFactorAndVertexLight.x;
                    COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                #endif

                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
            }

            void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
            {
                result.positionCS = surfVertex.pos;
                result.positionWS = surfVertex.worldPos;
                result.normalWS = surfVertex.worldNormal;
                // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                // World Tangent isn't an available input on v2f_surf
                result.shadowCoord = surfVertex._ShadowCoord;

                #if UNITY_ANY_INSTANCING_ENABLED
                #endif
                #if !defined(LIGHTMAP_ON)
                #if UNITY_SHOULD_SAMPLE_SH
                result.sh = surfVertex.sh;
                #endif
                #endif
                #if defined(LIGHTMAP_ON)
                result.lightmapUV = surfVertex.lmap.xy;
                #endif
                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                    result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                    COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                #endif

                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"

            ENDHLSL
            }
            Pass
            {
                Name "BuiltIn Deferred"
                Tags
                {
                    "LightMode" = "Deferred"
                }

                // Render State
                Cull Back
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
                ColorMask RGB

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma multi_compile_instancing
                #pragma exclude_renderers nomrt
                #pragma multi_compile_prepassfinal
                #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                // GraphKeywords: <None>

                // Defines
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEFERRED
                #define BUILTIN_TARGET_API 1
                #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                #endif
                #ifdef _BUILTIN_ALPHATEST_ON
                #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                #endif
                #ifdef _BUILTIN_AlphaClip
                #define _AlphaClip _BUILTIN_AlphaClip
                #endif
                #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                #endif


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                     float4 shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float3 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float3 interp6 : INTERP6;
                     float4 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyzw = input.texCoord0;
                    output.interp4.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy = input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz = input.sh;
                    #endif
                    output.interp7.xyzw = input.fogFactorAndVertexLight;
                    output.interp8.xyzw = input.shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    output.shadowCoord = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _Flowspeed1;
                float _WaterOpacity;
                float _ReflectionSize;
                float _FoamDist;
                float4 _WaterColor;
                float _WaterSaturation;
                float _WaterBrightness;
                float _Flowspeed2;
                float _Foamspeed;
                float _FoamGrainSize;
                float _WavesFrequency;
                float _WavesIntensity;
                float _HighlightWavesIntentisy;
                float _ScaleAll;
                CBUFFER_END

                    // Object and Global properties

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                // -- Properties used by SceneSelectionPass
                #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
                #endif

                // Graph Includes
                // GraphIncludes: <None>

                // Graph Functions

                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }

                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }


                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }

                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }

                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }

                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }

                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }

                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }

                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }


                inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
                {
                    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                    UV = frac(sin(mul(UV, m)));
                    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
                }

                void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                {
                    float2 g = floor(UV * CellDensity);
                    float2 f = frac(UV * CellDensity);
                    float t = 8.0;
                    float3 res = float3(8.0, 0.0, 0.0);

                    for (int y = -1; y <= 1; y++)
                    {
                        for (int x = -1; x <= 1; x++)
                        {
                            float2 lattice = float2(x,y);
                            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                            float d = distance(lattice + offset, f);

                            if (d < res.x)
                            {
                                res = float3(d, offset.x, offset.y);
                                Out = res.x;
                                Cells = res.y;
                            }
                        }
                    }
                }

                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }

                void Unity_Preview_float(float In, out float Out)
                {
                    Out = In;
                }

                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }

                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }

                void Unity_Preview_float3(float3 In, out float3 Out)
                {
                    Out = In;
                }

                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }

                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }

                void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                {
                    float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                    float4 result2 = 2.0 * Base * Blend;
                    float4 zeroOrOne = step(Base, 0.5);
                    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                    Out = lerp(Base, Out, Opacity);
                }

                void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
                {
                    float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
                    Out = luma.xxx + Saturation.xxx * (In - luma.xxx);
                }

                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }

                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }

                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }

                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }

                void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float angle = Strength * length(delta);
                    float x = cos(angle) * delta.x - sin(angle) * delta.y;
                    float y = sin(angle) * delta.x + cos(angle) * delta.y;
                    Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
                }

                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }

                void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
                {
                    Out = lerp(A, B, T);
                }

                void Unity_Preview_float4(float4 In, out float4 Out)
                {
                    Out = In;
                }

                void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A / B;
                }

                // Custom interpolators pre vertex
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };

                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0 = _ScaleAll;
                    float2 _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0 = float2(_Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0, _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0);
                    float _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2);
                    float2 _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0, (_Multiply_07528d03b0694f3192da7136a24c7ede_Out_2.xx), _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3);
                    float _Property_a7ead8b7711341789beccb0469347376_Out_0 = _WavesFrequency;
                    float _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3, _Property_a7ead8b7711341789beccb0469347376_Out_0, _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2);
                    float _Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0 = _WavesIntensity;
                    float _Multiply_061b9cf479f9430f8304394a06651e05_Out_2;
                    Unity_Multiply_float_float(_Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0, 0.1, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                    float2 _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0 = float2(0, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                    float _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3;
                    Unity_Remap_float(_GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2, float2 (0, 1), _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0, _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3);
                    float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                    float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                    float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                    float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                    float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                    float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                    float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                    float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                    float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                    Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                    float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                    Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                    float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                    float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                    Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                    float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                    float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                    float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                    Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                    float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                    float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                    float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                    Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                    float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                    float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                    float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                    float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                    Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                    float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                    Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                    float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                    float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                    float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                    Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                    float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                    Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                    float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                    float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                    Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                    float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                    float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                    Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                    float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                    Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                    float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                    float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                    float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                    float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                    Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                    float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                    Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                    float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                    Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                    float _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1;
                    Unity_Preview_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1);
                    float _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0 = _HighlightWavesIntentisy;
                    float _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3;
                    Unity_Lerp_float(_Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1, _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0, _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3);
                    float3 _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3.xxx), _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2);
                    float3 _Add_dcb4d072333f430884ac2187cb03b851_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2, _Add_dcb4d072333f430884ac2187cb03b851_Out_2);
                    float3 _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                    Unity_Preview_float3(_Add_dcb4d072333f430884ac2187cb03b851_Out_2, _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1);
                    description.Position = _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }

                // Custom interpolators, pre surface
                #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                #endif

                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };

                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 Color_c906eb65ab7a48859fe6e622ccfd9407 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                    float4 _Property_e06bf2151463465d888ff777d73f9b2c_Out_0 = _WaterColor;
                    float4 Color_675a8e94075a4b6cbc38600b371d0430 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                    float _Property_1ddd793de35b42559e4ee175da0a8aee_Out_0 = _WaterBrightness;
                    float4 _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3;
                    Unity_Lerp_float4(_Property_e06bf2151463465d888ff777d73f9b2c_Out_0, Color_675a8e94075a4b6cbc38600b371d0430, (_Property_1ddd793de35b42559e4ee175da0a8aee_Out_0.xxxx), _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3);
                    float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                    float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                    float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                    float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                    float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                    float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                    float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                    float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                    float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                    Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                    float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                    Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                    float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                    float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                    Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                    float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                    float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                    float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                    Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                    float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                    float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                    float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                    Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                    float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                    float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                    float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                    float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                    Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                    float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                    Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                    float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                    float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                    float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                    Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                    float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                    Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                    float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                    float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                    Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                    float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                    float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                    Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                    float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                    Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                    float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                    float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                    float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                    float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                    Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                    float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                    Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                    float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                    Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                    float _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3;
                    Unity_Clamp_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, 0.09, 0.64, _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3);
                    float4 _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2;
                    Unity_Blend_Overlay_float4(_Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3, (_Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3.xxxx), _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2, 1);
                    float _Property_a5f984dd09df4e9db5c03281dbe348b7_Out_0 = _WaterSaturation;
                    float3 _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2;
                    Unity_Saturation_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2.xyz), _Property_a5f984dd09df4e9db5c03281dbe348b7_Out_0, _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2);
                    float4 _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                    float4 _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2;
                    Unity_Add_float4(float4(0, 0, 0, 0), _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0, _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2);
                    float _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1;
                    Unity_SceneDepth_Eye_float(_Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2, _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1);
                    float4 _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0 = IN.ScreenPosition;
                    float _Split_60712163e709416ab973ae1098153d0b_R_1 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[0];
                    float _Split_60712163e709416ab973ae1098153d0b_G_2 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[1];
                    float _Split_60712163e709416ab973ae1098153d0b_B_3 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[2];
                    float _Split_60712163e709416ab973ae1098153d0b_A_4 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[3];
                    float _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2;
                    Unity_Subtract_float(_SceneDepth_1db86451195940499820af4d9f81f51a_Out_1, _Split_60712163e709416ab973ae1098153d0b_A_4, _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2);
                    float _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0 = _FoamDist;
                    float _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2;
                    Unity_Divide_float(_Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2, _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0, _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2);
                    float _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1;
                    Unity_Saturate_float(_Divide_0ad9107ae77e4ab0a52099430319a368_Out_2, _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1);
                    float _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2);
                    float _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1;
                    Unity_Sine_float(_Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2, _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1);
                    float _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2;
                    Unity_Multiply_float_float(_Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1, 2, _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2);
                    float2 _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4;
                    Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0.59), _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2, float2 (0, 0), _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4);
                    float _Property_7c2bb84d3f254093bc157a6f9326384e_Out_0 = _ScaleAll;
                    float _Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0 = _Foamspeed;
                    float _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2;
                    Unity_Multiply_float_float(_Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0, 0.02, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2);
                    float _Multiply_602038ad40634891891adf354011cff7_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2, _Multiply_602038ad40634891891adf354011cff7_Out_2);
                    float2 _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3;
                    Unity_TilingAndOffset_float(_Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4, (_Property_7c2bb84d3f254093bc157a6f9326384e_Out_0.xx), (_Multiply_602038ad40634891891adf354011cff7_Out_2.xx), _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3);
                    float _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0 = _FoamGrainSize;
                    float _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3, _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2);
                    float _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3;
                    Unity_Lerp_float(_Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2, 0.45, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3);
                    float _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2;
                    Unity_Step_float(0.5, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3, _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2);
                    float _Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1;
                    Unity_Preview_float(_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2, _Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1);
                    float3 _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3;
                    Unity_Lerp_float3((Color_c906eb65ab7a48859fe6e622ccfd9407.xyz), _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2, (_Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1.xxx), _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3);
                    float _Remap_e1cf40a760a747a399255773e6323b2d_Out_3;
                    Unity_Remap_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, float2 (0.09, 1.45), float2 (-0.11, 0.99), _Remap_e1cf40a760a747a399255773e6323b2d_Out_3);
                    float4 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4;
                    float3 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5;
                    float2 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6;
                    Unity_Combine_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, _Remap_e1cf40a760a747a399255773e6323b2d_Out_3, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6);
                    float4 _Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1;
                    Unity_Preview_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1);
                    float _Property_c8a4e036104c4d60bd1416088f02ab81_Out_0 = _WaterOpacity;
                    float4 _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2;
                    Unity_Add_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, (_Property_c8a4e036104c4d60bd1416088f02ab81_Out_0.xxxx), _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2);
                    float4 _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2;
                    Unity_Divide_float4(_Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2, (_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2.xxxx), _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2);
                    float4 _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1;
                    Unity_Preview_float4(_Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2, _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1);
                    surface.BaseColor = _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3;
                    surface.NormalTS = IN.TangentSpaceNormal;
                    surface.Emission = (_Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1.xyz);
                    surface.Metallic = 0;
                    surface.Smoothness = 0.5;
                    surface.Occlusion = 1;
                    surface.Alpha = (_Preview_28df349a152f4d13aea4acdb5949ca87_Out_1).x;
                    return surface;
                }

                // --------------------------------------------------
                // Build Graph Inputs

                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                    output.ObjectSpaceNormal = input.normalOS;
                    output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                    output.ObjectSpacePosition = input.positionOS;
                    output.uv0 = input.uv0;
                    output.TimeParameters = _TimeParameters.xyz;

                    return output;
                }
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 = input.texCoord0;
                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                        return output;
                }

                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                {
                    result.vertex = float4(attributes.positionOS, 1);
                    result.tangent = attributes.tangentOS;
                    result.normal = attributes.normalOS;
                    result.texcoord = attributes.uv0;
                    result.texcoord1 = attributes.uv1;
                    result.vertex = float4(vertexDescription.Position, 1);
                    result.normal = vertexDescription.Normal;
                    result.tangent = float4(vertexDescription.Tangent, 0);
                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                }

                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                {
                    result.pos = varyings.positionCS;
                    result.worldPos = varyings.positionWS;
                    result.worldNormal = varyings.normalWS;
                    result.viewDir = varyings.viewDirectionWS;
                    // World Tangent isn't an available input on v2f_surf

                    result._ShadowCoord = varyings.shadowCoord;

                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    #if UNITY_SHOULD_SAMPLE_SH
                    result.sh = varyings.sh;
                    #endif
                    #endif
                    #if defined(LIGHTMAP_ON)
                    result.lmap.xy = varyings.lightmapUV;
                    #endif
                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                    #endif

                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                }

                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                {
                    result.positionCS = surfVertex.pos;
                    result.positionWS = surfVertex.worldPos;
                    result.normalWS = surfVertex.worldNormal;
                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                    // World Tangent isn't an available input on v2f_surf
                    result.shadowCoord = surfVertex._ShadowCoord;

                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    #if UNITY_SHOULD_SAMPLE_SH
                    result.sh = surfVertex.sh;
                    #endif
                    #endif
                    #if defined(LIGHTMAP_ON)
                    result.lightmapUV = surfVertex.lmap.xy;
                    #endif
                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                    #endif

                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                }

                // --------------------------------------------------
                // Main

                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"

                ENDHLSL
                }
                Pass
                {
                    Name "ShadowCaster"
                    Tags
                    {
                        "LightMode" = "ShadowCaster"
                    }

                    // Render State
                    Cull Back
                    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                    ZTest LEqual
                    ZWrite On
                    ColorMask 0

                    // Debug
                    // <None>

                    // --------------------------------------------------
                    // Pass

                    HLSLPROGRAM

                    // Pragmas
                    #pragma target 3.0
                    #pragma multi_compile_shadowcaster
                    #pragma vertex vert
                    #pragma fragment frag

                    // DotsInstancingOptions: <None>
                    // HybridV1InjectedBuiltinProperties: <None>

                    // Keywords
                    #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                    // GraphKeywords: <None>

                    // Defines
                    #define _NORMALMAP 1
                    #define _NORMAL_DROPOFF_TS 1
                    #define ATTRIBUTES_NEED_NORMAL
                    #define ATTRIBUTES_NEED_TANGENT
                    #define ATTRIBUTES_NEED_TEXCOORD0
                    #define VARYINGS_NEED_POSITION_WS
                    #define VARYINGS_NEED_TEXCOORD0
                    #define FEATURES_GRAPH_VERTEX
                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                    #define SHADERPASS SHADERPASS_SHADOWCASTER
                    #define BUILTIN_TARGET_API 1
                    #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                    #define REQUIRE_DEPTH_TEXTURE
                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                    #endif
                    #ifdef _BUILTIN_ALPHATEST_ON
                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                    #endif
                    #ifdef _BUILTIN_AlphaClip
                    #define _AlphaClip _BUILTIN_AlphaClip
                    #endif
                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                    #endif


                    // custom interpolator pre-include
                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                    // Includes
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                    // --------------------------------------------------
                    // Structs and Packing

                    // custom interpolators pre packing
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                    struct Attributes
                    {
                         float3 positionOS : POSITION;
                         float3 normalOS : NORMAL;
                         float4 tangentOS : TANGENT;
                         float4 uv0 : TEXCOORD0;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : INSTANCEID_SEMANTIC;
                        #endif
                    };
                    struct Varyings
                    {
                         float4 positionCS : SV_POSITION;
                         float3 positionWS;
                         float4 texCoord0;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };
                    struct SurfaceDescriptionInputs
                    {
                         float3 WorldSpacePosition;
                         float4 ScreenPosition;
                         float4 uv0;
                         float3 TimeParameters;
                    };
                    struct VertexDescriptionInputs
                    {
                         float3 ObjectSpaceNormal;
                         float3 WorldSpaceNormal;
                         float3 ObjectSpaceTangent;
                         float3 ObjectSpacePosition;
                         float4 uv0;
                         float3 TimeParameters;
                    };
                    struct PackedVaryings
                    {
                         float4 positionCS : SV_POSITION;
                         float3 interp0 : INTERP0;
                         float4 interp1 : INTERP1;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };

                    PackedVaryings PackVaryings(Varyings input)
                    {
                        PackedVaryings output;
                        ZERO_INITIALIZE(PackedVaryings, output);
                        output.positionCS = input.positionCS;
                        output.interp0.xyz = input.positionWS;
                        output.interp1.xyzw = input.texCoord0;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }

                    Varyings UnpackVaryings(PackedVaryings input)
                    {
                        Varyings output;
                        output.positionCS = input.positionCS;
                        output.positionWS = input.interp0.xyz;
                        output.texCoord0 = input.interp1.xyzw;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }


                    // --------------------------------------------------
                    // Graph

                    // Graph Properties
                    CBUFFER_START(UnityPerMaterial)
                    float _Flowspeed1;
                    float _WaterOpacity;
                    float _ReflectionSize;
                    float _FoamDist;
                    float4 _WaterColor;
                    float _WaterSaturation;
                    float _WaterBrightness;
                    float _Flowspeed2;
                    float _Foamspeed;
                    float _FoamGrainSize;
                    float _WavesFrequency;
                    float _WavesIntensity;
                    float _HighlightWavesIntentisy;
                    float _ScaleAll;
                    CBUFFER_END

                        // Object and Global properties

                        // -- Property used by ScenePickingPass
                        #ifdef SCENEPICKINGPASS
                        float4 _SelectionID;
                        #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Includes
                    // GraphIncludes: <None>

                    // Graph Functions

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }


                    float2 Unity_GradientNoise_Dir_float(float2 p)
                    {
                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                        p = p % 289;
                        // need full precision, otherwise half overflows when p > 1
                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                        x = (34 * x + 1) * x % 289;
                        x = frac(x / 41) * 2 - 1;
                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                    }

                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                    {
                        float2 p = UV * Scale;
                        float2 ip = floor(p);
                        float2 fp = frac(p);
                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                    }

                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                    {
                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                    }

                    void Unity_Lerp_float(float A, float B, float T, out float Out)
                    {
                        Out = lerp(A, B, T);
                    }

                    void Unity_Sine_float(float In, out float Out)
                    {
                        Out = sin(In);
                    }

                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                    {
                        RGBA = float4(R, G, B, A);
                        RGB = float3(R, G, B);
                        RG = float2(R, G);
                    }

                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A + B;
                    }


                    inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
                    {
                        float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                        UV = frac(sin(mul(UV, m)));
                        return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
                    }

                    void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                    {
                        float2 g = floor(UV * CellDensity);
                        float2 f = frac(UV * CellDensity);
                        float t = 8.0;
                        float3 res = float3(8.0, 0.0, 0.0);

                        for (int y = -1; y <= 1; y++)
                        {
                            for (int x = -1; x <= 1; x++)
                            {
                                float2 lattice = float2(x,y);
                                float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                                float d = distance(lattice + offset, f);

                                if (d < res.x)
                                {
                                    res = float3(d, offset.x, offset.y);
                                    Out = res.x;
                                    Cells = res.y;
                                }
                            }
                        }
                    }

                    void Unity_Power_float(float A, float B, out float Out)
                    {
                        Out = pow(A, B);
                    }

                    void Unity_Preview_float(float In, out float Out)
                    {
                        Out = In;
                    }

                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Preview_float3(float3 In, out float3 Out)
                    {
                        Out = In;
                    }

                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                    {
                        Out = lerp(A, B, T);
                    }

                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                    {
                        Out = clamp(In, Min, Max);
                    }

                    void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                    {
                        float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                        float4 result2 = 2.0 * Base * Blend;
                        float4 zeroOrOne = step(Base, 0.5);
                        Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                        Out = lerp(Base, Out, Opacity);
                    }

                    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                    {
                        if (unity_OrthoParams.w == 1.0)
                        {
                            Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                        }
                        else
                        {
                            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                        }
                    }

                    void Unity_Subtract_float(float A, float B, out float Out)
                    {
                        Out = A - B;
                    }

                    void Unity_Divide_float(float A, float B, out float Out)
                    {
                        Out = A / B;
                    }

                    void Unity_Saturate_float(float In, out float Out)
                    {
                        Out = saturate(In);
                    }

                    void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
                    {
                        float2 delta = UV - Center;
                        float angle = Strength * length(delta);
                        float x = cos(angle) * delta.x - sin(angle) * delta.y;
                        float y = sin(angle) * delta.x + cos(angle) * delta.y;
                        Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
                    }

                    void Unity_Step_float(float Edge, float In, out float Out)
                    {
                        Out = step(Edge, In);
                    }

                    void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A / B;
                    }

                    void Unity_Preview_float4(float4 In, out float4 Out)
                    {
                        Out = In;
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        float _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0 = _ScaleAll;
                        float2 _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0 = float2(_Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0, _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0);
                        float _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2);
                        float2 _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0, (_Multiply_07528d03b0694f3192da7136a24c7ede_Out_2.xx), _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3);
                        float _Property_a7ead8b7711341789beccb0469347376_Out_0 = _WavesFrequency;
                        float _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3, _Property_a7ead8b7711341789beccb0469347376_Out_0, _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2);
                        float _Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0 = _WavesIntensity;
                        float _Multiply_061b9cf479f9430f8304394a06651e05_Out_2;
                        Unity_Multiply_float_float(_Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0, 0.1, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                        float2 _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0 = float2(0, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                        float _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3;
                        Unity_Remap_float(_GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2, float2 (0, 1), _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0, _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3);
                        float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                        float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                        float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                        float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                        float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                        float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                        float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                        float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                        Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                        float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                        Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                        float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                        Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                        float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                        float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                        Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                        float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                        Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                        float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                        float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                        Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                        float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                        Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                        float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                        float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                        Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                        float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                        Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                        float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                        float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                        float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                        Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                        float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                        Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                        float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                        float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                        float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                        Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                        float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                        Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                        float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                        float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                        Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                        float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                        float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                        Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                        float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                        Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                        float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                        float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                        float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                        float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                        Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                        float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                        Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                        float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                        Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                        float _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1;
                        Unity_Preview_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1);
                        float _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0 = _HighlightWavesIntentisy;
                        float _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3;
                        Unity_Lerp_float(_Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1, _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0, _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3);
                        float3 _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2;
                        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3.xxx), _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2);
                        float3 _Add_dcb4d072333f430884ac2187cb03b851_Out_2;
                        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2, _Add_dcb4d072333f430884ac2187cb03b851_Out_2);
                        float3 _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                        Unity_Preview_float3(_Add_dcb4d072333f430884ac2187cb03b851_Out_2, _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1);
                        description.Position = _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float4 _Property_e06bf2151463465d888ff777d73f9b2c_Out_0 = _WaterColor;
                        float4 Color_675a8e94075a4b6cbc38600b371d0430 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                        float _Property_1ddd793de35b42559e4ee175da0a8aee_Out_0 = _WaterBrightness;
                        float4 _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3;
                        Unity_Lerp_float4(_Property_e06bf2151463465d888ff777d73f9b2c_Out_0, Color_675a8e94075a4b6cbc38600b371d0430, (_Property_1ddd793de35b42559e4ee175da0a8aee_Out_0.xxxx), _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3);
                        float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                        float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                        float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                        float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                        float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                        float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                        float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                        float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                        Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                        float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                        Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                        float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                        Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                        float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                        float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                        Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                        float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                        Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                        float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                        float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                        Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                        float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                        Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                        float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                        float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                        Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                        float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                        Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                        float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                        float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                        float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                        Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                        float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                        Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                        float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                        float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                        float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                        Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                        float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                        Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                        float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                        float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                        Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                        float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                        float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                        Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                        float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                        Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                        float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                        float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                        float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                        float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                        Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                        float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                        Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                        float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                        Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                        float _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3;
                        Unity_Clamp_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, 0.09, 0.64, _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3);
                        float4 _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2;
                        Unity_Blend_Overlay_float4(_Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3, (_Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3.xxxx), _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2, 1);
                        float _Remap_e1cf40a760a747a399255773e6323b2d_Out_3;
                        Unity_Remap_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, float2 (0.09, 1.45), float2 (-0.11, 0.99), _Remap_e1cf40a760a747a399255773e6323b2d_Out_3);
                        float4 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4;
                        float3 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5;
                        float2 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6;
                        Unity_Combine_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, _Remap_e1cf40a760a747a399255773e6323b2d_Out_3, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6);
                        float _Property_c8a4e036104c4d60bd1416088f02ab81_Out_0 = _WaterOpacity;
                        float4 _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2;
                        Unity_Add_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, (_Property_c8a4e036104c4d60bd1416088f02ab81_Out_0.xxxx), _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2);
                        float4 _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                        float4 _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2;
                        Unity_Add_float4(float4(0, 0, 0, 0), _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0, _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2);
                        float _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1;
                        Unity_SceneDepth_Eye_float(_Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2, _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1);
                        float4 _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0 = IN.ScreenPosition;
                        float _Split_60712163e709416ab973ae1098153d0b_R_1 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[0];
                        float _Split_60712163e709416ab973ae1098153d0b_G_2 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[1];
                        float _Split_60712163e709416ab973ae1098153d0b_B_3 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[2];
                        float _Split_60712163e709416ab973ae1098153d0b_A_4 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[3];
                        float _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2;
                        Unity_Subtract_float(_SceneDepth_1db86451195940499820af4d9f81f51a_Out_1, _Split_60712163e709416ab973ae1098153d0b_A_4, _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2);
                        float _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0 = _FoamDist;
                        float _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2;
                        Unity_Divide_float(_Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2, _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0, _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2);
                        float _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1;
                        Unity_Saturate_float(_Divide_0ad9107ae77e4ab0a52099430319a368_Out_2, _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1);
                        float _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2);
                        float _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1;
                        Unity_Sine_float(_Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2, _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1);
                        float _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2;
                        Unity_Multiply_float_float(_Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1, 2, _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2);
                        float2 _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4;
                        Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0.59), _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2, float2 (0, 0), _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4);
                        float _Property_7c2bb84d3f254093bc157a6f9326384e_Out_0 = _ScaleAll;
                        float _Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0 = _Foamspeed;
                        float _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2;
                        Unity_Multiply_float_float(_Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0, 0.02, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2);
                        float _Multiply_602038ad40634891891adf354011cff7_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2, _Multiply_602038ad40634891891adf354011cff7_Out_2);
                        float2 _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3;
                        Unity_TilingAndOffset_float(_Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4, (_Property_7c2bb84d3f254093bc157a6f9326384e_Out_0.xx), (_Multiply_602038ad40634891891adf354011cff7_Out_2.xx), _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3);
                        float _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0 = _FoamGrainSize;
                        float _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3, _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2);
                        float _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3;
                        Unity_Lerp_float(_Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2, 0.45, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3);
                        float _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2;
                        Unity_Step_float(0.5, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3, _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2);
                        float4 _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2;
                        Unity_Divide_float4(_Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2, (_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2.xxxx), _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2);
                        float4 _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1;
                        Unity_Preview_float4(_Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2, _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1);
                        surface.Alpha = (_Preview_28df349a152f4d13aea4acdb5949ca87_Out_1).x;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs

                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;
                        output.uv0 = input.uv0;
                        output.TimeParameters = _TimeParameters.xyz;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                        output.WorldSpacePosition = input.positionWS;
                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                        output.uv0 = input.texCoord0;
                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                    {
                        result.vertex = float4(attributes.positionOS, 1);
                        result.tangent = attributes.tangentOS;
                        result.normal = attributes.normalOS;
                        result.texcoord = attributes.uv0;
                        result.vertex = float4(vertexDescription.Position, 1);
                        result.normal = vertexDescription.Normal;
                        result.tangent = float4(vertexDescription.Tangent, 0);
                        #if UNITY_ANY_INSTANCING_ENABLED
                        #endif
                    }

                    void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                    {
                        result.pos = varyings.positionCS;
                        result.worldPos = varyings.positionWS;
                        // World Tangent isn't an available input on v2f_surf


                        #if UNITY_ANY_INSTANCING_ENABLED
                        #endif
                        #if !defined(LIGHTMAP_ON)
                        #if UNITY_SHOULD_SAMPLE_SH
                        #endif
                        #endif
                        #if defined(LIGHTMAP_ON)
                        #endif
                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                            result.fogCoord = varyings.fogFactorAndVertexLight.x;
                            COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                        #endif

                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                    }

                    void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                    {
                        result.positionCS = surfVertex.pos;
                        result.positionWS = surfVertex.worldPos;
                        // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                        // World Tangent isn't an available input on v2f_surf

                        #if UNITY_ANY_INSTANCING_ENABLED
                        #endif
                        #if !defined(LIGHTMAP_ON)
                        #if UNITY_SHOULD_SAMPLE_SH
                        #endif
                        #endif
                        #if defined(LIGHTMAP_ON)
                        #endif
                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                            result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                            COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                        #endif

                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "Meta"
                        Tags
                        {
                            "LightMode" = "Meta"
                        }

                        // Render State
                        Cull Off

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 3.0
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                        // GraphKeywords: <None>

                        // Defines
                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define ATTRIBUTES_NEED_TEXCOORD1
                        #define ATTRIBUTES_NEED_TEXCOORD2
                        #define VARYINGS_NEED_POSITION_WS
                        #define VARYINGS_NEED_TEXCOORD0
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_META
                        #define BUILTIN_TARGET_API 1
                        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                        #define REQUIRE_DEPTH_TEXTURE
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                        #endif
                        #ifdef _BUILTIN_ALPHATEST_ON
                        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                        #endif
                        #ifdef _BUILTIN_AlphaClip
                        #define _AlphaClip _BUILTIN_AlphaClip
                        #endif
                        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                        #endif


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                             float4 uv1 : TEXCOORD1;
                             float4 uv2 : TEXCOORD2;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 positionWS;
                             float4 texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float3 WorldSpacePosition;
                             float4 ScreenPosition;
                             float4 uv0;
                             float3 TimeParameters;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 WorldSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                             float4 uv0;
                             float3 TimeParameters;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                             float4 interp1 : INTERP1;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.positionWS;
                            output.interp1.xyzw = input.texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.positionWS = input.interp0.xyz;
                            output.texCoord0 = input.interp1.xyzw;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float _Flowspeed1;
                        float _WaterOpacity;
                        float _ReflectionSize;
                        float _FoamDist;
                        float4 _WaterColor;
                        float _WaterSaturation;
                        float _WaterBrightness;
                        float _Flowspeed2;
                        float _Foamspeed;
                        float _FoamGrainSize;
                        float _WavesFrequency;
                        float _WavesIntensity;
                        float _HighlightWavesIntentisy;
                        float _ScaleAll;
                        CBUFFER_END

                            // Object and Global properties

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                        // -- Properties used by SceneSelectionPass
                        #ifdef SCENESELECTIONPASS
                        int _ObjectId;
                        int _PassValue;
                        #endif

                        // Graph Includes
                        // GraphIncludes: <None>

                        // Graph Functions

                        void Unity_Multiply_float_float(float A, float B, out float Out)
                        {
                            Out = A * B;
                        }

                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                        {
                            Out = UV * Tiling + Offset;
                        }


                        float2 Unity_GradientNoise_Dir_float(float2 p)
                        {
                            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                            p = p % 289;
                            // need full precision, otherwise half overflows when p > 1
                            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                            x = (34 * x + 1) * x % 289;
                            x = frac(x / 41) * 2 - 1;
                            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                        }

                        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                        {
                            float2 p = UV * Scale;
                            float2 ip = floor(p);
                            float2 fp = frac(p);
                            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                        }

                        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                        {
                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                        }

                        void Unity_Lerp_float(float A, float B, float T, out float Out)
                        {
                            Out = lerp(A, B, T);
                        }

                        void Unity_Sine_float(float In, out float Out)
                        {
                            Out = sin(In);
                        }

                        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                        {
                            RGBA = float4(R, G, B, A);
                            RGB = float3(R, G, B);
                            RG = float2(R, G);
                        }

                        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                        {
                            Out = A + B;
                        }


                        inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
                        {
                            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                            UV = frac(sin(mul(UV, m)));
                            return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
                        }

                        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                        {
                            float2 g = floor(UV * CellDensity);
                            float2 f = frac(UV * CellDensity);
                            float t = 8.0;
                            float3 res = float3(8.0, 0.0, 0.0);

                            for (int y = -1; y <= 1; y++)
                            {
                                for (int x = -1; x <= 1; x++)
                                {
                                    float2 lattice = float2(x,y);
                                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                                    float d = distance(lattice + offset, f);

                                    if (d < res.x)
                                    {
                                        res = float3(d, offset.x, offset.y);
                                        Out = res.x;
                                        Cells = res.y;
                                    }
                                }
                            }
                        }

                        void Unity_Power_float(float A, float B, out float Out)
                        {
                            Out = pow(A, B);
                        }

                        void Unity_Preview_float(float In, out float Out)
                        {
                            Out = In;
                        }

                        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                        {
                            Out = A + B;
                        }

                        void Unity_Preview_float3(float3 In, out float3 Out)
                        {
                            Out = In;
                        }

                        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                        {
                            Out = lerp(A, B, T);
                        }

                        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                        {
                            Out = clamp(In, Min, Max);
                        }

                        void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                        {
                            float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                            float4 result2 = 2.0 * Base * Blend;
                            float4 zeroOrOne = step(Base, 0.5);
                            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                            Out = lerp(Base, Out, Opacity);
                        }

                        void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
                        {
                            float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
                            Out = luma.xxx + Saturation.xxx * (In - luma.xxx);
                        }

                        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                        {
                            if (unity_OrthoParams.w == 1.0)
                            {
                                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                            }
                            else
                            {
                                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                            }
                        }

                        void Unity_Subtract_float(float A, float B, out float Out)
                        {
                            Out = A - B;
                        }

                        void Unity_Divide_float(float A, float B, out float Out)
                        {
                            Out = A / B;
                        }

                        void Unity_Saturate_float(float In, out float Out)
                        {
                            Out = saturate(In);
                        }

                        void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
                        {
                            float2 delta = UV - Center;
                            float angle = Strength * length(delta);
                            float x = cos(angle) * delta.x - sin(angle) * delta.y;
                            float y = sin(angle) * delta.x + cos(angle) * delta.y;
                            Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
                        }

                        void Unity_Step_float(float Edge, float In, out float Out)
                        {
                            Out = step(Edge, In);
                        }

                        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
                        {
                            Out = lerp(A, B, T);
                        }

                        void Unity_Preview_float4(float4 In, out float4 Out)
                        {
                            Out = In;
                        }

                        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
                        {
                            Out = A / B;
                        }

                        // Custom interpolators pre vertex
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                        // Graph Vertex
                        struct VertexDescription
                        {
                            float3 Position;
                            float3 Normal;
                            float3 Tangent;
                        };

                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                        {
                            VertexDescription description = (VertexDescription)0;
                            float _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0 = _ScaleAll;
                            float2 _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0 = float2(_Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0, _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0);
                            float _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2);
                            float2 _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3;
                            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0, (_Multiply_07528d03b0694f3192da7136a24c7ede_Out_2.xx), _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3);
                            float _Property_a7ead8b7711341789beccb0469347376_Out_0 = _WavesFrequency;
                            float _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3, _Property_a7ead8b7711341789beccb0469347376_Out_0, _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2);
                            float _Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0 = _WavesIntensity;
                            float _Multiply_061b9cf479f9430f8304394a06651e05_Out_2;
                            Unity_Multiply_float_float(_Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0, 0.1, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                            float2 _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0 = float2(0, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                            float _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3;
                            Unity_Remap_float(_GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2, float2 (0, 1), _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0, _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3);
                            float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                            float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                            float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                            float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                            float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                            float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                            float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                            float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                            Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                            float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                            Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                            float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                            Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                            float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                            float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                            Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                            float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                            float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                            float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                            Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                            float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                            float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                            float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                            Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                            float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                            float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                            float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                            float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                            Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                            float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                            Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                            float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                            float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                            float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                            Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                            float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                            Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                            float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                            float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                            Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                            float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                            float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                            Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                            float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                            Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                            float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                            float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                            float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                            float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                            Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                            float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                            Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                            float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                            Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                            float _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1;
                            Unity_Preview_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1);
                            float _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0 = _HighlightWavesIntentisy;
                            float _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3;
                            Unity_Lerp_float(_Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1, _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0, _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3);
                            float3 _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2;
                            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3.xxx), _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2);
                            float3 _Add_dcb4d072333f430884ac2187cb03b851_Out_2;
                            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2, _Add_dcb4d072333f430884ac2187cb03b851_Out_2);
                            float3 _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                            Unity_Preview_float3(_Add_dcb4d072333f430884ac2187cb03b851_Out_2, _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1);
                            description.Position = _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                            description.Normal = IN.ObjectSpaceNormal;
                            description.Tangent = IN.ObjectSpaceTangent;
                            return description;
                        }

                        // Custom interpolators, pre surface
                        #ifdef FEATURES_GRAPH_VERTEX
                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                        {
                        return output;
                        }
                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                        #endif

                        // Graph Pixel
                        struct SurfaceDescription
                        {
                            float3 BaseColor;
                            float3 Emission;
                            float Alpha;
                        };

                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                        {
                            SurfaceDescription surface = (SurfaceDescription)0;
                            float4 Color_c906eb65ab7a48859fe6e622ccfd9407 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                            float4 _Property_e06bf2151463465d888ff777d73f9b2c_Out_0 = _WaterColor;
                            float4 Color_675a8e94075a4b6cbc38600b371d0430 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                            float _Property_1ddd793de35b42559e4ee175da0a8aee_Out_0 = _WaterBrightness;
                            float4 _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3;
                            Unity_Lerp_float4(_Property_e06bf2151463465d888ff777d73f9b2c_Out_0, Color_675a8e94075a4b6cbc38600b371d0430, (_Property_1ddd793de35b42559e4ee175da0a8aee_Out_0.xxxx), _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3);
                            float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                            float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                            float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                            float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                            float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                            float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                            float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                            float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                            Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                            float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                            Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                            float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                            Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                            float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                            float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                            Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                            float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                            float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                            float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                            Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                            float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                            float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                            float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                            Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                            float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                            Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                            float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                            float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                            float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                            Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                            float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                            Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                            float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                            float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                            float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                            Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                            float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                            Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                            float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                            float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                            Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                            float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                            float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                            Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                            float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                            Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                            float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                            float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                            float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                            float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                            Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                            float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                            Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                            float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                            Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                            float _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3;
                            Unity_Clamp_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, 0.09, 0.64, _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3);
                            float4 _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2;
                            Unity_Blend_Overlay_float4(_Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3, (_Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3.xxxx), _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2, 1);
                            float _Property_a5f984dd09df4e9db5c03281dbe348b7_Out_0 = _WaterSaturation;
                            float3 _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2;
                            Unity_Saturation_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2.xyz), _Property_a5f984dd09df4e9db5c03281dbe348b7_Out_0, _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2);
                            float4 _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                            float4 _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2;
                            Unity_Add_float4(float4(0, 0, 0, 0), _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0, _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2);
                            float _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1;
                            Unity_SceneDepth_Eye_float(_Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2, _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1);
                            float4 _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0 = IN.ScreenPosition;
                            float _Split_60712163e709416ab973ae1098153d0b_R_1 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[0];
                            float _Split_60712163e709416ab973ae1098153d0b_G_2 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[1];
                            float _Split_60712163e709416ab973ae1098153d0b_B_3 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[2];
                            float _Split_60712163e709416ab973ae1098153d0b_A_4 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[3];
                            float _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2;
                            Unity_Subtract_float(_SceneDepth_1db86451195940499820af4d9f81f51a_Out_1, _Split_60712163e709416ab973ae1098153d0b_A_4, _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2);
                            float _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0 = _FoamDist;
                            float _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2;
                            Unity_Divide_float(_Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2, _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0, _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2);
                            float _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1;
                            Unity_Saturate_float(_Divide_0ad9107ae77e4ab0a52099430319a368_Out_2, _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1);
                            float _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2);
                            float _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1;
                            Unity_Sine_float(_Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2, _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1);
                            float _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2;
                            Unity_Multiply_float_float(_Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1, 2, _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2);
                            float2 _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4;
                            Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0.59), _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2, float2 (0, 0), _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4);
                            float _Property_7c2bb84d3f254093bc157a6f9326384e_Out_0 = _ScaleAll;
                            float _Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0 = _Foamspeed;
                            float _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2;
                            Unity_Multiply_float_float(_Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0, 0.02, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2);
                            float _Multiply_602038ad40634891891adf354011cff7_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2, _Multiply_602038ad40634891891adf354011cff7_Out_2);
                            float2 _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3;
                            Unity_TilingAndOffset_float(_Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4, (_Property_7c2bb84d3f254093bc157a6f9326384e_Out_0.xx), (_Multiply_602038ad40634891891adf354011cff7_Out_2.xx), _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3);
                            float _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0 = _FoamGrainSize;
                            float _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3, _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2);
                            float _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3;
                            Unity_Lerp_float(_Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2, 0.45, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3);
                            float _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2;
                            Unity_Step_float(0.5, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3, _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2);
                            float _Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1;
                            Unity_Preview_float(_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2, _Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1);
                            float3 _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3;
                            Unity_Lerp_float3((Color_c906eb65ab7a48859fe6e622ccfd9407.xyz), _Saturation_0943f04ebaec40d7a51db46af549d0d5_Out_2, (_Preview_a1f0e124475b4799bae9a1c9376f1c09_Out_1.xxx), _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3);
                            float _Remap_e1cf40a760a747a399255773e6323b2d_Out_3;
                            Unity_Remap_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, float2 (0.09, 1.45), float2 (-0.11, 0.99), _Remap_e1cf40a760a747a399255773e6323b2d_Out_3);
                            float4 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4;
                            float3 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5;
                            float2 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6;
                            Unity_Combine_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, _Remap_e1cf40a760a747a399255773e6323b2d_Out_3, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6);
                            float4 _Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1;
                            Unity_Preview_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1);
                            float _Property_c8a4e036104c4d60bd1416088f02ab81_Out_0 = _WaterOpacity;
                            float4 _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2;
                            Unity_Add_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, (_Property_c8a4e036104c4d60bd1416088f02ab81_Out_0.xxxx), _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2);
                            float4 _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2;
                            Unity_Divide_float4(_Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2, (_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2.xxxx), _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2);
                            float4 _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1;
                            Unity_Preview_float4(_Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2, _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1);
                            surface.BaseColor = _Lerp_55f92bb10c1d42ffaabe7f70e2690f69_Out_3;
                            surface.Emission = (_Preview_0aa8ad2c9d7d497188376dbfc803e074_Out_1.xyz);
                            surface.Alpha = (_Preview_28df349a152f4d13aea4acdb5949ca87_Out_1).x;
                            return surface;
                        }

                        // --------------------------------------------------
                        // Build Graph Inputs

                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                        {
                            VertexDescriptionInputs output;
                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                            output.ObjectSpaceNormal = input.normalOS;
                            output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                            output.ObjectSpacePosition = input.positionOS;
                            output.uv0 = input.uv0;
                            output.TimeParameters = _TimeParameters.xyz;

                            return output;
                        }
                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                        {
                            SurfaceDescriptionInputs output;
                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                            output.WorldSpacePosition = input.positionWS;
                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                            output.uv0 = input.texCoord0;
                            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                        #else
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                        #endif
                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                return output;
                        }

                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                        {
                            result.vertex = float4(attributes.positionOS, 1);
                            result.tangent = attributes.tangentOS;
                            result.normal = attributes.normalOS;
                            result.texcoord = attributes.uv0;
                            result.texcoord1 = attributes.uv1;
                            result.texcoord2 = attributes.uv2;
                            result.vertex = float4(vertexDescription.Position, 1);
                            result.normal = vertexDescription.Normal;
                            result.tangent = float4(vertexDescription.Tangent, 0);
                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                        }

                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                        {
                            result.pos = varyings.positionCS;
                            result.worldPos = varyings.positionWS;
                            // World Tangent isn't an available input on v2f_surf


                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                            #if !defined(LIGHTMAP_ON)
                            #if UNITY_SHOULD_SAMPLE_SH
                            #endif
                            #endif
                            #if defined(LIGHTMAP_ON)
                            #endif
                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                            #endif

                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                        }

                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                        {
                            result.positionCS = surfVertex.pos;
                            result.positionWS = surfVertex.worldPos;
                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                            // World Tangent isn't an available input on v2f_surf

                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                            #if !defined(LIGHTMAP_ON)
                            #if UNITY_SHOULD_SAMPLE_SH
                            #endif
                            #endif
                            #if defined(LIGHTMAP_ON)
                            #endif
                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                            #endif

                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                        }

                        // --------------------------------------------------
                        // Main

                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                        ENDHLSL
                        }
                        Pass
                        {
                            Name "SceneSelectionPass"
                            Tags
                            {
                                "LightMode" = "SceneSelectionPass"
                            }

                            // Render State
                            Cull Off

                            // Debug
                            // <None>

                            // --------------------------------------------------
                            // Pass

                            HLSLPROGRAM

                            // Pragmas
                            #pragma target 3.0
                            #pragma multi_compile_instancing
                            #pragma vertex vert
                            #pragma fragment frag

                            // DotsInstancingOptions: <None>
                            // HybridV1InjectedBuiltinProperties: <None>

                            // Keywords
                            // PassKeywords: <None>
                            // GraphKeywords: <None>

                            // Defines
                            #define _NORMALMAP 1
                            #define _NORMAL_DROPOFF_TS 1
                            #define ATTRIBUTES_NEED_NORMAL
                            #define ATTRIBUTES_NEED_TANGENT
                            #define ATTRIBUTES_NEED_TEXCOORD0
                            #define VARYINGS_NEED_POSITION_WS
                            #define VARYINGS_NEED_TEXCOORD0
                            #define FEATURES_GRAPH_VERTEX
                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                            #define SHADERPASS SceneSelectionPass
                            #define BUILTIN_TARGET_API 1
                            #define SCENESELECTIONPASS 1
                            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                            #define REQUIRE_DEPTH_TEXTURE
                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                            #endif
                            #ifdef _BUILTIN_ALPHATEST_ON
                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                            #endif
                            #ifdef _BUILTIN_AlphaClip
                            #define _AlphaClip _BUILTIN_AlphaClip
                            #endif
                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                            #endif


                            // custom interpolator pre-include
                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                            // Includes
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                            // --------------------------------------------------
                            // Structs and Packing

                            // custom interpolators pre packing
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                            struct Attributes
                            {
                                 float3 positionOS : POSITION;
                                 float3 normalOS : NORMAL;
                                 float4 tangentOS : TANGENT;
                                 float4 uv0 : TEXCOORD0;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : INSTANCEID_SEMANTIC;
                                #endif
                            };
                            struct Varyings
                            {
                                 float4 positionCS : SV_POSITION;
                                 float3 positionWS;
                                 float4 texCoord0;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };
                            struct SurfaceDescriptionInputs
                            {
                                 float3 WorldSpacePosition;
                                 float4 ScreenPosition;
                                 float4 uv0;
                                 float3 TimeParameters;
                            };
                            struct VertexDescriptionInputs
                            {
                                 float3 ObjectSpaceNormal;
                                 float3 WorldSpaceNormal;
                                 float3 ObjectSpaceTangent;
                                 float3 ObjectSpacePosition;
                                 float4 uv0;
                                 float3 TimeParameters;
                            };
                            struct PackedVaryings
                            {
                                 float4 positionCS : SV_POSITION;
                                 float3 interp0 : INTERP0;
                                 float4 interp1 : INTERP1;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };

                            PackedVaryings PackVaryings(Varyings input)
                            {
                                PackedVaryings output;
                                ZERO_INITIALIZE(PackedVaryings, output);
                                output.positionCS = input.positionCS;
                                output.interp0.xyz = input.positionWS;
                                output.interp1.xyzw = input.texCoord0;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }

                            Varyings UnpackVaryings(PackedVaryings input)
                            {
                                Varyings output;
                                output.positionCS = input.positionCS;
                                output.positionWS = input.interp0.xyz;
                                output.texCoord0 = input.interp1.xyzw;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }


                            // --------------------------------------------------
                            // Graph

                            // Graph Properties
                            CBUFFER_START(UnityPerMaterial)
                            float _Flowspeed1;
                            float _WaterOpacity;
                            float _ReflectionSize;
                            float _FoamDist;
                            float4 _WaterColor;
                            float _WaterSaturation;
                            float _WaterBrightness;
                            float _Flowspeed2;
                            float _Foamspeed;
                            float _FoamGrainSize;
                            float _WavesFrequency;
                            float _WavesIntensity;
                            float _HighlightWavesIntentisy;
                            float _ScaleAll;
                            CBUFFER_END

                                // Object and Global properties

                                // -- Property used by ScenePickingPass
                                #ifdef SCENEPICKINGPASS
                                float4 _SelectionID;
                                #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Includes
                            // GraphIncludes: <None>

                            // Graph Functions

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }


                            float2 Unity_GradientNoise_Dir_float(float2 p)
                            {
                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                p = p % 289;
                                // need full precision, otherwise half overflows when p > 1
                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                x = (34 * x + 1) * x % 289;
                                x = frac(x / 41) * 2 - 1;
                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                            }

                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                            {
                                float2 p = UV * Scale;
                                float2 ip = floor(p);
                                float2 fp = frac(p);
                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                            }

                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                            {
                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                            }

                            void Unity_Lerp_float(float A, float B, float T, out float Out)
                            {
                                Out = lerp(A, B, T);
                            }

                            void Unity_Sine_float(float In, out float Out)
                            {
                                Out = sin(In);
                            }

                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                            {
                                RGBA = float4(R, G, B, A);
                                RGB = float3(R, G, B);
                                RG = float2(R, G);
                            }

                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                            {
                                Out = A + B;
                            }


                            inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
                            {
                                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                                UV = frac(sin(mul(UV, m)));
                                return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
                            }

                            void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                            {
                                float2 g = floor(UV * CellDensity);
                                float2 f = frac(UV * CellDensity);
                                float t = 8.0;
                                float3 res = float3(8.0, 0.0, 0.0);

                                for (int y = -1; y <= 1; y++)
                                {
                                    for (int x = -1; x <= 1; x++)
                                    {
                                        float2 lattice = float2(x,y);
                                        float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                                        float d = distance(lattice + offset, f);

                                        if (d < res.x)
                                        {
                                            res = float3(d, offset.x, offset.y);
                                            Out = res.x;
                                            Cells = res.y;
                                        }
                                    }
                                }
                            }

                            void Unity_Power_float(float A, float B, out float Out)
                            {
                                Out = pow(A, B);
                            }

                            void Unity_Preview_float(float In, out float Out)
                            {
                                Out = In;
                            }

                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Preview_float3(float3 In, out float3 Out)
                            {
                                Out = In;
                            }

                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                            {
                                Out = lerp(A, B, T);
                            }

                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                            {
                                Out = clamp(In, Min, Max);
                            }

                            void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                            {
                                float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                                float4 result2 = 2.0 * Base * Blend;
                                float4 zeroOrOne = step(Base, 0.5);
                                Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                                Out = lerp(Base, Out, Opacity);
                            }

                            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                            {
                                if (unity_OrthoParams.w == 1.0)
                                {
                                    Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                }
                                else
                                {
                                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                }
                            }

                            void Unity_Subtract_float(float A, float B, out float Out)
                            {
                                Out = A - B;
                            }

                            void Unity_Divide_float(float A, float B, out float Out)
                            {
                                Out = A / B;
                            }

                            void Unity_Saturate_float(float In, out float Out)
                            {
                                Out = saturate(In);
                            }

                            void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
                            {
                                float2 delta = UV - Center;
                                float angle = Strength * length(delta);
                                float x = cos(angle) * delta.x - sin(angle) * delta.y;
                                float y = sin(angle) * delta.x + cos(angle) * delta.y;
                                Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
                            }

                            void Unity_Step_float(float Edge, float In, out float Out)
                            {
                                Out = step(Edge, In);
                            }

                            void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
                            {
                                Out = A / B;
                            }

                            void Unity_Preview_float4(float4 In, out float4 Out)
                            {
                                Out = In;
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                float _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0 = _ScaleAll;
                                float2 _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0 = float2(_Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0, _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0);
                                float _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2);
                                float2 _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0, (_Multiply_07528d03b0694f3192da7136a24c7ede_Out_2.xx), _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3);
                                float _Property_a7ead8b7711341789beccb0469347376_Out_0 = _WavesFrequency;
                                float _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3, _Property_a7ead8b7711341789beccb0469347376_Out_0, _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2);
                                float _Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0 = _WavesIntensity;
                                float _Multiply_061b9cf479f9430f8304394a06651e05_Out_2;
                                Unity_Multiply_float_float(_Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0, 0.1, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                                float2 _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0 = float2(0, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                                float _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3;
                                Unity_Remap_float(_GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2, float2 (0, 1), _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0, _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3);
                                float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                                float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                                float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                                float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                                float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                                float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                                float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                                float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                                Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                                float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                                Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                                float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                                Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                                float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                                float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                                Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                                float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                                float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                                float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                                Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                                float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                                float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                                float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                                Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                                float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                                float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                                float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                                float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                                Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                                float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                                Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                                float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                                float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                                float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                                Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                                float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                                Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                                float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                                float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                                Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                                float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                                float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                                Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                                float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                                Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                                float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                                float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                                float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                                float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                                Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                                float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                                Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                                float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                                Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                                float _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1;
                                Unity_Preview_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1);
                                float _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0 = _HighlightWavesIntentisy;
                                float _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3;
                                Unity_Lerp_float(_Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1, _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0, _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3);
                                float3 _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2;
                                Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3.xxx), _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2);
                                float3 _Add_dcb4d072333f430884ac2187cb03b851_Out_2;
                                Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2, _Add_dcb4d072333f430884ac2187cb03b851_Out_2);
                                float3 _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                                Unity_Preview_float3(_Add_dcb4d072333f430884ac2187cb03b851_Out_2, _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1);
                                description.Position = _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float4 _Property_e06bf2151463465d888ff777d73f9b2c_Out_0 = _WaterColor;
                                float4 Color_675a8e94075a4b6cbc38600b371d0430 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                                float _Property_1ddd793de35b42559e4ee175da0a8aee_Out_0 = _WaterBrightness;
                                float4 _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3;
                                Unity_Lerp_float4(_Property_e06bf2151463465d888ff777d73f9b2c_Out_0, Color_675a8e94075a4b6cbc38600b371d0430, (_Property_1ddd793de35b42559e4ee175da0a8aee_Out_0.xxxx), _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3);
                                float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                                float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                                float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                                float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                                float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                                float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                                float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                                float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                                Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                                float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                                Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                                float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                                Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                                float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                                float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                                Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                                float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                                float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                                float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                                Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                                float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                                float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                                float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                                Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                                float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                                Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                                float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                                float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                                float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                                Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                                float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                                Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                                float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                                float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                                float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                                Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                                float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                                Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                                float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                                float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                                Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                                float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                                float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                                Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                                float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                                Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                                float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                                float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                                float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                                float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                                Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                                float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                                Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                                float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                                Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                                float _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3;
                                Unity_Clamp_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, 0.09, 0.64, _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3);
                                float4 _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2;
                                Unity_Blend_Overlay_float4(_Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3, (_Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3.xxxx), _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2, 1);
                                float _Remap_e1cf40a760a747a399255773e6323b2d_Out_3;
                                Unity_Remap_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, float2 (0.09, 1.45), float2 (-0.11, 0.99), _Remap_e1cf40a760a747a399255773e6323b2d_Out_3);
                                float4 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4;
                                float3 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5;
                                float2 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6;
                                Unity_Combine_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, _Remap_e1cf40a760a747a399255773e6323b2d_Out_3, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6);
                                float _Property_c8a4e036104c4d60bd1416088f02ab81_Out_0 = _WaterOpacity;
                                float4 _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2;
                                Unity_Add_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, (_Property_c8a4e036104c4d60bd1416088f02ab81_Out_0.xxxx), _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2);
                                float4 _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                float4 _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2;
                                Unity_Add_float4(float4(0, 0, 0, 0), _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0, _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2);
                                float _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1;
                                Unity_SceneDepth_Eye_float(_Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2, _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1);
                                float4 _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0 = IN.ScreenPosition;
                                float _Split_60712163e709416ab973ae1098153d0b_R_1 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[0];
                                float _Split_60712163e709416ab973ae1098153d0b_G_2 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[1];
                                float _Split_60712163e709416ab973ae1098153d0b_B_3 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[2];
                                float _Split_60712163e709416ab973ae1098153d0b_A_4 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[3];
                                float _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2;
                                Unity_Subtract_float(_SceneDepth_1db86451195940499820af4d9f81f51a_Out_1, _Split_60712163e709416ab973ae1098153d0b_A_4, _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2);
                                float _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0 = _FoamDist;
                                float _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2;
                                Unity_Divide_float(_Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2, _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0, _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2);
                                float _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1;
                                Unity_Saturate_float(_Divide_0ad9107ae77e4ab0a52099430319a368_Out_2, _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1);
                                float _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2);
                                float _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1;
                                Unity_Sine_float(_Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2, _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1);
                                float _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2;
                                Unity_Multiply_float_float(_Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1, 2, _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2);
                                float2 _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4;
                                Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0.59), _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2, float2 (0, 0), _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4);
                                float _Property_7c2bb84d3f254093bc157a6f9326384e_Out_0 = _ScaleAll;
                                float _Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0 = _Foamspeed;
                                float _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2;
                                Unity_Multiply_float_float(_Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0, 0.02, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2);
                                float _Multiply_602038ad40634891891adf354011cff7_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2, _Multiply_602038ad40634891891adf354011cff7_Out_2);
                                float2 _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3;
                                Unity_TilingAndOffset_float(_Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4, (_Property_7c2bb84d3f254093bc157a6f9326384e_Out_0.xx), (_Multiply_602038ad40634891891adf354011cff7_Out_2.xx), _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3);
                                float _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0 = _FoamGrainSize;
                                float _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3, _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2);
                                float _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3;
                                Unity_Lerp_float(_Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2, 0.45, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3);
                                float _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2;
                                Unity_Step_float(0.5, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3, _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2);
                                float4 _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2;
                                Unity_Divide_float4(_Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2, (_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2.xxxx), _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2);
                                float4 _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1;
                                Unity_Preview_float4(_Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2, _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1);
                                surface.Alpha = (_Preview_28df349a152f4d13aea4acdb5949ca87_Out_1).x;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs

                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;
                                output.uv0 = input.uv0;
                                output.TimeParameters = _TimeParameters.xyz;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                output.WorldSpacePosition = input.positionWS;
                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                output.uv0 = input.texCoord0;
                                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                            {
                                result.vertex = float4(attributes.positionOS, 1);
                                result.tangent = attributes.tangentOS;
                                result.normal = attributes.normalOS;
                                result.texcoord = attributes.uv0;
                                result.vertex = float4(vertexDescription.Position, 1);
                                result.normal = vertexDescription.Normal;
                                result.tangent = float4(vertexDescription.Tangent, 0);
                                #if UNITY_ANY_INSTANCING_ENABLED
                                #endif
                            }

                            void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                            {
                                result.pos = varyings.positionCS;
                                result.worldPos = varyings.positionWS;
                                // World Tangent isn't an available input on v2f_surf


                                #if UNITY_ANY_INSTANCING_ENABLED
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                #if UNITY_SHOULD_SAMPLE_SH
                                #endif
                                #endif
                                #if defined(LIGHTMAP_ON)
                                #endif
                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                    result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                    COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                #endif

                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                            }

                            void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                            {
                                result.positionCS = surfVertex.pos;
                                result.positionWS = surfVertex.worldPos;
                                // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                // World Tangent isn't an available input on v2f_surf

                                #if UNITY_ANY_INSTANCING_ENABLED
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                #if UNITY_SHOULD_SAMPLE_SH
                                #endif
                                #endif
                                #if defined(LIGHTMAP_ON)
                                #endif
                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                    result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                    COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                #endif

                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "ScenePickingPass"
                                Tags
                                {
                                    "LightMode" = "Picking"
                                }

                                // Render State
                                Cull Back

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 3.0
                                #pragma multi_compile_instancing
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines
                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define VARYINGS_NEED_POSITION_WS
                                #define VARYINGS_NEED_TEXCOORD0
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS ScenePickingPass
                                #define BUILTIN_TARGET_API 1
                                #define SCENEPICKINGPASS 1
                                #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                #define REQUIRE_DEPTH_TEXTURE
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                #endif
                                #ifdef _BUILTIN_ALPHATEST_ON
                                #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                #endif
                                #ifdef _BUILTIN_AlphaClip
                                #define _AlphaClip _BUILTIN_AlphaClip
                                #endif
                                #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                #endif


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                     float4 uv0 : TEXCOORD0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 positionWS;
                                     float4 texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                     float3 WorldSpacePosition;
                                     float4 ScreenPosition;
                                     float4 uv0;
                                     float3 TimeParameters;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 WorldSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                     float4 uv0;
                                     float3 TimeParameters;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 interp0 : INTERP0;
                                     float4 interp1 : INTERP1;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.interp0.xyz = input.positionWS;
                                    output.interp1.xyzw = input.texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.positionWS = input.interp0.xyz;
                                    output.texCoord0 = input.interp1.xyzw;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float _Flowspeed1;
                                float _WaterOpacity;
                                float _ReflectionSize;
                                float _FoamDist;
                                float4 _WaterColor;
                                float _WaterSaturation;
                                float _WaterBrightness;
                                float _Flowspeed2;
                                float _Foamspeed;
                                float _FoamGrainSize;
                                float _WavesFrequency;
                                float _WavesIntensity;
                                float _HighlightWavesIntentisy;
                                float _ScaleAll;
                                CBUFFER_END

                                    // Object and Global properties

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                // -- Properties used by SceneSelectionPass
                                #ifdef SCENESELECTIONPASS
                                int _ObjectId;
                                int _PassValue;
                                #endif

                                // Graph Includes
                                // GraphIncludes: <None>

                                // Graph Functions

                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                {
                                    Out = UV * Tiling + Offset;
                                }


                                float2 Unity_GradientNoise_Dir_float(float2 p)
                                {
                                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                    p = p % 289;
                                    // need full precision, otherwise half overflows when p > 1
                                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                    x = (34 * x + 1) * x % 289;
                                    x = frac(x / 41) * 2 - 1;
                                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                }

                                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                {
                                    float2 p = UV * Scale;
                                    float2 ip = floor(p);
                                    float2 fp = frac(p);
                                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                }

                                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                {
                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                }

                                void Unity_Lerp_float(float A, float B, float T, out float Out)
                                {
                                    Out = lerp(A, B, T);
                                }

                                void Unity_Sine_float(float In, out float Out)
                                {
                                    Out = sin(In);
                                }

                                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                {
                                    RGBA = float4(R, G, B, A);
                                    RGB = float3(R, G, B);
                                    RG = float2(R, G);
                                }

                                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                {
                                    Out = A + B;
                                }


                                inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
                                {
                                    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                                    UV = frac(sin(mul(UV, m)));
                                    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
                                }

                                void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                                {
                                    float2 g = floor(UV * CellDensity);
                                    float2 f = frac(UV * CellDensity);
                                    float t = 8.0;
                                    float3 res = float3(8.0, 0.0, 0.0);

                                    for (int y = -1; y <= 1; y++)
                                    {
                                        for (int x = -1; x <= 1; x++)
                                        {
                                            float2 lattice = float2(x,y);
                                            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                                            float d = distance(lattice + offset, f);

                                            if (d < res.x)
                                            {
                                                res = float3(d, offset.x, offset.y);
                                                Out = res.x;
                                                Cells = res.y;
                                            }
                                        }
                                    }
                                }

                                void Unity_Power_float(float A, float B, out float Out)
                                {
                                    Out = pow(A, B);
                                }

                                void Unity_Preview_float(float In, out float Out)
                                {
                                    Out = In;
                                }

                                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                {
                                    Out = A + B;
                                }

                                void Unity_Preview_float3(float3 In, out float3 Out)
                                {
                                    Out = In;
                                }

                                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                {
                                    Out = lerp(A, B, T);
                                }

                                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                {
                                    Out = clamp(In, Min, Max);
                                }

                                void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                {
                                    float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                                    float4 result2 = 2.0 * Base * Blend;
                                    float4 zeroOrOne = step(Base, 0.5);
                                    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                                    Out = lerp(Base, Out, Opacity);
                                }

                                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                {
                                    if (unity_OrthoParams.w == 1.0)
                                    {
                                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                    }
                                    else
                                    {
                                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                    }
                                }

                                void Unity_Subtract_float(float A, float B, out float Out)
                                {
                                    Out = A - B;
                                }

                                void Unity_Divide_float(float A, float B, out float Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Saturate_float(float In, out float Out)
                                {
                                    Out = saturate(In);
                                }

                                void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
                                {
                                    float2 delta = UV - Center;
                                    float angle = Strength * length(delta);
                                    float x = cos(angle) * delta.x - sin(angle) * delta.y;
                                    float y = sin(angle) * delta.x + cos(angle) * delta.y;
                                    Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
                                }

                                void Unity_Step_float(float Edge, float In, out float Out)
                                {
                                    Out = step(Edge, In);
                                }

                                void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Preview_float4(float4 In, out float4 Out)
                                {
                                    Out = In;
                                }

                                // Custom interpolators pre vertex
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                // Graph Vertex
                                struct VertexDescription
                                {
                                    float3 Position;
                                    float3 Normal;
                                    float3 Tangent;
                                };

                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                {
                                    VertexDescription description = (VertexDescription)0;
                                    float _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0 = _ScaleAll;
                                    float2 _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0 = float2(_Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0, _Property_adf3151ff3604dd1b9a4fbb23d2dda3c_Out_0);
                                    float _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_07528d03b0694f3192da7136a24c7ede_Out_2);
                                    float2 _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3;
                                    Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_61e90677fb87415fa00c93a0f4e2113f_Out_0, (_Multiply_07528d03b0694f3192da7136a24c7ede_Out_2.xx), _TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3);
                                    float _Property_a7ead8b7711341789beccb0469347376_Out_0 = _WavesFrequency;
                                    float _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2;
                                    Unity_GradientNoise_float(_TilingAndOffset_bb01ae1dd03f423eb7b33b85cf0cd5f2_Out_3, _Property_a7ead8b7711341789beccb0469347376_Out_0, _GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2);
                                    float _Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0 = _WavesIntensity;
                                    float _Multiply_061b9cf479f9430f8304394a06651e05_Out_2;
                                    Unity_Multiply_float_float(_Property_0050ef3c98a6496cbe78a8e2ce969903_Out_0, 0.1, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                                    float2 _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0 = float2(0, _Multiply_061b9cf479f9430f8304394a06651e05_Out_2);
                                    float _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3;
                                    Unity_Remap_float(_GradientNoise_c79577e18e554e9a94c55ba5e17f4b53_Out_2, float2 (0, 1), _Vector2_770eb6aa6f9448b896d367bac3692f4e_Out_0, _Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3);
                                    float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                                    float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                                    float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                                    float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                                    Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                                    float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                                    float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                                    float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                                    Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                                    float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                                    Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                                    float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                                    Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                                    float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                                    Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                                    float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                                    float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                                    Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                                    float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                                    float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                                    float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                                    Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                                    float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                                    float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                                    float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                                    Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                                    float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                                    float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                                    float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                                    float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                                    Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                                    float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                                    Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                                    float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                                    float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                                    float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                                    Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                                    float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                                    Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                                    float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                                    float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                                    Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                                    float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                                    float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                                    Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                                    float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                                    Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                                    float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                                    float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                                    float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                                    float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                                    Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                                    float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                                    Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                                    float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                                    Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                                    float _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1;
                                    Unity_Preview_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1);
                                    float _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0 = _HighlightWavesIntentisy;
                                    float _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3;
                                    Unity_Lerp_float(_Remap_ec1d38e644cc47ec96368db2148d31ff_Out_3, _Preview_9ba8d5acc4fc4bf6afc3218f9460c5f8_Out_1, _Property_37b14bbedd134de18e0ad5fa4bc175e9_Out_0, _Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3);
                                    float3 _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2;
                                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Lerp_0ceeeeb59ba140728cc468bb5e2736ef_Out_3.xxx), _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2);
                                    float3 _Add_dcb4d072333f430884ac2187cb03b851_Out_2;
                                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6417948c0c14424d8996bcbdcd0c8903_Out_2, _Add_dcb4d072333f430884ac2187cb03b851_Out_2);
                                    float3 _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                                    Unity_Preview_float3(_Add_dcb4d072333f430884ac2187cb03b851_Out_2, _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1);
                                    description.Position = _Preview_fb21c3732e1a4492bdd3a164a7ef597d_Out_1;
                                    description.Normal = IN.ObjectSpaceNormal;
                                    description.Tangent = IN.ObjectSpaceTangent;
                                    return description;
                                }

                                // Custom interpolators, pre surface
                                #ifdef FEATURES_GRAPH_VERTEX
                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                {
                                return output;
                                }
                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                #endif

                                // Graph Pixel
                                struct SurfaceDescription
                                {
                                    float Alpha;
                                };

                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                {
                                    SurfaceDescription surface = (SurfaceDescription)0;
                                    float4 _Property_e06bf2151463465d888ff777d73f9b2c_Out_0 = _WaterColor;
                                    float4 Color_675a8e94075a4b6cbc38600b371d0430 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                                    float _Property_1ddd793de35b42559e4ee175da0a8aee_Out_0 = _WaterBrightness;
                                    float4 _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3;
                                    Unity_Lerp_float4(_Property_e06bf2151463465d888ff777d73f9b2c_Out_0, Color_675a8e94075a4b6cbc38600b371d0430, (_Property_1ddd793de35b42559e4ee175da0a8aee_Out_0.xxxx), _Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3);
                                    float4 _UV_90b818de03d5440889c3c741d1281e99_Out_0 = IN.uv0;
                                    float _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.y, 0.01, _Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2);
                                    float2 _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3;
                                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_f2be7b56e6d54829a2e925d4041ffcc8_Out_2.xx), _TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3);
                                    float _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2;
                                    Unity_GradientNoise_float(_TilingAndOffset_75b8915a6b9144d5a7a145df62106db8_Out_3, 5.9, _GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2);
                                    float _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2);
                                    float2 _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3;
                                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_b1f1e6d7d087453b9048f0e998c7af2d_Out_2.xx), _TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3);
                                    float _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2;
                                    Unity_GradientNoise_float(_TilingAndOffset_3e12963a245a41159c9a292f9449dc4d_Out_3, 7.43, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2);
                                    float _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2;
                                    Unity_Multiply_float_float(_GradientNoise_a050337e99aa415a8cf6c3e7445a06ac_Out_2, _GradientNoise_ead37b5644114b3e9e5baa45b0b17722_Out_2, _Multiply_1362c23b4d8041d2add681c5db41c028_Out_2);
                                    float _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3;
                                    Unity_Lerp_float(_Multiply_1362c23b4d8041d2add681c5db41c028_Out_2, 0, 0.9, _Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3);
                                    float _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3;
                                    Unity_Remap_float(_Lerp_6fca5ff6860e4050b1ccfb4893f51a10_Out_3, float2 (-1, 1), float2 (0, 1), _Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3);
                                    float _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.01, _Multiply_7373b07233a14dd99a89101d59c3063b_Out_2);
                                    float _Sine_5f20a440934142318f34c8dff299b4e5_Out_1;
                                    Unity_Sine_float(_Multiply_7373b07233a14dd99a89101d59c3063b_Out_2, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1);
                                    float _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2;
                                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_5f20a440934142318f34c8dff299b4e5_Out_1, _Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2);
                                    float _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.02, _Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2);
                                    float _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1;
                                    Unity_Sine_float(_Multiply_77dcc0fc1f2c4116965b34b682f109af_Out_2, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1);
                                    float _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2;
                                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_b8c9b1d8fded4dfd95e41c3739f8fc10_Out_1, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2);
                                    float _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.005, _Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2);
                                    float _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1;
                                    Unity_Sine_float(_Multiply_d8bad3fb8e4f4c1fa898087500984cb6_Out_2, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1);
                                    float _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2;
                                    Unity_Multiply_float_float(_Remap_9cd8d7c43fa74059ad5c18dc11a42267_Out_3, _Sine_fffda9ed1440444ab8e51c531c97759e_Out_1, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2);
                                    float4 _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4;
                                    float3 _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5;
                                    float2 _Combine_02d743f7db0e462e82875ebafb07f457_RG_6;
                                    Unity_Combine_float(_Multiply_2227043c21bf4cf0943073c33f8652c8_Out_2, _Multiply_bbfb02420cd6480e83272da733ba8d4a_Out_2, _Multiply_86d3c5b4c4f94541b1c0c66133ec52b8_Out_2, 0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Combine_02d743f7db0e462e82875ebafb07f457_RGB_5, _Combine_02d743f7db0e462e82875ebafb07f457_RG_6);
                                    float4 _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2;
                                    Unity_Add_float4(_UV_90b818de03d5440889c3c741d1281e99_Out_0, _Combine_02d743f7db0e462e82875ebafb07f457_RGBA_4, _Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2);
                                    float _Property_48f004b338e14bef99e87e592c2ba989_Out_0 = _ReflectionSize;
                                    float _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0 = _ScaleAll;
                                    float _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2;
                                    Unity_Multiply_float_float(_Property_48f004b338e14bef99e87e592c2ba989_Out_0, _Property_a34232dd41754cfe9c8ee97a1c9bd77b_Out_0, _Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2);
                                    float2 _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3;
                                    Unity_TilingAndOffset_float((_Add_68b29e1be64240dfbd314e2b356cdc9a_Out_2.xy), (_Multiply_312f5c181d884f8cbae0d63b6b42cf41_Out_2.xx), float2 (0, 0), _TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3);
                                    float _Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0 = _Flowspeed1;
                                    float _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2;
                                    Unity_Multiply_float_float(_Property_b89b0a22c3b7421eaf026c703f1bfd7c_Out_0, IN.TimeParameters.x, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2);
                                    float _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3;
                                    float _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4;
                                    Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_59446492cfd94dfbb51cb807cd9cea83_Out_2, 37.6, _Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, _Voronoi_21eea62698fa417b97832710cacdb98c_Cells_4);
                                    float _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2;
                                    Unity_Power_float(_Voronoi_21eea62698fa417b97832710cacdb98c_Out_3, 2.81, _Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2);
                                    float _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0 = _Flowspeed2;
                                    float _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cfb12f4ac5cc40b8b3e0ea356eb1549b_Out_0, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2);
                                    float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3;
                                    float _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4;
                                    Unity_Voronoi_float(_TilingAndOffset_ca65e916fbbc4af8ab457c38c087e703_Out_3, _Multiply_df773294a6544dbe992b0eb4dd7bbcc2_Out_2, 13.58, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, _Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Cells_4);
                                    float _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2;
                                    Unity_Power_float(_Voronoi_1d5d62a1d4f4479b857ba2971ca5e907_Out_3, 2.59, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2);
                                    float _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3;
                                    Unity_Lerp_float(_Power_fe8d3db227984ab99f95a5f9de452aa1_Out_2, _Power_7fcabb57ffeb4cfdbe749f666abed863_Out_2, 0.85, _Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3);
                                    float _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3;
                                    Unity_Clamp_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, 0.09, 0.64, _Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3);
                                    float4 _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2;
                                    Unity_Blend_Overlay_float4(_Lerp_fff5a97a996643d487e7bfbb0450276e_Out_3, (_Clamp_2dd9fd9502db4e7c89b6bd11474461dc_Out_3.xxxx), _Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2, 1);
                                    float _Remap_e1cf40a760a747a399255773e6323b2d_Out_3;
                                    Unity_Remap_float(_Lerp_5d854402028c4f849ebaa8d5a43d374c_Out_3, float2 (0.09, 1.45), float2 (-0.11, 0.99), _Remap_e1cf40a760a747a399255773e6323b2d_Out_3);
                                    float4 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4;
                                    float3 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5;
                                    float2 _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6;
                                    Unity_Combine_float((_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, (_Blend_7d84dfa01c76401386e86c0c85fd543f_Out_2).x, _Remap_e1cf40a760a747a399255773e6323b2d_Out_3, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGB_5, _Combine_e6dc2dcf67e04e9fb282effd836f62f7_RG_6);
                                    float _Property_c8a4e036104c4d60bd1416088f02ab81_Out_0 = _WaterOpacity;
                                    float4 _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2;
                                    Unity_Add_float4(_Combine_e6dc2dcf67e04e9fb282effd836f62f7_RGBA_4, (_Property_c8a4e036104c4d60bd1416088f02ab81_Out_0.xxxx), _Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2);
                                    float4 _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                    float4 _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2;
                                    Unity_Add_float4(float4(0, 0, 0, 0), _ScreenPosition_41c86f69ee924492b126fa1a0b6e7ec3_Out_0, _Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2);
                                    float _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1;
                                    Unity_SceneDepth_Eye_float(_Add_f5b8bcc75c9f49c7a48bba1dcb632a95_Out_2, _SceneDepth_1db86451195940499820af4d9f81f51a_Out_1);
                                    float4 _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0 = IN.ScreenPosition;
                                    float _Split_60712163e709416ab973ae1098153d0b_R_1 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[0];
                                    float _Split_60712163e709416ab973ae1098153d0b_G_2 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[1];
                                    float _Split_60712163e709416ab973ae1098153d0b_B_3 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[2];
                                    float _Split_60712163e709416ab973ae1098153d0b_A_4 = _ScreenPosition_fcf743ad95324b29a3b6dc3ea50689ee_Out_0[3];
                                    float _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2;
                                    Unity_Subtract_float(_SceneDepth_1db86451195940499820af4d9f81f51a_Out_1, _Split_60712163e709416ab973ae1098153d0b_A_4, _Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2);
                                    float _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0 = _FoamDist;
                                    float _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2;
                                    Unity_Divide_float(_Subtract_1d8372ff2d71496782a17c05fd2aaa64_Out_2, _Property_2e4ec5e388984da7bc7ea60cb2b9f436_Out_0, _Divide_0ad9107ae77e4ab0a52099430319a368_Out_2);
                                    float _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1;
                                    Unity_Saturate_float(_Divide_0ad9107ae77e4ab0a52099430319a368_Out_2, _Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1);
                                    float _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, 0.1, _Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2);
                                    float _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1;
                                    Unity_Sine_float(_Multiply_938c7ac061a44b59a7f0ee7ce6078bd7_Out_2, _Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1);
                                    float _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2;
                                    Unity_Multiply_float_float(_Sine_f63f538076bc49ffab9f2db3e4efff83_Out_1, 2, _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2);
                                    float2 _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4;
                                    Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0.59), _Multiply_0ca00c8c1e5743c9849a809a30568751_Out_2, float2 (0, 0), _Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4);
                                    float _Property_7c2bb84d3f254093bc157a6f9326384e_Out_0 = _ScaleAll;
                                    float _Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0 = _Foamspeed;
                                    float _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2;
                                    Unity_Multiply_float_float(_Property_d5a2247c4bf24edabd6aedeaa67d736c_Out_0, 0.02, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2);
                                    float _Multiply_602038ad40634891891adf354011cff7_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_b39d80e36327475b9eb37e05e1854cb0_Out_2, _Multiply_602038ad40634891891adf354011cff7_Out_2);
                                    float2 _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3;
                                    Unity_TilingAndOffset_float(_Twirl_a88cae6343ad4f54a26e988ff57d1050_Out_4, (_Property_7c2bb84d3f254093bc157a6f9326384e_Out_0.xx), (_Multiply_602038ad40634891891adf354011cff7_Out_2.xx), _TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3);
                                    float _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0 = _FoamGrainSize;
                                    float _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2;
                                    Unity_GradientNoise_float(_TilingAndOffset_09e82a59b4a140229fe6ed4a3bdeea68_Out_3, _Property_0539d6ca3b714977bf2fa703db9dd49c_Out_0, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2);
                                    float _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3;
                                    Unity_Lerp_float(_Saturate_8d953c90146746589a30bea2a16cdaf8_Out_1, _GradientNoise_ac4c82d921684a7c87d7355cd08440a1_Out_2, 0.45, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3);
                                    float _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2;
                                    Unity_Step_float(0.5, _Lerp_d8cd547f1c4946349c6eab2a4c46320a_Out_3, _Step_e6db6220feea41c8a288b016fa1e0f57_Out_2);
                                    float4 _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2;
                                    Unity_Divide_float4(_Add_37ed56e8ba76402ea57e91913e5d26c6_Out_2, (_Step_e6db6220feea41c8a288b016fa1e0f57_Out_2.xxxx), _Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2);
                                    float4 _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1;
                                    Unity_Preview_float4(_Divide_dbb31658799649a18a9fc32c5bfe4074_Out_2, _Preview_28df349a152f4d13aea4acdb5949ca87_Out_1);
                                    surface.Alpha = (_Preview_28df349a152f4d13aea4acdb5949ca87_Out_1).x;
                                    return surface;
                                }

                                // --------------------------------------------------
                                // Build Graph Inputs

                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                {
                                    VertexDescriptionInputs output;
                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                    output.ObjectSpaceNormal = input.normalOS;
                                    output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                    output.ObjectSpacePosition = input.positionOS;
                                    output.uv0 = input.uv0;
                                    output.TimeParameters = _TimeParameters.xyz;

                                    return output;
                                }
                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                {
                                    SurfaceDescriptionInputs output;
                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                    output.WorldSpacePosition = input.positionWS;
                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                    output.uv0 = input.texCoord0;
                                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                #else
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                #endif
                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                        return output;
                                }

                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                {
                                    result.vertex = float4(attributes.positionOS, 1);
                                    result.tangent = attributes.tangentOS;
                                    result.normal = attributes.normalOS;
                                    result.texcoord = attributes.uv0;
                                    result.vertex = float4(vertexDescription.Position, 1);
                                    result.normal = vertexDescription.Normal;
                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                }

                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                {
                                    result.pos = varyings.positionCS;
                                    result.worldPos = varyings.positionWS;
                                    // World Tangent isn't an available input on v2f_surf


                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                    #if !defined(LIGHTMAP_ON)
                                    #if UNITY_SHOULD_SAMPLE_SH
                                    #endif
                                    #endif
                                    #if defined(LIGHTMAP_ON)
                                    #endif
                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                    #endif

                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                }

                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                {
                                    result.positionCS = surfVertex.pos;
                                    result.positionWS = surfVertex.worldPos;
                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                    // World Tangent isn't an available input on v2f_surf

                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                    #if !defined(LIGHTMAP_ON)
                                    #if UNITY_SHOULD_SAMPLE_SH
                                    #endif
                                    #endif
                                    #if defined(LIGHTMAP_ON)
                                    #endif
                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                    #endif

                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                }

                                // --------------------------------------------------
                                // Main

                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                ENDHLSL
                                }
    }
        CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
                                    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                    FallBack "Hidden/Shader Graph/FallbackError"
}