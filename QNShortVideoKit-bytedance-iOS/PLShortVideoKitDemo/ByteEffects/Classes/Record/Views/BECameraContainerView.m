// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import "BECameraContainerView.h"
#import <Masonry/Masonry.h>
#import "BEGesturePropertyListViewController.h"
#import "BEFacePropertyListViewController.h"
#import "BEFaceVerifyListViewController.h"
#import "UIViewController+BEAdd.h"
#import "UIResponder+BEAdd.h"
#import "BEFaceDistanceViewController.h"
#import "BEStudioConstants.h"
#import "BENetworking.h"
#import "BEModernEffectPickerControlFactory.h"
#import "BESlider.h"
#import "BECircleBubbleView.h"
#import "BEMacro.h"

@interface BECameraContainerView()

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *switchCameraButton;
//@property (nonatomic, strong) UIButton *scanQRButton;

@property (nonatomic, strong) UIButton *recognizeButton;
@property (nonatomic, strong) UIButton *effectButton;
@property (nonatomic, strong) UIButton *stickerButton;

@property (nonatomic, strong) UILabel *recognizeLabel;
@property (nonatomic, strong) UILabel *effectLabel;
@property (nonatomic, strong) UILabel *stickerLabel;

@property (nonatomic, strong) UIImageView *faceVerifyImageView;
@property (nonatomic, strong) UIImageView *watermarkView;
@property (nonatomic, strong) UIButton* saveButton;

@end

@implementation BECameraContainerView

@synthesize gesPropertyListVC = _gesPropertyListVC;
@synthesize facePropertyListVC = _facePropertyListVC;
@synthesize faceVerifyListVC = _faceVerifyListVC;
@synthesize faceDistanceVC = _faceDistanceVC;

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];

    if (self) {
       // [self addSubview:self.settingsButton];
        [self addSubview:self.switchCameraButton];
//        [self addSubview:self.scanQRButton];
        [self addSubview:self.watermarkView];
        
#if APP_IS_DEBUG
        [self addSubview:self.saveButton];
#endif
        [self addSubview:self.recognizeButton];
        [self addSubview:self.effectButton];
        [self addSubview:self.stickerButton];
        
        [self addSubview:self.recognizeLabel];
        [self addSubview:self.effectLabel];
        [self addSubview:self.stickerLabel];
        
        [self addSubview:self.faceVerifyImageView];
        
        [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-30);
            make.top.equalTo(self.mas_top).with.offset(30);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        [self.watermarkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(30);
            make.leading.equalTo(self).offset(26);
            make.size.mas_equalTo(CGSizeMake(128, 30));
        }];
        
//        [self.scanQRButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self).offset(30);
//            make.trailing.equalTo(self.switchCameraButton.mas_leading).offset(-20);
//            make.size.mas_equalTo(CGSizeMake(30, 30));
//        }];
        
        [self.effectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.bottom.equalTo(self.mas_bottom).with.offset(-80);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        [self.effectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.effectButton.mas_bottom);
            make.centerX.mas_equalTo(self.effectButton);
            make.size.mas_equalTo(CGSizeMake(50, 32));
        }];
        
        [self.recognizeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.effectButton.mas_leading).offset(-80);
            make.bottom.equalTo(self.mas_bottom).with.offset(-80);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        [self.recognizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.recognizeButton.mas_bottom);
            make.centerX.mas_equalTo(self.recognizeButton);
            make.size.mas_equalTo(CGSizeMake(50, 32));
        }];
        
        [self.stickerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.effectButton.mas_trailing).offset(80);
            make.bottom.equalTo(self.mas_bottom).with.offset(-80);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        [self.stickerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.stickerButton.mas_bottom);
            make.centerX.mas_equalTo(self.stickerButton);
            make.size.mas_equalTo(CGSizeMake(50, 32));
        }];
        
        [self.faceVerifyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.mas_trailing).offset(-5);
            make.bottom.equalTo(self.mas_bottom).with.offset(-225);
            make.size.mas_equalTo(CGSizeMake(100, 150));
        }];
        
#if APP_IS_DEBUG
        [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.bottom.mas_equalTo(self).offset(-140);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
#endif
        
        [BENetworking startNetworkMonintoring];
    }
    return self;
}

#pragma mark - event
- (void) onSwitchCameraClicked {
    if ([self.delegate respondsToSelector:@selector(onSwitchCameraClicked:)]) {
        [self.delegate onSwitchCameraClicked:self.switchCameraButton];
    }
}

