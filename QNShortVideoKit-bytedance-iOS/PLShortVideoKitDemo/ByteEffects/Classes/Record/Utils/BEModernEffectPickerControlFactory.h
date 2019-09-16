// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class BESlider;

NS_ASSUME_NONNULL_BEGIN

@interface BEModernEffectPickerControlFactory : NSObject

+ (UILabel *)createLabel;
+ (BESlider *)createSlider;
+ (UISwitch *)createSwitch;

@end

@interface BEModernFaceBeautyPickerSliderView: UIView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UISlider *slider;

@end

@interface BEModernFaceBeautyPickerSwitchView: UIView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UISwitch *switcher;

@end

@interface BEModernFaceActionView: UIView
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@end

NS_ASSUME_NONNULL_END
