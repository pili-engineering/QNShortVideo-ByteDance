// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
#import "BERenderHelper.h"
#import "BERender.h"
#import "bef_effect_ai_hand.h"
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_skeleton.h"
#import "bef_effect_ai_public_define.h"
#import "bef_effect_ai_api.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>
#import "BEEffectBaseDefine.h"
#import "BEMacro.h"

@interface BERender () {
    BERenderHelper *renderHelper;
    GLuint _frameBuffer;
    GLuint _textureInput;
    GLuint _textureOutput;
    unsigned char* _pixelBuffer;
}

/*
 * 当前美颜资源类型
 */
@property (nonatomic, copy) NSString *currentFaceBeautyType;

/*
 * 当前滤镜资源路径
 */
@property (nonatomic, copy) NSString *currentFilterPath;

/*
 * 当前瘦脸资源路径
 */
@property (nonatomic, copy) NSString *currentReshapePath;

@property (nonatomic, readwrite) NSString *triggerAction;
@property (nonatomic, assign) BOOL effectEnable;

@property (nonatomic, assign) GLuint currentTexture;
@property (nonatomic, assign) bef_effect_handle_t renderMangerHandle;
@property (nonatomic, strong) NSMutableDictionary *intensityDict;
@property (nonatomic, strong) NSDictionary *faceBeautyKeys;

@end

@implementation BERender

static NSString* LICENSE_PATH;

static be_rgba_color const BE_COLOR_RED = {1.0, 0.0, 0.0, 1.0};
static be_rgba_color const BE_COLOR_GREEN = {0.0, 1.0, 0.0, 1.0};
static be_rgba_color const BE_COLOR_BLUE = {0.0, 0.0, 1.0, 1.0};
static be_rgba_color const BE_COLOR_HAIR = {0.5, 0.08, 1.0, 0.3};
static be_rgba_color const BE_COLOR_PRORTRAIT = {1.0, 0.0, 0.0, 0.3};

static float const BE_HAND_BOX_LINE_WIDTH = 2.0;
static float const BE_HAND_KEYPOINT_LINE_WIDTH = 3.0;
static float const BE_HAND_KEYPOINT_POINT_SIZE = 8.0;
static float const BE_SKELETON_LINE_WIDTH = 4.0;
static float const BE_SKELETION_LINE_POINT_SIZE = 8.0;
static float const BE_FACE_KEYPOINT_SIZE = 4.0;
static float const BE_FACE_KEYPOINT_EXTRA_SIZE = 3.0;
static float const BE_FACE_BOX_WIDTH = 2.0;

static NSString *RESHAPE_RESOURCE_DIR_NAME = @"reshape";
static NSString *BEAUTY_RESOURCE_DIR_NAME = @"beauty";
static NSString *MAKEUP_BEAUTY_RESOURCE_DIR_NAME = @"ComposeMakeup";

- (instancetype) init{
    self = [super init];
    if (self){
        renderHelper = [[BERenderHelper alloc] init];
        
        //保存资源文件路径的字典，
        _composeNodeDict = [NSMutableDictionary dictionary];
        
        //保存美颜强度的字典
        _intensityDict = [NSMutableDictionary dictionary];
        
        //更新美颜强度的key
        _faceBeautyKeys = @{@"bigeye":@"Internal_Deform_Eye",
                               @"reshape":@"Internal_Deform_Face",
                               @"smooth":@"epm/frag/blurAlpha",
                               @"whiten":@"epm/frag/whiten",
                               @"sharp":@"epm/frag/sharpen",};
    }
    return self;
}

- (void)setupEffectRenderMangerWithLicenseVersion: (NSString *)path{
    LICENSE_PATH = [path mutableCopy];
    
    bef_effect_result_t result = bef_effect_ai_create(&_renderMangerHandle);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_create error: %d", result);
    }
    NSString *licBundleName = [[NSBundle mainBundle] pathForResource:@"LicenseBag" ofType:@"bundle"];
    NSString *licbag = [licBundleName stringByAppendingString:LICENSE_PATH];
    // 检查license
    result = bef_effect_ai_check_license(_renderMangerHandle, licbag.UTF8String);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_check_license error: %d", result);
    }
    
    NSString *resourceBundleName = [[NSBundle mainBundle] pathForResource:@"ModelResource" ofType:@"bundle"];
    // 此处宽高传入视频捕获宽高。此处传入的路径是算法模型文件所在目录的父目录，设备名称传空即可。
    result = bef_effect_ai_init(_renderMangerHandle, VIDEO_INPUT_WIDTH, VIDEO_INPUT_HEIGHT, resourceBundleName.UTF8String, "");
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_init error: %d", result);
    }
    
    [self initFaceMakeUpAndBeauty];
    //初始化资源路径
