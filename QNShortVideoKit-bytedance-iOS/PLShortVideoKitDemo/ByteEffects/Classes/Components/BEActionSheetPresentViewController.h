// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import <UIKit/UIKit.h>

@interface BEActionSheetPresentViewController : UIViewController
@end

@interface UIView (ActionSheetPresent)
- (void)actionSheetToViewController:(UIViewController *_Nonnull)viewController animated: (BOOL)animated completion:(void (^ __nullable)(void))completion;
@end
