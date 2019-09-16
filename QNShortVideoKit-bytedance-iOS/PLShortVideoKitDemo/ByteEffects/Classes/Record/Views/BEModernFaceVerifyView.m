// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernFaceVerifyView.h"
#import "BEForm.h"
#import <Masonry/Masonry.h>
#import "BEBeautyPickerCommonDefines.h"
#import "BEModernFaceBeautyPickerCell.h"
#import "BEEffectPickerDataStore.h"
#import "NSArray+BEAdd.h"
#import "BEModernEffectPickerControlFactory.h"
#import "BEStudioConstants.h"
#import "BEModernBasePickerView.h"

@interface BEModernFaceVerifyView () <BEModernBasePickerViewDelegate>

@property (nonatomic, strong) BEModernBasePickerView *buttonView;
@property (nonatomic, strong) BEModernBasePickerView *upLoadView;

@end

@implementation BEModernFaceVerifyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.buttonView];
        [self addSubview:self.upLoadView];

        [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.leading.mas_equalTo(self.mas_leading).with.offset(20);
            make.centerY.mas_equalTo(self);
        }];
        
        [self.upLoadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.trailing.mas_equalTo(self.mas_trailing).with.offset(-20);
            make.centerY.mas_equalTo(self);
        }];
        
        [self.buttonView setSelected:YES];
        [self.upLoadView setSelected:NO];
        self.upLoadView.userInteractionEnabled = NO;
    }
    return self;
}


#pragma mark - public
-(void) setCellsUnSelected{
    [self.buttonView setSelected:YES];
    [self.upLoadView setSelected:NO];
    self.upLoadView.userInteractionEnabled = false;
}

-(void)imageViewSetImage:(UIImage*) image{
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceVerifyImageNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey:image}];
}

#pragma mark - delegate

- (void)openAlbumButtonClicked{
    if ([self.delegate respondsToSelector:@selector(openSystemAlbumButtonClicked)]){
        [self.delegate openSystemAlbumButtonClicked];
    }
}

- (void)onRecongnizedViewClicked:(BEModernBasePickerView *)sender{
    BOOL isON = sender.enabled;
    
    if (sender == self.buttonView){
        self.upLoadView.userInteractionEnabled = !isON;
        [self.upLoadView setSelected:!isON];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceVerifyPickerNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey:@(!sender.enabled)}];
    }else if (sender == self.upLoadView){
        [self openAlbumButtonClicked];
        [sender setSelected:YES];
    }
}

#pragma mark - getter
- (BEModernBasePickerView *)buttonView {
    if (!_buttonView) {
        _buttonView = [[BEModernBasePickerView alloc] init];
        
        [_buttonView cellSetUnSelectedImagePath:@"iconCloseButtonNormal" selectedImagePath:@"iconCloseButtonSelected" describeStr:NSLocalizedString(@"face_verify_none_title", nil) additionStr:NSLocalizedString(@"face_verify_none_desc",nil)];
        _buttonView.delegate = self;
    }
    return _buttonView;
}

- (BEModernBasePickerView *)upLoadView {
    if (!_upLoadView) {
        _upLoadView = [[BEModernBasePickerView alloc] init];
        
        [_upLoadView cellSetUnSelectedImagePath:@"iconUpLoadNormal" selectedImagePath:@"iconUpLoadSelected" describeStr:NSLocalizedString(@"face_verify_upload_title", nil) additionStr:NSLocalizedString(@"face_verify_upload_desc", nil)];
        _upLoadView.delegate = self;
    }
    return _upLoadView;
}

@end
