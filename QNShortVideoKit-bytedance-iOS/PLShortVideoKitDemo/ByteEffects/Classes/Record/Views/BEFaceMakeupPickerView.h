// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>
@class BEFaceBeautyModel;

NS_ASSUME_NONNULL_BEGIN

@protocol BEFaceMakeupPickerViewDelegate <NSObject>

@required
- (void)faceMakeUpDidSelectedAtIndex:(NSIndexPath*)indexPath;
@end


@interface BEFaceMakeupPickerView : UIView

@property (nonatomic, strong) void(^onValueChanged)(NSString *key, id value);

@property (nonatomic, strong) BEFaceBeautyModel *beautyModel;
@property (nonatomic, weak) id<BEFaceMakeupPickerViewDelegate> delegate;

- (void) setAllCellsUnSelected;
@end

NS_ASSUME_NONNULL_END
