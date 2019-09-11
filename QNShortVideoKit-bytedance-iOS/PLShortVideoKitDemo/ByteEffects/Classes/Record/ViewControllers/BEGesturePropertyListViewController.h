//  Copyright © 2019 ailab. All rights reserved.

#import <UIKit/UIKit.h>
#import "bef_effect_ai_hand.h"

NS_ASSUME_NONNULL_BEGIN

@interface BEGesturePropertyListViewController : UIViewController

-(void)updateHandInfo:(bef_ai_hand)info widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio;

@end

NS_ASSUME_NONNULL_END
