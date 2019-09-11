// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernEffectPickerView.h"
#import "BEEffectContentCollectionViewCell.h"
#import "BEEffectDataManager.h"
#import "BEEffectSwitchTabView.h"
#import <Masonry/Masonry.h>
#import "UIResponder+BEAdd.h"
#import "BEEffectBaseScrollView.h"
#import "BECircleBubbleView.h"
#import "BESlider.h"
#import "BEModernEffectPickerControlFactory.h"
#import "BEStudioConstants.h"
#import "BEEffectPickerDataStore.h"
#import "BEModernBasePickerViewCell.h"
#import "BEFaceMakeUpPresentViewController.h"

@interface BEModernEffectPickerView ()<UICollectionViewDelegate, UICollectionViewDataSource, BEEffectSwitchTabViewDelegate, BEFaceMakeUpPresentViewControllerDelegate>

@property (nonatomic, strong) BEEffectBaseCollectionView *contentCollectionView;
@property (nonatomic, strong) BEEffectSwitchTabView *switchTabView;
@property (nonatomic, strong) BEEffectDataManager *filterDataManager;
@property (nonatomic, copy) NSArray <BEEffectCategoryModel *> *categories;
@property (nonatomic, strong) NSMutableSet *registeredCellClass;
@property (nonatomic, strong) BECircleBubbleView *bubbleView;

@property (nonatomic, strong) BEFaceMakeUpPresentViewController *makeUpPresentVC;

@end

@implementation BEModernEffectPickerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        
        [self addSubview:self.switchTabView];
        [self addSubview:self.contentCollectionView];
        [self addSubview:self.bubbleView];
        
        [self addSubview:self.intensitySlider];
        
        [self.intensitySlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(self);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(220);
        }];
        [self.switchTabView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.intensitySlider.mas_bottom);
            make.leading.equalTo(self).offset(0);
            make.trailing.equalTo(self).offset(0);
            make.height.mas_equalTo(40);
        }];
        [self.contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self);
            make.top.equalTo(self.switchTabView.mas_bottom);
        }];
    }
    [self loadData];
    [self addObserver];
    return self;
}

- (void)loadData {
    self.categories = [BEEffectDataManager effectCategoryModelArray];
    [self.switchTabView refreshWithStickerCategories:self.categories];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.switchTabView selectItemAtIndex:0 animated:NO];
    });
    
    // 注册新的contentCellClass
    for (BEEffectCategoryModel *model in self.categories) {
        Class cellClass = [BEEffectContentCollectionViewCellFactory contentCollectionViewCellWithPanelTabType:model.type];
        NSString *classStr = NSStringFromClass(cellClass);
        if (![self.registeredCellClass containsObject:classStr]) {
            [self.contentCollectionView registerClass:[cellClass class] forCellWithReuseIdentifier:[cellClass be_identifier]];
            [self.registeredCellClass addObject:classStr];
        }
    }
    
    // 更新每一个tab最后的美颜类型
    for (int i = 0; i < self.categories.count; i++){
        [[self lastSelectedEffectTypes] addObject:@(BEEffectClearStatus)];
        [[self lastSelectedEffectCells] addObject:[NSNull null]];
    }
}

- (void)displayContentController:(UIViewController *)viewController {
    UIViewController *parent = [self be_topViewController];
    [parent addChildViewController:viewController];
    [self addSubview:viewController.view];
    [viewController didMoveToParentViewController:parent];
    [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.mas_equalTo(self).with.offset(40);
    }];
}

- (void)hideContentController:(UIViewController*)content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

#pragma mark - Notification

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSliderBeginTracking:)
                                                 name:BESliderBeginTrackingTouchNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSliderContinueTracking:)
                                                 name:BESliderContinueTrackingTouchNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSliderEndTracking:)
                                                 name:BESliderEndTrackingTouchNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFaceMakeUpComposedChanged:)
                                                 name:BEEffectFaceMakeupComposeNotification
                                               object:nil];
}

