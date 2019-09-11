// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEFormDescriptor.h"
#import <UIKit/UIKit.h>

@interface BEFormDescriptor ()

@property (nonatomic, strong) NSMutableArray *formSections;
@property (nonatomic, copy) NSString *title;
@property (readonly) NSMutableDictionary* allRowsByTag;

@end

@implementation BEFormDescriptor

-(instancetype)init
{
    return [self initWithTitle:nil];
}

-(instancetype)initWithTitle:(NSString *)title;
{
    self = [super init];
    if (self){
        _formSections = [NSMutableArray array];
        _title = title;
        _allRowsByTag = [NSMutableDictionary dictionary];
    }
    return self;
}

+(instancetype)formDescriptor {
    return [[self class] formDescriptorWithTitle:nil];
}
+(instancetype)formDescriptorWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title];
}

-(void)addFormSection:(BEFormSectionDescriptor *)formSection
{
    [self insertObject:formSection inFormSectionsAtIndex:[self.formSections count]];
}

-(void)addFormSection:(BEFormSectionDescriptor *)formSection atIndex:(NSUInteger)index
{
    if (index == 0){
        [self insertObject:formSection inFormSectionsAtIndex:0];
    }
    else{
        BEFormSectionDescriptor* previousSection = [self.formSections objectAtIndex:MIN(self.formSections.count, index-1)];
        [self addFormSection:formSection afterSection:previousSection];
    }
}

-(void)addFormSection:(BEFormSectionDescriptor *)formSection afterSection:(BEFormSectionDescriptor *)afterSection
{
    NSUInteger sectionIndex;
    NSUInteger afterSectionIndex;
    if ((sectionIndex = [self.formSections indexOfObject:formSection]) == NSNotFound){
        afterSectionIndex = [self.formSections indexOfObject:afterSection];
        if (afterSectionIndex != NSNotFound) {
            [self insertObject:formSection inFormSectionsAtIndex:(afterSectionIndex + 1)];
        }
        else { //case when afterSection does not exist. Just insert at the end.
            [self addFormSection:formSection];
            return;
        }
    }
}

-(void)addFormRow:(BEFormRowDescriptor *)formRow beforeRow:(BEFormRowDescriptor *)beforeRow
{
    if (beforeRow.sectionDescriptor){
        [beforeRow.sectionDescriptor addFormRow:formRow beforeRow:beforeRow];
    }
    else{
        [[self.formSections lastObject] addFormRow:formRow beforeRow:beforeRow];
    }
}

-(void)addFormRow:(BEFormRowDescriptor *)formRow beforeRowTag:(NSString *)beforeRowTag
{
    BEFormRowDescriptor * beforeRowForm = [self formRowWithTag:beforeRowTag];
    [self addFormRow:formRow beforeRow:beforeRowForm];
}

-(void)addFormRow:(BEFormRowDescriptor *)formRow afterRow:(BEFormRowDescriptor *)afterRow
{
    if (afterRow.sectionDescriptor){
        [afterRow.sectionDescriptor addFormRow:formRow afterRow:afterRow];
    }
    else{
        [[self.formSections lastObject] addFormRow:formRow afterRow:afterRow];
    }
}

-(void)addFormRow:(BEFormRowDescriptor *)formRow afterRowTag:(NSString *)afterRowTag
{
    BEFormRowDescriptor * afterRowForm = [self formRowWithTag:afterRowTag];
    [self addFormRow:formRow afterRow:afterRowForm];
}

-(void)removeFormSectionAtIndex:(NSUInteger)index
{
    if (self.formSections.count > index){
        [self removeObjectFromFormSectionsAtIndex:index];
    }
}

-(void)removeFormSection:(BEFormSectionDescriptor *)formSection
{
    NSUInteger index = NSNotFound;
    if ((index = [self.formSections indexOfObject:formSection]) != NSNotFound){
        [self removeFormSectionAtIndex:index];
    }
}

-(void)removeFormRow:(BEFormRowDescriptor *)formRow
{
    for (BEFormSectionDescriptor * section in self.formSections){
        if ([section.formRows containsObject:formRow]){
            [section removeFormRow:formRow];
        }
    }
}

-(BEFormRowDescriptor *)formRowWithTag:(NSString *)tag
{
    return self.allRowsByTag[tag];
}

-(void)removeFormRowWithTag:(NSString *)tag
{
    BEFormRowDescriptor * formRow = [self formRowWithTag:tag];
    [self removeFormRow:formRow];
}

-(BEFormRowDescriptor *)formRowAtIndex:(NSIndexPath *)indexPath
{
    if ((self.formSections.count > indexPath.section) && [[self.formSections objectAtIndex:indexPath.section] formRows].count > indexPath.row){
        return [[[self.formSections objectAtIndex:indexPath.section] formRows] objectAtIndex:indexPath.row];
    }
    return nil;
}

-(NSIndexPath *)indexPathOfFormRow:(BEFormRowDescriptor *)formRow
{
    BEFormSectionDescriptor * section = formRow.sectionDescriptor;
    if (section){
        NSUInteger sectionIndex = [self.formSections indexOfObject:section];
        if (sectionIndex != NSNotFound){
            NSUInteger rowIndex = [section.formRows indexOfObject:formRow];
            if (rowIndex != NSNotFound){
                return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            }
        }
    }
    return nil;
}

#pragma mark - KVC

-(NSUInteger)countOfFormSections
{
    return self.formSections.count;
}

- (id)objectInFormSectionsAtIndex:(NSUInteger)index {
    return [self.formSections objectAtIndex:index];
}

- (NSArray *)formSectionsAtIndexes:(NSIndexSet *)indexes {
    return [self.formSections objectsAtIndexes:indexes];
}

- (void)insertObject:(BEFormSectionDescriptor *)formSection inFormSectionsAtIndex:(NSUInteger)index {
    formSection.formDescriptor = self;
    [self.formSections insertObject:formSection atIndex:index];
}

- (void)removeObjectFromFormSectionsAtIndex:(NSUInteger)index {
    [self.formSections removeObjectAtIndex:index];
}

#pragma mark - Helpers

-(void)addRowToTagCollection:(BEFormRowDescriptor*) rowDescriptor
{
    if (rowDescriptor.tag) {
        self.allRowsByTag[rowDescriptor.tag] = rowDescriptor;
    }
}

-(void)removeRowFromTagCollection:(BEFormRowDescriptor *)rowDescriptor
{
    if (rowDescriptor.tag){
        [self.allRowsByTag removeObjectForKey:rowDescriptor.tag];
    }
}

@end