//    [self initFaceBeautyResource];
//    [self initFaceMakeUpResource];
//    [self initFaceReshapedResource];
    
    //初始化强度
//    BEIndensityParam parm = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
//    [self setInitIndensity:parm];
    //生成一个frame buffer object，
    glGenFramebuffers(1, &_frameBuffer);
}

- (void)releaseEffectRenderManger{
    LICENSE_PATH = @"";
    
    glDeleteFramebuffers(1, &_frameBuffer);
    bef_effect_ai_destroy(_renderMangerHandle);
}

// 加载美颜资源路径
- (void)initFaceReshapedResource{
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"BeautyResource" ofType:@"bundle"];
    NSError *error = nil;
    NSArray *faceBeautyPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
    NSString *tmpPath;
    
    for (NSString *path in faceBeautyPaths) {
        tmpPath = [resourcePath stringByAppendingPathComponent:path];
        break;
    }
    [self setEffectPath:tmpPath type:BEEffectBeautify];
}

// 加载瘦脸资源路径
- (void)initFaceBeautyResource{
    //
    NSString *reshapePath = [[NSBundle mainBundle] pathForResource:@"ReshapeResource" ofType:@"bundle"];
    NSError *error;
    NSString *tmpPath;
    NSArray *reshapePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:reshapePath error:&error];
    
    for (NSString *path in reshapePaths) {
        tmpPath = [reshapePath stringByAppendingPathComponent:path];
        break;
    }
    [self setEffectPath:tmpPath type:BEEffectReshape];
}

// 加载美妆资源路径
- (void)initFaceMakeUpResource{
    NSString *makeUpPath = [[NSBundle mainBundle] pathForResource:@"BuildinMakeup" ofType:@"bundle"];
    NSError *error;
    NSString *tmpPath;
    NSArray *makeUpPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:makeUpPath error:&error];
    
    for (NSString *path in makeUpPaths) {
        tmpPath = [makeUpPath stringByAppendingPathComponent:path];
        break;
    }
    [self setEffectPath:tmpPath type:BEEffectMakeup];
}

/*
 * 设置初始的强度
 */
- (void)setInitIndensity:(BEIndensityParam)indensity{
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_FACE_SHAPE, indensity.indensity);
    bef_effect_ai_update_reshape_face_intensity(_renderMangerHandle, indensity.eyeIndensity, indensity.cheekIndensity);
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_GLOBAL_FILTER_V2, indensity.indensity);
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BEAUTY_SMOOTH, indensity.smoothIndensity);
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BEAUTY_WHITEN, indensity.whiteIndensity);
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BEAUTY_SHARP, indensity.sharpIndensity);
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BUILDIN_LIP, indensity.lipIndensity);
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BUILDIN_BLUSHER, indensity.blusherIndensity);
}


/*
 * 初始化高级美妆和美颜资源路径
 * 初始化步骤：
 * 1.初始化高级美颜的部分，传入算法的组合模块，composer文件
 * 2.传入美颜和大眼瘦脸的资源路径
 */
- (void)initFaceMakeUpAndBeauty{
    //高级美妆的路径接口
    NSString *makeUpPath = [[NSBundle mainBundle] pathForResource:@"ComposeMakeup" ofType:@"bundle"];
    NSString *composeDirPath = [makeUpPath stringByAppendingPathComponent:MAKEUP_BEAUTY_RESOURCE_DIR_NAME];
    NSString *composerPath = [composeDirPath stringByAppendingPathComponent:@"composer"];
    
    bef_effect_result_t result;
    
//    传入composer 文件的路径，使能美颜和美妆效果
    result = bef_effect_ai_set_effect(_renderMangerHandle, [composerPath UTF8String]);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_set_effect error: %d", result);
        return ;
    }
    
