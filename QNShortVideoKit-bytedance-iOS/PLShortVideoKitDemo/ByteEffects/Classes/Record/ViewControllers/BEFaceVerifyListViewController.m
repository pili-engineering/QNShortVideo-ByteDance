//  Copyright © 2019 ailab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BEFaceVerifyListViewController.h"
#import "BEForm.h"
#import <Masonry/Masonry.h>
#import "BEPropertyListCell.h"
#import "BEPropertyListSectionFormViewCoordinator.h"
#import "UIView+BEAdd.h"

@interface BEFaceVerifyListViewController ()<BEFormViewCoordinatorDatasource>

@property (nonatomic, strong) BEPropertyListSectionFormViewCoordinator *formCoordinator;
@property (nonatomic, weak) BEFormRowDescriptor *similarityRow;
@property (nonatomic, weak) BEFormRowDescriptor *singleFrameTimeRow;
@property (nonatomic, assign) double lastSimilarity;
@property (nonatomic, assign) long lastSingleFrameTime;
@end


@implementation BEFaceVerifyListViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    [self setupForm];
    [self setupUI];
    
    _lastSimilarity = 0.0;
    _lastSingleFrameTime = 0;
}

- (void)setupUI {
    [self.view addSubview:self.tableView];
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    int width = mainBounds.size.width;
    
    self.view.frame = CGRectMake(width - 120, 100, 100, 2 * 20.0f);
    [self tableView].rowHeight = 20.f;
    self.tableView.userInteractionEnabled = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupForm {
    
    // setup form
    BEFormDescriptor *form = [BEFormDescriptor formDescriptor];
    [form addFormSection:[self faceVerifyDescriptionSection]];
    
    // register cell-row-mapping
    [BEFormViewCoordinator cellClassesForRowDescriptorTypes][BERowDescriptorTypeText] = [BEPropertyListCell class];
    
    // create formCoordinator
    self.formCoordinator = [[BEPropertyListSectionFormViewCoordinator alloc] initWithForm:form];
    self.formCoordinator.datasource = self;
    
    // display content
    [self.tableView reloadData];
}

- (BEFormSectionDescriptor *)faceVerifyDescriptionSection {
    BEFormSectionDescriptor *section = [BEFormSectionDescriptor formSection];
    self.similarityRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"similarity", nil)];
    self.singleFrameTimeRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"cost", nil)];
    NSArray *rowArr = @[self.similarityRow, self.singleFrameTimeRow];
    [section addFormRows:rowArr];
    return section;
}

- (void) updateFaceVerifyInfo:(double)similarity time:(long)time{
    if (_lastSimilarity != similarity  || _lastSingleFrameTime != time){
        self.similarityRow.detailTitle = [NSString stringWithFormat:@"%.2f", similarity];
        self.singleFrameTimeRow.detailTitle = [NSString stringWithFormat:@"%ldms", time];
        
        [self.formCoordinator.tableView reloadData];
    }
    _lastSingleFrameTime = time;
    _lastSimilarity = similarity;
}

#pragma mark - BEFormViewCoordinatorDatasource

- (UITableViewCell *)coordinator:(BEFormViewCoordinator *)coordinator cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BEFormRowDescriptor *rowDescriptor = [self.formCoordinator.form formRowAtIndex:indexPath];
    UITableViewCell *c = [rowDescriptor cellForFormCoordinator:self.formCoordinator];
    if (![c isKindOfClass:[BEPropertyListCell class]]) {
        return c;
    }
    BEPropertyListCell *cell = (BEPropertyListCell *)c;
    [cell configWithRowDescriptor:rowDescriptor];
    return cell;
}

#pragma mark - getter && setter

- (UITableView *)tableView {
    return self.formCoordinator.tableView;
}
@end
