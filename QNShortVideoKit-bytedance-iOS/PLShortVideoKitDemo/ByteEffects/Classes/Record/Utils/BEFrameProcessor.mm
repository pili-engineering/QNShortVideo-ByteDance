// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import "BEFrameProcessor.h"
#import <CoreMotion/CoreMotion.h>
#import <OpenGLES/ES2/glext.h>
#import "bef_effect_ai_api.h"
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_yuv_process.h"

#import "BEDetect.h"
#import "BERender.h"
#import <memory>


@implementation BEProcessResult
@end

@interface BEFrameProcessor() {
    
    EAGLContext *_glContext;
    
    BOOL                    _detectFaceOn;
    BOOL                    _detectFaceExtraOn;
    BOOL                    _detectFaceAttrOn;
    BOOL                    _detectGestureOn;
    
    BOOL                    _detectSkeletonOn;
    BOOL                    _detectHairSegmentationOn;
    BOOL                    _detectBodySegmentationOn;
    BOOL                    _detectFaceVerifyOn;
    BOOL                    _faceVerifyCurrentVaild;
    
    BOOL                    _faceDistanceOn;

    BERender*               _render;
    BEDetect*               _detect;
    
    dispatch_queue_t    _face_verify_queen;
}
//@property (nonatomic, assign) UIImage* currentFaceVerifyImage;

@end

@implementation BEFrameProcessor

/**
 * license有效时间2019-03-01到2019-04-30
 * license只是为了追踪使用情况，可以随时申请无任何限制license
 */

static NSString * LICENSE_PATH = @"/qiniu_test_20190829_20191030_com.qiniu.shortvideo.bytedance_qiniu_test_v2.7.2.licbag";

static CGSize FACE_106_MODEL_INPUT;
static CGSize FACE_280_MODEL_INPUT;
static CGSize FaceAttriInput;
static CGSize HAND_MODEL_INPUT;
static CGSize SKELETON_MODEL_INPUT;
static CGSize HAIR_MODEL_INPUT;
static CGSize MATTINGINPUT;


- (instancetype)initWithContext:(EAGLContext *)context videoSize:(CGSize)size {
    self = [super init];
    if (self) {
        _glContext = context;
        _videoDimensions = size;
        
        _detectFaceOn = NO;
        _detectFaceExtraOn = NO;
        _detectFaceAttrOn = NO;
        _detectSkeletonOn = NO;
        _detectGestureOn = NO;
        _detectHairSegmentationOn = NO;
        _detectBodySegmentationOn = NO;
        _faceVerifyCurrentVaild = NO;
        _detectFaceVerifyOn = NO;
        _faceDistanceOn = NO;
        
        _render = [[BERender alloc] init];
        _detect = [[BEDetect alloc] init];
        //_currentFaceVerifyImage = nil;
        //_face_verify_queen = dispatch_queue_create("faceVerify", DISPATCH_QUEUE_SERIAL);

        [self _setupEffectSDK];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FACE_106_MODEL_INPUT = CGSizeMake(128, 224);
        FACE_280_MODEL_INPUT = CGSizeMake(360, 640);
        FaceAttriInput = CGSizeMake(360, 640);
        HAND_MODEL_INPUT = CGSizeMake(360, 640);
        SKELETON_MODEL_INPUT = CGSizeMake(128, 224);
        HAIR_MODEL_INPUT = CGSizeMake(128, 224);
        MATTINGINPUT = CGSizeMake(128, 224);
    });
    return self;
}

/*
 * 初始化SDK
 */
- (void)_setupEffectSDK {
    [_detect setupEffectDetectSDKWithLicenseVersion:LICENSE_PATH];
    [_render setupEffectRenderMangerWithLicenseVersion:LICENSE_PATH];
}

- (void)_releaseSDK {
    // 要在opengl上下文中调用
    [_render releaseEffectRenderManger];
    [_detect releaseEffcetDetectSDK];
}



- (void)reset {
    NSLog(@"BEFrameProcessor reset");
    [self _releaseSDK];
    [self _setupEffectSDK];
}

- (void)dealloc {
    NSLog(@"BEFrameProcessor dealloc %@", NSStringFromSelector(_cmd));
    [EAGLContext setCurrentContext:_glContext];
    [self _releaseSDK];
}