//    传入composer 文件的路径，使能美颜和美妆效果
    result = bef_effect_ai_set_composer(_renderMangerHandle, [composerPath UTF8String]);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_set_composer error: %d", result);
        return ;
    }
    
    //美颜和瘦脸资源的目录
    [_composeNodeDict setObject:@"beauty"  forKey:@"beauty"];
    [_composeNodeDict setObject:@"reshape" forKey:@"reshape"];

    [self setMakeUpComposeNodes];
}

/*
 * 初始化美颜资源强度的字典
 */
- (void)initFaceBeautyIntensity{
    [_intensityDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"reshape"];
    [_intensityDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"bigeye"];
    [_intensityDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"smooth"];
    [_intensityDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"whiten"];
    [_intensityDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"sharp"];
}


/*
 * 将美颜美妆的效果传入SDK中
 */
- (void)setMakeUpComposeNodes{
    NSString *makeUpPath = [[NSBundle mainBundle] pathForResource:@"ComposeMakeup" ofType:@"bundle"];
    NSString *composePath = [makeUpPath stringByAppendingPathComponent:MAKEUP_BEAUTY_RESOURCE_DIR_NAME];
    char** nodesPath;
    
    nodesPath = (char**)malloc(10 * sizeof(char*));
    bef_effect_result_t result;
    
    int validCount = 0;
    //设置composer nodes的数组
    for (NSString *key in [_composeNodeDict allKeys]){
        NSString *path = [_composeNodeDict valueForKey:key];
        
        //如果的资源的路径长度为0
        if (path.length == 0)
            continue;
        
        NSString *absolutePath = [composePath stringByAppendingPathComponent:path];
        nodesPath[validCount] = (char*)malloc((absolutePath.length + 1) * sizeof(char));
        nodesPath[validCount][absolutePath.length] = '\0';
        strncpy(nodesPath[validCount++], [absolutePath UTF8String], absolutePath.length);
    }
    
    result = bef_effect_ai_composer_set_nodes(_renderMangerHandle, (const char **)nodesPath, validCount);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_composer_set_nodes error: %d", result);
    }
    
    for (int i = 0; i < validCount; i ++){
        free(nodesPath[i]);
    }
    free(nodesPath);
}

/*
 * 清空高级美妆效果
 */
- (void)clearFaceMakeUpEffect{
    for (NSString *key in [_composeNodeDict allKeys]){
        if (![key isEqualToString:@"reshape"] && ![key isEqualToString:@"beauty"]){
            [_composeNodeDict setObject:@"" forKey:key];
        }
    }
    [self setMakeUpComposeNodes];
}

/*
 *  更新高级美妆的资源路径
 */
- (void)updateFaceMakeUpResourceWithType:(NSString*) type path:(NSString*)path{
    [_composeNodeDict setObject:path forKey:type];
    
    //更新资源
    [self setMakeUpComposeNodes];
}

/*
 * 更新compose的node
 */
- (void) updataComposeDictNodeWithType:(BEEffectFaceBeautyType)type{
    if (type >= BEEffectFaceBeautyReshape && type <= BEEffectFaceBeautyBigEye){
        [_composeNodeDict setObject:@"reshape" forKey:@"reshape"];
        [self setMakeUpComposeNodes];
    }else if (type >= BEEffectFaceBeautySmooth && type <= BEEffectFaceBeautySharp){
        [_composeNodeDict setObject:@"beauty" forKey:@"beauty"];
        [self setMakeUpComposeNodes];
    }
}

/*
 *
 */

- (void)setInitStatus{
    [_composeNodeDict removeAllObjects];
    [self setMakeUpComposeNodes];
    
    [self initFaceMakeUpAndBeauty];
}
/*
 * 更新美颜的强度
 */
