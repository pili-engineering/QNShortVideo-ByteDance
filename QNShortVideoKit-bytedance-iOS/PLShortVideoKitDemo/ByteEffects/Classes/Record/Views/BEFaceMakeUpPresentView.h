// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>
#import "BEEffectResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BEFaceMakeUpPresentViewDelegate <NSObject>

-(void)backButtonClicked;

@end

@interface BEFaceMakeUpPresentView : UIView

@property (nonatomic, weak) id<BEFaceMakeUpPresentViewDelegate> delegate;
- (void) refreshWithMakeUpGroup:(BEEffectFaceMakeUpGroup *)group;
@end

NS_ASSUME_NONNULL_END
