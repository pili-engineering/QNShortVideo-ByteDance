//
//  RecordViewController.m
//  PLShortVideoKitDemo
//
//  Created by suntongmian on 17/3/1.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "RecordViewController.h"
#import "PLShortVideoKit/PLShortVideoKit.h"
#include <mach/mach_time.h>
#import "PLSProgressBar.h"
#import "EditViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CMMetadata.h>
#import <GLKit/GLKit.h>
#import "BEGLView.h"
#import "BEFrameProcessor.h"
#import "BEVideoCapture.h"
#import "BECameraContainerView.h"
#import "BEActionSheetPresentViewController.h"
#import "BEModernEffectPickerView.h"
#import "BEModernRecognizePickerView.h"
#import "BEModernFaceBeautyViewController.h"
#import "BEEffectPickerDataStore.h"
#import "BEGesturePropertyListViewController.h"
#import "BEFacePropertyListViewController.h"
#import "BEFaceDistanceViewController.h"
#import <Toast/UIView+Toast.h>
#import "BENetworking.h"
#import "bef_effect_ai_human_distance.h"
#import "BEModernStickerPickerView.h"
#import "BEEffectDataManager.h"
#import "BEMacro.h"

typedef enum : NSUInteger {
    BefEffectNone = 0,
    BefEffectDetect,
    BefEffectFaceBeauty,
    BefEffectSticker,
}BefEffectMainStatue;

#define AlertViewShow(msg) [[[UIAlertView alloc] initWithTitle:@"warning" message:[NSString stringWithFormat:@"%@", msg] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show]

#define PLS_CLOSE_CONTROLLER_ALERTVIEW_TAG 10001
#define PLS_SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define PLS_SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)
#define PLS_RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define PLS_RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define PLS_BaseToolboxView_HEIGHT 64
#define PLS_SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define PLS_SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)

@interface RecordViewController ()<BECameraContainerViewDelegate, BEFrameProcessorDelegate, BEModernStickerPickerViewDelegate,PLShortVideoRecorderDelegate>
{
    BEFrameProcessor *_processor;
    BefEffectMainStatue lastEffectStatue;
}

@property (nonatomic, assign) AVCaptureVideoOrientation referenceOrientation; // 视频播放方向
@property (nonatomic, strong) BEGLView *glView;

@property (nonatomic, strong) BECameraContainerView *cameraContainerView;
@property (nonatomic, strong) BEModernEffectPickerView *effectPickerView;
@property (nonatomic, strong) BEModernRecognizePickerView *recognizePickerView;

@property (nonatomic, strong) BEModernStickerPickerView *stickerPickerView;

@property (nonatomic, strong) BEEffectDataManager *stickerDataManager;
@property (nonatomic, copy) NSArray<BEEffectSticker*> *stickers;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) EAGLContext *glcontext;

// ==== 七牛 =====
@property (strong, nonatomic) PLSVideoConfiguration *videoConfiguration;
@property (strong, nonatomic) PLSAudioConfiguration *audioConfiguration;
@property (strong, nonatomic) PLShortVideoRecorder *shortVideoRecorder;

@property (strong, nonatomic) PLSProgressBar *progressBar;
@property (strong, nonatomic) UILabel *durationLabel;
@property (assign, nonatomic) BOOL bufferPause;
@end

static uint64_t getUptimeInNanosecondWithMachTime(uint64_t machTime) {
    static mach_timebase_info_data_t s_timebase_info = {0};
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    return (uint64_t)((machTime * s_timebase_info.numer) / s_timebase_info.denom);
}

@implementation RecordViewController

- (void)dealloc
{
    self.shortVideoRecorder.delegate = nil;
    self.shortVideoRecorder = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupShortVideoRecorder];
    [self _setupUI];
    
    [self addObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    lastEffectStatue = BefEffectNone;
    [self createCamera];
    [self.shortVideoRecorder startCaptureSession];
    [self.shortVideoRecorder deleteAllFiles];
    self.bufferPause = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.shortVideoRecorder stopCaptureSession];
    self.bufferPause = YES;
    self.ciContext = nil;
    [self.glView removeFromSuperview];
    _processor = nil;
    _processor.delegate = nil;
    
}

- (void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
}

#pragma mark - Private
- (void)_setupUI {
    self.cameraContainerView = [[BECameraContainerView alloc] initWithFrame:self.view.bounds];
    self.cameraContainerView.delegate = self;
    [self.view addSubview:self.cameraContainerView];
    
    // 返回
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 10, 35, 35);
    [backButton setBackgroundImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraContainerView addSubview:backButton];
    
    // 视频录制进度条
    self.progressBar = [[PLSProgressBar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.cameraContainerView.frame) - 10, PLS_SCREEN_WIDTH, 10)];
    [self.cameraContainerView addSubview:self.progressBar];
    
    self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(PLS_SCREEN_WIDTH - 150, CGRectGetHeight(self.cameraContainerView.frame) - 45, 130, 40)];
    self.durationLabel.textColor = [UIColor whiteColor];
    self.durationLabel.text = [NSString stringWithFormat:@"%.2fs", self.shortVideoRecorder.getTotalDuration];
    self.durationLabel.textAlignment = NSTextAlignmentRight;
    [self.cameraContainerView addSubview:self.durationLabel];
}

