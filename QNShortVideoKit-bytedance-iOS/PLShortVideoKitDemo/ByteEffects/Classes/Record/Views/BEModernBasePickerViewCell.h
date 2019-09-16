//  Copyright © 2019 ailab. All rights reserved.
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BEModernBasePickerViewCell : UICollectionViewCell

- (void)setSelectedStatus:(bool)selected;
- (void) setCurrentCellUsed:(bool)used;

-(void) cellSetUnSelectedImagePath:(NSString*)unSelectedPath selectedImagePath:(NSString*)selectedPath describeStr:(NSString*)descStr additionStr:(NSString *)additionStr;
@end


NS_ASSUME_NONNULL_END
