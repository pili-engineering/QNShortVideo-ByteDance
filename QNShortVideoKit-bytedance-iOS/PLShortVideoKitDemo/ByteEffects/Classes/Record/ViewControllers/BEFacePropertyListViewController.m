//  Copyright © 2019 ailab. All rights reserved.

#import <Foundation/Foundation.h>
#import "BEFacePropertyListViewController.h"
#import "BEForm.h"
#import "BEPropertyListCell.h"
#import "BEPropertyListSectionFormViewCoordinator.h"
#import <Masonry/Masonry.h>
#import "BEModernFaceBeautyPickerCell.h"

@interface BEFacePropertyListViewController ()<BEFormViewCoordinatorDatasource>

@property (nonatomic, strong) BEPropertyListSectionFormViewCoordinator *formCoordinator;

@property (nonatomic, weak) BEFormRowDescriptor *totalDetectRow;
@property (nonatomic, weak) BEFormRowDescriptor *totalFaceCountRow;

@property (nonatomic, weak) BEFormRowDescriptor *yawRow;
@property (nonatomic, weak) BEFormRowDescriptor *pitchRow;
@property (nonatomic, weak) BEFormRowDescriptor *rollRow;

@property (nonatomic, weak) BEFormRowDescriptor *faccActionRow;

@property (nonatomic, weak) BEFormRowDescriptor *ageRow;
@property (nonatomic, weak) BEFormRowDescriptor *sexRow;
@property (nonatomic, weak) BEFormRowDescriptor *colorRow;
@property (nonatomic, weak) BEFormRowDescriptor *beatyRow;
@property (nonatomic, weak) BEFormRowDescriptor *happinessRow;
@property (nonatomic, weak) BEFormRowDescriptor *expressionRow;


@property (nonatomic, assign) bef_ai_face_106 info;
@property (nonatomic, assign) bef_ai_face_attribute_info attributeInfo;

@property (nonatomic, assign) unsigned int lastDetectFaceCount;
@property (nonatomic, assign) unsigned int totalDetectCount;
@end

@implementation BEFacePropertyListViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self setupForm];
    [self setupUI];
    
    _lastDetectFaceCount = 0;
    _totalDetectCount = 0;
}

- (void) setupUI{
    [self.view addSubview:self.tableView];
    
    self.view.frame = CGRectMake(20, 100, 112, 11 * 20.0f);
    [self tableView].rowHeight =20.f;
    self.tableView.userInteractionEnabled = false;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.sectionHeaderHeight = 2.0f;
    self.tableView.sectionFooterHeight = 2.0f;

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view);
    }];
    
}
- (void)setupForm {
    //set up form
    BEFormDescriptor *form = [BEFormDescriptor formDescriptor];
    [form addFormSection:[self faceIDSection]];
    [form addFormSection:[self angleSection]];
    [form addFormSection:[self expressionSection]];
    [form addFormSection:[self faceExtendSection]];
    
    // register cell-row-mapping
    [BEFormViewCoordinator cellClassesForRowDescriptorTypes][BERowDescriptorTypeText] = [BEPropertyListCell class];
    [BEFormViewCoordinator cellClassesForRowDescriptorTypes][BERowDescriptorTypeCollection] = [BEModernFaceActionCell class];
    
    self.formCoordinator = [[BEPropertyListSectionFormViewCoordinator alloc] initWithForm:form style:UITableViewStyleGrouped];
    self.formCoordinator.datasource = self;
    
    [self.tableView reloadData];
}

- (BEFormSectionDescriptor *) faceIDSection{
    BEFormSectionDescriptor *section = [BEFormSectionDescriptor formSection];
    self.totalDetectRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"detect_count", nil)];
    
    self.totalFaceCountRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"current_face", nil)];
    
    NSArray *rowArr = @[self.totalDetectRow, self.totalFaceCountRow];
    [section addFormRows:rowArr];
    return section;
}

- (BEFormSectionDescriptor *) angleSection{
    BEFormSectionDescriptor *section = [BEFormSectionDescriptor formSection];
    self.yawRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"yaw", nil)];
    self.pitchRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"pitch", nil)];
    self.rollRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"roll", nil)];
    
    NSArray *rowArr = @[self.yawRow, self.pitchRow, self.rollRow];
    [section addFormRows:rowArr];
    return section;
}

- (BEFormSectionDescriptor *) expressionSection{
    BEFormSectionDescriptor *section = [BEFormSectionDescriptor formSection];
    
    self.faccActionRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeCollection rowType:BERowDescriptorTypeCollection title:@"面部动作"];
    self.faccActionRow.height = 50;
    
    NSArray *rowArr = @[self.faccActionRow];
    [section addFormRows:rowArr];
    return section;
}

- (BEFormSectionDescriptor *)faceExtendSection{
    BEFormSectionDescriptor *section = [BEFormSectionDescriptor formSection];
    
    self.ageRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"age", nil)];
    self.sexRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"gender", nil)];
    self.colorRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"race", nil)];
    
    self.beatyRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"beauty", nil)];
    self.happinessRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"happiness", nil)];
    self.expressionRow = [BEFormRowDescriptor rowDescriptorWithTag:BERowDescriptorTypeText rowType:BERowDescriptorTypeText title:NSLocalizedString(@"expression", nil)];
    
    NSArray *rowArr = @[self.ageRow, self.sexRow, self.colorRow, self.beatyRow, self.happinessRow, self.expressionRow];
    [section addFormRows:rowArr];
    return section;
}