- (void)onSettingsButtonClicked {
    if ([self.delegate respondsToSelector:@selector(onSettingsClicked:)]) {
        [self.delegate onSettingsClicked:self.switchCameraButton];
    }
}

- (void) onRecognizeClicked {
    if ([self.delegate respondsToSelector:@selector(onRecognizeClicked:)]) {
        [self.delegate onRecognizeClicked:self.switchCameraButton];
    }
}

- (void)onEffectButtonClicked {
    if ([self.delegate respondsToSelector:@selector(onEffectButtonClicked:)]) {
        [self.delegate onEffectButtonClicked:self.switchCameraButton];
    }
}

- (void)onStickerButtonClicked {
    if ([self.delegate respondsToSelector:@selector(onStickerButtonClicked:)]) {
        [self.delegate onStickerButtonClicked:self.switchCameraButton];
    }
}

- (void)onScanQRCodeButtonClicked:(UIButton*) sender{
    sender.selected = !sender.selected;
    if (sender.selected){
        [self hiddenBottomButton];
    } else {
        [self showBottomButton];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectQRCodeDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey:@(sender.selected)}];
}

- (void)onSaveButtonClicked:(UIButton*) sender{
    if ([self.delegate respondsToSelector:@selector(onSaveButtonClicked:)]){
        [self.delegate onSaveButtonClicked:sender];
    }
}
#pragma mark - public

- (void)showGesPropertyListVC {
    [self.be_topViewController displayContentController:self.gesPropertyListVC inView:self];
}

- (void)hideGesPropertyListVC {
    [self.be_topViewController hideContentController:self.gesPropertyListVC];
}

- (void)showFacePropertyListVC {
    [self.be_topViewController displayContentController:self.facePropertyListVC inView:self];
}

- (void) hideFacePropertyListVC {
    [self.be_topViewController hideContentController:self.facePropertyListVC];
}

- (void)showFaceVerifyListVC {
    [self.be_topViewController displayContentController:self.faceVerifyListVC inView:self];
}

- (void) hideFaceVerifyListVC {
    [self.be_topViewController hideContentController:self.faceVerifyListVC];
}

- (void)showFaceDistanceVC{
    [self.be_topViewController displayContentController:self.faceDistanceVC inView:self];
}

- (void)hideFaceDistanceVC{
    [self.be_topViewController hideContentController:self.faceDistanceVC];

}

- (void)showBottomButton{
    self.saveButton.hidden = NO;

    self.recognizeButton.hidden = NO;
    self.effectButton.hidden = NO;
    self.stickerButton.hidden = NO;
    
    self.recognizeLabel.hidden = NO;
    self.effectLabel.hidden = NO;
    self.stickerLabel.hidden = NO;
}

- (void)hiddenBottomButton{
    self.saveButton.hidden = YES;
    
    self.recognizeButton.hidden = YES;
    self.effectButton.hidden = YES;
    self.stickerButton.hidden = YES;
    
    self.recognizeLabel.hidden = YES;
    self.effectLabel.hidden = YES;
    self.stickerLabel.hidden = YES;
}

//- (void)setScanQRButtonSelected:(bool)selected{
//    self.scanQRButton.selected = selected;
//}

- (void) setFaceVerifyImage:(UIImage*)image{
    self.faceVerifyImageView.image = image;
}

- (void) setFaceVerifyHidden:(BOOL) hidden{
    self.faceVerifyImageView.hidden = hidden;
}

#pragma mark - getter && setter
- (UIButton *)settingsButton {
    if (!_settingsButton) {
        _settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingsButton setImage:[UIImage imageNamed:@"ic_bar_setting"] forState:UIControlStateNormal];
        [_settingsButton addTarget:self action:@selector(onSettingsButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingsButton;
}

/*
 * 切换摄像头按键
 */
- (UIButton *)switchCameraButton {
    if (!_switchCameraButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"iconCameraSwitch"];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onSwitchCameraClicked) forControlEvents:UIControlEventTouchUpInside];
        _switchCameraButton = button;
    }
    return _switchCameraButton;
}

/*
 * 扫码按键
 */
//- (UIButton *)scanQRButton {
//    if (!_scanQRButton) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *image = [UIImage imageNamed:@"iconScanQRCode"];
//        [button setImage:image forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(onScanQRCodeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        _scanQRButton = button;
//    }
//    return _scanQRButton;
//}

