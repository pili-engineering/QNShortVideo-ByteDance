// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEFormViewCoordinator.h"

@interface BEFormViewCoordinator ()

@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, strong) UITableView *internalTableView;

@end

@implementation BEFormViewCoordinator

#pragma mark - Initialization

-(instancetype)initWithForm:(BEFormDescriptor *)form
{
    return [self initWithForm:form style:UITableViewStylePlain];
}

-(instancetype)initWithForm:(BEFormDescriptor *)form style:(UITableViewStyle)style
{
    if (self = [super init]) {
        _tableViewStyle = style;
        _form = form;
        _tableView = [self internalTableView];
    }
    return self;
}

- (void)updateForm:(BEFormDescriptor *)form {
    _form = form;
}

-(void)reloadFormRow:(BEFormRowDescriptor *)formRow
{
    NSIndexPath * indexPath = [self.form indexPathOfFormRow:formRow];
    if (indexPath){
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - CellClasses

+(NSMutableDictionary *)cellClassesForRowDescriptorTypes
{
    static NSMutableDictionary * _cellClassesForRowDescriptorTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cellClassesForRowDescriptorTypes = [@{} mutableCopy];
    });
    return _cellClassesForRowDescriptorTypes;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.form.formSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section >= self.form.formSections.count){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil];
    }
    return [[[self.form.formSections objectAtIndex:section] formRows] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.datasource respondsToSelector:@selector(coordinator:cellForRowAtIndexPath:)]) {
        return [self.datasource coordinator:self cellForRowAtIndexPath:indexPath];
    }
    NSAssert(YES, @"BEFormViewCoordinator must not return nil");
    return nil;
}

#pragma mark - UITableViewDelegate

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.form.formSections objectAtIndex:section] headerTitle];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [[self.form.formSections objectAtIndex:section] footerTitle];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    CGFloat height = rowDescriptor.height;
    if (height != BEFormUnspecifiedCellHeight){
        return height;
    }
    return self.tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BEFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    CGFloat height = rowDescriptor.height;
    if (height != BEFormUnspecifiedCellHeight){
        return height;
    }
    if (@available(iOS 8.0, *)) {
        return self.tableView.estimatedRowHeight;
    }
    return self.tableView.rowHeight;
}

#pragma mark - getter && setter

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    if (!tableView) {
        _tableView = self.internalTableView;
    }
}

- (UITableView *)internalTableView {
    if (!_internalTableView) {
        _internalTableView = [[UITableView alloc] initWithFrame:CGRectZero style:self.tableViewStyle];
        _internalTableView.tableFooterView = [UIView new];
        _internalTableView.estimatedSectionHeaderHeight = 0;
        _internalTableView.estimatedSectionFooterHeight = 0;
//        if (@available(iOS 8.0, *)){
//            self.tableView.rowHeight = UITableViewAutomaticDimension;
//            self.tableView.estimatedRowHeight = 44.0;
//        }
        _internalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _internalTableView.showsVerticalScrollIndicator = NO;
        _internalTableView.delegate = self;
        _internalTableView.dataSource = self;
    }
    return _internalTableView;
}

@end