/*
 * 更新详细的表情信息
 */

- (void) _updateFaceInfoTotal:(int)total current:(int)current yaw:(float)yaw pitch:(float)pitch roll:(float)roll expression:(int)expression{
    self.totalDetectRow.detailTitle = [NSString stringWithFormat:@"%d",total];
    
    //检测人脸个数
    self.totalFaceCountRow.detailTitle = [NSString stringWithFormat:@"%d",current];
    
    //更新角度
    self.yawRow.detailTitle = [NSString stringWithFormat:@"%.1f", yaw];
    self.pitchRow.detailTitle = [NSString stringWithFormat:@"%.1f",pitch];
    self.rollRow.detailTitle = [NSString stringWithFormat:@"%.1f", roll];
    
    [self.tableView reloadData];
    
    [self _updateFaceAction:expression];
}

/*
 * 更新面部动作
 */
- (void) _updateFaceAction:(int)action{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    BEModernFaceActionCell *actionCell = (BEModernFaceActionCell* )cell;

    for (int i = 0; i <= 5; i ++){
        if((1 << (i + 1)) & action)
            [actionCell setFaceActionSelected:i];
        else
            [actionCell setFaceActionUnSelected:i];
    }
}
- (void) updateFaceInfo:(bef_ai_face_106)info faceCount:(int)count{
    _info = info;
    
    if (count <= 0) {
        if (_lastDetectFaceCount == 0)
            return;
        else {
            [self _updateFaceInfoTotal:_totalDetectCount current:count yaw:0.0 pitch:0.0 roll:0.0 expression:0];
//            [self _updateFaceExtraInfoBlank];
        }
        _lastDetectFaceCount = count;
        return ;
    }
    
    if (count > 0 && _lastDetectFaceCount == 0){
        _lastDetectFaceCount = count;
        _totalDetectCount ++;
    }
    
    [self _updateFaceInfoTotal:_totalDetectCount current:count yaw:_info.yaw pitch:_info.pitch roll:_info.yaw expression:_info.action];
}

-(void)_updateFaceExtraInfoBlank{
    self.ageRow.title  = @"年龄";
    self.sexRow.title = @"性别";
    self.colorRow.title = @"肤色";
    self.beatyRow.title = @"颜值";
    self.happinessRow.title = @"开心值";
    self.expressionRow.title = @"表情";
    [self.tableView reloadData];
}

- (void)updateFaceExtraInfo:(bef_ai_face_attribute_info)info count:(int)count{
    _attributeInfo = info;
    
    if (count  <= 0) return ;
    
    [self.tableView reloadData];
    
    self.ageRow.detailTitle  = [NSString stringWithFormat:@"%.0f", _attributeInfo.age];
    NSString *sex = _attributeInfo.boy_prob > 0.5 ? NSLocalizedString(@"male", nil): NSLocalizedString(@"female", nil);
    self.sexRow.detailTitle = [NSString stringWithFormat:@"%@", sex];
    self.colorRow.detailTitle = [NSString stringWithFormat:@"%@", BEColorTypes()[_attributeInfo.racial_type]];
    self.beatyRow.detailTitle = [NSString stringWithFormat:@"%.0f", _attributeInfo.attractive];
    self.happinessRow.detailTitle = [NSString stringWithFormat:@"%.0f", _attributeInfo.happy_score];
    NSString *expression;
    
    if (_attributeInfo.exp_type < 0 || _attributeInfo.exp_type >= 7)
        expression = NSLocalizedString(@"poker_face", nil);
    else
        expression = BEExpressionTypes()[_attributeInfo.exp_type];
    
    self.expressionRow.detailTitle = [NSString stringWithFormat:@"%@", expression];
}
#pragma mark - BEFormViewCoordinatorDatasource

- (UITableViewCell *)coordinator:(BEFormViewCoordinator *)coordinator cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BEFormRowDescriptor *rowDescriptor = [self.formCoordinator.form formRowAtIndex:indexPath];
    UITableViewCell *c = [rowDescriptor cellForFormCoordinator:self.formCoordinator];
    
    if ([c isKindOfClass:[BEPropertyListCell class]]){
        BEPropertyListCell *cell = (BEPropertyListCell *)c;
        
        [cell configWithRowDescriptor:rowDescriptor];
        return cell;
    }
    return c;
}

#pragma mark - getter && setter

- (UITableView *)tableView {
    return self.formCoordinator.tableView;
}

static NSArray *BEColorTypes(){
    static NSArray *colorTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorTypes =@[
                      NSLocalizedString(@"white", nil),
                      NSLocalizedString(@"yellow", nil),
                      NSLocalizedString(@"brown", nil),
                      NSLocalizedString(@"black", nil),
                    ];
    });
    return colorTypes;
}

static NSArray *BEExpressionTypes(){
    static NSArray *expressionTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expressionTypes =@[
                           NSLocalizedString(@"anger", nil),
                           NSLocalizedString(@"nausea", nil),
                           NSLocalizedString(@"fear", nil),
                           NSLocalizedString(@"happy", nil),
                           NSLocalizedString(@"sad", nil),
                           NSLocalizedString(@"surprise", nil),
                           NSLocalizedString(@"poker_face", nil),];
    });
    return expressionTypes;
}
@end
