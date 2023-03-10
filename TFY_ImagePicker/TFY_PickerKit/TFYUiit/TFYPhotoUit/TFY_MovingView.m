//
//  TFY_MovingView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_MovingView.h"
#import "TFY_ImageCoder.h"
#import "TFY_StickerItem+views.h"
#import "UIView+picker.h"

#define TFYMovingView_margin 22
#define TFYMovingView_contentMargin 40

@interface TFY_MovingContentView : UIView <UIGestureRecognizerDelegate>
@end

@implementation TFY_MovingContentView

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    gestureRecognizer.delegate = self;
    [super addGestureRecognizer:gestureRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer.view == self && otherGestureRecognizer.view == self) {
        return YES;
    }
    return NO;
}


@end

@interface TFY_MovingView ()
{
    TFY_MovingContentView *_contentView;
    UIButton *_deleteButton;
    UIImageView *_circleView;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

@property (nonatomic, assign, getter=isActive) BOOL active;
@end

@implementation TFY_MovingView

+ (void)setActiveEmoticonView:(TFY_MovingView *)view
{
    static TFY_MovingView *activeView = nil;
    /** 停止取消激活 */
    [activeView cancelDeactivated];
    if(view != activeView){
        [activeView setActive:NO];
        activeView = view;
        [activeView setActive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
        
    }
    [activeView autoDeactivated];
}

- (void)dealloc
{
    [self cancelDeactivated];
}

#pragma mark - 自动取消激活
- (void)cancelDeactivated
{
    [TFY_MovingView cancelPreviousPerformRequestsWithTarget:self];
}

- (void)autoDeactivated
{
    [self performSelector:@selector(setActiveEmoticonView:) withObject:nil afterDelay:self.deactivatedDelay];
}

- (void)setActiveEmoticonView:(TFY_MovingView *)view
{
    [TFY_MovingView setActiveEmoticonView:view];
}

- (instancetype)initWithItem:(TFY_StickerItem *)item
{
    UIView *view = item.displayView;
    if (view == nil) {
        return nil;
    }
    self = [super initWithFrame:CGRectMake(0, 0, view.frame.size.width+TFYMovingView_contentMargin+TFYMovingView_margin, view.frame.size.height+TFYMovingView_contentMargin+TFYMovingView_margin)];
    if(self){
        _deactivatedDelay = 4.f;
        _view = view;
        _item = item;
        _contentView = [[TFY_MovingContentView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width+TFYMovingView_contentMargin, view.frame.size.height+TFYMovingView_contentMargin)];
        _contentView.layer.borderColor = [[UIColor colorWithWhite:1.f alpha:0.8] CGColor];
        {
            // shadow
            _contentView.layer.shadowColor = [UIColor clearColor].CGColor;
            _contentView.layer.shadowOpacity = .5f;
            _contentView.layer.shadowOffset = CGSizeMake(0, 0);
            _contentView.layer.shadowRadius = 2.f;
            
            [_contentView picker_updateSquareShadow];
        }
        
        _contentView.center = self.center;
        [_contentView addSubview:view];
        view.userInteractionEnabled = self.isActive;
        view.center = CGPointMake(_contentView.bounds.size.width/2, _contentView.bounds.size.height/2);
        [self addSubview:_contentView];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, TFYMovingView_margin, TFYMovingView_margin);
        _deleteButton.center = _contentView.frame.origin;
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [_deleteButton setImage:[NSBundle picker_imageNamed:@"StickerZoomingViewDelete.png"] forState:UIControlStateNormal];
        _deleteButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _deleteButton.layer.shadowOpacity = .2f;
        _deleteButton.layer.shadowOffset = CGSizeMake(0, 0);
        _deleteButton.layer.shadowRadius = 2;
        [_deleteButton picker_updateCircleShadow];
        [self addSubview:_deleteButton];
        
        _circleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TFYMovingView_margin, TFYMovingView_margin)];
        _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
        [_circleView setImage:[NSBundle picker_imageNamed:@"StickerZoomingViewCircle.png"]];
        _circleView.layer.shadowColor = [UIColor blackColor].CGColor;
        _circleView.layer.shadowOpacity = .2f;
        _circleView.layer.shadowOffset = CGSizeMake(0, 0);
        _circleView.layer.shadowRadius = 2;
        [_circleView picker_updateCircleShadow];
        [self addSubview:_circleView];
        
