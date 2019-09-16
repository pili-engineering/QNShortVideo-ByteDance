// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>
#import "BEForm.h"
@class BEFormViewCoordinator;

static CGFloat BEFormUnspecifiedCellHeight = -3.0;
typedef void(^BEOnChangeBlock)(id oldValue,id newValue, BEFormRowDescriptor* rowDescriptor);

@interface BEFormRowDescriptor : NSObject

@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *rowType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailTitle;
@property (nonatomic) id value;
@property (nonatomic) BOOL enabled;
@property (nonatomic, assign) Class cellClass;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, weak) BEFormSectionDescriptor *sectionDescriptor;
@property (nonatomic, strong) BEOnChangeBlock onChangeBlock;

+ (instancetype)rowDescriptorWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title;
+ (instancetype)rowDescriptorWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title detailTitle:(NSString*) detailString;

- (instancetype)initWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title;

- (UITableViewCell *)cellForFormCoordinator:(BEFormViewCoordinator *)formCoordinator;

@end
