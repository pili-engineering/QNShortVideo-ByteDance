// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernFaceBeautyPickerCell.h"
#import <Masonry/Masonry.h>
#import "BEModernEffectPickerControlFactory.h"
#import "BEMacro.h"

@implementation BEModernFaceBeautyPickerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configWithRowDescriptor:(BEFormRowDescriptor *)rowDescriptor {
    _row = rowDescriptor;
}

@end

@interface BEModernFaceBeautyPickerSwitchCell ()

@property (nonatomic, strong) BEModernFaceBeautyPickerSwitchView *containerView;

@end

@implementation BEModernFaceBeautyPickerSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.leading.equalTo(self).offset(10);
            make.trailing.equalTo(self).offset(-10);
        }];
    }
    return self;
}

- (void)configWithRowDescriptor:(BEFormRowDescriptor *)rowDescriptor {
    [super configWithRowDescriptor:rowDescriptor];
    self.containerView.label.text = rowDescriptor.title;
    self.containerView.switcher.on = [rowDescriptor.value boolValue];
    self.containerView.switcher.enabled = rowDescriptor.enabled;
}

- (void)onValueChanged:(UISwitch *)sender {
    BEBLOCK_INVOKE(self.onValueChanged, self, @(sender.isOn));
}

- (BEModernFaceBeautyPickerSwitchView *)containerView {
    if (!_containerView) {
        _containerView = [BEModernFaceBeautyPickerSwitchView new];
        [_containerView.switcher addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _containerView;
}

@end

@interface BEModernFaceBeautyPickerSliderCell ()

@property (nonatomic, strong) BEModernFaceBeautyPickerSliderView *containerView;

@end

@implementation BEModernFaceBeautyPickerSliderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.leading.equalTo(self).offset(10);
            make.trailing.equalTo(self).offset(-10);
        }];
    }
    return self;
}

- (void)configWithRowDescriptor:(BEFormRowDescriptor *)rowDescriptor {
    [super configWithRowDescriptor:rowDescriptor];
    self.containerView.label.text = rowDescriptor.title;
    self.containerView.slider.value = [rowDescriptor.value floatValue];
    self.containerView.slider.enabled = rowDescriptor.enabled;
}

- (void)onValueChanged:(UISlider *)sender {
    BEBLOCK_INVOKE(self.onValueChanged, self, @(sender.value));
}

- (BEModernFaceBeautyPickerSliderView *)containerView {
    if (!_containerView) {
        _containerView = [BEModernFaceBeautyPickerSliderView new];
        [_containerView.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _containerView;
}

@end

@interface BEModernFaceActionCell ()

@property (nonatomic, strong) BEModernFaceActionView *containerView;

@end

@implementation BEModernFaceActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configWithRowDescriptor:(BEFormRowDescriptor *)rowDescriptor {
    [super configWithRowDescriptor:rowDescriptor];
}

- (void)setFaceActionSelected:(NSInteger)index{
    [self.containerView.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:false scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

-(void)setFaceActionUnSelected:(NSInteger)index{
    [self.containerView.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:false];
}

- (BEModernFaceActionView *)containerView {
    if (!_containerView) {
        _containerView = [[BEModernFaceActionView alloc]init];
    }
    return _containerView;
}
@end

