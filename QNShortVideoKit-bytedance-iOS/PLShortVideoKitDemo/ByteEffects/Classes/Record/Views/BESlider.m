// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BESlider.h"

NSString *const BESliderBeginTrackingTouchNotification = @"kBESliderBeginTrackingTouchNotification";
NSString *const BESliderContinueTrackingTouchNotification = @"kBESliderContinueTrackingTouchNotification";
NSString *const BESliderEndTrackingTouchNotification = @"kBESliderEndTrackingTouchNotification";

@implementation BESlider

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:BESliderBeginTrackingTouchNotification object:nil];
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:BESliderContinueTrackingTouchNotification object:nil userInfo:@{@"sender":self}];
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:BESliderEndTrackingTouchNotification object:nil];
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:BESliderEndTrackingTouchNotification object:nil];
    [super cancelTrackingWithEvent:event];
}

@end
