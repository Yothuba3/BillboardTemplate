Shader "Yothuba/BillBoard/Unlit/BillBoard"
{
 Properties
    {
        [Header(Base Setting)]
        [HDR]_Color("Color",Color) = (1,1,1)
        _Scale("Scale", FLoat) = 0.2 //particle scale

        [Space][Header(Mode)]
        [KeywordEnum(WAVE,POINT)] _Mode("Animation Mode", Float) = 0

        [Space][Header(VertSetting)]
        _VertSpace("VertSpace",Float) = 1.0 //頂点間隔 WaveModeのみ機能
        _TimeScale("TimeScale",Float) = 1.0 //そのまま WaveModeのみ機能

        [Space][Header(WAVE Settings)]
        _MasterLength("MasterLength",Float) = 50 //全体の波の長さ
        _WaveLength("WaveLength",Float) = 1 //波長
        _Amplitude("Amplitude", Float) = 1.0 //振幅
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType"="Transparent"
                "LightMode" = "ForwardBase"
            }
            Blend SrcAlpha One

            LOD 100
            Cull OFF
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
            #pragma multi_compile _MODE_WAVE _MODE_POINT
            #include "cginc/Billboard.cginc"
            ENDCG
        }
    }
}
