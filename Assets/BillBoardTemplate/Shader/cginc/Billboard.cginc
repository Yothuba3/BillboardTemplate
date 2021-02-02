#ifndef BILLBOARD_INCLUDED //cginc書くときのお作法(インクルードガード)
#define BILLBOARD_INCLUDED //cginc書くときのお作法(インクルードガード)

#include"UnityCG.cginc"

float4 _Color;		//パーティクルの色
float _Scale;		//パーティクルの大きさ
float _VertSpace;	//頂点間隔 WaveModeのみ機能
float _TimeScale;   //そのまま WaveModeのみ機能
float _MasterLength;//全体の波の長さ
float _WaveLength;  //波長
float _Amplitude;   //振幅

struct appdata
{
    float4 vertex : POSITION;
};

struct g2f
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
};

//ビルボード用のQuad
//Quadを構成する4頂点分の情報
struct BBQuad{
    g2f leftUp;
    g2f rightUp;
    g2f rightUnder;
    g2f leftUnder;
};


float GetAspectRatio()	//アス比取得 ここは勉強不足
{
    return - UNITY_MATRIX_P[0][0] / UNITY_MATRIX_P[1][1];
}

//Quad生成(中心点，スケール，アス比，QuadのUV範囲)
BBQuad Geom_CreateQuad(float4 origin, float scale, float aspectRatio, float2 uvRange)
{
    BBQuad quad;
    float2 radius;
    radius = float2(0.5 * aspectRatio ,0.5) * scale * 0.01;
    quad.leftUp.vertex = origin + float4(-radius.x, radius.y, 0, 0);
    quad.rightUp.vertex = origin + float4(radius.x, radius.y, 0, 0);
    quad.rightUnder.vertex = origin + float4(radius.x, -radius.y, 0, 0);
    quad.leftUnder.vertex = origin + float4(-radius.x, -radius.y, 0, 0);

    quad.leftUp.uv = float2(uvRange.x, uvRange.y);
    quad.rightUp.uv = float2(uvRange.y,uvRange.y);
    quad.rightUnder.uv = float2(uvRange.y, uvRange.x);
    quad.leftUnder.uv = float2(uvRange.x, uvRange.x);

    return quad;
}

g2f vert (appdata v)
{
    g2f o;
    o.vertex = v.vertex;
    o.uv = float2(0,0);
    return o;
}

[maxvertexcount(6)]
void geom(triangle g2f input[3],uint pid : SV_PrimitiveID, inout TriangleStream<g2f> stream)
{
    float4 origin;
    #ifdef _MODE_WAVE //WaveMode
    //particle一つの中心点の座標設定
    origin.x = pid * _VertSpace + _Time.x * _TimeScale;
    origin.x = origin.x % _MasterLength;
    origin.y = sin(origin.x / (_WaveLength*0.1)) * _Amplitude;
    origin.z = sin(origin.x / (_WaveLength*0.1) + 1.5) * _Amplitude;
    origin.w = 0.0;

    #elif _MODE_POINT //一ポリゴンの重心をparticleの中心点とする
    if(pid % 2 == 0) return;
    origin = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
    #endif

    float aspectRatio = GetAspectRatio();
    origin = UnityObjectToClipPos(origin); //ビルボードは常にカメラ方向を向くためQuad生成前にMVP変換
    BBQuad quad = Geom_CreateQuad(origin, _Scale, aspectRatio, float2(-1,1));

    stream.Append(quad.leftUp);
    stream.Append(quad.rightUp);
    stream.Append(quad.rightUnder);
    stream.RestartStrip();

    stream.Append(quad.leftUp);
    stream.Append(quad.rightUnder);
    stream.Append(quad.leftUnder);
    stream.RestartStrip();

}

float4 frag (g2f i) : SV_Target
{
    float l = length(i.uv);
    clip(1 - l);
    float4 color = _Color;
    color.a = 1.0 / ((l / 0.25) * ( l / 0.25)); //距離の逆2乗で透明度
    return color;
}
#endif