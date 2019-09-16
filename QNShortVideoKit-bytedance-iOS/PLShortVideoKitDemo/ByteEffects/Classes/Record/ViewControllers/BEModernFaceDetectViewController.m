// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernFaceDetectViewController.h"
#import "BEModernFaceDetectView.h"
#import <Masonry/Masonry.h>
#import "BEEffectPickerDataStore.h"
#import "BEBeautyPickerCommonDefines.h"
#import "BEStudioConstants.h"
#import <Toast/UIView+Toast.h>

@interface BEModernFaceDetectViewController () <BEModernFaceDetectViewDelegate>

@property (nonatomic, strong) BEModernFaceDetectView *faceDetectPickerView;

@end

@implementation BEModernFaceDetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.faceDetectPickerView];
    [self.faceDetectPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    BEEffectClearStatusDataStore *store = [BEEffectClearStatusDataStore sharedDataStore];

    if (store.shouldClearFaceDetect){
        [self setAllCellUnSelected];
        store.shouldClearFaceDetect = NO;
    }
}

#pragma mark - Public
- (void) setAllCellUnSelected{
    //view 里面反选中所有的cell
    [self.faceDetectPickerView setAllCellsUnSelected];
}

#pragma mark - BEModernFaceDetectViewDelegate

- (void)faceDetectChangedAtIndex:(NSIndexPath *)indexPath status:(BOOL)status{
    int row = (int)indexPath.row;
    NSString* key = BEFaceDetectTypesArray()[row];
    NSNumber *value = [NSNumber numberWithBool:status];
    
    [self _updateFaceDetectModelWithKey:key value:value];
}

#pragma mark - Private
- (void)_updateFaceDetectModelWithKey:(NSString *)key value:(id)value {
    BEEffectPickerDataStore *store = [BEEffectPickerDataStore sharedDataStore];
    NSString *_key = BERowDescriptorTagAndBeautyParamMapping()[key];
    if ([key isEqualToString:BERowDescriptorTagFaceDetect106]) {
        if (![value boolValue]) {
            store.enableFaceDetect280 = NO;
            store.enableFaceDetectProps = NO;
        }
    } else {
        if (!store.enableFaceDetect106) {
            value = @(NO);
        }
    }
    [store setValue:value forKey:_key];
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceDetectDataDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: @""}];
}

#pragma mark - getter
- (BEModernFaceDetectView *)faceDetectPickerView {
    if (!_faceDetectPickerView) {
        _faceDetectPickerView = [[BEModernFaceDetectView alloc] init];
        _faceDetectPickerView.delegate = self;
    }
    return _faceDetectPickerView;
}

static NSArray *BEFaceDetectTypesArray(){
    static NSArray *BEFaceDetectTypesArray;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        BEFaceDetectTypesArray =@[BERowDescriptorTagFaceDetect106, BERowDescriptorTagFaceDetect280, BERowDescriptorTagFaceDetectProperty];
    });
    return BEFaceDetectTypesArray;
}
@end
