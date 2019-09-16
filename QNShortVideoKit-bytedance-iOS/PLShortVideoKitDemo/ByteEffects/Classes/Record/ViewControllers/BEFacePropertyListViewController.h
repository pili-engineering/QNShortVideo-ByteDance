//  Copyright © 2019 ailab. All rights reserved.

#import <UIKit/UIKit.h>
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_face_attribute.h"

NS_ASSUME_NONNULL_BEGIN

@interface BEFacePropertyListViewController : UIViewController

- (void) updateFaceInfo:(bef_ai_face_106)info faceCount:(int)count;
- (void) updateFaceExtraInfo:(bef_ai_face_attribute_info)info count:(int)count;

@end

NS_ASSUME_NONNULL_END
