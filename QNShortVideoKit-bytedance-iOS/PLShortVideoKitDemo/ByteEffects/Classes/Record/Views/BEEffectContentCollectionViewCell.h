// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "UICollectionViewCell+BEAdd.h"
#import "BEEffectResponseModel.h"

@class BEEffectContentCollectionViewCell;

NS_ASSUME_NONNULL_BEGIN

@interface BEEffectContentCollectionViewCellFactory : NSObject

+ (Class)contentCollectionViewCellWithPanelTabType:(BEEffectPanelTabType)type;

@end

@interface BEEffectContentCollectionViewCell : UICollectionViewCell
@property (nonatomic, assign) BOOL shouldClearStatus;

-(void)setCellUnSelected;
@end

@interface BEEffectFaceDetectCollectionViewCell : BEEffectContentCollectionViewCell
-(void)setCellUnSelected;

@end

@interface BEEffectGestureCollectionViewCell : BEEffectContentCollectionViewCell
-(void)setCellUnSelected;

@end

@interface BEEffectFaceBodyCollectionViewCell : BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
@end

@interface BEEffectFaceBeautyCollectionViewCell : BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
@end

@interface BEEffecFiltersCollectionViewCell : BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
@end

@interface BEEffectMakeupCollectionViewCell : BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
@end

@interface BEEffectStickersCollectionViewCell : BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
@end

@interface BEEffectSegmentationCollectionViewCell: BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
@end

@interface BEEffectFaceVerifyViewCell: BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
@end

@interface BEEffectHumanDistanceCollectionViewCell: BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
@end

NS_ASSUME_NONNULL_END
