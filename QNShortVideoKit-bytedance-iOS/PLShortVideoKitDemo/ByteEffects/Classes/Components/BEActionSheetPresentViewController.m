// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import "BEActionSheetPresentViewController.h"
#import "BEActionSheetPresentAnimator.h"

@interface BEActionSheetPresentViewController ()<UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) BEActionSheetPresentAnimator *animator;
@end

@implementation BEActionSheetPresentViewController

- (BEActionSheetPresentAnimator *)animator {
    if (!_animator) {
        _animator = [[BEActionSheetPresentAnimator alloc] initWithViewController:self];
    }
    return _animator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationCustom;
}

- (id<UIViewControllerTransitioningDelegate>)transitioningDelegate {
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.animator;
}
@end


@interface AnyActionSheetPresentViewController: BEActionSheetPresentViewController
- (instancetype)initWithView: (UIView *)view size:(CGSize)size;
@end
@implementation AnyActionSheetPresentViewController

- (instancetype)initWithView:(UIView *)view size:(CGSize)size {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.view = view;
        self.preferredContentSize = size;
    }
    return self;
}

@end

@implementation UIView (ActionSheetPresent)
- (void)actionSheetToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    AnyActionSheetPresentViewController *actionSheetViewController = [[AnyActionSheetPresentViewController alloc] initWithView:self size:self.bounds.size];
    [viewController presentViewController:actionSheetViewController animated:animated completion:completion];
}

@end

