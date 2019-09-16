// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernFaceMakeupViewController.h"
#import <Masonry/Masonry.h>
#import "BEFaceMakeupPickerView.h"
#import "BEEffectPickerDataStore.h"
#import "BEBeautyPickerCommonDefines.h"
#import "BEEffectDataManager.h"
#import "BEStudioConstants.h"
#import "BEFaceMakeUpPresentViewController.h"
#import "UIResponder+BEAdd.h"

@interface BEModernFaceMakeupViewController () <BEFaceMakeupPickerViewDelegate>

@property (nonatomic, strong) BEFaceMakeupPickerView *faceMakeupPickerView;

@end

@implementation BEModernFaceMakeupViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.faceMakeupPickerView];
    [self.faceMakeupPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.faceMakeupPickerView setAllCellsUnSelected];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    BEEffectClearStatusDataStore *store = [BEEffectClearStatusDataStore sharedDataStore];
    
    if (store.shouldClearFaceMakeUp){
        
        [self.faceMakeupPickerView setAllCellsUnSelected];
        store.shouldClearFaceMakeUp = false;
    }
}

#pragma mark - BEModernFaceBeautyPickerViewDelegate
- (void)faceMakeUpDidSelectedAtIndex:(NSIndexPath *)indexPath{
    int row = (int)indexPath.row;
    
    if (row == 0){ // 关闭美颜状态
        BEEffectClearStatusDataStore *store = [BEEffectClearStatusDataStore sharedDataStore];
        store.shouldClearFaceMakeUp = YES;
        store.shouldClearFaceMakeUpPresent = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceBeautyTypeDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: @(BEEffectFaceMakeNone)}];
        return ;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceMakeupComposeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: @(row)}];
}

#pragma mark - getter
- (BEFaceMakeupPickerView *)faceMakeupPickerView {
    if (!_faceMakeupPickerView) {
        _faceMakeupPickerView = [[BEFaceMakeupPickerView alloc] init];
        _faceMakeupPickerView.beautyModel = self.beautyModel;
        _faceMakeupPickerView.delegate = self;

    }
    return _faceMakeupPickerView;
}

- (BEFaceBeautyModel *)beautyModel {
    return [BEEffectPickerDataStore sharedDataStore].beautyModel;
}

-(NSMutableArray *) lastSelectedEffectTypes{
    return [BEEffectPickerDataStore sharedDataStore].lastSelectedEffectTypes;
}

@end

