//  Copyright © 2019 ailab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BEModernBasePickerView.h"
#import <Masonry/Masonry.h>

@interface BEModernBasePickerView ()

@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UILabel *additionLabel;
@property(nonatomic, strong) CAShapeLayer *boardLayer; // 按键的边框
@end

@implementation BEModernBasePickerView

- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self addSubview:self.button];
        [self addSubview:self.descLabel];
        [self addSubview:self.additionLabel];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.button.mas_bottom);
            make.centerX.equalTo(self);
        }];
        
        [self.additionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.descLabel.mas_bottom);
            make.centerX.equalTo(self);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClicked)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        
        _enabled = false;
    }
    return self;
}

-(void) cellSetUnSelectedImagePath:(NSString*)unSelectedPath selectedImagePath:(NSString*)selectedPath describeStr:(NSString*)descStr additionStr:(NSString *)additionStr{
    UIImage *unSelectedImage = [UIImage imageNamed:unSelectedPath];
    UIImage *selectedImage = [UIImage imageNamed:selectedPath];
    
    [self.button setImage:unSelectedImage forState:UIControlStateNormal];
    [self.button setImage:selectedImage forState:UIControlStateSelected];

    self.descLabel.text = descStr;
    self.additionLabel.text = additionStr;
}


- (void )onClicked{
    _enabled = !_enabled;
    [self setSelected:_enabled];
    
    if ([self.delegate respondsToSelector:@selector(onRecongnizedViewClicked:)]){
        [self.delegate onRecongnizedViewClicked:self];
    }
}

#pragma util

/*
 * 设置选中状态，边框及其他状态
 */
- (void)setSelected:(BOOL)selected{
    if (selected){
        self.descLabel.textColor = [UIColor whiteColor];
        self.additionLabel.textColor = [UIColor whiteColor];
    }else {
        self.descLabel.textColor =  [UIColor colorWithRed:156.0 / 255.0 green:156.0 / 255.0 blue:156.0 / 255.0 alpha:1.0];
        self.additionLabel.textColor =  [UIColor colorWithRed:156.0 / 255.0 green:156.0 / 255.0 blue:156.0 / 255.0 alpha:1.0];
    }
    _enabled = selected;
    self.button.selected = selected;
}

/*
 * 隐藏掉底部描述框
 */
- (void) hiddenAdditionLabel:(bool)hidden{
    if (self.additionLabel.hidden != hidden){
        self.additionLabel.hidden = hidden;
    }
}
#pragma getter
- (UILabel *) descLabel{
    if (!_descLabel){
        UILabel *label = [[UILabel alloc] init];
        
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:156.0 / 255.0 green:156.0 / 255.0 blue:156.0 / 255.0 alpha:1.0];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        _descLabel = label;
    }
    return _descLabel;
}

- (UILabel *) additionLabel{
    if (!_additionLabel){
        UILabel *label = [[UILabel alloc] init];
        
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor colorWithRed:156.0 / 255.0 green:156.0 / 255.0 blue:156.0 / 255.0 alpha:1.0];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        _additionLabel = label;
    }
    return _additionLabel;
}

- (UIButton*) button {
    if (!_button){
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor clearColor];
        _button.userInteractionEnabled = NO;
//        _button.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    return _button;
}
- (CAShapeLayer *) boardLayer{
    if (!_boardLayer){
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.lineWidth = 1.0f;
        layer.lineDashPattern = @[@4, @2];
        layer.strokeColor = [UIColor colorWithRed:156.0 / 255.0 green:156.0 / 255.0 blue:156.0 / 255.0 alpha:1.0].CGColor;
        layer.fillColor = nil;
        _boardLayer = layer;
    }
    return _boardLayer;
}
@end