- (void)createCamera {
    
    self.glView = [[BEGLView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self.view insertSubview:self.glView belowSubview:self.cameraContainerView];
    self.glcontext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:self.glView.context.sharegroup];
    [EAGLContext setCurrentContext:self.glcontext];
    _processor = [[BEFrameProcessor alloc] initWithContext:self.glcontext videoSize:self.shortVideoRecorder.previewView.bounds.size];
    _processor.cameraPosition = self.shortVideoRecorder.captureDevicePosition;
    _processor.delegate = self;
}

- (void)faceBeautyPickerDidSelectFaceBeautyData:(BEFaceBeautyModel *)data
{
    BEIndensityParam param;
    param.smoothIndensity = data.smooth;
    param.whiteIndensity = data.white;
    param.sharpIndensity = data.sharp;
    param.eyeIndensity = data.eyeIntensity;
    param.cheekIndensity = data.cheekIntensity;
    param.lipIndensity = data.lip;
    param.blusherIndensity = data.blusher;
    
    if (!BE_isEmptyString(data.path)) {
        [_processor setEffectPath:data.path type:data.type];
        [_processor setIndensity:param type:data.type];
    } else {
        if (data.type == BEEffectMakeup)
            [_processor setIndensity:param type:BEEffectMakeup];
        else{
            [_processor setIndensity:param type:BEEffectBeautify];
            [_processor setIndensity:param type:BEEffectReshapeTwoParam];
        }
    }
}


#pragma mark - Notification
- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenFaceDetectChanged:)
                                                 name:BEEffectFaceDetectDataDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenBodySwitchChanged:)
                                                 name:BEEffectBodyDidChangeNotification
                                               object:nil];
    //美颜部分
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenBeautyDataChanged:)
                                                 name:BEEffectFaceBeautyDataDidChangeNotification
                                               object:nil];
    //美颜种类
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenBeautyTypeChanged:)
                                                 name:BEEffectFaceBeautyTypeDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenFilterChanged:)
                                                 name:BEEffectFilterDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenFilterIntensityChanged:)
                                                 name:BEEffectFilterIntensityDidChangeNotification
                                               object:nil];
    
    //手势
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenGestureSwitchChanged:)
                                                 name:BEEffectGestureDidChangeNotification
                                               object:nil];
    
    //分割改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenSegmentationChanged:)
                                                 name:BEEffectSegmentationDidChangeNotification
                                               object:nil];
    //授权成功
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenAuthorizationChanged:)
                                                 name:BEEffectCameraDidAuthorizationNotification
                                               object:nil];
    
    //人脸比对开关
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFaceVerifyChanged:)
                                                 name:BEEffectFaceVerifyPickerNotification
                                               object:nil];
    
    //人脸比对原图片改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFaceVerifyImageChanged:)
                                                 name:BEEffectFaceVerifyImageNotification
                                               object:nil];
    
    //二维码开关改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenQRCodeChanged:)
                                                 name:BEEffectQRCodeDidChangeNotification
                                               object:nil];
    
    //网络贴纸准备完毕
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenNetworkStickerReady:)
                                                 name:BEEffectNetworkStickerReadyNotification
                                               object:nil];
    
    //扫码贴纸时网络状况为不可达
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenNetworkNotReachable:)
                                                 name:BEEffectNetworkNotReachedNotification
                                               object:nil];
    
    //人脸距离估计开关
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenFaceDistaceChanged:)
                                                 name:BEEffectFaceDistanceDidChangeNotification
                                               object:nil];
    
    //返回主界面
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenReturnToMainUI:)
                                                 name:BEEffectDidReturnToMainUINotification
                                               object:nil];
    
    //美妆改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenFaceMakeUpChanged:)
                                                 name:BEEffectFaceMakeupComposeSelectedNotification
                                               object:nil];
    
}

//美妆接口
- (void) onListenFaceMakeUpChanged:(NSNotification *)aNote{
    NSArray *array = aNote.userInfo[BEEffectNotificationUserInfoKey];
    
    [self cleanUpLastEffectWithCurrentStatus:BefEffectFaceBeauty];
    [_processor setFaceMakeUpType:array[0] path:array[1]];
}

- (void)onListenReturnToMainUI:(NSNotification *)aNote{
    [self.cameraContainerView showBottomButton];
}

