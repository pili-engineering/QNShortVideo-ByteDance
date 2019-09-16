// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEPropertyListCell.h"
#import <Masonry/Masonry.h>

@interface BEPropertyListCell ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *describeLabel;

@end

@implementation BEPropertyListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.label];
        [self.contentView addSubview:self.describeLabel];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.width.mas_equalTo(self);
            make.leading.mas_equalTo(self).with.offset(0);
        }];
        [self.describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self).with.offset(-5);
            make.top.mas_equalTo(self);
        }];
        
        UIView * selectedBackgroundView = [UIView new];
        selectedBackgroundView.backgroundColor = [UIColor blueColor];
        self.selectedBackgroundView = selectedBackgroundView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)configWithRowDescriptor:(BEFormRowDescriptor *)rowDescriptor {
    _row = rowDescriptor;
    _label.text = _row.title;
    _describeLabel.text = _row.detailTitle;
}

- (UILabel *)label {
    if (!_label) {
        _label = [UILabel new];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:13];
        _label.textAlignment = NSTextAlignmentLeft;
    }
    return _label;
}

- (UILabel *)describeLabel {
    if (!_describeLabel) {
        _describeLabel = [UILabel new];
        _describeLabel.textColor = [UIColor whiteColor];
        _describeLabel.font = [UIFont systemFontOfSize:13];
        _describeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _describeLabel;
}
@end