- (float)_getModelResizeRatioWithWidth:(int)width height:(int)height{
    float xRatio = 0.0, yRatio = 0.0;
    float retRatio = 0.0;
    if (_detectFaceOn){
        xRatio = MAX(xRatio, FACE_106_MODEL_INPUT.width / width);
        yRatio = MAX(yRatio, FACE_106_MODEL_INPUT.height / height);
        retRatio = MAX(retRatio, MAX(xRatio, yRatio));
    }
    if (_detectFaceExtraOn){
        xRatio = MAX(xRatio, FACE_280_MODEL_INPUT.width / width);
        yRatio = MAX(yRatio, FACE_280_MODEL_INPUT.height / height);
        retRatio = MAX(retRatio, MAX(xRatio, yRatio));
    }
    if (_detectGestureOn){
        xRatio = MAX(xRatio, HAND_MODEL_INPUT.width / width);
        yRatio = MAX(yRatio, HAND_MODEL_INPUT.height / height);
        retRatio = MAX(retRatio, MAX(xRatio, yRatio));
    }
    if (_detectSkeletonOn){
        xRatio = MAX(xRatio, SKELETON_MODEL_INPUT.width / width);
        yRatio = MAX(yRatio, SKELETON_MODEL_INPUT.height / height);
        retRatio = MAX(retRatio, MAX(xRatio, yRatio));
    }
    if (_detectBodySegmentationOn){
        xRatio = MAX(xRatio, MATTINGINPUT.width / width);
        yRatio = MAX(yRatio, MATTINGINPUT.height / height);
        retRatio = MAX(retRatio, MAX(xRatio, yRatio));
    }
    
    if (_detectHairSegmentationOn){
        xRatio = MAX(xRatio, HAIR_MODEL_INPUT.width / width);
        yRatio = MAX(yRatio, HAIR_MODEL_INPUT.height / height);
        retRatio = MAX(retRatio, MAX(xRatio, yRatio));
    }
    return retRatio;
}

/*
 * 帧处理流程
 */
