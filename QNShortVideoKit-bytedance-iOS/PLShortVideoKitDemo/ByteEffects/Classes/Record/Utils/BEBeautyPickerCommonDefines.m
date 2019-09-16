// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEBeautyPickerCommonDefines.h"
#import "BEEffectPickerDataStore.h"
@import AVFoundation;
/**
 This macro ensures that key path exists at compile time.
 */
#define BEKVOClassKeyPath(CLASS, KEYPATH) \
@(((void)(NO && ((void)((CLASS *)(nil)).KEYPATH, NO)), #KEYPATH))

NSString *const BERowDescriptorTagEnabled = @"kBERowDescriptorTagEnabled";
NSString *const BERowDescriptorTagCheekIntensity = @"kBERowDescriptorTagCheekIntensity";
NSString *const BERowDescriptorTagEyeIntensity = @"kBERowDescriptorTagEyeIntensity";
NSString *const BERowDescriptorTagSmoothIntensity = @"kBERowDescriptorTagSmoothIntensity";
NSString *const BERowDescriptorTagWhiteIntensity = @"kBERowDescriptorTagWhiteIntensity";
NSString *const BERowDescriptorTagSharpIntensity = @"kBERowDescriptorTagSharpIntensity";
NSString *const BERowDescriptorTagLipIntensity = @"kBERowDescriptorTagLipIntensity";
NSString *const BERowDescriptorTagBlusherIntensity = @"kBERowDescriptorTagBlusherIntensity";

NSString *const BERowDescriptorTagFaceDetect106 = @"kBERowDescriptorTagFaceDetect106";
NSString *const BERowDescriptorTagFaceDetect280 = @"kBERowDescriptorTagFaceDetect280";
NSString *const BERowDescriptorTagFaceDetectProperty = @"kBERowDescriptorTagFaceDetectProperty";


NSString *const BERowDescriptorTagBodySegmentationProperty = @"kBERowDescriptorTagBodySegmentationProperty";
NSString *const BERowDescriptorTagHairSegmentationProperty = @"kBERowDescriptorTagHairSegmentationProperty";

NSString *const BERowDescriptorTagFaceVerify = @"kBERowDescriptorTagFaceVerify";

NSDictionary *BERowDescriptorTagAndBeautyParamMapping() {
    static NSDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict =  @{
                  BERowDescriptorTagEnabled: BEKVOClassKeyPath(BEFaceBeautyModel, enabled),
                  BERowDescriptorTagCheekIntensity: BEKVOClassKeyPath(BEFaceBeautyModel, cheekIntensity),
                  BERowDescriptorTagEyeIntensity: BEKVOClassKeyPath(BEFaceBeautyModel, eyeIntensity),
                  BERowDescriptorTagSmoothIntensity: BEKVOClassKeyPath(BEFaceBeautyModel, smooth),
                  BERowDescriptorTagWhiteIntensity: BEKVOClassKeyPath(BEFaceBeautyModel, white),
                  BERowDescriptorTagSharpIntensity: BEKVOClassKeyPath(BEFaceBeautyModel, sharp),
                  BERowDescriptorTagLipIntensity: BEKVOClassKeyPath(BEFaceBeautyModel, lip),
                  BERowDescriptorTagBlusherIntensity: BEKVOClassKeyPath(BEFaceBeautyModel, blusher),
                  BERowDescriptorTagFaceDetect106: BEKVOClassKeyPath(BEEffectPickerDataStore, enableFaceDetect106),
                  BERowDescriptorTagFaceDetect280: BEKVOClassKeyPath(BEEffectPickerDataStore, enableFaceDetect280),
                  BERowDescriptorTagFaceDetectProperty: BEKVOClassKeyPath(BEEffectPickerDataStore, enableFaceDetectProps),
                  BERowDescriptorTagHairSegmentationProperty: BEKVOClassKeyPath(BEEffectPickerDataStore, enableHairSegmentation),
                  BERowDescriptorTagBodySegmentationProperty: BEKVOClassKeyPath(BEEffectPickerDataStore, enableBodySegmentation),
                  };
    });
    return dict;
}

NSString *const BEVideoRecorderSegmentContent640x480 = @"640x480";
NSString *const BEVideoRecorderSegmentContent1280x720 = @"1280x720";

NSDictionary* BEVideoRecorderSegmentContentAndSessionPresetMapping() {
    static NSDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict =  @{
                  BEVideoRecorderSegmentContent640x480: AVCaptureSessionPreset640x480,
                  BEVideoRecorderSegmentContent1280x720: AVCaptureSessionPreset1280x720,
                  };
    });
    return dict;
}
