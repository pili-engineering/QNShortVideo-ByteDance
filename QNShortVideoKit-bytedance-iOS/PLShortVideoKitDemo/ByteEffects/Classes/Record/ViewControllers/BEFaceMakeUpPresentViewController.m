//  Copyright © 2019 ailab. All rights reserved.

#import <Foundation/Foundation.h>
#import "BEFaceMakeUpPresentViewController.h"
#import "BEFaceMakeUpPresentView.h"
#import <Masonry/Masonry.h>
#import "BEEffectDataManager.h"
#import "BEEffectPickerDataStore.h"
#import <Mantle/EXTScope.h>

@interface BEFaceMakeUpPresentViewController () <BEFaceMakeUpPresentViewDelegate>
@property (nonatomic, strong) BEFaceMakeUpPresentView* presentView;
@property (nonatomic, strong) BEEffectDataManager *makeUpDataManager;
@property (nonatomic, copy) NSMutableArray <BEEffectFaceMakeUpGroup*> *makeUps;
@end

@implementation BEFaceMakeUpPresentViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.view addSubview:self.presentView];
    [self.presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    BEEffectClearStatusDataStore *store = [BEEffectClearStatusDataStore sharedDataStore];
    
    if (store.shouldClearFaceMakeUpPresent){
        for (int index = 0; index < _makeUps.count; index++){
            self.makeUps[_makeUpType].selectedIndex = nil;
        }
        store.shouldClearFaceMakeUpPresent = FALSE;
    }
    [self.presentView refreshWithMakeUpGroup:self.makeUps[_makeUpType]];
}

- (void)loadData{
    @weakify(self)
    void(^completion)(BEEffectResponseModel *, NSError *) = ^(BEEffectResponseModel *responseModel, NSError *error) {
        @strongify(self)
        if (!error) {
            self.makeUps = responseModel.makeUpGroup;
            [self.presentView refreshWithMakeUpGroup:self.makeUps[_makeUpType]];
        }
    };
    [self.makeUpDataManager fetchDataWithCompletion:^(BEEffectResponseModel *responseModel, NSError *error) {
        completion(responseModel, error);
    }];
}

#pragma mark - BEFaceMakeUpPresentViewDelegate
- (void)backButtonClicked{
    if ([self.delegate respondsToSelector:@selector(onFaceMakeUpPresentViewExist)]){
        [self.delegate onFaceMakeUpPresentViewExist];
    }
}

#pragma mark - getter
- (BEEffectDataManager *)makeUpDataManager {
    if (!_makeUpDataManager) {
        _makeUpDataManager = [BEEffectDataManager dataManagerWithType:BEEffectDataManagerTypeMakeup];
    }
    return _makeUpDataManager;
}

- (BEFaceMakeUpPresentView*) presentView{
    if (!_presentView){
        _presentView = [[BEFaceMakeUpPresentView alloc] init];
        _presentView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        _presentView.delegate = self;
    }
    return _presentView;
}
@end
