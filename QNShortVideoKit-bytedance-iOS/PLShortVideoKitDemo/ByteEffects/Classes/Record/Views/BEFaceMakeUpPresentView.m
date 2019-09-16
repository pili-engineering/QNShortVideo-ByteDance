//  Copyright © 2019 ailab. All rights reserved.

#import <Foundation/Foundation.h>
#import "BEFaceMakeUpPresentView.h"
#import <Masonry.h>
#import "BEEffectBaseScrollView.h"
#import "BEEffectContentCollectionViewCell.h"
#import "BEModernBasePickerViewCell.h"
#import "BEStudioConstants.h"

@interface BEFaceMakeUpPresentView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) BEEffectBaseCollectionView *contentCollectionView;
@property (nonatomic, strong) BEEffectFaceMakeUpGroup* makeUpGroup;
@property (nonatomic, strong) UIButton *backButton;
@end

@implementation BEFaceMakeUpPresentView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self addSubview:self.title];
        [self addSubview:self.contentCollectionView];
        [self addSubview:self.backButton];
        
        [self.title mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(self).with.offset(20);
        }];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.mas_equalTo(self).with.offset(10);
            make.leading.mas_equalTo(self).with.offset(20);
        }];
        
        [self.contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.mas_equalTo(self.title.mas_bottom);
            make.left.right.mas_equalTo(self);
            make.bottom.mas_equalTo(self);
        }];
        
    }
    return self;
}

#pragma mark - public
-(void)refreshWithMakeUpGroup:(BEEffectFaceMakeUpGroup *)group{
    self.makeUpGroup = group;
    self.title.text = group.title;
    
    [self.contentCollectionView reloadData];
    
    if (self.makeUpGroup.selectedIndex != nil)
        [self.contentCollectionView selectItemAtIndexPath:self.makeUpGroup.selectedIndex animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    else
        [self.contentCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BEModernBasePickerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BEModernBasePickerViewCell be_identifier] forIndexPath:indexPath];
    int row = (int)indexPath.row;
    
    BEEffectFaceMakeUp *makeUp = self.makeUpGroup.faceMakeUps[row];
    [cell cellSetUnSelectedImagePath:makeUp.normalImageName selectedImagePath:makeUp.selectedImageName describeStr:makeUp.title additionStr:@""];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.makeUpGroup.faceMakeUps.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(85, 70);
}

- (void)onBackButtonClicked{
    if ([self.delegate respondsToSelector:@selector(backButtonClicked)]){
        [self.delegate backButtonClicked];
    }
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    int row = (int)indexPath.row;
    
    if (row < 0 || row >= self.makeUpGroup.faceMakeUps.count)
        return ;
    
    NSString *effectPath = _makeUpGroup.faceMakeUps[row].filePath;
    _makeUpGroup.selectedIndex = indexPath;
    NSString *makeType = [effectPath stringByDeletingLastPathComponent];

    if (row == 0){
        makeType = effectPath;
        effectPath = @"";
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceMakeupComposeSelectedNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: @[makeType, effectPath]}];
}

#pragma mark - getter
- (BEEffectBaseCollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 5);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _contentCollectionView = [[BEEffectBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _contentCollectionView.backgroundColor = [UIColor clearColor];
        [_contentCollectionView registerClass:[BEModernBasePickerViewCell class] forCellWithReuseIdentifier:[BEModernBasePickerViewCell be_identifier]];
        _contentCollectionView.showsHorizontalScrollIndicator = NO;
        _contentCollectionView.showsVerticalScrollIndicator = NO;
        _contentCollectionView.pagingEnabled = YES;
        _contentCollectionView.dataSource = self;
        _contentCollectionView.delegate = self;
    }
    return _contentCollectionView;
}

- (UILabel *)title{
    if (!_title){
        _title = [[UILabel alloc] init];
        _title.textColor = [UIColor whiteColor];
        _title.font = [UIFont systemFontOfSize:17];
        _title.textAlignment = NSTextAlignmentCenter;
    }
    return _title;
}
- (UIButton *)backButton{
    if (!_backButton){
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:NSLocalizedString(@"btn_back", nil) forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(onBackButtonClicked) forControlEvents:UIControlEventTouchDown];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _backButton;
}
@end
