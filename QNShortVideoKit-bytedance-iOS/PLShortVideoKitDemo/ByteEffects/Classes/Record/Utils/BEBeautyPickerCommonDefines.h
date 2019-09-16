// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>

extern NSString *const BERowDescriptorTagEnabled;
extern NSString *const BERowDescriptorTagCheekIntensity;
extern NSString *const BERowDescriptorTagEyeIntensity;
extern NSString *const BERowDescriptorTagSmoothIntensity;
extern NSString *const BERowDescriptorTagWhiteIntensity;
extern NSString *const BERowDescriptorTagSharpIntensity;
extern NSString *const BERowDescriptorTagLipIntensity;
extern NSString *const BERowDescriptorTagBlusherIntensity;

extern NSString *const BERowDescriptorTagFaceDetect106;
extern NSString *const BERowDescriptorTagFaceDetect280;
extern NSString *const BERowDescriptorTagFaceDetectProperty;
extern NSString *const BERowDescriptorTagFaceVerify;

extern NSString *const BERowDescriptorTagBodySegmentationProperty;
extern NSString *const BERowDescriptorTagHairSegmentationProperty;

extern NSDictionary *BERowDescriptorTagAndBeautyParamMapping(void);

extern NSString *const BEVideoRecorderSegmentContent640x480;
extern NSString *const BEVideoRecorderSegmentContent1280x720;

extern NSDictionary *BEVideoRecorderSegmentContentAndSessionPresetMapping(void);
