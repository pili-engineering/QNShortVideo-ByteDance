// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernFilterPickerViewController.h"
#import "BEModernFilterPickerView.h"
#import "BEEffectDataManager.h"
#import <Masonry/Masonry.h>
#import "BEStudioConstants.h"
#import "BEEffectPickerDataStore.h"
#import <Mantle/EXTScope.h>

@interface BEModernFilterPickerViewController ()<BEModernFilterPickerViewDelegate>

@property (nonatomic, strong) BEModernFilterPickerView *filterPickerView;
@property (nonatomic, strong) BEEffectDataManager *filterDataManager;
@property (nonatomic, copy) NSArray <BEEffect *> *filters;

@end

@implementation BEModernFilterPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.filterPickerView];
    [self.filterPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self loadData];
    [self setAllCellsUnSelected];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    BEEffectClearStatusDataStore *store = [BEEffectClearStatusDataStore sharedDataStore];
    
    if (store.shouldClearFilter){
        store.shouldClearFilter = false;
        
        [self setAllCellsUnSelected];
    }
}
#pragma mark - public
- (void)setAllCellsUnSelected{
    [self.filterPickerView setAllCellsUnSelected];
}

#pragma mark - BEModernFilterPickerViewDelegate
- (void)filterPicker:(BEModernFilterPickerView *)pickerView didSelectFilterPath:(NSString *)path {
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFilterDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: path?:@""}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceBeautyTypeDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: @(BEEffectFaceFilter)}];
    [self lastSelectedEffectTypes][2] = @(BEEffectFaceFilter);
}

- (void)loadData {
    @weakify(self)
    void(^completion)(BEEffectResponseModel *, NSError *) = ^(BEEffectResponseModel *responseModel, NSError *error) {
        @strongify(self)
        if (!error) {
            self.filters = responseModel.filterGroups.firstObject.filters;
            [self.filterPickerView refreshWithFilters:self.filters];
        }
    };
    [self.filterDataManager fetchDataWithCompletion:^(BEEffectResponseModel *responseModel, NSError *error) {
        completion(responseModel, error);
    }];
}

#pragma mark - getter

- (BEModernFilterPickerView *)filterPickerView {
    if (!_filterPickerView) {
        _filterPickerView = [[BEModernFilterPickerView alloc] init];
        _filterPickerView.delegate = self;
    }
    return _filterPickerView;
}

- (BEEffectDataManager *)filterDataManager {
    if (!_filterDataManager) {
        _filterDataManager = [BEEffectDataManager dataManagerWithType:BEEffectDataManagerTypeFilter];
    }
    return _filterDataManager;
}

-(NSMutableArray *) lastSelectedEffectTypes{
    return [BEEffectPickerDataStore sharedDataStore].lastSelectedEffectTypes;
}
@end
