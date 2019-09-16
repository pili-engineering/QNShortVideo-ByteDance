// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
@class BEFormDescriptor, BEFormRowDescriptor;

@interface BEFormSectionDescriptor : NSObject

@property (nonatomic, copy) NSString *headerTitle;
@property (nonatomic, copy) NSString *footerTitle;
@property (nonatomic, strong) NSMutableArray <BEFormRowDescriptor *>*formRows;

@property (nonatomic, weak) BEFormDescriptor * formDescriptor;

+(instancetype)formSection;
+(instancetype)formSectionWithTitle:(NSString *)title;

-(void)addFormRow:(BEFormRowDescriptor *)formRow;
-(void)addFormRow:(BEFormRowDescriptor *)formRow afterRow:(BEFormRowDescriptor *)afterRow;
-(void)addFormRow:(BEFormRowDescriptor *)formRow beforeRow:(BEFormRowDescriptor *)beforeRow;
-(void)addFormRows:(NSArray <BEFormRowDescriptor *>*)formRows;
-(void)removeFormRowAtIndex:(NSUInteger)index;
-(void)removeFormRow:(BEFormRowDescriptor *)formRow;
-(void)moveRowAtIndexPath:(NSIndexPath *)sourceIndex toIndexPath:(NSIndexPath *)destinationIndex;

@end

