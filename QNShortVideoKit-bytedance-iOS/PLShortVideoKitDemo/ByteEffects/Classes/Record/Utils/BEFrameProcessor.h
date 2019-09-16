// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "BEEffectBaseDefine.h"
#import "bef_effect_ai_hand.h"
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_face_attribute.h"
#import "bef_effect_ai_human_distance.h"

@class BEFrameProcessor;

@protocol BEFrameProcessorDelegate <NSObject>

@optional

- (void)BEFrameProcessor:(BEFrameProcessor *)processor didDetectHandInfo:(bef_ai_hand_info)handInfo;
- (void)BEFrameProcessor:(BEFrameProcessor *)processor didDetectFaceInfo:(bef_ai_face_info)faceInfo;
- (void) BEFrameProcessor:(BEFrameProcessor *)processor didDetectExtraFaceInfo:(bef_ai_face_attribute_result)faceInfo;
- (void) BEFrameProcessor:(BEFrameProcessor *)processor updateFaceVerifyInfo:(double)similarity costTime:(long)time;
- (void)BEFrameProcessor:(BEFrameProcessor *)processor didDetectFace:(bef_ai_face_info)faceInfo distance:(bef_ai_human_distance_result) distance;

@end

@interface BEProcessResult : NSObject
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, assign) CGSize size;
@end

@interface BEFrameProcessor : NSObject
@property (nonatomic, weak) id<BEFrameProcessorDelegate> delegate;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, assign) CGSize videoDimensions;
@property (nonatomic, readonly) NSString *triggerAction;

- (instancetype)initWithContext:(EAGLContext *)context videoSize:(CGSize)size;
- (BEProcessResult *)process:(CVPixelBufferRef)pixelBuffer timeStamp:(double)timeStamp;
- (void)dealloc;

- (int)setEffectPath:(NSString *)path type:(BEEffectType)type;
- (void)setIndensity:(BEIndensityParam)indensity type:(BEEffectType)type;
- (void)setFaceBeautyPath:(NSString *)path withIndensity:(BEIndensityParam)indensity;
- (void)setReshapePath:(NSString *)path withIndensity:(BEIndensityParam)indensity;
- (void)setFilterPath:(NSString *)path;
- (void)setFilterIntensity:(float)intensity;
- (void)setRenderLicense:(NSString *)license;
//- (void)setGlobalFilterIntensity:(float)intensity;

- (void)setFaceDetector:(BOOL)on;
- (void)setFaceAttrDetector:(BOOL)on;
- (void)setFaceExtraDetector:(BOOL)on;

- (void)setSkeletonDetector:(BOOL)on;
- (void)setGestureDetector:(BOOL)on;

- (void)setStickerPath:(NSString *)path;

- (void)setHairSegmentationOn:(BOOL) on;
- (void)setBodySegmentationOn:(BOOL) on;
- (void)setFaceVerifyOn:(BOOL) on;

-(void) setFaceDistanceOn:(BOOL) on;

- (int)setFaceVerifysoSourceImageAndGenFeature:(UIImage*) image;
- (void)setFaceMakeUpType:(NSString*) type path:(NSString*)path;
- (void)clearFaceMakeUpEffect;
- (void)renderSetInternalStatus:(BEEffectFaceBeautyType)type;
- (void)renderSetInitStatus;
@end
