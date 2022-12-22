//
//  TFY_ResizeControl.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_ResizeControl.h"

@interface TFY_ResizeControl ()
@property (nonatomic, readwrite) CGPoint translation;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizer;
@end

@implementation TFY_ResizeControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:gestureRecognizer];
        _gestureRecognizer = gestureRecognizer;
    }
    return self;
}

- (BOOL)isEnabled
{
    return _gestureRecognizer.isEnabled;
}

- (void)setEnabled:(BOOL)enabled
{
    _gestureRecognizer.enabled = enabled;
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint translationInView = [gestureRecognizer translationInView:self.superview];
        self.startPoint = CGPointMake(roundf(translationInView.x), translationInView.y);
        
        if ([self.delegate respondsToSelector:@selector(picker_resizeConrolDidBeginResizing:)]) {
            [self.delegate picker_resizeConrolDidBeginResizing:self];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        self.translation = CGPointMake(roundf(self.startPoint.x + translation.x),
                                       roundf(self.startPoint.y + translation.y));
        
        if ([self.delegate respondsToSelector:@selector(picker_resizeConrolDidResizing:)]) {
            [self.delegate picker_resizeConrolDidResizing:self];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if ([self.delegate respondsToSelector:@selector(picker_resizeConrolDidEndResizing:)]) {
            [self.delegate picker_resizeConrolDidEndResizing:self];
        }
    }
}
@end
