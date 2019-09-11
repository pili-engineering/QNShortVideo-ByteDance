//  Copyright © 2019 ailab. All rights reserved.

#import <Foundation/Foundation.h>
#import "BEModernBasePickerViewCell.h"
#import "BEModernBasePickerView.h"
#import <Masonry.h>

@interface BEModernBasePickerViewCell ()
@property (nonatomic, strong) BEModernBasePickerView* pickerView;
@property (nonatomic, assign) BOOL used;

@end

@implementation BEModernBasePickerViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self addSubview:self.pickerView];
        
        [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _pickerView.userInteractionEnabled = NO;
    }
    return self;
}

/*
 * 初始化cell的数据
 */
-(void) cellSetUnSelectedImagePath:(NSString*)unSelectedPath selectedImagePath:(NSString*)selectedPath describeStr:(NSString*)descStr additionStr:(NSString *)additionStr{
    [self.pickerView cellSetUnSelectedImagePath:unSelectedPath selectedImagePath:selectedPath describeStr:descStr additionStr:additionStr];
}



#pragma mark - public

- (void)setSelectedStatus:(bool)selected{
    [self.pickerView setSelected:selected];
}

- (void) setCurrentCellUsed:(bool)used{
    [self.pickerView hiddenAdditionLabel:!used];
    _used = used;
}

#pragma mark - override
- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    [self.pickerView setSelected:selected];
}

#pragma mark - getter

- (BEModernBasePickerView *)pickerView{
    if (!_pickerView){
        _pickerView = [[BEModernBasePickerView alloc] init];
        
    }
    return _pickerView;
}
@end