- (void) onFaceMakeUpComposedChanged:(NSNotification *)aNote{
    BEEffectFaceMakeUpType makeUpType = [aNote.userInfo[BEEffectNotificationUserInfoKey] integerValue];

//    self.intensitySlider.hidden = YES;
    self.switchTabView.hidden = YES;
    self.contentCollectionView.hidden = YES;
    
    self.makeUpPresentVC.makeUpType = makeUpType - 1;
    [self displayContentController:self.makeUpPresentVC];
}
- (void)onSliderBeginTracking:(NSNotification *)aNote {
    self.bubbleView.hidden = YES;
}

- (void)onSliderContinueTracking:(NSNotification *)aNote {
    UISlider *slider = aNote.userInfo[@"sender"];
    if (self.bubbleView.hidden == YES)
        self.bubbleView.hidden = NO;
    [self _updateBubbleViewPositioWithSlider:slider];
}

- (void)onSliderEndTracking:(NSNotification *)aNote {
    self.bubbleView.hidden = YES;
}

#pragma mark - BEFaceMakeUpPresentViewController.h
- (void) onFaceMakeUpPresentViewExist{
    [self hideContentController:self.makeUpPresentVC];
    
//    self.intensitySlider.hidden = NO;
    self.switchTabView.hidden = NO;
    self.contentCollectionView.hidden = NO;
}

#pragma mark - Private

- (void)_updateBubbleViewPositioWithSlider:(UISlider *)slider {
    CGFloat delta = slider.currentThumbImage.size.width/2;
    CGRect sliderRect = [slider convertRect:slider.bounds toView:self];
    CGFloat minX = CGRectGetMinX(sliderRect) + delta;
    CGFloat maxX = CGRectGetMaxX(sliderRect) - delta;
    CGFloat range = slider.maximumValue-slider.minimumValue;
    CGFloat currentX = minX + slider.value / range * (CGRectGetWidth(sliderRect) - 2*delta);
    if (currentX < minX) {
        currentX = minX;
    } else if (currentX > maxX) {
        currentX = maxX;
    }
    self.bubbleView.center = CGPointMake(currentX, CGRectGetMinY(sliderRect) - CGRectGetHeight(sliderRect)/4);
    self.bubbleView.text = [NSString stringWithFormat:@"%.0f", slider.value * 100];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BEEffectCategoryModel *model = self.categories[indexPath.row];
    Class cellClass = [BEEffectContentCollectionViewCellFactory contentCollectionViewCellWithPanelTabType:model.type];
    BEEffectContentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[cellClass be_identifier] forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.contentCollectionView.bounds.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger wouldSelectIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (self.switchTabView.selectedIndex != wouldSelectIndex) {
        [self.switchTabView selectItemAtIndex:wouldSelectIndex animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSInteger wouldSelectIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        if (self.switchTabView.selectedIndex != wouldSelectIndex) {
            [self.switchTabView selectItemAtIndex:wouldSelectIndex animated:YES];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.switchTabView.shouldIgnoreAnimation = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.switchTabView.shouldIgnoreAnimation) {
        return;
    }
    CGFloat offsetX = self.contentCollectionView.contentOffset.x;
    CGFloat proportion = offsetX / self.contentCollectionView.frame.size.width;
    self.switchTabView.proportion = proportion;
}

#pragma mark - BEEffectSwitchTabViewDelegate
- (void)switchTabDidSelectedAtIndex:(NSInteger)index {
    if (index < 0 || index >= [self.contentCollectionView numberOfItemsInSection:0]) {
        return;
    }
    
    //现在在美妆状态关闭，隐藏slider
    if(index == 1){
        self.intensitySlider.hidden = YES;
    }else
        self.intensitySlider.hidden = NO;
    
    [self.contentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    BEEffectFaceBeautyType type = [[self lastSelectedEffectTypes][index] integerValue];
    
    //切换tab
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceBeautyTypeDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: @(type)}];
    
    self.intensitySlider.value = [[self beautyModel] getValueWithType:type];
    [self sharedDataStore].lastSelectedEffectCell = [self lastSelectedEffectCells][index];
}

#pragma mark - event
- (void)onSliderValueChanged:(UISlider*) sender{
    float value = sender.value;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceBeautyDataDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: @(value)}];
    
    UICollectionViewCell *cell = [self sharedDataStore].lastSelectedEffectCell;
    if ([cell isKindOfClass:[BEModernBasePickerViewCell class]]){
        
        BEModernBasePickerViewCell* basePickercell = [self sharedDataStore].lastSelectedEffectCell;
        if (value > 0){
            [basePickercell setCurrentCellUsed:true];
        }else {
            [basePickercell setCurrentCellUsed:false];
        }
    }
}

