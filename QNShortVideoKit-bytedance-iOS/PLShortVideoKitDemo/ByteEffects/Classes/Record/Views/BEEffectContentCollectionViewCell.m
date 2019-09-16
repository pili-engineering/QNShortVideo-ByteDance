// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEEffectContentCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "UIResponder+BEAdd.h"
#import "BEStudioConstants.h"
#import "BEModernEffectPickerControlFactory.h"
#import "BEModernBasePickerView.h"
#import "BEEffectPickerDataStore.h"

@implementation BEEffectContentCollectionViewCellFactory

+ (Class)contentCollectionViewCellWithPanelTabType:(BEEffectPanelTabType)type {
    Class cellClass = [BEEffectContentCollectionViewCell class];
    switch (type) {
        case BEEffectPanelTabFace:
            cellClass = [BEEffectFaceDetectCollectionViewCell class];
            break;
        case BEEffectPanelTabGesture:
            cellClass = [BEEffectGestureCollectionViewCell class];
            break;
        case BEEffectPanelTabBody:
            cellClass = [BEEffectFaceBodyCollectionViewCell class];
            break;
        case BEEffectPanelTabBeauty:
            cellClass = [BEEffectFaceBeautyCollectionViewCell class];
            break;
        case BEEffectPanelTabFilter:
            cellClass = [BEEffecFiltersCollectionViewCell class];
            break;
        case BEEffectPanelTabMakeup:
            cellClass = [BEEffectMakeupCollectionViewCell class];
            break;
        case BEEffectPanelTabSegmentation:
            cellClass = [BEEffectSegmentationCollectionViewCell class];
            break;
        case BEEffectPanelTabFaceVerify:
            cellClass = [BEEffectFaceVerifyViewCell class];
            break;
        case BEEffectPanelTabHumanDistance:
            cellClass = [BEEffectHumanDistanceCollectionViewCell class];
            break;

    }
    return cellClass;
}

@end

@interface BEEffectContentCollectionViewCell ()

- (void)displayContentController:(UIViewController *)viewController;

@end

@implementation BEEffectContentCollectionViewCell

- (void)displayContentController:(UIViewController *)viewController {
    UIViewController *parent = [self be_topViewController];
    [parent addChildViewController:viewController];
    [self.contentView addSubview:viewController.view];
    [viewController didMoveToParentViewController:parent];
    [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)hideContentController:(UIViewController*)content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)setCellUnSelected{
    return ;
}
@end

#pragma mark - 人脸cell

#import "BEModernFaceDetectViewController.h"

@interface BEEffectFaceDetectCollectionViewCell ()

@property (nonatomic, strong) BEModernFaceDetectViewController *faceDetectVC;

@end

@implementation BEEffectFaceDetectCollectionViewCell

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    self.faceDetectVC = [BEModernFaceDetectViewController new];
    [self displayContentController:self.faceDetectVC];
}

- (void)setCellUnSelected{
    [super setCellUnSelected];
}

@end

#pragma mark - 手势cell

@interface BEEffectGestureCollectionViewCell () <BEModernBasePickerViewDelegate>
@property (nonatomic, strong) BEModernBasePickerView *containerView;
@end

@implementation BEEffectGestureCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)onRecongnizedViewClicked:(BEModernBasePickerView* )sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectGestureDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey:@(sender.enabled)}];
}

- (BEModernBasePickerView *)containerView {
    if (!_containerView) {
        _containerView = [[BEModernBasePickerView alloc] init];
        [_containerView cellSetUnSelectedImagePath:@"iconGestureNormal" selectedImagePath:@"iconGestureSelected" describeStr:NSLocalizedString(@"hand_detect_title", nil) additionStr:NSLocalizedString(@"hand_detect_desc", nil)];
        
        _containerView.delegate = self;
    }
    return _containerView;
}

- (void)setCellUnSelected{
    [super setCellUnSelected];
    
    if (self.containerView.enabled){
        [self.containerView setSelected:false];
    }
}

@end

#pragma mark - 人体cell

@interface BEEffectFaceBodyCollectionViewCell ()  <BEModernBasePickerViewDelegate>
@property (nonatomic, strong) BEModernBasePickerView *containerView;
@end

@implementation BEEffectFaceBodyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)onRecongnizedViewClicked:(BEModernBasePickerView*)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectBodyDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey:@(sender.enabled)}];
}

- (BEModernBasePickerView *)containerView {
    [super setCellUnSelected];

    if (!_containerView) {
        _containerView = [BEModernBasePickerView new];
        [_containerView cellSetUnSelectedImagePath:@"iconSkeletonNormal" selectedImagePath:@"iconSkeletonSelected" describeStr:NSLocalizedString(@"setting_skeleton", nil) additionStr:NSLocalizedString(@"skeleton_detect_desc", nil)];
        _containerView.delegate = self;
    }
    return _containerView;
}

- (void)setCellUnSelected{
    if (_containerView.enabled != false){
        _containerView.enabled = false;
        [_containerView setSelected:false];
    }
}

@end

#pragma mark - 美颜cell

#import "BEModernFaceBeautyViewController.h"

@interface BEEffectFaceBeautyCollectionViewCell ()

@property (nonatomic, strong) BEModernFaceBeautyViewController *faceBeautyVC;

@end

