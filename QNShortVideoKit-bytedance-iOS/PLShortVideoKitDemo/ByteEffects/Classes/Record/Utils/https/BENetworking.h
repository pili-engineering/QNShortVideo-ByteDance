//  Copyright © 2019 ailab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface BENetworking:NSObject

+ (BOOL) downLoadStickerWithUrl:(NSString* )stickerID;
+ (NSString*) createStickersPathIfNeeded;
+ (void) startNetworkMonintoring;
+ (AFNetworkReachabilityStatus) getCurrentNetworkingStatus;

@end

NS_ASSUME_NONNULL_END