// 人脸距离估计
- (void)onListenFaceDistaceChanged:(NSNotification *)aNote{
    BOOL isOn = [aNote.userInfo[BEEffectNotificationUserInfoKey] boolValue];
    [_processor setFaceDistanceOn:isOn];
    
    if (isOn)
        [self.cameraContainerView showFaceDistanceVC];
    else
        [self.cameraContainerView hideFaceDistanceVC];
}

//扫码贴纸时网络状况为不可达
- (void)onListenNetworkNotReachable:(NSNotification *)aNote{
    
    //显示网络不可达情况
//    [self.cameraContainerView setScanQRButtonSelected:false];
    [self.cameraContainerView makeToast:NSLocalizedString(@"network_error", nil)];
}

//人脸比对图片改变
- (void)onFaceVerifyImageChanged:(NSNotification *)aNote{
    
    UIImage *image = aNote.userInfo[BEEffectNotificationUserInfoKey];
    int faceCount = [_processor setFaceVerifysoSourceImageAndGenFeature:image];
    
    [self.cameraContainerView setFaceVerifyImage:image];
    image = nil;
    
    if (faceCount <= 0){
        [self.recognizePickerView makeToast:NSLocalizedString(@"no_face_detected", nil)];
    }else  if (faceCount > 1){
        [self.recognizePickerView makeToast:NSLocalizedString(@"face_more_than_one", nil)];
    }
    
    [self.cameraContainerView.faceVerifyListVC updateFaceVerifyInfo:0.0 time:0];
}

//人脸比对开关
- (void)onFaceVerifyChanged:(NSNotification *)aNote{
    BOOL isOn = [aNote.userInfo[BEEffectNotificationUserInfoKey] boolValue];
    
    [_processor setFaceVerifyOn:isOn];
    [self.cameraContainerView setFaceVerifyHidden:!isOn];
    //显示人脸比对的结果
    if (isOn){
        [self.cameraContainerView showFaceVerifyListVC];
    }else
        [self.cameraContainerView hideFaceVerifyListVC];
    
    [self cleanUpLastEffectWithCurrentStatus:BefEffectDetect];
    
}

- (void) onListenAuthorizationChanged:(NSNotification *)aNote{
    CGRect displayViewRect = [UIScreen mainScreen].bounds;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.glView.frame = displayViewRect;});
}

//网络贴纸准备完毕，切换到原始的glview，并开始执行
- (void) onListenNetworkStickerReady:(NSNotification *)aNote{
    NSString *stickerID = aNote.userInfo[BEEffectNotificationUserInfoKey];
    NSString *stickerPath = [[BENetworking createStickersPathIfNeeded] stringByAppendingPathComponent:stickerID];
    NSString *license = [stickerPath stringByAppendingPathComponent:@"license.licbag"];
    
    [_processor setRenderLicense:license];
    [_processor setStickerPath:stickerPath];
    
    [self.cameraContainerView makeToast:NSLocalizedString(@"sticker_download_success", nil)];
//    [self.cameraContainerView setScanQRButtonSelected:false];
    [self.cameraContainerView showBottomButton];
    
    [self cleanUpLastEffectWithCurrentStatus:BefEffectSticker];
}

- (void)onListenQRCodeChanged:(NSNotification *)aNote{
    // UIButton *button = aNote.userInfo[BEEffectNotificationUserInfoKey];
    BOOL isOn = [aNote.userInfo[BEEffectNotificationUserInfoKey] boolValue];
    
    if (isOn){
        
    }else {
       
    }
}

- (void)onListenSegmentationChanged:(NSNotification *)aNote {
    NSArray *array = aNote.userInfo[BEEffectNotificationUserInfoKey];
    BOOL isOn = [array[1] boolValue];
    
    if ([array[0]  isEqual: @"backGround"])
        [_processor setBodySegmentationOn:isOn];
    else if ([array[0]  isEqual: @"hair"])
        [_processor setHairSegmentationOn:isOn];
    
    [self cleanUpLastEffectWithCurrentStatus:BefEffectDetect];
}


//手势检测
- (void) onListenGestureSwitchChanged:(NSNotification *)aNote{
    BOOL isOn = [aNote.userInfo[BEEffectNotificationUserInfoKey] boolValue];
    
    [_processor setGestureDetector:isOn];
    if (!isOn) {
        [self.cameraContainerView hideGesPropertyListVC];
    } else {
        [self.cameraContainerView showGesPropertyListVC];
    }
    
    [self cleanUpLastEffectWithCurrentStatus:BefEffectDetect];
}

