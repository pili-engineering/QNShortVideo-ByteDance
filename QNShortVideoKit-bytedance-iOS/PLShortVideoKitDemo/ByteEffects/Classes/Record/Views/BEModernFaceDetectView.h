// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BEModernFaceDetectViewDelegate <NSObject>

- (void)faceDetectChangedAtIndex:(NSIndexPath*)indexPath status:(BOOL)status;

@end

@interface BEModernFaceDetectView : UIView
@property (nonatomic, weak) id<BEModernFaceDetectViewDelegate> delegate;

- (void)setAllCellsUnSelected;
@end

NS_ASSUME_NONNULL_END
