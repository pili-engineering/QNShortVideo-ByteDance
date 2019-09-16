// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernRecognizePickerView.h"
#import "BEEffectContentCollectionViewCell.h"
#import "BEEffectDataManager.h"
#import "BEEffectSwitchTabView.h"
#import <Masonry/Masonry.h>
#import "UIResponder+BEAdd.h"
#import "BEEffectBaseScrollView.h"
#import "BECircleBubbleView.h"
#import "BESlider.h"

@interface BEModernRecognizePickerView ()<UICollectionViewDelegate, UICollectionViewDataSource, BEEffectSwitchTabViewDelegate>

@property (nonatomic, strong) BEEffectBaseCollectionView *contentCollectionView;
@property (nonatomic, strong) BEEffectSwitchTabView *switchTabView;
@property (nonatomic, strong) BEEffectDataManager *filterDataManager;
@property (nonatomic, copy) NSArray <BEEffectCategoryModel *> *categories;
@property (nonatomic, strong) NSMutableSet *registeredCellClass;
@property (nonatomic, strong) BECircleBubbleView *bubbleView;
@property (nonatomic, strong) NSMutableArray* clearStatus;

@end

@implementation BEModernRecognizePickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.switchTabView];
        [self addSubview:self.contentCollectionView];
        [self addSubview:self.bubbleView];

        [self.switchTabView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.mas_equalTo(0);
            make.trailing.equalTo(self).offset(0);
            make.height.mas_equalTo(40);
        }];
        [self.contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self);
            make.top.equalTo(self.switchTabView.mas_bottom);
        }];

        self.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6].CGColor;
    }
    [self loadData];
    
    return self;
}

- (void)loadData {
    self.categories = [BEEffectDataManager recognizeCategoryModelArray];
    
    for (int i = 0; i < self.categories.count; i ++)
        [self.clearStatus addObject:[NSNumber numberWithBool:false]];
    
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
}

#pragma mark - Public
- (void)setAllTabsUnSelected{
    //contentCollectionView reload data, 重新加载一遍
    [self reloadData];
}

//重新加载view collection view中的数据，这样的话
- (void) reloadData{
    for (int i = 0; i < self.categories.count; i ++)
        self.clearStatus[i] = [NSNumber numberWithBool:true];
    
    [self.contentCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BEEffectCategoryModel *model = self.categories[indexPath.row];
    Class cellClass = [BEEffectContentCollectionViewCellFactory contentCollectionViewCellWithPanelTabType:model.type];
    BEEffectContentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[cellClass be_identifier] forIndexPath:indexPath];
    
    if ([self.clearStatus[indexPath.row] boolValue] != false){
        [cell setCellUnSelected];
        self.clearStatus[indexPath.row] = [NSNumber numberWithBool:false];
    }
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
    [self.contentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
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
    }
    return _contentCollectionView;
}

- (BEEffectSwitchTabView *)switchTabView {
    if (!_switchTabView) {
        _switchTabView = [[BEEffectSwitchTabView alloc] initWithStickerCategories:[BEEffectDataManager recognizeCategoryModelArray]];
        _switchTabView.delegate = self;
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

- (NSMutableArray*)clearStatus{
    if (!_clearStatus){
        _clearStatus = [NSMutableArray new];
    }
    return _clearStatus;
}

@end
