// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>
#import "BEBeautyPickerCommonDefines.h"
#import "BEFacePropertyListViewController.h"
#import "BEFaceVerifyListViewController.h"
#import "BEFaceDistanceViewController.h"

@class BEGesturePropertyListViewController, BEFacePropertyListViewController, BEFaceVerifyListViewController;

@protocol BECameraContainerViewDelegate <NSObject>
@optional
- (void)onSwitchCameraClicked:(id)sender;
- (void)onSettingsClicked:(id)sender;
- (void)onSegmentControlChanged:(UISegmentedControl *)sender;
- (void)onRecognizeClicked:(id)sender;
- (void)onEffectButtonClicked:(id)sender;
- (void)onStickerButtonClicked:(id)sender;
- (void)onSaveButtonClicked:(UIButton*)sender;
@end

@interface BECameraContainerView : UIView

@property(nonatomic, weak) id<BECameraContainerViewDelegate> delegate;
@property (nonatomic, readonly) BEGesturePropertyListViewController *gesPropertyListVC;
@property (nonatomic, readonly) BEFacePropertyListViewController *facePropertyListVC;
@property (nonatomic, readonly) BEFaceVerifyListViewController *faceVerifyListVC;
@property (nonatomic, readonly) BEFaceDistanceViewController *faceDistanceVC;


- (void)showGesPropertyListVC;
- (void)hideGesPropertyListVC;

- (void)showFacePropertyListVC;
- (void)hideFacePropertyListVC;

- (void)showFaceVerifyListVC;
- (void)hideFaceVerifyListVC;

- (void)showFaceDistanceVC;
- (void)hideFaceDistanceVC;

- (NSArray <NSString *>*)segmentItems;
- (void) setFaceVerifyImage:(UIImage*)image;
- (void) setFaceVerifyHidden:(BOOL) hidden;

- (void)showBottomButton;
- (void)hiddenBottomButton;
- (void)setScanQRButtonSelected:(bool)selected;
@end
