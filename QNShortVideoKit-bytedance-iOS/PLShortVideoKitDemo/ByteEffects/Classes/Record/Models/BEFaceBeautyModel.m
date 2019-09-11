// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEFaceBeautyModel.h"

@implementation BEFaceBeautyModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enabled = YES;
        _path = @"";
    }
    return self;
}

- (void)setModelWithtType:(BEEffectFaceBeautyType)type value:(float)value{
    switch (type) {
        case BEEffectFaceBeautyReshape:
            self.cheekIntensity = value;
            break;
        case BEEffectFaceBeautyBigEye:
            self.eyeIntensity = value;
            break;
        case BEEffectFaceBeautySmooth:
            self.smooth = value;
            break;
        case BEEffectFaceBeautyWhiten:
            self.white = value;
            break;
        case BEEffectFaceBeautySharp:
            self.sharp = value;
            break;
        case BEEffectFaceMakeUpLips:
            self.lip = value;
            break;
        case BEEffectFaceMakeUpBlusher:
            self.blusher = value;
            break;
        case BEEffectFaceFilter:
            self.filter = value;
        default:
            break;
    }
}

- (float)getValueWithType:(BEEffectFaceBeautyType)type{
    float retValue = 0.0;
    
    switch (type) {
        case BEEffectFaceBeautyReshape:
            retValue = self.cheekIntensity;
            break;
        case BEEffectFaceBeautyBigEye:
            retValue = self.eyeIntensity;
            break;
        case BEEffectFaceBeautySmooth:
            retValue = self.smooth;
            break;
        case BEEffectFaceBeautyWhiten:
            retValue = self.white;
            break;
        case BEEffectFaceBeautySharp:
            retValue = self.sharp;
            break;
        case BEEffectFaceMakeUpLips:
            retValue = self.lip;
            break;
        case BEEffectFaceMakeUpBlusher:
            retValue = self.blusher;
            break;
        case BEEffectFaceFilter:
            retValue = self.filter;
            break;
        default:
            break;
    }
    return retValue;
}
#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    NSError *error;
    NSDictionary *dic = [MTLJSONAdapter JSONDictionaryFromModel:self error:&error];
    if (error) {
        return nil;
    }
    BEFaceBeautyModel *copy = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:&error];
    return copy;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

@end