        _scale = 1.f;
        _screenScale = 1.f;
        _arg = 0;
        _minScale = .2f;
        _maxScale = 3.f;
        
        [self initGestures];
        [self setActive:NO];
    }
    return self;
}

- (void)setItem:(TFY_StickerItem *)item
{
    _item = item;
    [_view removeFromSuperview];
    _view = item.displayView;
    if (_view) {
        [_contentView addSubview:_view];
        _view.userInteractionEnabled = self.isActive;
        [self updateFrameWithViewSize:_view.frame.size];
    } else {
        [self removeFromSuperview];
    }
}

/** 更新坐标 */
- (void)updateFrameWithViewSize:(CGSize)viewSize
{
    /** 记录自身中心点 */
    CGPoint center = self.center;
    /** 更新自身大小 */
    CGRect frame = self.frame;
    frame.size = CGSizeMake(viewSize.width+TFYMovingView_contentMargin+TFYMovingView_margin, viewSize.height+TFYMovingView_contentMargin+TFYMovingView_margin);
    self.frame = frame;
    self.center = center;
    
    /** 还原缩放率 */
    _contentView.transform = CGAffineTransformIdentity;
    
    /** 更新主体大小 */
    CGRect contentFrame = _contentView.frame;
    contentFrame.size = CGSizeMake(viewSize.width+TFYMovingView_contentMargin, viewSize.height+TFYMovingView_contentMargin);
    _contentView.frame = contentFrame;
    _contentView.center = center;
    _deleteButton.center = _contentView.frame.origin;
    _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
    [_contentView picker_updateSquareShadow];
    /** 更新显示视图大小 */
    _view.center = CGPointMake(_contentView.bounds.size.width/2, _contentView.bounds.size.height/2);
    
    [self setScale:_scale rotation:_arg];
}

- (void)initGestures
{
    self.userInteractionEnabled = YES;
    _contentView.userInteractionEnabled = YES;
    _circleView.userInteractionEnabled = YES;
    [_contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_contentView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_circleView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(circleViewDidPan:)]];
    
    /** Add two finger pinching and rotating gestures */
    [_contentView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPinch:)]];
    [_contentView addGestureRecognizer:[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidRotation:)]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view= [super hitTest:point withEvent:event];
    if(view==self){
        view = nil;
    }
    if (view == nil) {
        [TFY_MovingView setActiveEmoticonView:nil];
    }
    return view;
}

- (void)setActive:(BOOL)active
{
    _deleteButton.hidden = self.item.isMain ? YES : !active;
    _circleView.hidden = !active;
    _contentView.layer.borderWidth = (active) ? 1/_scale/self.screenScale : 0;
    _contentView.layer.cornerRadius = (active) ? 3/_scale/self.screenScale : 0;
    
    _contentView.layer.shadowColor = (active) ? [UIColor blackColor].CGColor : [UIColor clearColor].CGColor;
    
    _view.userInteractionEnabled = active;
    
    if (_active != active) {
        _active = active;
        if (self.movingActived) {
            self.movingActived(self);
        }
    }
}

- (void)setScale:(CGFloat)scale
{
    [self setScale:scale rotation:MAXFLOAT];
}

- (void)setScale:(CGFloat)scale rotation:(CGFloat)rotation
{
    if (rotation != MAXFLOAT) {
        _arg = rotation;
    }
    _scale = MIN(MAX(scale, _minScale), _maxScale);
    
    self.transform = CGAffineTransformIdentity;
    
    _contentView.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_contentView.frame.size.width + TFYMovingView_margin)) / 2;
    rct.origin.y += (rct.size.height - (_contentView.frame.size.height + TFYMovingView_margin)) / 2;
    rct.size.width  = _contentView.frame.size.width + TFYMovingView_margin;
    rct.size.height = _contentView.frame.size.height + TFYMovingView_margin;
    self.frame = rct;
    
    _contentView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    _deleteButton.center = _contentView.frame.origin;
    _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
    
    self.transform = CGAffineTransformMakeRotation(_arg);

    if (self.isActive) {
        _contentView.layer.borderWidth = 1/_scale/self.screenScale;
        _contentView.layer.cornerRadius = 3/_scale/self.screenScale;
        [_contentView picker_updateSquareShadow];
    }
}