- (void) updateFaceBeautyWithType:(BEEffectFaceBeautyType)type andIntensity:(float)intensity{
    NSString *resourcePath, *key;
    
    switch (type) {
        case BEEffectFaceBeautyReshape:
            _intensityDict[@"reshape"] = [NSNumber numberWithFloat:intensity];
            resourcePath = _composeNodeDict[@"reshape"];
            key = _faceBeautyKeys[@"reshape"];
            break;
        case BEEffectFaceBeautyBigEye:
            _intensityDict[@"bigeye"] = [NSNumber numberWithFloat:intensity];
            resourcePath = _composeNodeDict[@"reshape"];
            key = _faceBeautyKeys[@"bigeye"];
            break;
        case BEEffectFaceBeautySharp:
            _intensityDict[@"sharp"] = [NSNumber numberWithFloat:intensity];
            resourcePath = _composeNodeDict[@"beauty"];
            key = _faceBeautyKeys[@"sharp"];
            break;
        case BEEffectFaceBeautySmooth:
            _intensityDict[@"smooth"] = [NSNumber numberWithFloat:intensity];
            resourcePath = _composeNodeDict[@"beauty"];
            key = _faceBeautyKeys[@"smooth"];
            break;
        case BEEffectFaceBeautyWhiten:
            _intensityDict[@"whiten"] = [NSNumber numberWithFloat:intensity];
            resourcePath = _composeNodeDict[@"beauty"];
            key = _faceBeautyKeys[@"whiten"];
            break;
        default:
            break;
    }
    
    bef_effect_result_t result;
    
    NSString *makeUpPath = [[NSBundle mainBundle] pathForResource:@"ComposeMakeup" ofType:@"bundle"];
    NSString *composeDirPath = [makeUpPath stringByAppendingPathComponent:MAKEUP_BEAUTY_RESOURCE_DIR_NAME];
    NSString *makupDir = [composeDirPath stringByAppendingPathComponent:resourcePath];
    
//    NSLog(@"dir is %@ and key is %@", makeUpPath, key);
    result = bef_effect_ai_composer_update_node(_renderMangerHandle, [makupDir UTF8String], [key UTF8String], intensity);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_composer_update_node error: %d", result);
    }
}

/*
 *
 */
- (void) genInputAndOutputTexture:(unsigned char*) buffer width:(int)iWidth height:(int)iHeigth
{
    GLuint textureInput;
    
    glGenTextures(1, &textureInput);
    glBindTexture(GL_TEXTURE_2D, textureInput);
    
    // 加载相机数据到纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, iWidth, iHeigth, 0, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GLuint textureOutput;
    
    glGenTextures(1, &textureOutput);
    glBindTexture(GL_TEXTURE_2D, textureOutput);
    
    // 为输出纹理开辟空间
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, iWidth, iHeigth, 0, GL_BGRA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
 
    _textureInput = textureInput;
    _textureOutput = textureOutput;
}

- (GLuint) processInputTexture:(double) timeStamp{
    bef_effect_result_t ret;
    // 用于大眼瘦脸，根据输入纹理执行算法，检测人脸位置，要在opengl上下文中调用
    bef_effect_ai_algorithm_texture(_renderMangerHandle, _textureInput, timeStamp);
    GLuint textureResult = _textureInput;
    
    // 帧处理，渲染到输出纹理，要在opengl上下文中调用
    ret = bef_effect_ai_process_texture(_renderMangerHandle, _textureInput, _textureOutput, timeStamp);
    
    if (ret == BEF_RESULT_SUC) {
        textureResult = _textureOutput;
    } else {
        NSLog(@"bef_effect_ai_process_texture error: %d", ret);
    }
    
    if (textureResult != _textureInput) {
        glDeleteTextures(1, &_textureInput);
    }
    
    if (textureResult != _textureOutput) {
        glDeleteTextures(1, &_textureOutput);
    }
    
    _currentTexture = textureResult;
    
    return textureResult;
}

- (void) renderMangerSetWidth:(int) iWidth height:(int)iHeight orientation:(int)orientation{
    bef_effect_result_t ret = bef_effect_ai_set_width_height(_renderMangerHandle, iWidth, iHeight);
    if (ret != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_set_width_height error: %d", ret);
    }
    
    ret = bef_effect_ai_set_orientation(_renderMangerHandle, (bef_ai_rotate_type)orientation);
    if (ret != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_set_orientation: error %d", ret);
    }
}


- (GLuint)transforImageToTexture:(unsigned char*)buffer imageWidth:(int)iWidth height:(int)iHeight{
    GLuint textureInput;
    
    glGenTextures(1, &textureInput);
    glBindTexture(GL_TEXTURE_2D, textureInput);
    
    // 加载相机数据到纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, iWidth, iHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    return textureInput;
}

