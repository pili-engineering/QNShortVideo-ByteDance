// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#ifndef BEFormDescriptorDelegate_h
#define BEFormDescriptorDelegate_h
#import "BEFormDescriptor.h"

@protocol BEFormDescriptorDelegate <NSObject>

-(void)formRowDescriptorValueHasChanged:(BEFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue;

@end


#endif /* BEFormDescriptorDelegate_h */
