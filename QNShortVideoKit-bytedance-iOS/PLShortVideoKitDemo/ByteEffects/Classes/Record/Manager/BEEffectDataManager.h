// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
#import "BEEffectResponseModel.h"

typedef NS_ENUM(NSUInteger, BEEffectDataManagerType) {
    BEEffectDataManagerTypeSticker,
    BEEffectDataManagerTypeFilter,
    BEEffectDataManagerTypeBeauty,
    BEEffectDataManagerTypeMakeup,
};

typedef void(^BEEffectDataFetchCompletion)(BEEffectResponseModel * responseModel, NSError *error);

@interface BEEffectDataManager : NSObject

@property (nonatomic, readonly) BEEffectResponseModel *responseModel;

+ (instancetype)dataManagerWithType:(BEEffectDataManagerType)type;
+ (NSArray<BEEffectCategoryModel *> *)recognizeCategoryModelArray;
+ (NSArray<BEEffectCategoryModel *> *)effectCategoryModelArray;

- (void)fetchDataWithCompletion:(BEEffectDataFetchCompletion)completion;

@end