//将texture转换为另一种大小的buffer
- (void)transforTextureToImage:(GLuint)texture buffer:(unsigned char*)buffer width:(int)iWidth height:(int)iHeight{
    [renderHelper textureToImage:texture withBuffer:buffer Width:iWidth height:iHeight];
}

- (void) renderHelperSetResizeRatio:(float) ratio{
    [renderHelper setResizeRatio:ratio];
}

- (void) renderHelperSetWidth:(int)width height:(int)height resizeRatio:(float)ratio{
    [renderHelper setViewWidth:width height:height];
    [renderHelper setResizeRatio:ratio];
}

/*
 * return current face is reshaped, it influences the skeleton and face decection
 */

- (BOOL) isFaceReshaped{
    if (_currentReshapePath == nil || _currentReshapePath.length == 0)
        return false;
    else
        return true;
}

- (bef_effect_result_t)setEffectPath:(NSString *)path type:(BEEffectType)type {
    
    if (!path) {
        path = @"";
    }
    bef_effect_result_t status = BEF_RESULT_SUC;
    
    switch (type) {
        case BEEffectReshape:
            status = bef_effect_ai_set_reshape_face(_renderMangerHandle, [path UTF8String]);
            self.currentReshapePath = path;
            break;
            
        case BEEffectFilter:
            status = bef_effect_ai_set_color_filter_v2(_renderMangerHandle, [path UTF8String]);
            self.currentFilterPath = path;
            break;
            
        case BEEffectBeautify:
            status = bef_effect_ai_set_beauty(_renderMangerHandle, [path UTF8String]);
            self.currentFaceBeautyType = path;
            break;
            
        case BEEffectMakeup:
            status = bef_effect_ai_set_buildin_makeup(_renderMangerHandle, [path UTF8String]);
            break;
        default:
            break;
    }
    if (status != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_set_effect error: %d", status);
    }
    
    return status;
}

//- (void)setIndensity:(BEIndensityParam)indensity type:(BEEffectType)type {
//    switch (type) {
//        case BEEffectReshape:
//            bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_FACE_SHAPE, indensity.indensity);
//            break;
//        case BEEffectReshapeTwoParam:
//            bef_effect_ai_update_reshape_face_intensity(_renderMangerHandle, indensity.eyeIndensity, indensity.cheekIndensity);
//            break;
//        case BEEffectFilter:
//            bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_GLOBAL_FILTER_V2, indensity.indensity);
//            break;
//        case BEEffectBeautify:
//            bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BEAUTY_SMOOTH, indensity.smoothIndensity);
//            bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BEAUTY_WHITEN, indensity.whiteIndensity);
//            bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BEAUTY_SHARP, indensity.sharpIndensity);
//            break;
//        case BEEffectMakeup:
//            bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BUILDIN_LIP, indensity.lipIndensity);
//            bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BUILDIN_BLUSHER, indensity.blusherIndensity);
//            break;
//        default:
//            break;
//    }
//}

- (void)setIndensity:(BEIndensityParam)indensity type:(BEEffectType)type {
    switch (type) {
        case BEEffectReshape:
            [self updateFaceBeautyWithType:BEEffectFaceBeautyReshape andIntensity:indensity.cheekIndensity];
            break;
        case BEEffectReshapeTwoParam:
            [self updateFaceBeautyWithType:BEEffectFaceBeautyReshape andIntensity:indensity.cheekIndensity];
            [self updateFaceBeautyWithType:BEEffectFaceBeautyBigEye andIntensity:indensity.eyeIndensity];
            break;
        case BEEffectFilter:
            bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_GLOBAL_FILTER_V2, indensity.indensity);
            break;
        case BEEffectBeautify:
            [self updateFaceBeautyWithType:BEEffectFaceBeautySharp andIntensity:indensity.sharpIndensity];
            [self updateFaceBeautyWithType:BEEffectFaceBeautySmooth andIntensity:indensity.smoothIndensity];
            [self updateFaceBeautyWithType:BEEffectFaceBeautyWhiten andIntensity:indensity.whiteIndensity];
            break;
        default:
            break;
    }
}


/*
 *设置贴纸资源的license
 */

