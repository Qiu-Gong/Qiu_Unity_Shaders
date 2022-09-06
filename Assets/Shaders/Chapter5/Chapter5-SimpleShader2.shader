// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "Unity Shaders Book/Chapter 5/Simple Shader2"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct a2v
            {
                // POSITION 语义告诉Unity，用模型空间的顶点坐标填充 vertex 变量
                float4 vertex:POSITION;
                // NORMAL 语义告诉Unity，用模型空间的法线方向填充 normal 变量
                float3 normal:NORMAL;
                // TEXCOORD0 语义告诉Unity，用模型的第一套纹理坐标填充 texcoord 变量
                float4 texcoord:TEXCOORD0;
            };

            float4 vert(a2v v):SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }

            fixed4 frag():SV_Target
            {
                return fixed4(1.0, 0.0, 0.0, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}