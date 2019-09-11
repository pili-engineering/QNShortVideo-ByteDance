//  Copyright © 2019 ailab. All rights reserved.

#import <UIKit/UIKit.h>
#import "BEFaceMakeUpPresentView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BEFaceMakeUpPresentViewControllerDelegate <NSObject>

-(void)onFaceMakeUpPresentViewExist;
@end

@interface BEFaceMakeUpPresentViewController : UIViewController

@property (nonatomic, readonly) BEFaceMakeUpPresentView* presentView;
@property (nonatomic, weak) id<BEFaceMakeUpPresentViewControllerDelegate> delegate;
@property (nonatomic, assign) BEEffectFaceMakeUpType  makeUpType;
@end

NS_ASSUME_NONNULL_END