- (void)setRenderMangerLicense:(NSString *)license{
    bef_effect_result_t result = bef_effect_ai_check_license(_renderMangerHandle, license.UTF8String);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_set_license error: %d", result);
    }
}

/*
 * 设置贴纸资源路径
 */
- (void)setStickerPath:(NSString *)path {    
    bef_effect_result_t result = bef_effect_ai_set_effect(_renderMangerHandle, path.UTF8String);
    
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_set_effect error: %d", result);
    }
}

/*
 * 设置美颜资源路径和美化系数
 */
- (void)setFaceBeautyPath:(NSString *)path withIndensity:(BEIndensityParam)indensity {
    bef_effect_result_t result = BEF_RESULT_SUC;
    result = bef_effect_ai_set_beauty(_renderMangerHandle, path.UTF8String);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_set_beauty error: %d", result);
    }
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BEAUTY_SMOOTH, indensity.smoothIndensity);
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BEAUTY_WHITEN, indensity.whiteIndensity);
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_BEAUTY_SHARP, indensity.sharpIndensity);
    _currentFaceBeautyType = path;
}

/*
 * 设置瘦脸资源路径
 */
-(void)setReshapePath:(NSString *)path withIndensity:(BEIndensityParam)indensity {
    bef_effect_ai_set_reshape_face(_renderMangerHandle, path.UTF8String);
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_FACE_SHAPE, indensity.indensity);
    _currentReshapePath = path;
}
/*
 * 设置滤镜强度
 */
-(void)setFilterIntensity:(float)intensity{
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_GLOBAL_FILTER_V2, intensity);
}

/*
 * 设置滤镜资源路径和系数
 */
- (void)setFilterPath:(NSString *)path {
    bef_effect_result_t result = bef_effect_ai_set_color_filter_v2(_renderMangerHandle, [path UTF8String]);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_set_color_filter_v2 error: %d", result);
    }
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_GLOBAL_FILTER_V2, 1.0);
    _currentFilterPath = path;
}

/*
 * 设置滤镜系数
 */
- (void)setGlobalFilterIntensity:(float)intensity {
    bef_effect_ai_set_intensity(_renderMangerHandle, BEF_INTENSITY_TYPE_GLOBAL_FILTER_V2, intensity);
}

//draw faces
- (void) drawFace:(bef_ai_face_info *)faceDetectResult withExtra:(BOOL)extra{
    //draw face 106
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _currentTexture, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE ){
        @throw [NSException exceptionWithName:@"drawFace glCheckFramebufferStatus when draw face" reason:[NSString stringWithFormat:@"error %d",status] userInfo:nil];
    }
    
    for (int i = 0; i < faceDetectResult->face_count; i ++){
        //draw basic 106 rect
        bef_ai_rect* rect = &faceDetectResult->base_infos[i].rect;
        [self.renderHelper drawRect:rect withColor:BE_COLOR_RED lineWidth:BE_FACE_BOX_WIDTH];
        
        //draw basic 106 points
        bef_ai_fpoint* points = faceDetectResult->base_infos[i].points_array;
        [self.renderHelper drawPoints:points count:106 color:BE_COLOR_RED pointSize:BE_FACE_KEYPOINT_SIZE];
        
        if (extra){ //draw th extra face info
            bef_ai_face_ext_info* extendInfo = faceDetectResult->extra_infos + i;
            
            if (extendInfo->eye_count > 0){
                //left eye
                be_rgba_color color = {200.0 / 255.0, 0.0, 0.0, 0.0};
                bef_ai_fpoint* left_eye = extendInfo->eye_left;
                
                [self.renderHelper drawPoints:left_eye count:22 color:color pointSize:BE_FACE_KEYPOINT_EXTRA_SIZE];
                
                //right eye
                bef_ai_fpoint* right_eye = extendInfo->eye_right;
                [self.renderHelper drawPoints:right_eye count:22 color:color pointSize:BE_FACE_KEYPOINT_EXTRA_SIZE];
            }
            
            if (extendInfo->eyebrow_count > 0){
                //left eyebrow
                bef_ai_fpoint* left_eyebrow = extendInfo->eyebrow_left;
                be_rgba_color color = {220.0 / 255.0, 0.0, 0.0, 0.0};
                
                [self.renderHelper drawPoints:left_eyebrow count:13 color:color pointSize:BE_FACE_KEYPOINT_EXTRA_SIZE];
                
                //right eyebrow
                bef_ai_fpoint* right_eyebrow = extendInfo->eyebrow_right;
                [self.renderHelper drawPoints:right_eyebrow count:13 color:color pointSize:BE_FACE_KEYPOINT_EXTRA_SIZE];
                
            }
            
            if (extendInfo->iris_count > 0){
                //left iris
                bef_ai_fpoint* left_iris = extendInfo->left_iris;
                be_rgba_color color = {1.0, 180.0 / 255.0, 0.0, 0.0};
                
                [self.renderHelper drawPoints:left_iris count:20 color:color pointSize:BE_FACE_KEYPOINT_EXTRA_SIZE];
                [self.renderHelper drawPoint:left_iris->x y:left_iris->y withColor:BE_COLOR_GREEN pointSize:BE_FACE_KEYPOINT_SIZE];
                
                //right iris
                bef_ai_fpoint* right_iris = extendInfo->right_iris;
                
                [self.renderHelper drawPoints:right_iris count:20 color:color pointSize:BE_FACE_KEYPOINT_EXTRA_SIZE];
                
                [self.renderHelper drawPoint:right_iris->x y:right_iris->y withColor:BE_COLOR_GREEN pointSize:BE_FACE_KEYPOINT_SIZE];
            }
            
            if (extendInfo->lips_count > 0){
                //lips
                bef_ai_fpoint* lips = extendInfo->lips;
                be_rgba_color color = {200.0 / 255.0, 40.0 / 255.0, 40.0 / 255.0, 0.0};
                
                [self.renderHelper drawPoints:lips count:60 color:color pointSize:BE_FACE_KEYPOINT_EXTRA_SIZE];
            }
        }
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    [self checkGLError];
}

