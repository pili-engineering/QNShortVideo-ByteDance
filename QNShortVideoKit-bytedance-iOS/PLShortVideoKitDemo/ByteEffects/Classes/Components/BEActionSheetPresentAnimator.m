// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import "BEActionSheetPresentAnimator.h"
#import "Masonry.h"
#import "BEStudioConstants.h"

static const NSTimeInterval transitionDuration = 0.25;
static const NSUInteger kTapViewTag = 1024;

@interface BEActionSheetPresentAnimator()
@property (nonatomic, weak) UIViewController *viewController;
@end
@implementation BEActionSheetPresentAnimator

- (instancetype)initWithViewController: (UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    
    UIView *containerView = transitionContext.containerView;
    if (fromVC == _viewController && _viewController.presentingViewController == toVC) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            [containerView viewWithTag:kTapViewTag].alpha = 0;
            [fromVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(fromVC.preferredContentSize.height);
                make.top.equalTo(containerView.mas_bottom);
                make.leading.trailing.equalTo(fromVC.view.superview);
            }];
            [containerView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [fromVC.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    } else {
        UIControl *tapView = [[UIControl alloc] init];
        tapView.backgroundColor = [UIColor clearColor];
        tapView.tag = kTapViewTag;
        [containerView addSubview:tapView];
        [tapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(containerView);
        }];
        [tapView addTarget:self action:@selector(onBackgroundTappped) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:toView];
        [toView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(containerView);
            make.height.mas_equalTo(toVC.preferredContentSize.height);
            make.top.equalTo(containerView.mas_bottom);
        }];
        [containerView layoutIfNeeded];
        tapView.alpha = 0;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            tapView.alpha = 1.0;
            [toView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(containerView);
                make.height.mas_equalTo(toVC.preferredContentSize.height);
                make.bottom.equalTo(containerView.mas_bottom);
            }];
            [containerView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

-(void)onBackgroundTappped {
    [_viewController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectDidReturnToMainUINotification object:nil];
}

@end
