// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "UITableViewCell+BEAdd.h"
#import "BEFormRowDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface BEPropertyListCell : UITableViewCell

@property (nonatomic, weak, readonly) BEFormRowDescriptor *row;
@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UILabel *describeLabel;

- (void)configWithRowDescriptor:(BEFormRowDescriptor *)rowDescriptor NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
