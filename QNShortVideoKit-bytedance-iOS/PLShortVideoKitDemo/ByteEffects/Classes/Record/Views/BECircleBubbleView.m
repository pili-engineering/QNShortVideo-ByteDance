// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BECircleBubbleView.h"
#import "BEAnimationUtils.h"
#import "BEMacro.h"

@interface BECircleBubbleView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation BECircleBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self.layer addSublayer:self.shapeLayer];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (!CGRectEqualToRect(self.shapeLayer.frame, self.bounds)) {
        self.shapeLayer.path = [self bubblePath].CGPath;
        [self layoutIfNeeded];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint circleCenter = BEBubbleViewCircleCenter(self.bounds);
    [self.textLabel sizeToFit];
    self.textLabel.center = circleCenter;
}

#pragma mark - Utils

CGPoint BEBubbleViewCircleCenter(CGRect rect) {
    CGFloat radius = CGRectGetHeight(rect)/2.42;
    return CGPointMake(CGRectGetWidth(rect)/2, radius);
}

- (UIBezierPath *)bubblePath {
    CGFloat radius = CGRectGetHeight(self.bounds)/2.42;
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2, radius);
    CGFloat startAngle = BEDegreesToRadians(45);
    CGFloat endAngle = BEDegreesToRadians(135);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO];
    CGPoint bottom = CGPointMake(center.x, CGRectGetMaxY(self.bounds));
    [path addLineToPoint:bottom];
    [path closePath];
    return path;
}

#pragma mark - getter && setter

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:11];
        _textLabel.text = @"60";
    }
    return _textLabel;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.path = [self bubblePath].CGPath;
        _shapeLayer.fillColor = BEColorWithRGBHex(0x2EC3C0).CGColor;
    }
    return _shapeLayer;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.textLabel.text = text;
    [self setNeedsLayout];
}

@end
