// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernFaceBeautyViewController.h"
#import <Masonry/Masonry.h>
#import "BEModernFaceBeautyPickerView.h"
#import "BEEffectDataManager.h"
#import "BEFaceBeautyModel.h"
#import "BEFrameProcessor.h"
#import "BEBeautyPickerCommonDefines.h"
#import "BEEffectPickerDataStore.h"

@interface BEModernFaceBeautyViewController () <BEModernFaceBeautyPickerViewDelegate>

@property (nonatomic, strong) BEModernFaceBeautyPickerView *faceBeautyPickerView;

@end

@implementation BEModernFaceBeautyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.faceBeautyPickerView];
    [self.faceBeautyPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.faceBeautyPickerView setClosedStatus];
}

//判断是否需要清空状态
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([self clearStatusDataStore].shouldClearFaceBeauty){
        [self.faceBeautyPickerView setClosedStatus];
        [self clearStatusDataStore].shouldClearFaceBeauty = false;

    }
}

#pragma mark - BEModernFaceBeautyPickerViewDelegate
- (void) faceBeautyDidSelectedAtIndex:(NSIndexPath *)indexPath{
    int row = (int)indexPath.row;
    
    //如果是关闭按钮，关闭美妆选项
    if (row == 0){
        [self.faceBeautyPickerView setClosedStatus];
    }
    
    //美颜数据被选择
    [self _notifyBeautyTypeChangeWithType:row - 1];
    [self lastSelectedEffectTypes][0] = @(row - 1);
}

#pragma mark - Private
- (void)_notifyBeautyTypeChangeWithType:(BEEffectFaceBeautyType)beautyType {
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceBeautyTypeDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: @(beautyType)}];
}

#pragma mark - getter
- (BEModernFaceBeautyPickerView *)faceBeautyPickerView {
    if (!_faceBeautyPickerView) {
        _faceBeautyPickerView = [[BEModernFaceBeautyPickerView alloc] init];
        _faceBeautyPickerView.delegate = self;
    }
    return _faceBeautyPickerView;
}

- (BEFaceBeautyModel *)beautyModel {
    return [BEEffectPickerDataStore sharedDataStore].beautyModel;
}

-(NSMutableArray *) lastSelectedEffectTypes{
    return [BEEffectPickerDataStore sharedDataStore].lastSelectedEffectTypes;
}

- (BEEffectClearStatusDataStore *)clearStatusDataStore{
    return [BEEffectClearStatusDataStore sharedDataStore];
}

@end
