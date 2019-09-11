// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "bef_effect_ai_hand.h"
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_skeleton.h"
#import "bef_effect_ai_public_define.h"
#import "bef_effect_ai_api.h"
#import "bef_effect_ai_face_attribute.h"
#import "bef_effect_ai_yuv_process.h"
#import "bef_effect_ai_human_distance.h"

@interface BEDetect : NSObject
- (void) faceDetect:(bef_ai_face_info*) faceInfo buffer:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation;
- (void)faceDetect280:(bef_ai_face_info *)faceInfo buffer:(unsigned char *)buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation;

- (void) skeletonDetect:(bef_skeleton_info*) skeletonDetectResult validCount:(int*)count buffer:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation;

- (void) handDetect:(bef_ai_hand_info*)faceDetectResult buffer:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation;

- (void) faceAttributeDetect:(bef_ai_face_attribute_result*)faceAttrResult buffer:(unsigned char*) buffer faceInfo:(bef_ai_face_106 *)faceInfo faceCount:(int)faceCount format:(bef_ai_pixel_format)format;

- (unsigned char* ) hairparseDetect:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation size:(int *)size;

- (unsigned char*) prortraitDetect:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation size:(int*)size;

- (int)setfaceVerifySourceFeature:(unsigned char* )buffer format:(bef_ai_pixel_format)format width:(int)iWidth height:(int)iHeight bytesPerRow:(int)bytesPerRow;
- (void)faceVerifyDetectSingle:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation similarity:(double*)similarity;

- (void)faceDistanceFaceDetect:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation faceDetectResult:(bef_ai_face_info*)faceInfo;
- (void)faceDistanceDetect:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation faceInfo:(bef_ai_face_info*)faceInfo faceDistanceResult:(bef_ai_human_distance_result*)distanceResult;

- (void) setSDKWidth:(int)width height:(int)height bytePerRow:(int)bytes;
- (void) releaseEffcetDetectSDK;
- (void) setupEffectDetectSDKWithLicenseVersion:(NSString*)path;
- (void) cvtYUV2RGBA:(unsigned char*) buffer dst:(unsigned char*)dst dst_width:(int) dst_width dst_height:(int) dst_height format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation is_front:(bool) is_front;
- (void) cvtRGBA2YUV:(unsigned char*) buffer dst:(unsigned char*)dst format:(bef_ai_pixel_format)format;
@end