// 人脸检测
- (void)onListenFaceDetectChanged:(NSNotification *)aNote {
    BEEffectPickerDataStore *store = [BEEffectPickerDataStore sharedDataStore];
    
    [self cleanUpLastEffectWithCurrentStatus:BefEffectDetect];
    
    [_processor setFaceDetector:store.enableFaceDetect106];
    [_processor setFaceExtraDetector:store.enableFaceDetect280];
    [_processor setFaceAttrDetector:store.enableFaceDetectProps];
    
    if (store.enableFaceDetect106 && store.enableFaceDetectProps){
        self.cameraContainerView.facePropertyListVC.view.frame = CGRectMake(20, 100, 112, 17 * 20.0f);
    }else
        self.cameraContainerView.facePropertyListVC.view.frame = CGRectMake(20, 100, 112, 190.0f);
    
    if (store.enableFaceDetect106){
        [self.cameraContainerView showFacePropertyListVC];
    }else {
        [self.cameraContainerView hideFacePropertyListVC];
    }
}

//人体关键点改变
- (void)onListenBodySwitchChanged:(NSNotification *)aNote {
    BOOL isOn = [aNote.userInfo[BEEffectNotificationUserInfoKey] boolValue];
    
    [_processor setSkeletonDetector:isOn];
    [self cleanUpLastEffectWithCurrentStatus:BefEffectDetect];
    
}

- (void)onListenBeautyDataChanged:(NSNotification *)aNote {
    float value = [aNote.userInfo[BEEffectNotificationUserInfoKey] floatValue];
    
    if ([self beautyModel].detailType == BEEffectFaceFilter){
        [_processor  setFilterIntensity:value];
        [[self beautyModel] setModelWithtType:[self beautyModel].detailType value:value];
    }else {
        [[self beautyModel] setModelWithtType:[self beautyModel].detailType value:value];
        [self faceBeautyPickerDidSelectFaceBeautyData:[self beautyModel]];
    }
}

/*
 * 清空美颜效果
 */
- (void)clearUpFaceBeautyStatus{
    [self beautyModel].cheekIntensity = 0.0;
    [self beautyModel].eyeIntensity = 0.0;
    [self beautyModel].sharp = 0.0;
    [self beautyModel].smooth = 0.0;
    [self beautyModel].white = 0.0;
    [self beautyModel].path = @"";
    
    [self faceBeautyPickerDidSelectFaceBeautyData:[self beautyModel]];
}

/*
 * 清空美妆效果
 */
- (void)cleanUpFaceMakeUpStatus{

    [_processor clearFaceMakeUpEffect];
 
}

- (void)onListenBeautyTypeChanged:(NSNotification *)aNote{
    BEEffectFaceBeautyType beautyType = [aNote.userInfo[BEEffectNotificationUserInfoKey] integerValue];

    
    if (beautyType == BEEffectClearStatus){
        //互斥操作的时候，处于这个状态，不需要别的tab的状态
   
        return ;
    }if (beautyType == BEEffectFaceMakeNone){
        [_processor clearFaceMakeUpEffect];
    }if (beautyType == BEEffectFaceBeautyNone){
        //清空美颜状态，恢复到初始状态
        [self clearUpFaceBeautyStatus];
    } else if (beautyType >= BEEffectFaceBeautyReshape && beautyType <= BEEffectFaceBeautyBigEye){
        [self beautyModel].type = BEEffectReshapeTwoParam;
    } else if (beautyType <= BEEffectFaceBeautySharp){
        [self beautyModel].type = BEEffectBeautify;
    } else if (beautyType <= BEEffectFaceFilter){
        [self beautyModel].type = BEEffectFaceFilter;
    }
    
    [_processor renderSetInternalStatus:beautyType];
    
    [self beautyModel].detailType = beautyType;
    self.effectPickerView.intensitySlider.value = [[self beautyModel] getValueWithType:beautyType];
    
    [self cleanUpLastEffectWithCurrentStatus:BefEffectFaceBeauty];
    
}

- (void)onListenFilterChanged:(NSNotification *)aNote {
    NSString *path = aNote.userInfo[BEEffectNotificationUserInfoKey];
   
    [_processor setFilterPath:path];
    self.effectPickerView.intensitySlider.value = 0.5;
    [[self beautyModel] setModelWithtType:BEEffectFaceFilter value:0.5];
    [_processor setFilterIntensity:0.5];
    
    [self cleanUpLastEffectWithCurrentStatus:BefEffectFaceBeauty];
  
}

- (void)onListenFilterIntensityChanged:(NSNotification *)aNote {
    float intensity = [aNote.userInfo[BEEffectNotificationUserInfoKey] floatValue];
 
    [_processor setFilterIntensity:intensity];
    
}

- (void)stickersLoadData{
    @weakify(self)
    void (^completion)(BEEffectResponseModel *, NSError *) =  ^(BEEffectResponseModel *responseModel, NSError *error) {
        @strongify(self)
        if (!error){
            self.stickers = responseModel.stickerGroup.firstObject.stickers;
            [self.stickerPickerView refreshWithStickers:self.stickers];
        }
    };
    [self.stickerDataManager fetchDataWithCompletion:^(BEEffectResponseModel *responseModel, NSError *error) {
        completion(responseModel, error);
    }];
}

