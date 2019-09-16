// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#ifndef BEEffectBaseDefine_h
#define BEEffectBaseDefine_h

typedef struct BEIndensityParam_t {
    // 通用
    float indensity;
    // 美颜
    float smoothIndensity;
    float whiteIndensity;
    float sharpIndensity;
    // 大眼瘦脸
    float eyeIndensity;
    float cheekIndensity;
    // Makeup
    float lipIndensity;     // 唇彩
    float blusherIndensity; // 腮红
} BEIndensityParam;

typedef NS_ENUM(NSInteger, BEEffectType) {
    //无效果
    BEEffectNone = 0,
    //美颜
    BEEffectBeautify,
    //滤镜
    BEEffectFilter,
    //变形
    BEEffectReshape,
    BEEffectReshapeTwoParam,
    //彩妆（口红、腮红）
    BEEffectMakeup,
};

typedef NS_ENUM(NSInteger, BEEffectFaceBeautyType) {
    //处于清空状态
    BEEffectClearStatus = -999,
    
    //美妆无效果
    BEEffectFaceMakeNone = -2,
    //美颜无效果
    BEEffectFaceBeautyNone = -1,
    //瘦脸
    BEEffectFaceBeautyReshape = 0,
    //大眼
    BEEffectFaceBeautyBigEye,
    //磨皮
    BEEffectFaceBeautySmooth,
    //美白
    BEEffectFaceBeautyWhiten,
    //锐化
    BEEffectFaceBeautySharp,
    //美唇
    BEEffectFaceMakeUpLips,
    //腮红
    BEEffectFaceMakeUpBlusher,
    //滤镜
    BEEffectFaceFilter,
};

typedef NS_ENUM(NSInteger, BEEffectFaceMakeUpType) {
    //无效果
    BEEffectFaceMakeUpNone = -1,
    //腮红
    BEEffectFaceMakeUpBlush,
    //口红
    BEEffectFaceMakeUpLip,
    //睫毛
    BEEffectFaceMakeUpEyelash,
    //美瞳
    BEEffectFaceMakeUpPupil,
    //眼影
    BEEffectFaceMakeUpHair,
    //头发
    BEEffectFaceMakeUpEyeshadow,
    //眉毛
    BEEffectFaceMakeUpEyebrow,
};

#endif /* BEEffectBaseDefine_h */
