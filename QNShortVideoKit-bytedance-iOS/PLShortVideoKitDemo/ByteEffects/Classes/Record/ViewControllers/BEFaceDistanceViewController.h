//  Copyright © 2019 ailab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_human_distance.h"

NS_ASSUME_NONNULL_BEGIN

@interface BEFaceDistanceViewController: UIViewController

- (void)updateFaceDistance:(bef_ai_face_info)faceInfo distance:(bef_ai_human_distance_result)distance widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio;

@end

NS_ASSUME_NONNULL_END

