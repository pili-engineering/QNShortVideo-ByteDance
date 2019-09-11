// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BEModernBasePickerView;
@protocol BEModernBasePickerViewDelegate <NSObject>

@required
- (void)onRecongnizedViewClicked:(BEModernBasePickerView*)sender;

@end

@interface BEModernBasePickerView : UIView

-(void) cellSetUnSelectedImagePath:(NSString*)unSelectedPath selectedImagePath:(NSString*)selectedPath describeStr:(NSString*)descStr additionStr:(NSString *)additionStr;

- (void)setSelected:(BOOL)selected;
- (void) hiddenAdditionLabel:(bool)hidden;

@property (nonatomic, weak) id <BEModernBasePickerViewDelegate> delegate;
@property(nonatomic, strong) UIButton *button;
@property(nonatomic, assign) BOOL enabled;

@end

NS_ASSUME_NONNULL_END


