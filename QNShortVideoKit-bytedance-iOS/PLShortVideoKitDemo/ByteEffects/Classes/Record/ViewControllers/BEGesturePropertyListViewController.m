//  Copyright © 2019 ailab. All rights reserved.

#import "BEGesturePropertyListViewController.h"
#import "BEForm.h"
#import <Masonry/Masonry.h>
#import "BEPropertyListCell.h"
#import "BEPropertyListSectionFormViewCoordinator.h"
#import "UIView+BEAdd.h"
#import "BEMacro.h"

static NSString *const BEGesturePropertyTextGesture = @"手势";
typedef struct {
    CGFloat widthRatio;
    CGFloat heightRatio;
} BEGesturePropertyScale;

@interface BEGesturePropertyListViewController ()<BEFormViewCoordinatorDatasource>

@property (nonatomic, assign) bef_ai_hand info;
@property (nonatomic, assign) BEGesturePropertyScale scale;
@property (nonatomic, strong) BEPropertyListSectionFormViewCoordinator *formCoordinator;
@property (nonatomic, weak) BEFormRowDescriptor *gestureRow;
@property (nonatomic, weak) BEFormRowDescriptor *punchRow;
@property (nonatomic, weak) BEFormRowDescriptor *clapRow;

@end

@implementation BEGesturePropertyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupForm];
    [self setupUI];
}

- (void)setupUI {
    [self.view addSubview:self.tableView];
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
    [form addFormSection:[self gesDescriptionSection]];
    [form addFormSection:[self gesRecognitionSection]];
    
    // register cell-row-mapping
    [BEFormViewCoordinator cellClassesForRowDescriptorTypes][BERowDescriptorTypeText] = [BEPropertyListCell class];
    
    // create formCoordinator
    self.formCoordinator = [[BEPropertyListSectionFormViewCoordinator alloc] initWithForm:form];
    self.formCoordinator.datasource = self;
    
    // display content
    [self.tableView reloadData];
}

- (BEFormSectionDescriptor *)gesDescriptionSection {
    BEFormSectionDescriptor *section = [BEFormSectionDescriptor formSection];
    self.gestureRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:BEGesturePropertyTextGesture];
    [section addFormRow:self.gestureRow];
    return section;
}

- (BEFormSectionDescriptor *)gesRecognitionSection {
    BEFormSectionDescriptor *section = [BEFormSectionDescriptor formSection];
    self.punchRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:@"击拳"];
    self.clapRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:@"鼓掌"];
    NSArray *rowArr = @[self.punchRow, self.clapRow];
    [section addFormRows:rowArr];
    return section;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    bef_ai_hand info = _info;
    CGSize maxRowSize = [self.gestureRow.title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, self.tableView.rowHeight) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size;
    
    int top = info.rect.top * _scale.heightRatio;
    float left = (float)info.rect.left / VIDEO_INPUT_WIDTH * 2 - 1.0;
    float ratio = VIDEO_INPUT_HEIGHT / SCREEN_HEIGHT * SCREEN_WIDTH / VIDEO_INPUT_WIDTH;
    left = left / ratio * (VIDEO_INPUT_WIDTH / 2)+ (VIDEO_INPUT_WIDTH / 2);
    left = left * _scale.widthRatio;

    int bottom = info.rect.bottom * _scale.heightRatio;
    CGFloat height = self.tableView.contentSize.height;
    CGFloat viewTop = top > height ? top - height : bottom;
    self.view.frame = CGRectMake(left, viewTop, maxRowSize.width + 1, height);
}

- (void)updateHandInfo:(bef_ai_hand)info widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio {
    // store value
    _info = info;
    
    BEGesturePropertyScale scale;
    scale.widthRatio = widthRatio;
    scale.heightRatio = heightRatio;
    _scale = scale;
    
    // logic & display
    NSString *gestureStr = @"unknown";
    if (info.action != 99 && info.action < BEHandTypes().count) {
        gestureStr = BEHandTypes()[info.action];
    }
    
    [self.tableView reloadData];
    [self.formCoordinator.form.formSections.lastObject.formRows enumerateObjectsUsingBlock:^(BEFormRowDescriptor * _Nonnull row, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == info.seq_action-1) {
            //NSLog(@"seq_action is %d", info.seq_action);
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:self.formCoordinator.form.formSections.count-1];
            UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
            selectedCell.selected = YES;
        }
    }];
    
    self.gestureRow.title = [BEGesturePropertyTextGesture stringByAppendingString:gestureStr];
    [self.formCoordinator reloadFormRow:self.gestureRow];
    
    // relayout
    [self.view setNeedsLayout];
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

static NSArray *BEHandTypes() {
    static NSArray *handTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handTypes =
        @[
          @"heart_a",
          @"heart_b",
          @"heart_c",
          @"heart_d",
          @"ok",
          @"hand_open",
          @"thumb_up",
          @"thumb_down",
          @"rock",
          @"namaste",
          @"palm_up",
          @"fist",
          @"index_finger_up",
          @"double_finger_up",
          @"victory",
          @"big_v",
          @"phonecall",
          @"beg",
          @"thanks",
          @"unknown",
          @"cabbage",
          @"three",
          @"four",
          @"pistol",
          @"rock2",
          @"swear",
          @"holdface",
          @"salute",
          @"spread",
          @"pray",
          @"qigong",
          @"slide",
          @"palm_down",
          @"pistol2",
          @"naturo1",
          @"naturo2",
          @"naturo3",
          @"naturo4",
          @"naturo5",
          @"naturo7",
          @"naturo8",
          @"naturo9",
          @"naturo10",
          @"naturo11",
          @"naturo12",
          ];
    });
    return handTypes;
};

@end