- (BEEffectDataManager *)stickerDataManager {
    if (!_stickerDataManager) {
        _stickerDataManager = [BEEffectDataManager dataManagerWithType:BEEffectDataManagerTypeSticker];
    }
    return _stickerDataManager;
}

#pragma mark - private
- (void)setStickerUnSelected{

    [self.stickerPickerView setAllCellUnSelected];
    //    [_processor setStickerPath:@""];
    [_processor renderSetInitStatus];
    
}

//去除所有的美颜效果
- (void)setEffectPickerUnSelected{

    //清除美妆和美颜的效果
    [_processor clearFaceMakeUpEffect];
    [self clearUpFaceBeautyStatus];
    [_processor setFilterPath:@""];
    self.effectPickerView.intensitySlider.value = 0.0;
    
    //在UI上更改
    BEEffectClearStatusDataStore *clearStore = [BEEffectClearStatusDataStore sharedDataStore];
    clearStore.shouldClearFaceBeauty = YES;
    clearStore.shouldClearFaceMakeUp = YES;
    clearStore.shouldClearFaceMakeUpPresent = YES;
    clearStore.shouldClearFilter = YES;
    
    //改为互斥状态
    BEEffectPickerDataStore *dataStore = [BEEffectPickerDataStore sharedDataStore];
    NSMutableArray *lastSelectedEffectTypes = dataStore.lastSelectedEffectTypes;
    
    dataStore.lastSelectedEffectCell = nil;
    dataStore.beautyModel.detailType = BEEffectFaceMakeNone;
    for  (int index = 0; index < lastSelectedEffectTypes.count; index ++){
        lastSelectedEffectTypes[index] = @(BEEffectClearStatus);
    }
    
   
}

- (void)setRecognizePickerUnSelected{
    //UI上的改变
    [self.recognizePickerView setAllTabsUnSelected];
    
    //主界面上的改动
    [self.cameraContainerView hideFaceVerifyListVC];
    [self.cameraContainerView hideFacePropertyListVC];
    [self.cameraContainerView hideGesPropertyListVC];
    [self.cameraContainerView setFaceVerifyHidden:YES];
    
    //detect上的改变
    [_processor setFaceDetector:false];
    [_processor setFaceExtraDetector:false];
    [_processor setFaceAttrDetector:false];
    [_processor setFaceVerifyOn:false];
    [_processor setSkeletonDetector:false];
    [_processor setBodySegmentationOn:false];
    [_processor setHairSegmentationOn:false];
    [_processor setGestureDetector:false];
    
    //共享状态的改变
    BEEffectPickerDataStore *pickerStore = [BEEffectPickerDataStore sharedDataStore];
    pickerStore.enableFaceDetect106 = NO;
    pickerStore.enableFaceDetect280 = NO;
    pickerStore.enableFaceDetectProps = NO;
    
    BEEffectClearStatusDataStore *clearStore = [BEEffectClearStatusDataStore sharedDataStore];
    clearStore.shouldClearFaceDetect = YES;
    clearStore.shouldClearFaceVerify = YES;
}

- (void)cleanUpLastEffectWithCurrentStatus:(BefEffectMainStatue)currentStatus{
    if (currentStatus != lastEffectStatue){
        switch (lastEffectStatue) {
            case BefEffectNone:
                break;
            case BefEffectDetect:
                [self setRecognizePickerUnSelected];
                break;
            case BefEffectFaceBeauty:
                [self setEffectPickerUnSelected];
                break;
            case BefEffectSticker:
                [self setStickerUnSelected];
                break;
            default:
                break;
        }
        lastEffectStatue = currentStatus;
    }
}

#pragma mark - Pickers
- (BEModernEffectPickerView *)effectPickerView {
    if (!_effectPickerView) {
        _effectPickerView = [[BEModernEffectPickerView alloc] initWithFrame:(CGRect)CGRectMake(0, 0, self.view.frame.size.width, 205)];
    }
    return _effectPickerView;
}

- (BEModernRecognizePickerView *)recognizePickerView {
    if (!_recognizePickerView) {
        _recognizePickerView = [[BEModernRecognizePickerView alloc] initWithFrame:(CGRect)CGRectMake(0, 0, self.view.frame.size.width, 160)];
    }
    return _recognizePickerView;
}

- (BEModernStickerPickerView *)stickerPickerView{
    if (!_stickerPickerView) {
        _stickerPickerView = [[BEModernStickerPickerView alloc] initWithFrame:(CGRect)CGRectMake(0, 0, self.view.frame.size.width, 205)];
        _stickerPickerView.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6].CGColor;
        _stickerPickerView.delegate = self;
        
        [self stickersLoadData];
    }
    return _stickerPickerView;
}

