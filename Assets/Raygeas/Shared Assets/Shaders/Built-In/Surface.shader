// Made with Amplify Shader Editor v1.9.9.4
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Raygeas/Built-In/Surface"
{
	Properties
	{
		[Header(Main Maps)][Space(5)] _Tiling( "Tiling", Float ) = 1
		[NoScaleOffset][Space(5)] _MainTex( "Albedo", 2D ) = "white" {}
		[NoScaleOffset][Normal] _BumpMap( "Normal", 2D ) = "bump" {}
		[NoScaleOffset] _MetallicGlossMap( "Metallic/Smoothness", 2D ) = "white" {}
		[NoScaleOffset] _OcclusionMap( "Occlusion", 2D ) = "white" {}
		[Header(Main Settings)][Space(5)] _Color( "Color", Color ) = ( 1, 1, 1, 0 )
		_BumpScale( "Normal", Float ) = 1
		_Metallic( "Metallic", Range( 0, 1 ) ) = 0
		_Glossiness( "Smoothness", Range( 0, 1 ) ) = 0
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel( "Smoothness Source", Float ) = 0
		_OcclusionStrength( "Occlusion", Range( 0, 1 ) ) = 1
		[Space(15)][Header(Coverage Maps)][Space(5)] _CovTiling( "Tiling", Float ) = 1
		[NoScaleOffset][Space(5)] _CovMainTex( "Albedo", 2D ) = "white" {}
		[NoScaleOffset][Normal] _CovBumpMap( "Normal", 2D ) = "bump" {}
		[NoScaleOffset] _CoverageMetallicSmoothness( "Metallic/Smoothness", 2D ) = "white" {}
		[NoScaleOffset] _CovMask( "Coverage Mask", 2D ) = "white" {}
		[Header(Coverage Settings)][Space(5)][Toggle( _COVERAGEON_ON )] _Coverageon( "Enable", Float ) = 0
		[Space(15)] _CovColor( "Color", Color ) = ( 1, 1, 1, 0 )
		_CovBumpScale( "Normal", Float ) = 1
		_CovMetallic( "Metallic", Range( 0, 1 ) ) = 0
		_CovGlossiness( "Smoothness", Range( 0, 1 ) ) = 0
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _CovSmoothnessTextureChannel( "Smoothness Source", Float ) = 0
		[Enum(World Normal,0,Vertex Position,1)][Space(15)] _CovOverlayMethod( "Overlay Method", Float ) = 0
		_CovOffset( "Offset", Float ) = 1
		_CovBalance( "Balance", Float ) = -1
		_MaskContrast( "Mask Contrast", Float ) = 1
		_NormalBlending( "Normal Blending", Range( 0, 1 ) ) = 1
		[Space(15)] _MaskTilingX( "Mask Tiling X", Float ) = 1
		_MaskTilingY( "Mask Tiling Y", Float ) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _COVERAGEON_ON
		#define ASE_VERSION 19904
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#endif//ASE Sampling Macros

		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 ase_positionOS4f;
		};

		UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
		uniform float _Tiling;
		SamplerState sampler_Linear_Repeat;
		uniform float _BumpScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_CovBumpMap);
		SamplerState sampler_CovBumpMap;
		uniform float _CovTiling;
		uniform float _CovBumpScale;
		uniform float _NormalBlending;
		uniform float _CovOverlayMethod;
		uniform float _CovOffset;
		uniform float _CovBalance;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_CovMask);
		uniform float _MaskTilingX;
		uniform float _MaskTilingY;
		uniform float _MaskContrast;
		uniform float4 _Color;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex);
		uniform float4 _CovColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_CovMainTex);
		SamplerState sampler_CovMainTex;
		uniform float _Metallic;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap);
		uniform float _CovMetallic;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_CoverageMetallicSmoothness);
		SamplerState sampler_CoverageMetallicSmoothness;
		uniform float _SmoothnessTextureChannel;
		uniform float _Glossiness;
		uniform float _CovSmoothnessTextureChannel;
		uniform float _CovGlossiness;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_OcclusionMap);
		uniform float _OcclusionStrength;


		inline float3 TriplanarSampling432( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackScaleNormal( xNorm, normalScale.y ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackScaleNormal( yNorm, normalScale.x ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackScaleNormal( zNorm, normalScale.y ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float4 TriplanarSampling421( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline float4 TriplanarSampling430( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_positionOS4f = v.vertex;
			o.ase_positionOS4f = ase_positionOS4f;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_Tiling).xx;
			float2 uv_TexCoord472 = i.uv_texcoord * temp_cast_0;
			float2 Tiling462 = uv_TexCoord472;
			float3 tex2DNode6 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _BumpMap, sampler_Linear_Repeat, Tiling462 ), _BumpScale );
			float CoverageTiling463 = _CovTiling;
			float2 temp_cast_1 = (CoverageTiling463).xx;
			float3 ase_positionWS = i.worldPos;
			float3 ase_normalWS = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_tangentWS = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_bitangentWS = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_tangentWS, ase_bitangentWS, ase_normalWS );
			float3 triplanar432 = TriplanarSampling432( _CovBumpMap, sampler_CovBumpMap, ase_positionWS, ase_normalWS, 10.0, temp_cast_1, _CovBumpScale, 0 );
			float3 tanTriplanarNormal432 = mul( ase_worldToTangent, triplanar432 );
			float3 lerpResult515 = lerp( BlendNormals( tex2DNode6 , tanTriplanarNormal432 ) , tanTriplanarNormal432 , ( 1.0 - _NormalBlending ));
			float3 MainNormalMap454 = tex2DNode6;
			float3 ase_positionOS = i.ase_positionOS4f.xyz;
			float lerpResult457 = lerp( (WorldNormalVector( i , MainNormalMap454 )).y , ase_positionOS.y , _CovOverlayMethod);
			float temp_output_289_0 = ( lerpResult457 + ( 1.0 - _CovOffset ) );
			float lerpResult541 = lerp( temp_output_289_0 , ( 1.0 - temp_output_289_0 ) , _CovBalance);
			float2 appendResult550 = (float2(_MaskTilingX , _MaskTilingY));
			float2 uv_TexCoord545 = i.uv_texcoord * appendResult550;
			float2 MaskTiling551 = uv_TexCoord545;
			float4 tex2DNode507 = SAMPLE_TEXTURE2D( _CovMask, sampler_Linear_Repeat, MaskTiling551 );
			float lerpResult524 = lerp( ( 1.0 - tex2DNode507.g ) , tex2DNode507.g , _MaskContrast);
			float CoverageMask297 = saturate( ( lerpResult541 * saturate( lerpResult524 ) ) );
			float3 lerpResult309 = lerp( tex2DNode6 , lerpResult515 , CoverageMask297);
			#ifdef _COVERAGEON_ON
				float3 staticSwitch308 = lerpResult309;
			#else
				float3 staticSwitch308 = tex2DNode6;
			#endif
			float3 Normal75 = staticSwitch308;
			o.Normal = Normal75;
			float4 tex2DNode2 = SAMPLE_TEXTURE2D( _MainTex, sampler_Linear_Repeat, Tiling462 );
			float4 temp_output_3_0 = ( _Color * tex2DNode2 );
			float2 temp_cast_2 = (CoverageTiling463).xx;
			float4 triplanar421 = TriplanarSampling421( _CovMainTex, sampler_CovMainTex, ase_positionWS, ase_normalWS, 10.0, temp_cast_2, 1.0, 0 );
			float4 lerpResult302 = lerp( temp_output_3_0 , ( _CovColor * triplanar421 ) , CoverageMask297);
			#ifdef _COVERAGEON_ON
				float4 staticSwitch304 = lerpResult302;
			#else
				float4 staticSwitch304 = temp_output_3_0;
			#endif
			float4 Albedo19 = staticSwitch304;
			o.Albedo = Albedo19.rgb;
			float4 tex2DNode239 = SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_Linear_Repeat, Tiling462 );
			float temp_output_241_0 = ( _Metallic * tex2DNode239.r );
			float2 temp_cast_5 = (CoverageTiling463).xx;
			float4 triplanar430 = TriplanarSampling430( _CoverageMetallicSmoothness, sampler_CoverageMetallicSmoothness, ase_positionWS, ase_normalWS, 10.0, temp_cast_5, 1.0, 0 );
			float lerpResult335 = lerp( temp_output_241_0 , ( _CovMetallic * triplanar430.x ) , CoverageMask297);
			#ifdef _COVERAGEON_ON
				float staticSwitch340 = lerpResult335;
			#else
				float staticSwitch340 = temp_output_241_0;
			#endif
			float Metallic262 = staticSwitch340;
			o.Metallic = Metallic262;
			float AlbedoAlpha434 = tex2DNode2.a;
			float lerpResult441 = lerp( tex2DNode239.a , AlbedoAlpha434 , _SmoothnessTextureChannel);
			float temp_output_240_0 = ( lerpResult441 * _Glossiness );
			float CoverageAlbedoAlpha369 = triplanar421.a;
			float lerpResult451 = lerp( triplanar430.a , CoverageAlbedoAlpha369 , _CovSmoothnessTextureChannel);
			float lerpResult333 = lerp( temp_output_240_0 , ( lerpResult451 * _CovGlossiness ) , CoverageMask297);
			#ifdef _COVERAGEON_ON
				float staticSwitch339 = lerpResult333;
			#else
				float staticSwitch339 = temp_output_240_0;
			#endif
			float Smoothness263 = staticSwitch339;
			o.Smoothness = Smoothness263;
			float lerpResult410 = lerp( 1.0 , SAMPLE_TEXTURE2D( _OcclusionMap, sampler_Linear_Repeat, Tiling462 ).g , _OcclusionStrength);
			float Ambient_Occlusion415 = lerpResult410;
			o.Occlusion = Ambient_Occlusion415;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows dithercrossfade vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack2.xyzw = customInputData.ase_positionOS4f;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.ase_positionOS4f = IN.customPack2.xyzw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19904
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;80;-5246.29,-134.5053;Inherit;False;2077.593;772.498;;1;557;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;547;-5196.686,1143.18;Inherit;False;Property;_MaskTilingY;Mask Tiling Y;28;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;546;-5196.686,1056.18;Inherit;False;Property;_MaskTilingX;Mask Tiling X;27;0;Create;True;0;0;0;False;1;Space(15);False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;550;-4964.165,1087.874;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;468;-5136,-80;Inherit;False;462;Tiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;175;-5104,16;Inherit;False;Property;_BumpScale;Normal;6;0;Create;False;0;1;Option1;0;0;False;0;False;1;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;557;-5168,112;Inherit;False;554;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;6;-4834.046,-5.186795;Inherit;True;Property;_BumpMap;Normal;2;2;[NoScaleOffset];[Normal];Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;545;-4768.686,1064.18;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;298;-3118.266,-139.3249;Inherit;False;2076.209;781.7334;;1;560;Coverage Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;454;-4421.551,74.17956;Inherit;False;MainNormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;551;-4497.429,1064.103;Inherit;False;MaskTiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;455;-3078.327,-55.61077;Inherit;False;454;MainNormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;552;-2847.237,414.4482;Inherit;False;551;MaskTiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;560;-2880,512;Inherit;False;554;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.PosVertexDataNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;357;-2849.578,102.7021;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;283;-2850.429,-55.41725;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;456;-2847.994,260.5911;Inherit;False;Property;_CovOverlayMethod;Overlay Method;22;1;[Enum];Create;False;0;2;World Normal;0;Vertex Position;1;0;False;1;Space(15);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;286;-2630.466,259.0982;Inherit;False;Property;_CovOffset;Offset;23;0;Create;False;0;0;0;False;0;False;1;-1.41;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;507;-2606.656,389.4706;Inherit;True;Property;_CovMask;Coverage Mask;15;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;457;-2576.994,82.59109;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;544;-2459.106,259.2239;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;523;-2283.287,381.6895;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;525;-2309.054,516.6456;Inherit;False;Property;_MaskContrast;Mask Contrast;25;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;289;-2253.86,83.08209;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;527;-2103.648,162.7202;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;524;-2090.287,414.6894;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;287;-2101.583,258.3081;Inherit;False;Property;_CovBalance;Balance;24;0;Create;False;0;0;0;False;0;False;-1;-0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;79;-5245.993,-1253.395;Inherit;False;2409.134;1027.341;;4;431;430;239;556;Metallic/Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;555;-3008,720;Inherit;False;595;222;;2;554;553;Sampler State;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;461;-4965.548,808.65;Inherit;False;Property;_Tiling;Tiling;0;0;Create;False;0;0;0;False;2;Header(Main Maps);Space(5);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;460;-4692.275,945.233;Inherit;False;Property;_CovTiling;Tiling;11;0;Create;False;0;0;0;False;3;Space(15);Header(Coverage Maps);Space(5);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;541;-1914.835,83.98171;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;531;-1913.686,414.4957;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;434;-1961.05,-877.3463;Inherit;False;AlbedoAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;472;-4760.245,784.6017;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;463;-4497.549,944.6509;Inherit;False;CoverageTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;466;-5011.479,-1063.774;Inherit;False;462;Tiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;437;-4674.257,-889.3327;Inherit;False;434;AlbedoAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;439;-4704.184,-793.5801;Inherit;False;Property;_SmoothnessTextureChannel;Smoothness Source;9;1;[Enum];Create;False;0;2;Metallic Alpha;0;Albedo Alpha;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;360;-1666.661,228.7535;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;471;-5177.73,518.2753;Inherit;False;463;CoverageTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;361;-5115.832,423.2877;Inherit;False;Property;_CovBumpScale;Normal;18;0;Create;False;0;1;Option1;0;0;False;0;False;1;2.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;369;-1994.562,-423.8585;Inherit;False;CoverageAlbedoAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;433;-5188.57,221.3949;Inherit;True;Property;_CovBumpMap;Normal;13;2;[NoScaleOffset];[Normal];Create;False;0;0;0;False;0;False;None;None;False;bump;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerStateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;553;-2928,800;Inherit;False;0;0;0;1;-1;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;556;-5040,-976;Inherit;False;554;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;462;-4496.549,784.6498;Inherit;False;Tiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;470;-2707.409,-393.6988;Inherit;False;463;CoverageTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;422;-2714.46,-596.0686;Inherit;True;Property;_CovMainTex;Albedo;12;1;[NoScaleOffset];Create;False;0;0;0;False;1;Space(5);False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;465;-5176.347,-522.9006;Inherit;False;463;CoverageTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;441;-4410.865,-913.1537;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;438;-4754.427,-443.8916;Inherit;False;369;CoverageAlbedoAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;242;-4406.52,-1163.217;Inherit;False;Property;_Metallic;Metallic;7;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;54;-4410.217,-789.8232;Inherit;False;Property;_Glossiness;Smoothness;8;0;Create;False;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;450;-4719.256,-354.9561;Inherit;False;Property;_CovSmoothnessTextureChannel;Smoothness Source;21;1;[Enum];Create;False;0;2;Metallic Alpha;0;Albedo Alpha;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;487;-1478.098,229.2119;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;516;-4556.359,446.4276;Inherit;False;Property;_NormalBlending;Normal Blending;26;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;432;-4906.278,332.9303;Inherit;True;Spherical;World;True;Top Texture 2;_TopTexture2;bump;0;None;Mid Texture 2;_MidTexture2;white;-1;None;Bot Texture 2;_BotTexture2;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;10;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;431;-5184,-720;Inherit;True;Property;_CoverageMetallicSmoothness;Metallic/Smoothness;14;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;239;-4777.259,-1087.302;Inherit;True;Property;_MetallicGlossMap;Metallic/Smoothness;3;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;554;-2688,800;Inherit;False;SamplerState;-1;True;1;0;SAMPLERSTATE;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;416;-4193.45,721.0216;Inherit;False;1113.388;393.1936;;2;406;558;Ambient Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;467;-2582.252,-933.5354;Inherit;False;462;Tiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TriplanarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;421;-2413.572,-519.6924;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;10;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;451;-4411.137,-467.4431;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;240;-4062.507,-913.7997;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;241;-4062.128,-1086.816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;435;-4410.078,-697.0166;Inherit;False;Property;_CovMetallic;Metallic;19;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;332;-4413.566,-343.2623;Inherit;False;Property;_CovGlossiness;Smoothness;20;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;297;-1291.606,229.7733;Inherit;False;CoverageMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;306;-4422.68,163.9788;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;517;-4279.708,446.5965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;300;-2259.796,-726.5112;Inherit;False;Property;_CovColor;Color;17;0;Create;False;0;0;0;False;1;Space(15);False;1,1,1,0;0.2901961,0.6344857,0.6901961,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TriplanarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;430;-4879.729,-642.3202;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;10;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;559;-2608,-832;Inherit;False;554;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;2;-2329.908,-957.6903;Inherit;True;Property;_MainTex;Albedo;1;1;[NoScaleOffset];Create;False;0;0;0;False;1;Space(5);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;1;-2261.156,-1141.94;Inherit;False;Property;_Color;Color;5;0;Create;False;0;0;0;False;2;Header(Main Settings);Space(5);False;1,1,1,0;0.668,0.5182759,0.4990805,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;370;-4058.444,-465.2663;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;436;-4059.553,-640.2471;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;365;-3591.754,-927.4928;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;363;-3591.993,-1102.355;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;334;-3934.646,-989.0728;Inherit;False;297;CoverageMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;469;-4164.05,810.6268;Inherit;False;462;Tiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;312;-3892.813,-23.02818;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;515;-4099.537,306.9151;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;310;-4166.596,71.59686;Inherit;False;297;CoverageMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;301;-1918.98,-630.9773;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;303;-1959.508,-799.1876;Inherit;False;297;CoverageMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;558;-4192,896;Inherit;False;554;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;3;-1916.578,-1057.209;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;335;-3593.652,-1087.556;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;333;-3594.719,-914.7487;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;364;-3467.303,-1104.154;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;366;-3463.754,-929.4928;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;408;-3933.847,1017.323;Inherit;False;Property;_OcclusionStrength;Occlusion;10;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;309;-3891.998,-11.46561;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;311;-3761.262,-22.99716;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;302;-1651.226,-848.3546;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;406;-3939.215,787.0216;Inherit;True;Property;_OcclusionMap;Occlusion;4;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;410;-3544.308,885.0372;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;339;-3371.297,-938.7908;Inherit;False;Property;_Coverageon2;Coverage;16;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;304;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;340;-3371.892,-1110.276;Inherit;False;Property;_Coverageon3;Coverage;16;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;304;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;308;-3682.621,-34.47466;Inherit;False;Property;_Coverageon1;Coverage;16;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;304;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;304;-1404.458,-1055.96;Inherit;False;Property;_Coverageon;Enable;16;0;Create;False;0;0;0;False;2;Header(Coverage Settings);Space(5);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;263;-3099.97,-938.7877;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;262;-3101.251,-1110.798;Inherit;False;Metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;415;-3349.893,884.5079;Inherit;False;Ambient Occlusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;75;-3413.293,-34.25854;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;19;-1108.726,-1055.769;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;20;-632.4727,-966.7545;Inherit;False;19;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;77;-632.3541,-885.075;Inherit;False;75;Normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;265;-630.7629,-712.2136;Inherit;False;263;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;264;-632.6641,-795.9246;Inherit;False;262;Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;452;-694.8375,-627.148;Inherit;False;415;Ambient Occlusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;0;-342.2618,-860.8546;Float;False;True;-1;2;;0;0;Standard;Raygeas/Built-In/Surface;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;0;15;10;25;False;0.5;True;0;5;False;;10;False;;0;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;_CullMode;-1;0;True;_AlphaCutoff;0;0;0;False;0.1;False;;0;False;;True;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;473;-5238.548,719.7208;Inherit;False;985.5457;524.7683;;0;Tiling;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;41;-2788.599,-1251.465;Inherit;False;1918.847;1025.771;;0;Albedo;1,1,1,1;0;0
WireConnection;550;0;546;0
WireConnection;550;1;547;0
WireConnection;6;1;468;0
WireConnection;6;5;175;0
WireConnection;6;7;557;0
WireConnection;545;0;550;0
WireConnection;454;0;6;0
WireConnection;551;0;545;0
WireConnection;283;0;455;0
WireConnection;507;1;552;0
WireConnection;507;7;560;0
WireConnection;457;0;283;2
WireConnection;457;1;357;2
WireConnection;457;2;456;0
WireConnection;544;0;286;0
WireConnection;523;0;507;2
WireConnection;289;0;457;0
WireConnection;289;1;544;0
WireConnection;527;0;289;0
WireConnection;524;0;523;0
WireConnection;524;1;507;2
WireConnection;524;2;525;0
WireConnection;541;0;289;0
WireConnection;541;1;527;0
WireConnection;541;2;287;0
WireConnection;531;0;524;0
WireConnection;434;0;2;4
WireConnection;472;0;461;0
WireConnection;463;0;460;0
WireConnection;360;0;541;0
WireConnection;360;1;531;0
WireConnection;369;0;421;4
WireConnection;462;0;472;0
WireConnection;441;0;239;4
WireConnection;441;1;437;0
WireConnection;441;2;439;0
WireConnection;487;0;360;0
WireConnection;432;0;433;0
WireConnection;432;8;361;0
WireConnection;432;3;471;0
WireConnection;239;1;466;0
WireConnection;239;7;556;0
WireConnection;554;0;553;0
WireConnection;421;0;422;0
WireConnection;421;3;470;0
WireConnection;451;0;430;4
WireConnection;451;1;438;0
WireConnection;451;2;450;0
WireConnection;240;0;441;0
WireConnection;240;1;54;0
WireConnection;241;0;242;0
WireConnection;241;1;239;1
WireConnection;297;0;487;0
WireConnection;306;0;6;0
WireConnection;306;1;432;0
WireConnection;517;0;516;0
WireConnection;430;0;431;0
WireConnection;430;3;465;0
WireConnection;2;1;467;0
WireConnection;2;7;559;0
WireConnection;370;0;451;0
WireConnection;370;1;332;0
WireConnection;436;0;435;0
WireConnection;436;1;430;1
WireConnection;365;0;240;0
WireConnection;363;0;241;0
WireConnection;312;0;6;0
WireConnection;515;0;306;0
WireConnection;515;1;432;0
WireConnection;515;2;517;0
WireConnection;301;0;300;0
WireConnection;301;1;421;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;335;0;241;0
WireConnection;335;1;436;0
WireConnection;335;2;334;0
WireConnection;333;0;240;0
WireConnection;333;1;370;0
WireConnection;333;2;334;0
WireConnection;364;0;363;0
WireConnection;366;0;365;0
WireConnection;309;0;6;0
WireConnection;309;1;515;0
WireConnection;309;2;310;0
WireConnection;311;0;312;0
WireConnection;302;0;3;0
WireConnection;302;1;301;0
WireConnection;302;2;303;0
WireConnection;406;1;469;0
WireConnection;406;7;558;0
WireConnection;410;1;406;2
WireConnection;410;2;408;0
WireConnection;339;1;366;0
WireConnection;339;0;333;0
WireConnection;340;1;364;0
WireConnection;340;0;335;0
WireConnection;308;1;311;0
WireConnection;308;0;309;0
WireConnection;304;1;3;0
WireConnection;304;0;302;0
WireConnection;263;0;339;0
WireConnection;262;0;340;0
WireConnection;415;0;410;0
WireConnection;75;0;308;0
WireConnection;19;0;304;0
WireConnection;0;0;20;0
WireConnection;0;1;77;0
WireConnection;0;3;264;0
WireConnection;0;4;265;0
WireConnection;0;5;452;0
ASEEND*/
//CHKSM=01A539566A603DE72AD9652AB7C4C90B2D3CC4AB