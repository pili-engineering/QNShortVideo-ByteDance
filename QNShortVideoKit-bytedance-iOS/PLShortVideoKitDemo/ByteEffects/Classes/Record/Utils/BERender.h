// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "bef_effect_ai_hand.h"
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_skeleton.h"
#import "bef_effect_ai_public_define.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>
#import "BEEffectBaseDefine.h"

@interface BERender : NSObject

@property (nonatomic, strong) NSMutableDictionary* composeNodeDict;

- (void) genInputAndOutputTexture:(unsigned char*) buffer width:(int)iwidth height:(int)iheight;
- (GLuint) processInputTexture:(double) timeStamp;

- (void) renderMangerSetWidth:(int) iWidth height:(int)iHeight orientation:(int)orientation;
- (void) renderHelperSetWidth:(int)width height:(int)height resizeRatio:(float)ratio;
- (GLuint)transforImageToTexture:(unsigned char*)buffer imageWidth:(int)iWidth height:(int)iHeight;

- (void)transforTextureToImage:(GLuint)texture buffer:(unsigned char*)buffer width:(int)iWidth height:(int)iHeight;

- (void) drawFace:(bef_ai_face_info *)faceDetectResult withExtra:(BOOL)extra;
- (void) drawFaceRect:(bef_ai_face_info *)faceDetectResult;

- (void) drawHands:(bef_ai_hand_info* )handDetectResult;

- (void)drawSkeleton:(bef_skeleton_info*) skeletonDetectResult withCount:(int)validCount;

- (void) drawHairParse:(unsigned char*)mask size:(int*)size;

- (void) drawPrortrait:(unsigned char*)mask size:(int*)size;

- (int)setEffectPath:(NSString *)path type:(BEEffectType)type;
- (void)setRenderMangerLicense:(NSString *)license;
- (void)setIndensity:(BEIndensityParam)indensity type:(BEEffectType)type;
- (void)setFaceBeautyPath:(NSString *)path withIndensity:(BEIndensityParam)indensity;
- (void)setReshapePath:(NSString *)path withIndensity:(BEIndensityParam)indensity;
- (void)setFilterPath:(NSString *)path;
- (void)setFilterIntensity:(float)intensity;
- (void)setGlobalFilterIntensity:(float)intensity;

- (void)setStickerPath:(NSString *)path;

- (BOOL) isFaceReshaped;

- (void)setupEffectRenderMangerWithLicenseVersion:(NSString *)path;
- (void)releaseEffectRenderManger;

- (void) renderHelperSetResizeRatio:(float) ratio;

- (void)updateFaceMakeUpResourceWithType:(NSString*) type path:(NSString*)path;
- (void)clearFaceMakeUpEffect;
- (void) updataComposeDictNodeWithType:(BEEffectFaceBeautyType)type;
- (void)setInitStatus;
@end