#pragma mark - BEModernStickerPickerViewDelegate
- (void)stickerPicker:(BEModernStickerPickerView *)pickerView didSelectStickerPath:(NSString *)path toastString:(NSString *)toast{

    [self cleanUpLastEffectWithCurrentStatus:BefEffectSticker];
    [_processor setStickerPath:path];
    [self.glView hideAllToasts];
    
    if (toast.length > 0 ){
        [self.glView makeToast:toast duration:(NSTimeInterval)(3.0) position:CSToastPositionCenter];
    }

}

#pragma mark - BECameraContainerViewDelegate

- (void) onSwitchCameraClicked:(UIButton *) sender {
    if (self.videoConfiguration.videoFrameRate >= 30) {
        sender.enabled = NO;
        __weak typeof(self) weakself = self;
        [self.shortVideoRecorder stopCaptureSession];
        [self.shortVideoRecorder toggleCamera:^(BOOL isFinish) {
            [weakself checkActiveFormat];// 默认的 active 可能最大只支持采集 30 帧，这里手动设置一下
            [weakself.shortVideoRecorder startCaptureSession];
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.enabled = YES;
            });
        }];
    } else {
        [self.shortVideoRecorder toggleCamera];
    }
}

- (void)checkActiveFormat {
    
    CGSize needCaptureSize = self.videoConfiguration.videoSize;
    
    if (AVCaptureVideoOrientationPortrait == self.videoConfiguration.videoOrientation ||
        AVCaptureVideoOrientationPortraitUpsideDown == self.videoConfiguration.videoOrientation) {
        needCaptureSize = CGSizeMake(self.videoConfiguration.videoSize.height, self.videoConfiguration.videoSize.width);
    }
    
    AVCaptureDeviceFormat *activeFormat = self.shortVideoRecorder.videoActiveFormat;
    AVFrameRateRange *frameRateRange = [activeFormat.videoSupportedFrameRateRanges firstObject];
    
    CMVideoDimensions captureSize = CMVideoFormatDescriptionGetDimensions(activeFormat.formatDescription);
    if (frameRateRange.maxFrameRate < self.videoConfiguration.videoFrameRate ||
        frameRateRange.minFrameRate > self.videoConfiguration.videoFrameRate ||
        needCaptureSize.width > captureSize.width ||
        needCaptureSize.height > captureSize.height) {
        
        NSArray *videoFormats = self.shortVideoRecorder.videoFormats;
        for (AVCaptureDeviceFormat *format in videoFormats) {
            frameRateRange = [format.videoSupportedFrameRateRanges firstObject];
            captureSize = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
            
            if (frameRateRange.maxFrameRate >= self.videoConfiguration.videoFrameRate &&
                frameRateRange.minFrameRate <= self.videoConfiguration.videoFrameRate &&
                captureSize.width >= needCaptureSize.width &&
                captureSize.height >= needCaptureSize.height) {
                NSLog(@"size = {%d x %d}, fps = %f ~ %f", captureSize.width, captureSize.height, frameRateRange.minFrameRate, frameRateRange.maxFrameRate);
                self.shortVideoRecorder.videoActiveFormat = format;
                break;
            }
        }
    }
}

- (void)onSettingsClicked:(UIButton *)sender {
    [self.effectPickerView actionSheetToViewController:self animated:YES completion:nil];
}

//显示识别view
- (void) onRecognizeClicked:(UIButton *)sender{
    [self.recognizePickerView actionSheetToViewController:self animated:YES completion:^{
        [self.cameraContainerView hiddenBottomButton];
    }];
}

//显示特效界面
- (void)onEffectButtonClicked:(UIButton *)sender{
    [self.cameraContainerView hiddenBottomButton];
    
    [self.effectPickerView actionSheetToViewController:self animated:YES completion:nil];
}

//显示贴纸界面
- (void)onStickerButtonClicked:(UIButton *)sender{
    [self.stickerPickerView actionSheetToViewController:self animated:YES completion:^{
        [self.cameraContainerView hiddenBottomButton];
    }];
}

- (void)onSegmentControlChanged:(UISegmentedControl *)sender {
//    NSString *key = [self.cameraContainerView segmentItems][sender.selectedSegmentIndex];
    
    self.glView.frame = [UIScreen mainScreen].bounds;

}

- (void)onSaveButtonClicked:(UIButton*)sender{
    if (self.shortVideoRecorder.isRecording) {
        self.bufferPause = YES;
        [self.shortVideoRecorder stopRecording];
    } else {
        [self.shortVideoRecorder startRecording];
    }
}

