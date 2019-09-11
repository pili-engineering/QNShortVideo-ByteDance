//  Copyright © 2019 ailab. All rights reserved.

#import <Foundation/Foundation.h>
#import "BEFaceDistanceViewController.h"
#import <Masonry/Masonry.h>
#import "BEMacro.h"

@interface BEFaceDistanceViewController ()

@property(nonatomic, strong) NSMutableArray* labelArray;

@end

@implementation BEFaceDistanceViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    [self addLabels];
    
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

//添加label数组
- (void) addLabels{
    int maxCount = BEF_MAX_FACE_NUM;
    
    for (int i = 0; i < maxCount; i ++){
        UILabel *label = [[UILabel alloc] init];
        
        label.backgroundColor = [UIColor clearColor];
        label.hidden = NO;
        label.font = [UIFont systemFontOfSize:15];
        label.userInteractionEnabled = NO;
        
        [self.view addSubview:label];
        [self.labelArray addObject:label];
    }
}

- (void)updateFaceDistance:(bef_ai_face_info)faceInfo distance:(bef_ai_human_distance_result)distance widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio{
    int faceCount = faceInfo.face_count;

    //显示有效face的距离
    for (int i = 0; i < faceCount; i++){
        UILabel *label = self.labelArray[i];
        
        label.hidden = NO;
        label.text = [NSString stringWithFormat:@"%@:%.2f", @"距离(m)", distance.distances[i]];
        
        CGSize maxRowSize = [label.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;

        bef_ai_rect rect = faceInfo.base_infos[i].rect;
        int top = rect.top  * heightRatio;
        
        float left = (float)rect.left / VIDEO_INPUT_WIDTH * 2 - 1.0;
        float ratio = VIDEO_INPUT_HEIGHT / SCREEN_HEIGHT * SCREEN_WIDTH / VIDEO_INPUT_WIDTH;
        left = left / ratio * (VIDEO_INPUT_WIDTH / 2)+ (VIDEO_INPUT_WIDTH / 2);
        
        left = left * widthRatio;
        int bottom = rect.bottom * heightRatio;
        int viewTop = top > maxRowSize.height ? top - maxRowSize.height : bottom;
        
        label.frame = CGRectMake(left, viewTop, maxRowSize.width, maxRowSize.height);
    }
    
    //对剩下的label，进行隐藏
    for (int i = faceCount; i < BEF_MAX_FACE_NUM; i ++){
        UILabel *label = self.labelArray[i];
        label.hidden = YES;
    }
}

-(NSMutableArray *) labelArray{
    if (!_labelArray){
        _labelArray = [[NSMutableArray alloc] init];
    }
    return _labelArray;
}
@end