- (void)setScreenScale:(CGFloat)screenScale
{
    _screenScale = screenScale;
    CGFloat scale = 1.f/screenScale;
    _deleteButton.transform = CGAffineTransformMakeScale(scale, scale);
    _circleView.transform = CGAffineTransformMakeScale(scale, scale);
    _deleteButton.center = _contentView.frame.origin;
    _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
}

- (CGFloat)scale
{
    return _scale;
}

- (CGFloat)rotation
{
    return _arg;
}

#pragma mark - Touch Event

- (void)pushedDeleteBtn:(id)sender
{
    [self cancelDeactivated];
    [self removeFromSuperview];
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    BOOL isActive = self.isActive;
    [[self class] setActiveEmoticonView:self];
    if (self.tapEnded) self.tapEnded(self, isActive);
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        [[self class] setActiveEmoticonView:self];
        _initialPoint = self.center;
        [self cancelDeactivated];
        if (self.movingBegan) {
            self.movingBegan(self);
        }
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.movingChanged) {
            CGPoint locationPoint = [sender locationInView:self.superview];
            self.movingChanged(self, locationPoint);
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        BOOL isMoveCenter = NO;
        CGRect rect = [self convertRect:_contentView.frame toView:self.superview];
        if (self.moveCenter) {
            isMoveCenter = self.moveCenter(rect);
        } else {
            isMoveCenter = !CGRectIntersectsRect(self.superview.frame, rect);
        }
        if (isMoveCenter) {
            /** 超出边界线 重置会中间 */
            [UIView animateWithDuration:0.25f animations:^{
                self.center = [self.superview convertPoint:TFYAppWindow().center fromView:(UIView *)TFYAppWindow()];
            }];
        }
        [self autoDeactivated];
        if (self.movingEnded) {
            self.movingEnded(self);
        }
    }
}

- (void)viewDidPinch:(UIPinchGestureRecognizer*)sender
{
    if(sender.state == UIGestureRecognizerStateBegan){
        [[self class] setActiveEmoticonView:self];
        [self cancelDeactivated];
        _initialScale = _scale;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self autoDeactivated];
    }
    [self setScale:(_initialScale * sender.scale)];
    if(sender.state == UIGestureRecognizerStateBegan && sender.state == UIGestureRecognizerStateChanged){
        sender.scale = 1.0;
    }
}

- (void)viewDidRotation:(UIRotationGestureRecognizer*)sender
{
    if(sender.state == UIGestureRecognizerStateBegan){
        [[self class] setActiveEmoticonView:self];
        [self cancelDeactivated];
        _initialArg = _arg;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self autoDeactivated];
    }
    _arg = _initialArg + sender.rotation;
    [self setScale:_scale];
    if(sender.state == UIGestureRecognizerStateBegan && sender.state == UIGestureRecognizerStateChanged){
        sender.rotation = 0.0;
    }
}


- (void)circleViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1;
    static CGFloat tmpA = 0;
    if(sender.state == UIGestureRecognizerStateBegan){
        [self cancelDeactivated];
        _initialPoint = [self.superview convertPoint:_circleView.center fromView:_circleView.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        tmpR = sqrt(p.x*p.x + p.y*p.y);
        tmpA = atan2(p.y, p.x);
        
        _initialArg = _arg;
        _initialScale = _scale;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self autoDeactivated];
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y);
    CGFloat arg = atan2(p.y, p.x);
    
    _arg = _initialArg + arg - tmpA;
    [self setScale:(_initialScale * R / tmpR)];
}


@end
