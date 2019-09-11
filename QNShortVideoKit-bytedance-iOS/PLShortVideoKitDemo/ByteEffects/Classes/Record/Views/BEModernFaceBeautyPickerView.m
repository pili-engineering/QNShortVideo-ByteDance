// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernFaceBeautyPickerView.h"
#import <Masonry/Masonry.h>
#import "BEModernFaceBeautyPickerCell.h"
#import "BEFaceBeautyModel.h"
#import "BEBeautyPickerCommonDefines.h"
#import "BEForm.h"
#import "BEModernBasePickerViewCell.h"
#import "UICollectionViewCell+BEAdd.h"
#import "BEEffectPickerDataStore.h"

@interface BEModernFaceBeautyPickerView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BEModernFaceBeautyPickerView

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
- (void)setClosedStatus{
     [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UICollectionViewScrollPositionNone];
    for (int index = 0; index < BEFaceBeautyTypes().count; index++){
        BEModernBasePickerViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell setCurrentCellUsed:false];
    }
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return BEFaceBeautyTypes().count;
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
    NSArray *array =BEFaceBeautyTypes()[row];
    
    [cell cellSetUnSelectedImagePath:array[0] selectedImagePath:array[1] describeStr:array[2] additionStr:array[3]];
    [cell setCurrentCellUsed:false];
    //cell
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self lastSelectedEffectCells][0] = [collectionView cellForItemAtIndexPath:indexPath];
    [self shardDataStore].lastSelectedEffectCell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(faceBeautyDidSelectedAtIndex:)]){
        [self.delegate faceBeautyDidSelectedAtIndex:indexPath];
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

static NSArray *BEFaceBeautyTypes(){
    static NSArray *BEFaceBeautyTypes;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        BEFaceBeautyTypes =@[
                             
                            @[@"iconCloseButtonNormal.png", @"iconCloseButtonSelected.png",
                                NSLocalizedString(@"close", nil), @""],
                            @[@"iconFaceBeautyLiftingNormal.png", @"iconFaceBeautyLiftingSelected.png",                 NSLocalizedString(@"setting_face_lift", nil), @"."],
                            @[@"iconFaceBeautyBigEyeNormal.png", @"iconFaceBeautyBigEyeSelected.png",                      NSLocalizedString(@"beauty_eye_reshape", nil), @"."],
                            @[@"iconFaceBeautySkinNormal.png", @"iconFaceBeautySkinSelected.png", NSLocalizedString(@"beauty_smooth", nil), @"."],
                            @[@"iconFaceBeautyWhiteningNormal.png", @"iconFaceBeautyWhiteningSelected.png", NSLocalizedString(@"beauty_whiten", nil), @"."],
                            @[@"iconFaceBeautySharpNormal.png", @"iconFaceBeautySharpSelected.png", NSLocalizedString(@"beauty_sharpen", nil), @"."],
                           ];
    });
    return BEFaceBeautyTypes;
}

-(NSMutableArray *) lastSelectedEffectCells{
    return  [BEEffectPickerDataStore sharedDataStore].lastSelectedEffectCells;
}

-(BEEffectPickerDataStore*) shardDataStore{
    return [BEEffectPickerDataStore sharedDataStore];
}
@end
