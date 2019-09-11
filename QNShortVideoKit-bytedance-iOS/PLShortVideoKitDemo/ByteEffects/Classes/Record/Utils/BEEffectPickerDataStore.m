// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEEffectPickerDataStore.h"

@interface BEEffectPickerDataStore ()

@property (nonatomic, strong) BEFaceBeautyModel *beautyModel;
@property (nonatomic, strong) NSMutableArray *lastSelectedEffectTypes;
@property (nonatomic, strong) NSMutableArray *lastSelectedEffectCells;

@end

@implementation BEEffectPickerDataStore

+ (instancetype)sharedDataStore {
    static BEEffectPickerDataStore *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BEFaceBeautyModel *)beautyModel {
    if (!_beautyModel) {
        _beautyModel = [BEFaceBeautyModel new];
    }
    return _beautyModel;
}

- (NSMutableArray *)lastSelectedEffectTypes{
    if (!_lastSelectedEffectTypes){
        _lastSelectedEffectTypes = [[NSMutableArray alloc] init];
    }
    return _lastSelectedEffectTypes;
}

- (NSMutableArray *)lastSelectedEffectCells{
    if (!_lastSelectedEffectCells){
        _lastSelectedEffectCells = [[NSMutableArray alloc] init];
    }
    return _lastSelectedEffectCells;
}

@end


@interface BEEffectClearStatusDataStore ()

@end

@implementation BEEffectClearStatusDataStore

+ (instancetype)sharedDataStore {
    static BEEffectClearStatusDataStore *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