- (BEProcessResult *)process:(CVPixelBufferRef)pixelBuffer timeStamp:(double)timeStamp{
    BEProcessResult *result = [[BEProcessResult alloc] init];
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char *baseAddress = (unsigned char *) CVPixelBufferGetBaseAddress(pixelBuffer);
    int iBytesPerRow = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
    int iWidth = (int) CVPixelBufferGetWidth(pixelBuffer);
    int iHeight = (int) CVPixelBufferGetHeight(pixelBuffer);
    
    //设置后续美颜以及其他识别功能的基本参数
    [_render renderMangerSetWidth:iWidth height:iHeight orientation:[self getDeviceOrientation]];
    
    size_t iTop, iBottom, iLeft, iRight;
    CVPixelBufferGetExtendedPixels(pixelBuffer, &iLeft, &iRight, &iTop, &iBottom);
    
    iWidth = iWidth + (int) iLeft + (int) iRight;
    iHeight = iHeight + (int) iTop + (int) iBottom;
    iBytesPerRow = iBytesPerRow + (int) iLeft + (int) iRight;
    
    // 设置 OpenGL 环境 , 需要与初始化 SDK 时一致
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
    //为美颜，瘦脸，滤镜分配输出纹理
    [_render genInputAndOutputTexture:baseAddress width:iWidth height:iHeight];
    //美颜，瘦脸，滤镜的渲染， 返回渲染后的纹理
    GLuint textureResult = [_render processInputTexture:timeStamp];
    
    //    float resizeRatio = [self _getModelResizeRatioWithWidth:iWidth height:iHeight];
    float resizeRatio = 1.0;
    if (resizeRatio != 0.0){ //使用了检测人脸，手掌，骨骼等功能
        int resizeWidth = iWidth * resizeRatio;
        int resizeHeight = iHeight * resizeRatio;
        unsigned char* buffer = NULL;
        
        buffer = (unsigned char*)malloc(resizeWidth * resizeHeight * 4);
        if (buffer == 0)
            NSLog(@"BEFrameProcessor malloc memory failed");
        
        [_render transforTextureToImage:textureResult buffer:buffer width:resizeWidth height:resizeHeight];
        bef_ai_pixel_format imageFormat = BEF_AI_PIX_FMT_RGBA8888;
        
        [_detect setSDKWidth:resizeWidth height:resizeHeight bytePerRow:iBytesPerRow];
        [_render renderHelperSetWidth:iWidth height:iHeight resizeRatio:resizeRatio];
        
        if (_detectFaceOn){
            bef_ai_face_info faceInfo;
            
            if (!_detectFaceExtraOn)
                [_detect faceDetect:&faceInfo buffer:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation]];
            else
                [_detect faceDetect280:&faceInfo buffer:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_render drawFace:(bef_ai_face_info*)&faceInfo withExtra:_detectFaceExtraOn];
                
                if ([self.delegate respondsToSelector:@selector(BEFrameProcessor:didDetectHandInfo:)]){
                    [self.delegate BEFrameProcessor:self didDetectFaceInfo:faceInfo];
                }
            });
            
            //人脸属性检测打开
            if(_detectFaceAttrOn && faceInfo.face_count > 0){
                bef_ai_face_attribute_result faceAttr;
                [_detect faceAttributeDetect:&faceAttr buffer:buffer faceInfo:faceInfo.base_infos faceCount:faceInfo.face_count format:imageFormat];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(BEFrameProcessor:didDetectExtraFaceInfo:)]){
                        [self.delegate BEFrameProcessor:self didDetectExtraFaceInfo:faceAttr];
                    }
                });
            }
        }
        
        if (_detectSkeletonOn){
            bef_skeleton_info* skeletonInfo = (bef_skeleton_info*)calloc(BEF_MAX_SKELETON_NUM, sizeof (bef_skeleton_info));
            int validCount = BEF_MAX_SKELETON_NUM;
            
            [_detect skeletonDetect:skeletonInfo validCount:&validCount buffer:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation]];
            
            if (validCount > 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_render drawSkeleton:skeletonInfo withCount:validCount];});
            }
        }
        
        if (_detectGestureOn){
            bef_ai_hand_info handInfo;
            [_detect handDetect:&handInfo buffer:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_render drawHands:(bef_ai_hand_info*)&handInfo];
                
                bef_ai_rect *rect = (bef_ai_rect*)&(handInfo.p_hands[0].rect);
                rect->top /= resizeRatio;
                rect->bottom /= resizeRatio;
                rect->left /= resizeRatio;
                rect->right /= resizeRatio;
                if ([self.delegate respondsToSelector:@selector(BEFrameProcessor:didDetectHandInfo:)]) {
                    [self.delegate BEFrameProcessor:self didDetectHandInfo:handInfo];
                }
            });
        }
        
        if (_detectHairSegmentationOn){
            int* size = (int*)calloc(3, sizeof (int));
            if (size == NULL)
                NSLog(@"detect hair malloc memory error");
            
            unsigned char* alpha = [_detect hairparseDetect:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation] size:size];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_render drawHairParse:alpha size:(int *)size];});
            free (size);
            free(alpha);
        }
        
        if (_detectBodySegmentationOn){
            int* size = (int*)calloc(3, sizeof (int));
            if (size == NULL)
                NSLog(@"detect body malloc memory error");
            
            unsigned char *alpha = [_detect prortraitDetect:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation] size:size];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_render drawPrortrait:alpha size:(int*) size];});
            
            free (alpha);
            free(size);
        }
        
        if (_detectFaceVerifyOn){
            double similarity = 0.0;
            long costTime = 0;
            
            if (_faceVerifyCurrentVaild){
                long startTime = [self currentTimeInMillis];
                [_detect faceVerifyDetectSingle:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation] similarity:&similarity];
                long endTime = [self currentTimeInMillis];
                costTime = endTime - startTime;
            }
            if (similarity == 0.0) costTime = 0;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(BEFrameProcessor:updateFaceVerifyInfo:costTime:)]){
                    [self.delegate BEFrameProcessor:self updateFaceVerifyInfo:similarity costTime:costTime];
                }
            });
        }
        
        //        if (_faceDistanceOn){
        //            bef_ai_face_info faceInfo;
        //            bef_ai_human_distance_result distanceResult;
        //
        //            [_detect faceDistanceFaceDetect:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation] faceDetectResult:&faceInfo];
        //
        //            if (faceInfo.face_count >= 0) {
        //                [_detect faceDistanceDetect:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation] faceInfo:&faceInfo faceDistanceResult:&distanceResult];
        //
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    [_render drawFaceRect:(bef_ai_face_info*)&faceInfo];
        //
        //                    if ([self.delegate respondsToSelector:@selector(BEFrameProcessor:didDetectFace:distance:)]){
        //                        [self.delegate BEFrameProcessor:self didDetectFace:faceInfo distance:distanceResult];
        //                    }
        //                });
        //            }
        //        }
        
        free(buffer);
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    result.texture = textureResult;
    result.size  = CGSizeMake(iWidth, iHeight);
    return result;
}

