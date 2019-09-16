// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEPropertyListSectionFormViewCoordinator.h"

@implementation BEPropertyListSectionFormViewCoordinator

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *view = [UIView new];
//    view.backgroundColor = [UIColor blueColor];
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.form.formSections.count-1 == section ? 0.f : 1.f;
}

@end
