// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEFaceMakeupPickerView.h"
#import <Masonry/Masonry.h>
#import "BEModernFaceBeautyPickerCell.h"
#import "BEFaceBeautyModel.h"
#import "BEBeautyPickerCommonDefines.h"
#import "BEForm.h"
#import "BEModernBasePickerViewCell.h"
#import "UICollectionViewCell+BEAdd.h"
#import "BEEffectPickerDataStore.h"
#import "BEActionSheetPresentViewController.h"

@interface BEFaceMakeupPickerView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BEFaceMakeupPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - public
- (void) setAllCellsUnSelected{
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//    for (int index = 0; index < BEFaceMakeUpTypes().count; index++){
//        BEModernBasePickerViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//
//        [cell setSelectedStatus:false];
//    }
}

#pragma mark - BEFormViewCoordinatorDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return BEFaceMakeUpTypes().count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 100);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    BEModernBasePickerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BEModernBasePickerViewCell be_identifier] forIndexPath:indexPath];
    int row = (int)indexPath.row;
    NSArray *array =BEFaceMakeUpTypes()[row];
    
    [cell cellSetUnSelectedImagePath:array[0] selectedImagePath:array[1] describeStr:array[2] additionStr:array[3]];
    [cell setCurrentCellUsed:false];
    
    //cell
    return cell;
}
#pragma mark - UICollectionViewDelegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(faceMakeUpDidSelectedAtIndex:)]){
        [self.delegate faceMakeUpDidSelectedAtIndex:indexPath];
    }
}

#pragma mark - getter && setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 5);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[BEModernBasePickerViewCell class] forCellWithReuseIdentifier:[BEModernBasePickerViewCell be_identifier]];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.allowsMultipleSelection = NO;
    }
    return _collectionView;
}

static NSArray *BEFaceMakeUpTypes(){
    static NSArray *BEFaceMakeUpTypes;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        BEFaceMakeUpTypes =@[
                             @[@"iconCloseButtonNormal.png", @"iconCloseButtonSelected.png",          NSLocalizedString(@"close", nil), @""],
                             @[@"iconFaceMakeUpBlusherNormal.png", @"iconFaceMakeUpBlusherSelected.png", NSLocalizedString(@"makeup_blusher", nil), @"."],
                             @[@"iconFaceMakeUpLipsNormal.png", @"iconFaceMakeUpLipsSelected.png", NSLocalizedString(@"makeup_lip", nil), @"."],
                             @[@"iconFaceMakeUpEyelashNormal.png", @"iconFaceMakeUpEyelashSelected.png", NSLocalizedString(@"makeup_eyelash", nil), @"."],
                             @[@"iconFaceMakeUpPupilNormal.png", @"iconFaceMakeUpPupilSelected.png", NSLocalizedString(@"makeup_pupil", nil), @"."],
                             @[@"iconHairNormal.png", @"iconHairSelected.png", NSLocalizedString(@"makeup_hair", nil), @"."],
                             @[@"iconFaceMakeUpEyeshadowNormal.png", @"iconFaceMakeUpEyeshadowSelected.png", NSLocalizedString(@"makeup_eye", nil), @"."],
                             @[@"iconFaceMakeUpEyebrowNormal.png", @"iconFaceMakeUpEyebrowSelected.png",  NSLocalizedString(@"makeup_eyebrow", nil), @"."],
                             ];
    });
    return BEFaceMakeUpTypes;
}

-(NSMutableArray *) lastSelectedEffectCells{
    return  [BEEffectPickerDataStore sharedDataStore].lastSelectedEffectCells;
}

-(BEEffectPickerDataStore*) shardDataStore{
    return [BEEffectPickerDataStore sharedDataStore];
}
@end

