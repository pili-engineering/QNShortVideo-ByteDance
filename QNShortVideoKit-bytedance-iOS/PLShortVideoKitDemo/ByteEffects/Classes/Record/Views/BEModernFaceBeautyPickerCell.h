// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "UITableViewCell+BEAdd.h"
#import "BEFormRowDescriptor.h"

@interface BEModernFaceBeautyPickerCell : UITableViewCell

@property (nonatomic, strong) void(^onValueChanged)(BEModernFaceBeautyPickerCell *cell, id value);
@property (nonatomic, weak, readonly) BEFormRowDescriptor *row;

- (void)configWithRowDescriptor:(BEFormRowDescriptor *)rowDescriptor NS_REQUIRES_SUPER;

@end

@interface BEModernFaceBeautyPickerSwitchCell : BEModernFaceBeautyPickerCell

@end

@interface BEModernFaceBeautyPickerSliderCell : BEModernFaceBeautyPickerCell

@end

@interface  BEModernFaceActionCell: BEModernFaceBeautyPickerCell

- (void)setFaceActionSelected:(NSInteger)index;
-(void)setFaceActionUnSelected:(NSInteger)index;

- (void)configWithRowDescriptor:(BEFormRowDescriptor *)rowDescriptor;
@end