@implementation BEEffectFaceBeautyCollectionViewCell

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    self.faceBeautyVC = [BEModernFaceBeautyViewController new];
    [self displayContentController:self.faceBeautyVC];
}

- (void) setCellUnSelected{
    [super setCellUnSelected];    
}

@end

#pragma mark - 滤镜cell

#import "BEModernFilterPickerViewController.h"

@interface BEEffecFiltersCollectionViewCell ()

@property (nonatomic, strong) BEModernFilterPickerViewController *filterVC;

@end

@implementation BEEffecFiltersCollectionViewCell

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    self.filterVC = [BEModernFilterPickerViewController new];
    [self displayContentController:self.filterVC];
}

- (void)setCellUnSelected{
}

@end

#pragma mark - 美妆cell

#import "BEModernFaceMakeupViewController.h"

@interface BEEffectMakeupCollectionViewCell ()

@property (nonatomic, strong) BEModernFaceMakeupViewController *makeupVC;

@end

@implementation BEEffectMakeupCollectionViewCell

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    self.makeupVC = [BEModernFaceMakeupViewController new];
    [self displayContentController:self.makeupVC];
}

-(void)setCellUnSelected{
    [super setCellUnSelected];
}
@end

#pragma mark - 分割cell

@interface BEEffectSegmentationCollectionViewCell ()  <BEModernBasePickerViewDelegate>
@property (nonatomic, strong) BEModernBasePickerView *hairView;
@property (nonatomic, strong) BEModernBasePickerView *backGroundView;
@end

@implementation BEEffectSegmentationCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.hairView];
        [self.contentView addSubview:self.backGroundView];

        [self.hairView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.leading.mas_equalTo(self.mas_leading).with.offset(20);
            make.centerY.mas_equalTo(self);

        }];
        
        [self.backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.trailing.mas_equalTo(self.mas_trailing).with.offset(-20);
            make.centerY.mas_equalTo(self);
        }];
        
    }
    return self;
}

#pragma mark - delegate
- (void)onRecongnizedViewClicked:(BEModernBasePickerView*)sender{
    if (sender == _hairView){
        [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectSegmentationDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey:@[@"hair",@(sender.enabled)]}];
    }else if (sender == _backGroundView){
        [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectSegmentationDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey:@[@"backGround", @(sender.enabled)]}];
    }
}

#pragma mark - getter
- (BEModernBasePickerView *)hairView {
    if (!_hairView) {
        _hairView = [[BEModernBasePickerView alloc] init];
        [_hairView cellSetUnSelectedImagePath:@"iconHairNormal" selectedImagePath:@"iconHairSelected" describeStr:NSLocalizedString(@"segment_hair_title", nil) additionStr:NSLocalizedString(@"segment_hair_desc", nil)];
        
        _hairView.delegate = self;
    }
    return _hairView;
}

- (BEModernBasePickerView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[BEModernBasePickerView alloc] init];
        [_backGroundView cellSetUnSelectedImagePath:@"iconBackGroundNormal" selectedImagePath:@"iconBackGroundSelected" describeStr:NSLocalizedString(@"segment_segment_title", nil) additionStr:NSLocalizedString(@"segment_segment_desc", nil)];
        
        _backGroundView.delegate = self;
    }
    return _backGroundView;
}

- (void)setCellUnSelected{
    [super setCellUnSelected];

    if (_hairView.enabled != false){
        [_hairView setSelected:false];
    }
    
    if (_backGroundView.enabled != false){
        [_backGroundView setSelected:false];
    }
}
@end


#pragma mark - 人脸比对cell

#import "BEModernFaceVerifyViewController.h"
@interface BEEffectFaceVerifyViewCell ()

@property (nonatomic, strong) BEModernFaceVerifyViewController *faceVerifyVC;
@end

@implementation BEEffectFaceVerifyViewCell

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    self.faceVerifyVC = [BEModernFaceVerifyViewController new];
    [self displayContentController:self.faceVerifyVC];
}

- (void)setCellUnSelected{
    [super setCellUnSelected];
}
@end

#pragma mark - 人脸距离估计cell
@interface BEEffectHumanDistanceCollectionViewCell ()
@property (nonatomic, strong) BEModernFaceBeautyPickerSwitchView *containerView;
@property (nonatomic, strong) UILabel *descrLabel;
@end

@implementation BEEffectHumanDistanceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.containerView];
        [self.contentView addSubview:self.descrLabel];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.leading.equalTo(self).offset(10);
            make.trailing.equalTo(self).offset(-10);
            make.height.mas_equalTo(40);
        }];
        [self.descrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView.mas_bottom).offset(10);
            make.leading.equalTo(self.containerView);
        }];
    }
    return self;
}

- (void)onValueChanged:(UISwitch *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceDistanceDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey:@(sender.isOn)}];
}

- (BEModernFaceBeautyPickerSwitchView *)containerView {
    if (!_containerView) {
        _containerView = [BEModernFaceBeautyPickerSwitchView new];
        _containerView.label.text = @"距离估计";
        [_containerView.switcher addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _containerView;
}

- (UILabel *)descrLabel {
    if (!_descrLabel) {
        _descrLabel = [UILabel new];
        _descrLabel.textColor = [UIColor lightGrayColor];
        _descrLabel.font = [UIFont systemFontOfSize:12];
        _descrLabel.text = @"人脸到摄像头的距离估计";
    }
    return _descrLabel;
}


@end
