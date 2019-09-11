// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BEActionSheetPresentAnimator : NSObject<UIViewControllerAnimatedTransitioning>
- (instancetype)initWithViewController: (UIViewController *)viewController;
@end
