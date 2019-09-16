// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEFormSectionDescriptor.h"
#import "BEFormRowDescriptor.h"
#import <UIKit/UIKit.h>
#import "BEFormDescriptor.h"

@interface BEFormDescriptor (_BEFormSectionDescriptor)

@property (readonly) NSDictionary* allRowsByTag;

-(void)addRowToTagCollection:(BEFormRowDescriptor*)rowDescriptor;
-(void)removeRowFromTagCollection:(BEFormRowDescriptor*) rowDescriptor;

@end

@interface BEFormSectionDescriptor ()

@end

@implementation BEFormSectionDescriptor

+ (instancetype)formSection {
    return [[self class] formSectionWithTitle:nil];
}

+ (instancetype)formSectionWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _formRows = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
{
    self = [self init];
    if (self) {
        _headerTitle = title;
    }
    return self;
}

-(void)addFormRow:(BEFormRowDescriptor *)formRow
{
    NSUInteger index = [self.formRows count];
    [self insertObject:formRow inFormRowsAtIndex:index];
}

-(void)addFormRow:(BEFormRowDescriptor *)formRow afterRow:(BEFormRowDescriptor *)afterRow
{
    NSUInteger rowIndex = [self.formRows indexOfObject:afterRow];
    if (rowIndex != NSNotFound) {
        [self insertObject:formRow inFormRowsAtIndex:rowIndex+1];
    }
    else { //case when afterRow does not exist. Just insert at the end.
        [self addFormRow:formRow];
        return;
    }
}

-(void)addFormRow:(BEFormRowDescriptor *)formRow beforeRow:(BEFormRowDescriptor *)beforeRow
{
    
    NSUInteger rowIndex = [self.formRows indexOfObject:beforeRow];
    if (rowIndex != NSNotFound) {
        [self insertObject:formRow inFormRowsAtIndex:rowIndex];
    }
    else { //case when afterRow does not exist. Just insert at the end.
        [self addFormRow:formRow];
        return;
    }
}

- (void)addFormRows:(NSArray<BEFormRowDescriptor *> *)formRows {
    for (BEFormRowDescriptor *row in formRows) {
        [self addFormRow:row];
    }
}

-(void)removeFormRowAtIndex:(NSUInteger)index
{
    if (self.formRows.count > index){
        [self removeObjectFromFormRowsAtIndex:index];
    }
}

-(void)removeFormRow:(BEFormRowDescriptor *)formRow
{
    NSUInteger index = NSNotFound;
    if ((index = [self.formRows indexOfObject:formRow]) != NSNotFound){
        [self removeFormRowAtIndex:index];
    }
}

- (void)moveRowAtIndexPath:(NSIndexPath *)sourceIndex toIndexPath:(NSIndexPath *)destinationIndex
{
    if ((sourceIndex.row < self.formRows.count) && (destinationIndex.row < self.formRows.count) && (sourceIndex.row != destinationIndex.row)){
        BEFormRowDescriptor * row = [self objectInFormRowsAtIndex:sourceIndex.row];
        [self.formRows removeObjectAtIndex:sourceIndex.row];
        [self.formRows insertObject:row atIndex:destinationIndex.row];
    }
}

#pragma mark - KVC

-(NSUInteger)countOfFormRows
{
    return self.formRows.count;
}

- (id)objectInFormRowsAtIndex:(NSUInteger)index
{
    return [self.formRows objectAtIndex:index];
}

- (NSArray *)formRowsAtIndexes:(NSIndexSet *)indexes
{
    return [self.formRows objectsAtIndexes:indexes];
}

- (void)insertObject:(BEFormRowDescriptor *)formRow inFormRowsAtIndex:(NSUInteger)index
{
    formRow.sectionDescriptor = self;
    [self.formDescriptor addRowToTagCollection:formRow];
    [self.formRows insertObject:formRow atIndex:index];
}

- (void)removeObjectFromFormRowsAtIndex:(NSUInteger)index
{
    BEFormRowDescriptor * row = [self.formRows objectAtIndex:index];
    [self.formDescriptor removeRowFromTagCollection:row];
    [self.formRows removeObjectAtIndex:index];
}

@end