// draw face rect
- (void) drawFaceRect:(bef_ai_face_info *)faceDetectResult{
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _currentTexture, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE ){
        @throw [NSException exceptionWithName:@"drawFaceRect glCheckFramebufferStatus when draw face" reason:@"error" userInfo:nil];
    }
    
    for (int i = 0; i < faceDetectResult->face_count; i ++){
        //draw basic 106 rect
        bef_ai_rect* rect = &faceDetectResult->base_infos[i].rect;
        [self.renderHelper drawRect:rect withColor:BE_COLOR_RED lineWidth:BE_FACE_BOX_WIDTH];
        
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    [self checkGLError];
    
}
//draw hands info
- (void) drawHands:(bef_ai_hand_info* )handDetectResult{
    int handsCount = handDetectResult->hand_count;
    if (handsCount <= 0) return;
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _currentTexture, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE ){
        @throw [NSException exceptionWithName:@"glCheckFramebufferStatus when draw hands" reason:@"error" userInfo:nil];
    }
    
    for (int i = 0; i < handsCount; i ++){
        bef_ai_hand* handInfo = &handDetectResult->p_hands[i];
        
        //draw hand rect
        bef_ai_rect* handRect = &handInfo->rect;
        [self.renderHelper drawRect:handRect withColor:BE_COLOR_RED lineWidth:BE_HAND_BOX_LINE_WIDTH];
        
        //draw hand basic key points
        struct bef_ai_tt_key_point *baiscHandKeyPoints = handInfo->key_points;
        for (int j = 0; j < BEF_HAND_KEY_POINT_NUM; j ++){
            struct bef_ai_tt_key_point *point = baiscHandKeyPoints + j;
            
            if (point->is_detect){
                [self.renderHelper drawPoint:point->x y:point->y withColor:BE_COLOR_RED pointSize:BE_HAND_KEYPOINT_POINT_SIZE];
            }
        }

        //draw hand extend key points
        struct bef_ai_tt_key_point *extendHandKeyPoins = handInfo->key_points_extension;
        for (int j = 0; j < BEF_HAND_KEY_POINT_NUM_EXTENSION; j ++){
            struct bef_ai_tt_key_point *point = extendHandKeyPoins + j;
            
            if (point->is_detect){
                [self.renderHelper drawPoint:point->x y:point->y withColor:BE_COLOR_RED pointSize:BE_HAND_KEYPOINT_POINT_SIZE];
            }
        }
        
        bef_ai_fpoint points[5];
        points[0].x = handInfo->key_points[0].x;
        points[0].y = handInfo->key_points[0].y;
        
        //draw hand line
        for (int n = 0; n < 5; n ++){
            int index = 4 * n + 1;
            for (int k = 1; k < 5; k++){
                points[k].x = handInfo->key_points[index].x;
                points[k].y = handInfo->key_points[index++].y;
            }
            [self.renderHelper drawLinesStrip:points withCount:5 withColor:BE_COLOR_RED lineWidth:BE_HAND_KEYPOINT_LINE_WIDTH];
        }
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    [self checkGLError];
}

