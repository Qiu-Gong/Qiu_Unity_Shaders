Shader "Unity Shaders Book/Chapter 7/Ramp Texture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _RampTex("Tamp Tex", 2D) = "white"{}
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags
        {
            "LightMode" = "ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 计算经过平铺和偏移后的纹理坐标
                o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // Use the texture to sample the diffuse color
                // 通过对法线方向和光照方向的点积做一次0.5倍的缩放以及一个0.5大小的偏移来计算半兰伯特部分 halfLambert
                // 得到的halfLambert的范围被映射到了[0,1]之间
                fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                // 我们使用 halfLambert来构建一个纹理坐标，并用这个纹理坐标对渐变纹理 _RampTex 进行采样。
                // 由于 _RampTex 实际就是一个一维纹理（它在纵轴方向上颜色不变），因此纹理坐标的u和v方向我们都使用了 halfLambert
                fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
                // 然后，把从渐变纹理采样得到的颜色和材质颜色_Color相乘，得到最终的漫反射颜色。
                fixed3 diffuse = _LightColor0.rgb * diffuseColor;

                // 计算高光反射和环境光
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}