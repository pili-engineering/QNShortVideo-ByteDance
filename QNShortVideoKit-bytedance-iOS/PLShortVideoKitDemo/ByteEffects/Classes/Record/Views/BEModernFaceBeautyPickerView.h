// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>
@class BEFaceBeautyModel;

NS_ASSUME_NONNULL_BEGIN

@protocol BEModernFaceBeautyPickerViewDelegate <NSObject>

@required
- (void)faceBeautyDidSelectedAtIndex:(NSIndexPath*)indexPath;
@end

@interface BEModernFaceBeautyPickerView : UIView

@property (nonatomic, strong) void(^onValueChanged)(NSString *key, id value);
@property (nonatomic, weak) id<BEModernFaceBeautyPickerViewDelegate> delegate;

- (void)setClosedStatus;
@property (nonatomic, strong) BEFaceBeautyModel *beautyModel;

@end

NS_ASSUME_NONNULL_END
