// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
#import "BEFaceBeautyModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BEEffectPickerDataStore : NSObject

+ (instancetype)sharedDataStore;

@property (nonatomic, strong, readonly) BEFaceBeautyModel *beautyModel;

@property (nonatomic, assign) BOOL enableFaceDetect106;
@property (nonatomic, assign) BOOL enableFaceDetect280;
@property (nonatomic, assign) BOOL enableFaceDetectProps;

@property (nonatomic, assign) BOOL enableHairSegmentation;
@property (nonatomic, assign) BOOL enableBodySegmentation;


//保存所有特效页面的美妆类型
@property (nonatomic, strong, readonly) NSMutableArray *lastSelectedEffectTypes;
//保存所有特效页面的当前被选中的cell，方便slider滑动时，找到当前的cell
@property (nonatomic, strong, readonly) NSMutableArray *lastSelectedEffectCells;
//当前被选中的cell，方便slider滑动时，改变cell的状态
@property (nonatomic, weak, readwrite) UICollectionViewCell *lastSelectedEffectCell;

@end

@interface BEEffectClearStatusDataStore: NSObject

+ (instancetype)sharedDataStore;

//保存了几个状态位，在viewController 每次viewWillAppear判断是否需要重新配置
@property (nonatomic, assign) BOOL shouldClearFaceDetect;
@property (nonatomic, assign) BOOL shouldClearFaceVerify;

//美颜的三个部分
@property (nonatomic, assign) BOOL shouldClearFaceBeauty;
@property (nonatomic, assign) BOOL shouldClearFaceMakeUp;
@property (nonatomic, assign) BOOL shouldClearFaceMakeUpPresent;
@property (nonatomic, assign) BOOL shouldClearFilter;

@end

NS_ASSUME_NONNULL_END
