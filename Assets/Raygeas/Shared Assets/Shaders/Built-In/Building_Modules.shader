// Made with Amplify Shader Editor v1.9.9.4
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Raygeas/Built-In/Building_Modules"
{
	Properties
	{
		[Header(Main Layer Maps)][Space(5)] _Tiling( "Tiling", Float ) = 1
		[NoScaleOffset] _MainTex( "Albedo", 2D ) = "white" {}
		[NoScaleOffset][Normal] _BumpMap( "Normal", 2D ) = "bump" {}
		[NoScaleOffset] _MetallicGlossMap( "Metallic/Smoothness", 2D ) = "white" {}
		[Header(Main Layer Settings)][Space(5)] _Color( "Color", Color ) = ( 1, 1, 1 )
		_Metallic( "Metallic", Range( 0, 1 ) ) = 0
		_Glossiness( "Smoothness", Range( 0, 1 ) ) = 0
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel( "Smoothness Source", Float ) = 0
		_NormalScale( "Normal Scale", Float ) = 1
		[Header(Alternative Layer Maps)][Space(5)] _Tiling_2( "Tiling", Float ) = 1
		[NoScaleOffset] _MainTex_2( "Albedo", 2D ) = "white" {}
		[NoScaleOffset][Normal] _BumpMap_2( "Normal", 2D ) = "bump" {}
		[NoScaleOffset] _MetallicGlossMap2( "Metallic/Smoothness", 2D ) = "white" {}
		[NoScaleOffset] _HeightMask( "Height", 2D ) = "white" {}
		[NoScaleOffset] _OverlayMask( "Overlay Mask", 2D ) = "white" {}
		[Header(Alternative Layer Settings)][Space(5)][Toggle( _ENABLEALTLAYER_ON )] _EnableAltLayer( "Enable", Float ) = 0
		[Space(10)] _Color_2( "Color", Color ) = ( 1, 1, 1 )
		_Metallic2( "Metallic", Range( 0, 1 ) ) = 0
		_Glossiness2( "Smoothness", Range( 0, 1 ) ) = 0
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel2( "Smoothness Source", Float ) = 0
		_NormalScale_2( "Normal Scale", Float ) = 1
		[Header(Mask Settings)][Space(5)] _MaskTiling( "Tiling", Float ) = 1
		_MaskLevel( "Level", Float ) = 2
		_MaskContrast( "Contrast", Float ) = 10
		_HeightBlending( "Height Blending", Range( 1, 10 ) ) = 1
		[Space(10)] _MaskOffset( "Mask Offset", Vector ) = ( 1, 1, 1, 0 )
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
		#pragma shader_feature_local _ENABLEALTLAYER_ON
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
		};

		UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
		uniform float _Tiling;
		SamplerState sampler_BumpMap;
		uniform float _NormalScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap_2);
		uniform float _Tiling_2;
		SamplerState sampler_BumpMap_2;
		uniform float _NormalScale_2;
		uniform float _MaskLevel;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_OverlayMask);
		SamplerState sampler_OverlayMask;
		uniform float _MaskTiling;
		uniform float3 _MaskOffset;
		uniform float _MaskContrast;
		uniform float _HeightBlending;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_HeightMask);
		SamplerState sampler_Linear_Repeat;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex);
		uniform float3 _Color;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex_2);
		uniform float3 _Color_2;
		uniform float _Metallic;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap);
		uniform float _Metallic2;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap2);
		uniform float _SmoothnessTextureChannel;
		uniform float _Glossiness;
		uniform float _SmoothnessTextureChannel2;
		uniform float _Glossiness2;


		inline float4 TriplanarSampling17( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_Tiling).xx;
			float2 uv_TexCoord48 = i.uv_texcoord * temp_cast_0;
			float2 Tiling52 = uv_TexCoord48;
			float3 tex2DNode2 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, Tiling52 ), _NormalScale );
			float2 temp_cast_1 = (_Tiling_2).xx;
			float2 uv_TexCoord56 = i.uv_texcoord * temp_cast_1;
			float2 Tiling_257 = uv_TexCoord56;
			float2 temp_cast_2 = (_MaskTiling).xx;
			float3 ase_positionWS = i.worldPos;
			float3 ase_normalWS = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar17 = TriplanarSampling17( _OverlayMask, sampler_OverlayMask, ( ase_positionWS + _MaskOffset ), ase_normalWS, 1.0, temp_cast_2, 1.0, 0 );
			float4 temp_cast_3 = (triplanar17.x).xxxx;
			float4 saferPower26 = abs( CalculateContrast(_MaskLevel,temp_cast_3) );
			float4 temp_cast_4 = (_MaskContrast).xxxx;
			float4 Mask36 = saturate( ( pow( saferPower26 , temp_cast_4 ) * CalculateContrast(_HeightBlending,SAMPLE_TEXTURE2D( _HeightMask, sampler_Linear_Repeat, Tiling_257 )) ) );
			float3 lerpResult39 = lerp( tex2DNode2 , UnpackScaleNormal( SAMPLE_TEXTURE2D( _BumpMap_2, sampler_BumpMap_2, Tiling_257 ), _NormalScale_2 ) , Mask36.rgb);
			#ifdef _ENABLEALTLAYER_ON
				float3 staticSwitch87 = lerpResult39;
			#else
				float3 staticSwitch87 = tex2DNode2;
			#endif
			float3 Normal44 = staticSwitch87;
			o.Normal = Normal44;
			float4 tex2DNode1 = SAMPLE_TEXTURE2D( _MainTex, sampler_Linear_Repeat, Tiling52 );
			float3 temp_output_4_0 = ( tex2DNode1.rgb * _Color );
			float4 tex2DNode24 = SAMPLE_TEXTURE2D( _MainTex_2, sampler_Linear_Repeat, Tiling_257 );
			float3 lerpResult22 = lerp( temp_output_4_0 , ( tex2DNode24.rgb * _Color_2 ) , Mask36.rgb);
			#ifdef _ENABLEALTLAYER_ON
				float3 staticSwitch86 = lerpResult22;
			#else
				float3 staticSwitch86 = temp_output_4_0;
			#endif
			float3 Albedo6 = staticSwitch86;
			o.Albedo = Albedo6;
			float4 tex2DNode112 = SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_Linear_Repeat, Tiling52 );
			float temp_output_114_0 = ( _Metallic * tex2DNode112.r );
			float4 tex2DNode128 = SAMPLE_TEXTURE2D( _MetallicGlossMap2, sampler_Linear_Repeat, Tiling_257 );
			float lerpResult136 = lerp( temp_output_114_0 , ( _Metallic2 * tex2DNode128.r ) , Mask36.r);
			#ifdef _ENABLEALTLAYER_ON
				float staticSwitch139 = lerpResult136;
			#else
				float staticSwitch139 = temp_output_114_0;
			#endif
			float Metallic116 = staticSwitch139;
			o.Metallic = Metallic116;
			float Albedo_Alpha118 = tex2DNode1.a;
			float lerpResult117 = lerp( tex2DNode112.a , Albedo_Alpha118 , _SmoothnessTextureChannel);
			float temp_output_122_0 = ( lerpResult117 * _Glossiness );
			float Albedo_Alpha_2119 = tex2DNode24.a;
			float lerpResult130 = lerp( tex2DNode128.a , Albedo_Alpha_2119 , _SmoothnessTextureChannel2);
			float lerpResult138 = lerp( temp_output_122_0 , ( lerpResult130 * _Glossiness2 ) , Mask36.r);
			#ifdef _ENABLEALTLAYER_ON
				float staticSwitch141 = lerpResult138;
			#else
				float staticSwitch141 = temp_output_122_0;
			#endif
			float Smoothness124 = staticSwitch141;
			o.Smoothness = Smoothness124;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows dithercrossfade 

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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;35;-2992,-896;Inherit;False;2173.801;889.0488;;18;36;108;104;99;26;88;33;100;34;111;27;17;29;18;82;79;80;153;Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;80;-2960,-688;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;79;-2960,-512;Inherit;False;Property;_MaskOffset;Mask Offset;25;0;Create;False;0;0;0;False;1;Space(10);False;1,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;82;-2656,-608;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;18;-2752,-832;Inherit;True;Property;_OverlayMask;Overlay Mask;14;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;1c37632da4539e94397a93db7998a959;1c37632da4539e94397a93db7998a959;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;29;-2688,-496;Inherit;False;Property;_MaskTiling;Tiling;21;0;Create;False;0;0;0;False;2;Header(Mask Settings);Space(5);False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;60;-2464,736;Inherit;False;750;558;;6;57;52;56;48;55;49;Tiling;1,1,1,1;0;0
Node;AmplifyShaderEditor.TriplanarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;17;-2400,-720;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;27;-2192,-512;Inherit;False;Property;_MaskLevel;Level;22;0;Create;False;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;111;-2416,-320;Inherit;False;57;Tiling 2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;153;-2432,-224;Inherit;False;145;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;55;-2416,1104;Inherit;False;Property;_Tiling_2;Tiling;9;0;Create;False;0;0;0;False;2;Header(Alternative Layer Maps);Space(5);False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;34;-1936,-480;Inherit;False;Property;_MaskContrast;Contrast;23;0;Create;False;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;100;-2176,-112;Inherit;False;Property;_HeightBlending;Height Blending;24;0;Create;True;0;0;0;False;0;False;1;0;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;33;-1968,-608;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;88;-2176,-352;Inherit;True;Property;_HeightMask;Height;13;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;7516c543d04386a4e986cb427978a4db;7516c543d04386a4e986cb427978a4db;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;146;-1664,736;Inherit;False;557;214.9999;;2;145;144;Sampler State;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;56;-2208,1072;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;49;-2416,880;Inherit;False;Property;_Tiling;Tiling;0;0;Create;False;0;0;0;False;2;Header(Main Layer Maps);Space(5);False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;46;-4864,-896;Inherit;False;1805.918;886.645;;16;6;86;22;37;25;4;23;3;119;118;24;1;58;53;147;148;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;26;-1712,-560;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleContrastOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;99;-1744,-240;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;57;-1952,1072;Inherit;False;Tiling 2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;48;-2208,848;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;143;-4864,96;Inherit;False;2340;1267;;29;113;135;120;112;121;127;129;128;117;123;115;130;131;134;122;114;132;133;137;136;138;140;142;139;141;116;124;149;150;Metallic/Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;104;-1456,-416;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;118;-4208,-576;Inherit;False;Albedo Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;119;-4208,-144;Inherit;False;Albedo Alpha 2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerStateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;144;-1584,816;Inherit;False;0;0;0;1;-1;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;52;-1952,848;Inherit;False;Tiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;58;-4832,-384;Inherit;False;57;Tiling 2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;113;-4816,304;Inherit;False;52;Tiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;135;-4816,912;Inherit;False;57;Tiling 2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;108;-1264,-416;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;47;-2464,96;Inherit;False;1455.332;556.1151;;10;44;87;39;38;2;40;59;42;41;54;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;120;-4480,544;Inherit;False;118;Albedo Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;121;-4480,640;Inherit;False;Property;_SmoothnessTextureChannel;Smoothness Source;7;1;[Enum];Create;False;0;2;Metallic Alpha;0;Albedo Alpha;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;127;-4480,1152;Inherit;False;119;Albedo Alpha 2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;129;-4480,1248;Inherit;False;Property;_SmoothnessTextureChannel2;Smoothness Source;19;1;[Enum];Create;False;0;2;Metallic Alpha;0;Albedo Alpha;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;145;-1360,816;Inherit;False;SamplerState;-1;True;1;0;SAMPLERSTATE;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;148;-4864,-288;Inherit;False;145;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;149;-4848,400;Inherit;False;145;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;150;-4848,1008;Inherit;False;145;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;53;-4832,-768;Inherit;False;52;Tiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;112;-4544,256;Inherit;True;Property;_MetallicGlossMap;Metallic/Smoothness;3;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;128;-4544,864;Inherit;True;Property;_MetallicGlossMap2;Metallic/Smoothness;12;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;36;-1056,-416;Inherit;False;Mask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;117;-4128,448;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;123;-4192,640;Inherit;False;Property;_Glossiness;Smoothness;6;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;115;-4192,144;Inherit;False;Property;_Metallic;Metallic;5;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;130;-4128,1056;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;131;-4192,1248;Inherit;False;Property;_Glossiness2;Smoothness;18;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;134;-4192,752;Inherit;False;Property;_Metallic2;Metallic;17;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;23;-4528,-208;Inherit;False;Property;_Color_2;Color;16;0;Create;False;0;0;0;False;1;Space(10);False;1,1,1,0;0,0,0,0;True;False;0;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;147;-4864,-672;Inherit;False;145;SamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;42;-2416,464;Inherit;False;Property;_NormalScale_2;Normal Scale;20;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;59;-2416,384;Inherit;False;57;Tiling 2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;24;-4592,-416;Inherit;True;Property;_MainTex_2;Albedo;10;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;54;-2416,144;Inherit;False;52;Tiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;41;-2416,224;Inherit;False;Property;_NormalScale;Normal Scale;8;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;3;-4528,-592;Inherit;False;Property;_Color;Color;4;0;Create;False;0;0;0;False;2;Header(Main Layer Settings);Space(5);False;1,1,1,0;0,0,0,0;True;False;0;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;40;-2080,544;Inherit;False;36;Mask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;38;-2176,352;Inherit;True;Property;_BumpMap_2;Normal;11;2;[NoScaleOffset];[Normal];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;122;-3824,448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;114;-3824,288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;132;-3824,1056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;133;-3824,896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;137;-3648,384;Inherit;False;36;Mask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;25;-4176,-304;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;37;-4160,-464;Inherit;False;36;Mask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;1;-4592,-800;Inherit;True;Property;_MainTex;Albedo;1;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;2;-2176,144;Inherit;True;Property;_BumpMap;Normal;2;2;[NoScaleOffset];[Normal];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;4;-4176,-704;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;39;-1776,320;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;136;-3344,288;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;138;-3344,448;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;140;-3296,240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;142;-3296,416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;22;-3872,-512;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;87;-1552,144;Inherit;False;Property;_Keyword0;Keyword 0;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;86;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;139;-3104,256;Inherit;False;Property;_Keyword1;Keyword 1;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;86;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;141;-3104,432;Inherit;False;Property;_Keyword2;Keyword 1;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;86;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;86;-3600,-704;Inherit;False;Property;_EnableAltLayer;Enable;15;0;Create;False;0;0;0;False;2;Header(Alternative Layer Settings);Space(5);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;44;-1248,144;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;116;-2768,256;Inherit;False;Metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;124;-2768,432;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;6;-3296,-704;Inherit;False;Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;7;-688,192;Inherit;False;6;Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;45;-688,288;Inherit;False;44;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;125;-688,384;Inherit;False;116;Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;126;-688,480;Inherit;False;124;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;0;-432,224;Float;False;True;-1;2;;0;0;Standard;Raygeas/Built-In/Building_Modules;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;82;0;80;0
WireConnection;82;1;79;0
WireConnection;17;0;18;0
WireConnection;17;9;82;0
WireConnection;17;3;29;0
WireConnection;33;1;17;1
WireConnection;33;0;27;0
WireConnection;88;1;111;0
WireConnection;88;7;153;0
WireConnection;56;0;55;0
WireConnection;26;0;33;0
WireConnection;26;1;34;0
WireConnection;99;1;88;0
WireConnection;99;0;100;0
WireConnection;57;0;56;0
WireConnection;48;0;49;0
WireConnection;104;0;26;0
WireConnection;104;1;99;0
WireConnection;118;0;1;4
WireConnection;119;0;24;4
WireConnection;52;0;48;0
WireConnection;108;0;104;0
WireConnection;145;0;144;0
WireConnection;112;1;113;0
WireConnection;112;7;149;0
WireConnection;128;1;135;0
WireConnection;128;7;150;0
WireConnection;36;0;108;0
WireConnection;117;0;112;4
WireConnection;117;1;120;0
WireConnection;117;2;121;0
WireConnection;130;0;128;4
WireConnection;130;1;127;0
WireConnection;130;2;129;0
WireConnection;24;1;58;0
WireConnection;24;7;148;0
WireConnection;38;1;59;0
WireConnection;38;5;42;0
WireConnection;122;0;117;0
WireConnection;122;1;123;0
WireConnection;114;0;115;0
WireConnection;114;1;112;1
WireConnection;132;0;130;0
WireConnection;132;1;131;0
WireConnection;133;0;134;0
WireConnection;133;1;128;1
WireConnection;25;0;24;5
WireConnection;25;1;23;0
WireConnection;1;1;53;0
WireConnection;1;7;147;0
WireConnection;2;1;54;0
WireConnection;2;5;41;0
WireConnection;4;0;1;5
WireConnection;4;1;3;0
WireConnection;39;0;2;0
WireConnection;39;1;38;0
WireConnection;39;2;40;0
WireConnection;136;0;114;0
WireConnection;136;1;133;0
WireConnection;136;2;137;0
WireConnection;138;0;122;0
WireConnection;138;1;132;0
WireConnection;138;2;137;0
WireConnection;140;0;114;0
WireConnection;142;0;122;0
WireConnection;22;0;4;0
WireConnection;22;1;25;0
WireConnection;22;2;37;0
WireConnection;87;1;2;0
WireConnection;87;0;39;0
WireConnection;139;1;140;0
WireConnection;139;0;136;0
WireConnection;141;1;142;0
WireConnection;141;0;138;0
WireConnection;86;1;4;0
WireConnection;86;0;22;0
WireConnection;44;0;87;0
WireConnection;116;0;139;0
WireConnection;124;0;141;0
WireConnection;6;0;86;0
WireConnection;0;0;7;0
WireConnection;0;1;45;0
WireConnection;0;3;125;0
WireConnection;0;4;126;0
ASEEND*/
//CHKSM=FBE90A4197BC0D7A567D092165D1ABD283F70AC1