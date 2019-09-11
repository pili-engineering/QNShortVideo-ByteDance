// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernFaceDetectView.h"
#import "BEForm.h"
#import <Masonry/Masonry.h>
#import "BEBeautyPickerCommonDefines.h"
#import "BEEffectSectionFormViewCoordinator.h"
#import "BEEffectPickerDataStore.h"
#import "NSArray+BEAdd.h"
#import "BEModernBasePickerView.h"
#import "UICollectionViewCell+BEAdd.h"
#import <UIView+Toast.h>
#import "BEStudioConstants.h"
#import "BEModernBasePickerViewCell.h"
#import "BEMacro.h"

@interface BEModernFaceDetectView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BEModernFaceDetectView

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
- (void)setAllCellsUnSelected{
    for (int index = 0; index < BEFaceDetectTypes().count; index++){
        [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:false];
    }
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return BEFaceDetectTypes().count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    BEModernBasePickerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BEModernBasePickerViewCell be_identifier] forIndexPath:indexPath];
    int row = (int)indexPath.row;
    NSArray *array =BEFaceDetectTypes()[row];
    [cell cellSetUnSelectedImagePath:array[0] selectedImagePath:array[1] describeStr:array[2] additionStr:array[3]];
    
    //cell
    return cell;
}


#pragma mark - UICollectionViewDelegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(faceDetectChangedAtIndex:status:)]){
        [self.delegate faceDetectChangedAtIndex:indexPath status:true];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    int row = (int)indexPath.row;
    BEModernBasePickerViewCell* curCell = [collectionView dequeueReusableCellWithReuseIdentifier:[BEModernBasePickerViewCell be_identifier] forIndexPath:indexPath];

        //如果是106点，关闭所有的3个功能
    if(row == 0){
        for (BEModernBasePickerViewCell* cell in self.collectionView.visibleCells){
            [cell setSelectedStatus:NO];
        }
    }else { //设置对应的状态正常
        curCell.selected = false;
    }
    if ([self.delegate respondsToSelector:@selector(faceDetectChangedAtIndex:status:)]){
        [self.delegate faceDetectChangedAtIndex:indexPath status:false];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    int row = (int)indexPath.row;
    BEEffectPickerDataStore* dataStore = [BEEffectPickerDataStore sharedDataStore];
    
    if (row == 0) return true;
    else {
        if (dataStore.enableFaceDetect106)
            return true;
        else{
            [self makeToast:NSLocalizedString(@"open_face106_fist", nil)];
            return false;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}

#pragma mark - getter && setter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        int totalLen = ((int)BEFaceDetectTypes().count) * 100 + ((int)BEFaceDetectTypes().count - 1) *  5;
        int left = SCREEN_WIDTH  - totalLen;
        int padding = left > 10? left / 2: 5;
        
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, padding, 5, padding);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[BEModernBasePickerViewCell class] forCellWithReuseIdentifier:[BEModernBasePickerViewCell be_identifier]];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.allowsMultipleSelection = YES;
    }
    return _collectionView;
}

static NSArray *BEFaceDetectTypes(){
    static NSArray *faceDetectTypes;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        faceDetectTypes =@[
                      @[@"iconFace106Normal.png", @"iconFace106Selected.png", NSLocalizedString(@"setting_face", nil), NSLocalizedString(@"face_106_desc", nil),],
                      @[@"iconFace280Normal.png", @"iconFace280Selected.png", NSLocalizedString(@"setting_face_extra", nil), NSLocalizedString(@"face_280_desc", nil)],
                      @[@"iconFaceAttriNormal.png", @"iconFaceAttriSelected.png",NSLocalizedString(@"face_attr_title", nil), NSLocalizedString(@"face_attr_desc", nil)],
                      ];
    });
    return faceDetectTypes;
}
@end
