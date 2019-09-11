// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>
#import "BEFormDescriptor.h"

@class BEFormViewCoordinator;

@protocol BEFormViewCoordinatorDatasource <NSObject>

@optional
- (UITableViewCell *)coordinator:(BEFormViewCoordinator *)coordinator cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface BEFormViewCoordinator : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<BEFormViewCoordinatorDatasource> datasource;

@property (nonatomic, readonly) BEFormDescriptor *form;
@property (nonatomic, strong) UITableView *tableView;

-(instancetype)initWithForm:(BEFormDescriptor *)form;
-(instancetype)initWithForm:(BEFormDescriptor *)form style:(UITableViewStyle)style;
- (void)updateForm:(BEFormDescriptor *)form;
-(void)reloadFormRow:(BEFormRowDescriptor *)formRow;

+(NSMutableDictionary *)cellClassesForRowDescriptorTypes;

@end

