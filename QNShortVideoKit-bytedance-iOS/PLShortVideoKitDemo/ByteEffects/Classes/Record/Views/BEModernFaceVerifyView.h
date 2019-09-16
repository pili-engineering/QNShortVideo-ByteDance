// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BEModernFaceVerifyViewDelegate <NSObject>

@required
- (void)openSystemAlbumButtonClicked;

@end

@interface BEModernFaceVerifyView : UIView

@property (nonatomic, weak) id <BEModernFaceVerifyViewDelegate> delegate;

-(void)imageViewSetImage:(UIImage*) image;
-(void) setCellsUnSelected;

@end

NS_ASSUME_NONNULL_END
