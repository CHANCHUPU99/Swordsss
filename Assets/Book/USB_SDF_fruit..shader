Shader "Unlit/USB_SDF_fruit."
{
    Properties
    {
        _Maintex ("Texture", 2D) = "white" {}
        // plane texture
        _PlaneTex ("Plane Texture", 2D) = "white" {}
        // edge color projection
        _CircleCol ("Circle Color", Color) = (1, 1, 1, 1)
        // edge radius projection
        _CircleRad ("Circle Radius", Range(0.0, 0.5)) = 0.45
        _Edge ("Edge", Range(-0.5, 0.5)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 hitPos : TEXCOORD1;
            };

           sampler2D _MainTex;
            sampler2D _PlaneTex;
            float4 _MainTex_ST;
            float4 _CircleCol;
            float _CircleRad;
            float _Edge;

            float planeSDF(float3 ray_position)
            {
                   
                    float plane = ray_position.y - _Edge;
                    return plane;
            }
            // maximum of steps to determine the surface intersection
            #define MAX_MARCHIG_STEPS 50
            // maximum distance to find the surface intersection
            #define MAX_DISTANCE 10.0
            // surface distance
            #define SURFACE_DISTANCE 0.001

            float sphereCasting(float3 ray_origin, float3 ray_direction)
                {
                float distance_origin = 0;
                for(int i = 0; i < MAX_MARCHIG_STEPS; i++)
                {
                float3 ray_position = ray_origin + ray_direction *
                distance_origin;
                float distance_scene = planeSDF(ray_position);
                distance_origin += distance_scene;
                if(distance_scene < SURFACE_DISTANCE || distance_origin >
                MAX_MARCHIG_STEPS);
                break;
                }
                return distance_origin;
                }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // we assign the vertex position in object-space
                o.hitPos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i, bool face : SV_isFrontFace) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 ray_origin = mul(unity_WorldToObject, float4(
                _WorldSpaceCameraPos, 1));
                float3 ray_direction = normalize(i.hitPos - ray_origin);
                float t = sphereCasting(ray_origin, ray_direction);
                float4 PlaneCol = 0;
                if(t < MAX_DISTANCE)
                {
                    float3 p = ray_origin + ray_direction * t;
                    float2 uv_p = p.xz;
                    planeCol = tex2D(_PlaneTex, uv_p);
                }
                if (i.hitPos > _Edge)
                    discard;
                return face ? col : planeCol);
            }

            ENDCG
            
        }
    }
}
