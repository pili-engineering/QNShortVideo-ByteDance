// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Mantle/Mantle.h>
#import "BEEffectBaseDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface BEFaceBeautyModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) float cheekIntensity;
@property (nonatomic, assign) float eyeIntensity;
@property (nonatomic, assign) float smooth;
@property (nonatomic, assign) float white;
@property (nonatomic, assign) float sharp;
@property (nonatomic, assign) float lip;
@property (nonatomic, assign) float blusher;
@property (nonatomic, assign) float filter;
@property (nonatomic, assign) BEEffectFaceBeautyType detailType;
@property (nonatomic, assign) BEEffectType type;

- (void)setModelWithtType:(BEEffectFaceBeautyType)type value:(float)value;
- (float)getValueWithType:(BEEffectFaceBeautyType)type;
@end

NS_ASSUME_NONNULL_END