#pragma mark - getter && setter

- (BEEffectBaseCollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 5);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _contentCollectionView = [[BEEffectBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _contentCollectionView.backgroundColor = [UIColor clearColor];
        [_contentCollectionView registerClass:[BEEffectContentCollectionViewCell class] forCellWithReuseIdentifier:[BEEffectContentCollectionViewCell be_identifier]];
        _contentCollectionView.showsHorizontalScrollIndicator = NO;
        _contentCollectionView.showsVerticalScrollIndicator = NO;
        _contentCollectionView.pagingEnabled = YES;
        _contentCollectionView.dataSource = self;
        _contentCollectionView.delegate = self;
        
        _contentCollectionView.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6].CGColor;
    }
    return _contentCollectionView;
}

- (BEEffectSwitchTabView *)switchTabView {
    if (!_switchTabView) {
        _switchTabView = [[BEEffectSwitchTabView alloc] initWithStickerCategories:[BEEffectDataManager effectCategoryModelArray]];
        _switchTabView.delegate = self;
        _switchTabView.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6].CGColor;
    }
    return _switchTabView;
}

- (BEEffectDataManager *)filterDataManager {
    if (!_filterDataManager) {
        _filterDataManager = [BEEffectDataManager dataManagerWithType:BEEffectDataManagerTypeFilter];
    }
    return _filterDataManager;
}


- (NSMutableSet *)registeredCellClass {
    if (!_registeredCellClass) {
        _registeredCellClass = [NSMutableSet set];
    }
    return _registeredCellClass;
}

- (BECircleBubbleView *)bubbleView {
    if (!_bubbleView) {
        _bubbleView = [[BECircleBubbleView alloc] init];
        _bubbleView.frame = CGRectMake(0, 0, 30, 30);
        _bubbleView.hidden = YES;

    }
    return _bubbleView;
}

- (BESlider*) intensitySlider{
    if (!_intensitySlider){
        _intensitySlider = [BEModernEffectPickerControlFactory createSlider];
        [_intensitySlider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _intensitySlider;
}


- (BEFaceMakeUpPresentViewController*)makeUpPresentVC{
    if (!_makeUpPresentVC){
        _makeUpPresentVC = [BEFaceMakeUpPresentViewController new];
        _makeUpPresentVC.delegate = self;
    }
    return _makeUpPresentVC;
}
/*
 * 保存着每一个tab下最后被选择的美颜种类
 */
-(NSMutableArray *) lastSelectedEffectTypes{
    return [BEEffectPickerDataStore sharedDataStore].lastSelectedEffectTypes;
}

- (BEFaceBeautyModel *)beautyModel {
    return [BEEffectPickerDataStore sharedDataStore].beautyModel;
}

-(NSMutableArray *) lastSelectedEffectCells{
    return [BEEffectPickerDataStore sharedDataStore].lastSelectedEffectCells;
}

-(BEEffectPickerDataStore* )sharedDataStore{
    return [BEEffectPickerDataStore sharedDataStore];
}

@end