- (void)goEditViewController {
    
    AVAsset *asset = self.shortVideoRecorder.assetRepresentingAllFiles;
    // 设置音视频、水印等编辑信息
    NSMutableDictionary *outputSettings = [[NSMutableDictionary alloc] init];
    // 待编辑的原始视频素材
    NSMutableDictionary *plsMovieSettings = [[NSMutableDictionary alloc] init];
    plsMovieSettings[PLSAssetKey] = asset;
    plsMovieSettings[PLSStartTimeKey] = [NSNumber numberWithFloat:0.f];
    plsMovieSettings[PLSDurationKey] = [NSNumber numberWithFloat:[self.shortVideoRecorder getTotalDuration]];
    plsMovieSettings[PLSVolumeKey] = [NSNumber numberWithFloat:1.0f];
    outputSettings[PLSMovieSettingsKey] = plsMovieSettings;
    EditViewController *videoEditViewController = [[EditViewController alloc] init];
    videoEditViewController.settings = outputSettings;
    videoEditViewController.filesURLArray = [self.shortVideoRecorder getAllFilesURL];
    [self setRecognizePickerUnSelected];
    [self setStickerUnSelected];
    [self setEffectPickerUnSelected];
    [self.progressBar deleteAllProgress];
    self.durationLabel.text = @"0.0f";
    [self presentViewController:videoEditViewController animated:YES completion:nil];
}

- (NSURL *)getFileURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"TestPath"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]) {
        // 如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    
    NSURL *fileURL = [NSURL fileURLWithPath:fileName];
    
    return fileURL;
}

#pragma mark - BEFrameProcessorDelegate

- (void)BEFrameProcessor:(BEFrameProcessor *)processor didDetectHandInfo:(bef_ai_hand_info)handInfo {
    if (handInfo.hand_count == 0)  {
        self.cameraContainerView.gesPropertyListVC.view.hidden = YES;
        return;
    }
    bef_ai_hand info = handInfo.p_hands[0];
    self.cameraContainerView.gesPropertyListVC.view.hidden = NO;
    CGFloat widthRatio = CGRectGetWidth(self.glView.bounds) / self.videoConfiguration.videoSize.width;
    CGFloat heightRatio = CGRectGetHeight(self.glView.bounds) / self.videoConfiguration.videoSize.height;
    [self.cameraContainerView.gesPropertyListVC updateHandInfo:info widthRatio:widthRatio heightRatio:heightRatio];
}

- (void)BEFrameProcessor:(BEFrameProcessor *)processor didDetectFaceInfo:(bef_ai_face_info)faceInfo{
    int count = faceInfo.face_count;
    
    [self.cameraContainerView.facePropertyListVC updateFaceInfo:faceInfo.base_infos[0] faceCount:count];
}

- (void) BEFrameProcessor:(BEFrameProcessor *)processor didDetectExtraFaceInfo:(bef_ai_face_attribute_result)faceInfo{
    int count = faceInfo.face_count;
    
    [self.cameraContainerView.facePropertyListVC updateFaceExtraInfo:faceInfo.attr_info[0] count:count];
}

- (void) BEFrameProcessor:(BEFrameProcessor *)processor updateFaceVerifyInfo:(double)similarity costTime:(long)time{
    [self.cameraContainerView.faceVerifyListVC updateFaceVerifyInfo:similarity time:time];
}

- (void) BEFrameProcessor:(BEFrameProcessor *)processor didDetectFace:(bef_ai_face_info)faceInfo distance:(bef_ai_human_distance_result) distance{
    CGFloat widthRatio = CGRectGetWidth(self.glView.bounds) / self.videoConfiguration.videoSize.width;
    CGFloat heightRatio = CGRectGetHeight(self.glView.bounds) / self.videoConfiguration.videoSize.height;
    
    [self.cameraContainerView.faceDistanceVC updateFaceDistance:faceInfo distance:distance widthRatio:widthRatio heightRatio:heightRatio];
}

- (BEFaceBeautyModel *)beautyModel {
    return [BEEffectPickerDataStore sharedDataStore].beautyModel;
}

