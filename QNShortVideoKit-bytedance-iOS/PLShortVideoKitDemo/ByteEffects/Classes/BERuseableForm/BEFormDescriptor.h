// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
#import "BEFormSectionDescriptor.h"
#import "BEFormRowDescriptor.h"
#import "BEFormDescriptorDelegate.h"

@interface BEFormDescriptor : NSObject

@property (nonatomic, readonly) NSMutableArray <BEFormSectionDescriptor *>*formSections;

@property (nonatomic, weak) id<BEFormDescriptorDelegate> delegate;

+(instancetype)formDescriptor;
+(instancetype)formDescriptorWithTitle:(NSString *)title;

-(void)addFormSection:(BEFormSectionDescriptor *)formSection;
-(void)addFormSection:(BEFormSectionDescriptor *)formSection atIndex:(NSUInteger)index;
-(void)addFormSection:(BEFormSectionDescriptor *)formSection afterSection:(BEFormSectionDescriptor *)afterSection;
-(void)addFormRow:(BEFormRowDescriptor *)formRow beforeRow:(BEFormRowDescriptor *)afterRow;
-(void)addFormRow:(BEFormRowDescriptor *)formRow beforeRowTag:(NSString *)afterRowTag;
-(void)addFormRow:(BEFormRowDescriptor *)formRow afterRow:(BEFormRowDescriptor *)afterRow;
-(void)addFormRow:(BEFormRowDescriptor *)formRow afterRowTag:(NSString *)afterRowTag;
-(void)removeFormSectionAtIndex:(NSUInteger)index;
-(void)removeFormSection:(BEFormSectionDescriptor *)formSection;
-(void)removeFormRow:(BEFormRowDescriptor *)formRow;
-(void)removeFormRowWithTag:(NSString *)tag;

-(BEFormRowDescriptor *)formRowAtIndex:(NSIndexPath *)indexPath;
-(NSIndexPath *)indexPathOfFormRow:(BEFormRowDescriptor *)formRow;

@end