- (long) currentTimeInMillis {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

- (bef_effect_result_t)setEffectPath:(NSString *)path type:(BEEffectType)type {
    return [_render setEffectPath:path type:type];
}

- (void)setIndensity:(BEIndensityParam)indensity type:(BEEffectType)type {
    [_render setIndensity:indensity type:type];
}

/*
 * 设置美颜资源路径和美化系数
 */
- (void)setFaceBeautyPath:(NSString *)path withIndensity:(BEIndensityParam)indensity {
    [_render setFaceBeautyPath:path withIndensity:indensity];
}

/*
 * 设置瘦脸资源路径
 */
-(void)setReshapePath:(NSString *)path withIndensity:(BEIndensityParam)indensity {
    [_render setReshapePath:path withIndensity:indensity];
}
/*
 * 设置滤镜强度
 */
-(void)setFilterIntensity:(float)intensity{
    [_render setFilterIntensity:intensity];
}

/*
 * 设置贴纸资源
 */
- (void)setStickerPath:(NSString *)path{
    [_render setStickerPath:path];
}

/*
 * 设置license
 */
- (void) setRenderLicense:(NSString *)license{
    [_render setRenderMangerLicense:license];
}
/*
 * 设置滤镜资源路径和系数
 */
- (void)setFilterPath:(NSString *)path {
    [_render setFilterPath:path];
}

/*
 * 设置滤镜系数
 */
- (void)setGlobalFilterIntensity:(float)intensity {
    [_render setGlobalFilterIntensity:intensity];
}

/*
 * 获取设备旋转角度
 */
- (int)getDeviceOrientation {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return BEF_AI_CLOCKWISE_ROTATE_0;

        case UIDeviceOrientationPortraitUpsideDown:
            return BEF_AI_CLOCKWISE_ROTATE_180;

        case UIDeviceOrientationLandscapeLeft:
            return BEF_AI_CLOCKWISE_ROTATE_270;

        case UIDeviceOrientationLandscapeRight:
            return BEF_AI_CLOCKWISE_ROTATE_90;

        default:
            return BEF_AI_CLOCKWISE_ROTATE_0;
    }
}

- (void) setFaceDetector:(BOOL)on {
    _detectFaceOn = on;
}

- (void)setFaceAttrDetector:(BOOL)on{
    _detectFaceAttrOn = on;
}
- (void)setFaceExtraDetector:(BOOL)on{
    _detectFaceExtraOn = on;
}

- (void)setSkeletonDetector:(BOOL)on{
    _detectSkeletonOn = on;
}

- (void)setGestureDetector:(BOOL)on {
    _detectGestureOn = on;
}

- (void)setHairSegmentationOn:(BOOL) on{
    _detectHairSegmentationOn = on;
}

- (void)setBodySegmentationOn:(BOOL) on{
    _detectBodySegmentationOn = on;
}

- (void)setFaceVerifyOn:(BOOL) on{
    _detectFaceVerifyOn = on;
}

-(void) setFaceDistanceOn:(BOOL) on{
    _faceDistanceOn = on;
}

- (void)setFaceMakeUpType:(NSString*) type path:(NSString*)path{
    [_render updateFaceMakeUpResourceWithType:type path:path];
}

- (void)clearFaceMakeUpEffect{
    [_render clearFaceMakeUpEffect];
}


- (void)renderSetInternalStatus:(BEEffectFaceBeautyType)type{
    [_render updataComposeDictNodeWithType:type];
}

- (void)renderSetInitStatus{
    [_render setInitStatus];
}
- (int)setFaceVerifysoSourceImageAndGenFeature:(UIImage*) image{
    size_t width = 0, height = 0, bytesPerRow = 0;
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const uint8_t *data = CFDataGetBytePtr(pixelData);
    
    width = CGImageGetWidth(image.CGImage);
    height = CGImageGetHeight(image.CGImage);
    bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
    
    int faceCount;
    faceCount = [_detect setfaceVerifySourceFeature:(unsigned char*)data format:BEF_AI_PIX_FMT_RGBA8888 width:(int)width  height:(int)height bytesPerRow:(int)bytesPerRow];
    
    _faceVerifyCurrentVaild = faceCount == 1? true:false;
    CFRelease(pixelData);
    return faceCount;
}

@end