// 返回上一层
- (void)backButtonEvent:(id)sender {
    [self.shortVideoRecorder cancelRecording];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 短视频录制核心类设置
- (void)setupShortVideoRecorder {
    
    // SDK 的版本信息
    NSLog(@"PLShortVideoRecorder versionInfo: %@", [PLShortVideoRecorder versionInfo]);
    
    // SDK 授权信息查询
    [PLShortVideoRecorder checkAuthentication:^(PLSAuthenticationResult result) {
        NSString *authResult[] = {@"NotDetermined", @"Denied", @"Authorized"};
        NSLog(@"PLShortVideoRecorder auth status: %@", authResult[result]);
    }];
    
    self.videoConfiguration = [PLSVideoConfiguration defaultConfiguration];
    self.videoConfiguration.position = AVCaptureDevicePositionFront;
    self.videoConfiguration.videoFrameRate = 30;
    self.videoConfiguration.videoSize = CGSizeMake(720, 1280);
    self.videoConfiguration.averageVideoBitRate = 4 * 1000 * 1000;
    self.videoConfiguration.videoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoConfiguration.sessionPreset = AVCaptureSessionPreset1280x720;
    
    self.audioConfiguration = [PLSAudioConfiguration defaultConfiguration];
    
    self.shortVideoRecorder = [[PLShortVideoRecorder alloc] initWithVideoConfiguration:self.videoConfiguration audioConfiguration:self.audioConfiguration];
    self.shortVideoRecorder.delegate = self;
    self.shortVideoRecorder.maxDuration = 10.0f; // 设置最长录制时长
    [self.shortVideoRecorder setBeautifyModeOn:NO]; // 默认打开美颜
    self.shortVideoRecorder.outputFileType = PLSFileTypeMPEG4;
    self.shortVideoRecorder.innerFocusViewShowEnable = YES; // 显示 SDK 内部自带的对焦动画
    self.shortVideoRecorder.previewView.frame = self.view.bounds;
    self.shortVideoRecorder.touchToFocusEnable = NO;
//    [self.view addSubview:self.shortVideoRecorder.previewView];
    self.shortVideoRecorder.backgroundMonitorEnable = NO;
    
    [self.shortVideoRecorder startCaptureSession];
}

#pragma mark - PLShortVideoRecorderDelegate

// 摄像头鉴权的回调
- (void)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder didGetCameraAuthorizationStatus:(PLSAuthorizationStatus)status {
    if (status == PLSAuthorizationStatusAuthorized) {
        [recorder startCaptureSession];
    }
    else if (status == PLSAuthorizationStatusDenied) {
        NSLog(@"Error: user denies access to camera");
    }
}

// 麦克风鉴权的回调
- (void)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder didGetMicrophoneAuthorizationStatus:(PLSAuthorizationStatus)status {
    if (status == PLSAuthorizationStatusAuthorized) {
        [recorder startCaptureSession];
    }
    else if (status == PLSAuthorizationStatusDenied) {
        NSLog(@"Error: user denies access to microphone");
    }
}

// 摄像头对焦位置的回调
- (void)shortVideoRecorder:(PLShortVideoRecorder *)recorder didFocusAtPoint:(CGPoint)point {
    NSLog(@"shortVideoRecorder: didFocusAtPoint: %@", NSStringFromCGPoint(point));
}

// 摄像头采集的视频数据的回调
/// @abstract 获取到摄像头原数据时的回调, 便于开发者做滤镜等处理，需要注意的是这个回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致帧率下降
- (CVPixelBufferRef)shortVideoRecorder:(PLShortVideoRecorder *)recorder cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    @autoreleasepool {
        if ([EAGLContext currentContext] != self.glcontext) {
            [EAGLContext setCurrentContext:self.glcontext];
        }
        CVPixelBufferRef resultPixelBuffer = pixelBuffer;
        if (!self.bufferPause) {
            uint64_t hostTime = getUptimeInNanosecondWithMachTime(mach_absolute_time());
            BEProcessResult *result =  [_processor process:pixelBuffer timeStamp:hostTime];
            glFlush();
            CIImage *outputImage = [CIImage imageWithTexture:result.texture size:result.size flipped:YES colorSpace:NULL];
            if( outputImage != nil) {
                if( self.ciContext == nil) {
                    self.ciContext = [CIContext contextWithEAGLContext: [EAGLContext currentContext]  options:@{kCIContextWorkingColorSpace : [NSNull null]}];
                }
                [self.ciContext render: outputImage toCVPixelBuffer: resultPixelBuffer  bounds:[outputImage extent] colorSpace:NULL];
                
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.glView renderWithTexture:result.texture
                                      size:result.size
                                   flipped:YES
                       applyingOrientation:0
                      savingCurrentTexture:NO];
                
            });
            GLuint texture = result.texture;
            glDeleteTextures(1, &texture);
        }
        return resultPixelBuffer;
    }
}


// 开始录制一段视频时
- (void)shortVideoRecorder:(PLShortVideoRecorder *)recorder didStartRecordingToOutputFileAtURL:(NSURL *)fileURL {
    NSLog(@"start recording fileURL: %@", fileURL);
    
    [self.progressBar addProgressView];
    [self.progressBar startShining];
}

// 正在录制的过程中
- (void)shortVideoRecorder:(PLShortVideoRecorder *)recorder didRecordingToOutputFileAtURL:(NSURL *)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration {
    [self.progressBar setLastProgressToWidth:fileDuration / self.shortVideoRecorder.maxDuration * self.progressBar.frame.size.width];
    
    self.durationLabel.text = [NSString stringWithFormat:@"%.2fs", totalDuration];
}

// 完成一段视频录制的回调
- (void)shortVideoRecorder:(PLShortVideoRecorder *)recorder didFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration {
    
    [self.progressBar stopShining];
    if (totalDuration >= self.shortVideoRecorder.maxDuration) {
        [self onSaveButtonClicked:nil];
    }
    if(totalDuration > 1.0 || totalDuration == 1.0){
        [self goEditViewController];
    }
    
    
}


@end

