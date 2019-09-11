// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEFormRowDescriptor.h"
#import "UITableViewCell+BEAdd.h"
#import <KVOController/KVOController.h>

@implementation BEFormRowDescriptor

- (void)dealloc
{
    [self.KVOController unobserve:self keyPath:FBKVOClassKeyPath(BEFormRowDescriptor, value)];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _height = BEFormUnspecifiedCellHeight;
        _enabled = YES;
        [self addKVOObserver];
    }
    return self;
}

- (instancetype)initWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title {
    if (self = [self init]) {
        _tag = tag;
        _rowType = rowType;
        _title = title;
    }
    return self;
}


- (instancetype)initWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title detailTitle:(NSString*)detailTitle{
    if (self = [self init]) {
        _tag = tag;
        _rowType = rowType;
        _title = title;
        _detailTitle = detailTitle;
    }
    return self;
}

+ (instancetype)rowDescriptorWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title {
    return [[self alloc] initWithTag:tag rowType:rowType title:title];
}

+ (instancetype)rowDescriptorWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title detailTitle:(NSString*) detailString{
    return [[self alloc] initWithTag:tag rowType:rowType title:title detailTitle:detailString];
}

-(UITableViewCell *)cellForFormCoordinator:(BEFormViewCoordinator *)formCoordinator
{
    Class cellClass = self.cellClass ?: [BEFormViewCoordinator cellClassesForRowDescriptorTypes][self.rowType];
    NSAssert(cellClass, @"Not defined BEFormRowDescriptorType: %@", self.rowType ?: @"");
    NSAssert([cellClass isSubclassOfClass: [UITableViewCell class]], @"cellClass must extend from UITableViewCell");
    NSString *cellIdentifier = [cellClass be_identifier];
    UITableViewCell *cell = [formCoordinator.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

#pragma mark - KVO

- (void)addKVOObserver {
    [self.KVOController observe:self keyPath:FBKVOClassKeyPath(BEFormRowDescriptor, value) options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        [self.sectionDescriptor.formDescriptor.delegate formRowDescriptorValueHasChanged:object oldValue:oldValue newValue:newValue];
        if (self.onChangeBlock) {
            self.onChangeBlock(oldValue, newValue, self);
        }
    }];
}

@end