/*
 * 水印
 */
- (UIImageView*) watermarkView{
    if (!_watermarkView){
        UIImage *logoImage = [UIImage imageNamed:@"qiniu_logo"];
        _watermarkView = [[UIImageView alloc] initWithImage:logoImage];
    }
    return _watermarkView;
}

/*
 * 识别按键
 */
- (UIButton *)recognizeButton {
    if (!_recognizeButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"iconRecognize"];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onRecognizeClicked) forControlEvents:UIControlEventTouchUpInside];
        _recognizeButton = button;
    }
    return _recognizeButton;
}

/*
 *识别的label
 */
- (UILabel *)recognizeLabel{
    if (!_recognizeLabel){
        _recognizeLabel = [[UILabel alloc] init];
        _recognizeLabel.text = NSLocalizedString(@"detect", nil);
        _recognizeLabel.textColor = [UIColor whiteColor];
        _recognizeLabel.textAlignment = NSTextAlignmentCenter;
        _recognizeLabel.numberOfLines = 1;
        _recognizeLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return _recognizeLabel;
}

/*
 * 特效按键
 */
- (UIButton *)effectButton {
    if (!_effectButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"iconEffect"];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onEffectButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _effectButton = button;
    }
    return _effectButton;
}

/*
 *特效的label
 */
- (UILabel *)effectLabel{
    if (!_effectLabel){
        _effectLabel = [[UILabel alloc] init];
        _effectLabel.text = NSLocalizedString(@"effect", nil);
        _effectLabel.textColor = [UIColor whiteColor];
        _effectLabel.textAlignment = NSTextAlignmentCenter;
        _effectLabel.numberOfLines = 1;
        _effectLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return _effectLabel;
}

/*
 * 贴纸按键
 */
- (UIButton *)stickerButton {
    if (!_stickerButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"iconSticker"];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onStickerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _stickerButton = button;
    }
    return _stickerButton;
}

/*
 *贴纸的label
 */
- (UILabel *)stickerLabel{
    if (!_stickerLabel){
        _stickerLabel = [[UILabel alloc] init];
        _stickerLabel.text = NSLocalizedString(@"sticker", nil);
        _stickerLabel.textColor = [UIColor whiteColor];
        _stickerLabel.textAlignment = NSTextAlignmentCenter;
        _stickerLabel.numberOfLines = 1;
        _stickerLabel.font = [UIFont boldSystemFontOfSize:15];

    }
    return _stickerLabel;
}

/*
 *人脸比对图片
 */
- (UIImageView *) faceVerifyImageView{
    if (!_faceVerifyImageView){
        _faceVerifyImageView = [[UIImageView alloc] init];
        _faceVerifyImageView.contentMode = UIViewContentModeScaleAspectFit;
        _faceVerifyImageView.hidden = YES;
    }
    return _faceVerifyImageView;
}

- (BEGesturePropertyListViewController *)gesPropertyListVC {
    if (!_gesPropertyListVC) {
        _gesPropertyListVC = [BEGesturePropertyListViewController new];
    }
    return _gesPropertyListVC;
}

- (BEFacePropertyListViewController *)facePropertyListVC {
    if (!_facePropertyListVC) {
        _facePropertyListVC = [BEFacePropertyListViewController new];
    }
    return _facePropertyListVC;
}

- (BEFaceVerifyListViewController *)faceVerifyListVC{
    if (!_faceVerifyListVC) {
        _faceVerifyListVC = [BEFaceVerifyListViewController new];
    }
    return _faceVerifyListVC;
}

- (BEFaceDistanceViewController *)faceDistanceVC{
    if (!_faceDistanceVC){
        _faceDistanceVC = [BEFaceDistanceViewController new];
    }
    return _faceDistanceVC;
}
- (NSArray<NSString *> *)segmentItems {
    return @[BEVideoRecorderSegmentContent640x480, BEVideoRecorderSegmentContent1280x720];
}

- (UIButton *) saveButton{
    if (!_saveButton){
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton addTarget:self action:@selector(onSaveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIImage* image = [UIImage imageNamed:@"iconButtonSavePhoto.png"];
        UIImage* selectedImage = [UIImage imageNamed:@"iconButtonSavePhotoSelected.png"];
        [_saveButton setImage:image forState:UIControlStateNormal];
        [_saveButton setImage:selectedImage forState:UIControlStateSelected];
    }
    return _saveButton;
}
@end