/*
 *Draw skeletons
 */
- (void)drawSkeleton:(bef_skeleton_info*) skeletonDetectResult withCount:(int)validCount{
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _currentTexture, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE ){
        @throw [NSException exceptionWithName:@"glCheckFramebufferStatus when draw skeleton" reason:@"error" userInfo:nil];
    }
    
    for (int j = 0; j < validCount; j ++){
        bef_skeleton_info* skeletonInfo = skeletonDetectResult + j;
        
        //draw huaman rect
        bef_ai_rect rect = skeletonInfo->skeletonRect;
        [self.renderHelper drawRect:&rect withColor:BE_COLOR_BLUE lineWidth:BE_HAND_KEYPOINT_LINE_WIDTH];

        //draw points
        for (int i = 0; i < BEF_MAX_SKELETON_POINT_NUM; i ++){
            struct bef_skeleton_point_info *point = skeletonInfo->keyPointInfos + i;
            
            if (point->is_detect)
                [self.renderHelper drawPoint:point->x y:point->y withColor:BE_COLOR_BLUE pointSize:BE_SKELETION_LINE_POINT_SIZE];
        }
        
        //draw line
        int pairs[36] = {4, 3, 3, 2, 2, 1, 1, 5, 5, 6, 6, 7,
            16, 14, 14, 0, 17, 15, 15, 0,
            1, 8, 8, 11, 11, 1, 1, 0,
            8, 9, 9, 10, 11, 12, 12, 13};
        
        for (int i = 0; i <= 34; i +=2){
            struct bef_skeleton_point_info *left = skeletonInfo->keyPointInfos + pairs[i];
            struct bef_skeleton_point_info *right = skeletonInfo->keyPointInfos + pairs[i + 1];
            struct be_render_helper_line line = {0.0, 0.0, 0.0, 0.0};
            
            if(left->is_detect && right->is_detect){
                line.x1 = left->x;
                line.y1 = left->y;
                line.x2 = right->x;
                line.y2 = right->y;
                [self.renderHelper drawLine:&line withColor:BE_COLOR_BLUE lineWidth:BE_SKELETON_LINE_WIDTH];
            }
        }
    }
    
    free (skeletonDetectResult);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    [self checkGLError];
}


/*
 *Draw hair parse result
 */
- (void) drawHairParse:(unsigned char*)mask size:(int*)size{
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _currentTexture, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE ){
        @throw [NSException exceptionWithName:@"glCheckFramebufferStatus when draw hair" reason:@"error" userInfo:nil];
    }
    
    [renderHelper drawMask:mask  withColor:BE_COLOR_HAIR currentTexture:_currentTexture frameBuffer:_frameBuffer size:size];
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

/*
 *Draw prortrait detect result
 */
- (void) drawPrortrait:(unsigned char*)mask size:(int*)size{
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _currentTexture, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE ){
        @throw [NSException exceptionWithName:@"glCheckFramebufferStatus when draw protrait" reason:@"error" userInfo:nil];
    }
    
    [renderHelper drawPortraitMask:mask withColor:BE_COLOR_PRORTRAIT currentTexture:_currentTexture frameBuffer:_frameBuffer size:size];
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)checkGLError {
    int error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"%d", error);
        @throw [NSException exceptionWithName:@"GLError" reason:@"error " userInfo:nil];
    }
}

- (BERenderHelper*) renderHelper{
    if (!renderHelper){
        renderHelper = [[BERenderHelper alloc] init];
    }
    return renderHelper;
}

@end

