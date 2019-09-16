// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEEffectSectionFormViewCoordinator.h"

@implementation BEEffectSectionFormViewCoordinator

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *footerTitle = [[self.form.formSections objectAtIndex:section] footerTitle];
    UILabel *label = [UILabel new];
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = footerTitle;
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSString *footerTitle = [[self.form.formSections objectAtIndex:section] footerTitle];
    CGSize footerSize = [footerTitle boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    return fmax(footerSize.height, 30);
}

@end
