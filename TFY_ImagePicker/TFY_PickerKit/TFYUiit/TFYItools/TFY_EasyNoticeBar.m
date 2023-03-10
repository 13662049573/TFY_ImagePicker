//
//  TFY_EasyNoticeBar.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_EasyNoticeBar.h"
#import "TFY_ImageCoder.h"

CGFloat const TFYEasyNoticeBarWidenSize = 50.0;

@implementation TFY_EasyNoticeBarConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = TFYEasyNoticeBarDisplayTypeInfo;
        _margin = 20.0;
        _textColor = [UIColor blackColor];
        _backgroundColor = [UIColor whiteColor];
        _statusBarStyle = UIStatusBarStyleDefault;
    }
    return self;
}

@end

@interface TFY_EasyNoticeBar ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, assign) UIStatusBarStyle currentStatusBarStyle;
@end

@implementation TFY_EasyNoticeBar

+ (NSBundle *)picker_noticeBarBundle {
    static NSBundle *noticeBarBundle = nil;
    if (noticeBarBundle == nil) {
        noticeBarBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"EasyNoticeBar" ofType:@"bundle"]];
        if (noticeBarBundle == nil) {
            return [NSBundle bundleForClass:[self class]];
        }
    }
    return noticeBarBundle;
}

- (UIImage *)picker_noticeBarImageNamed:(NSString *)name
{
    return [UIImage imageWithContentsOfFile:[[[self class] picker_noticeBarBundle] pathForResource:name ofType:nil]];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithConfig:(TFY_EasyNoticeBarConfig *)config
{
    self = [super init];
    if (self) {
        _config = config;
        [self customInit];
    }
    return self;
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    [self updateLayoutSubviews];
}

- (void)customInit
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.44;
}

- (void)configureSubviews {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = _config.title;
    titleLabel.textColor = _config.textColor;
//    titleLabel.minimumScaleFactor = 0.55;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.numberOfLines = 3;
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    UIImage *image = nil;
    switch (_config.type) {
        case TFYEasyNoticeBarDisplayTypeInfo:
        {
            image = [self picker_noticeBarImageNamed:@"info@2x.png"];
        }
            break;
        case TFYEasyNoticeBarDisplayTypeSuccess:
        {
            image = [self picker_noticeBarImageNamed:@"success@2x.png"];
        }
            break;
        case TFYEasyNoticeBarDisplayTypeWarning:
        {
            image = [self picker_noticeBarImageNamed:@"warning@2x.png"];
        }
            break;
        case TFYEasyNoticeBarDisplayTypeError:
        {
            image = [self picker_noticeBarImageNamed:@"error@2x.png"];
        }
            break;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    _imageView = imageView;
    
    [self updateLayoutSubviews];
}

- (void)showWithDuration:(NSTimeInterval)duration
{
    [[self class] hideAll];
    
    [self configureSubviews];
    
    UIWindow *keyWindow = TFYAppWindow();
    
    self.currentStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = self.config.statusBarStyle;
    
    [keyWindow addSubview:self];
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
    self.transform = transform;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.65 delay:0.0 usingSpringWithDamping:0.58 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.25 delay:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.transform = transform;
            } completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf removeFromSuperview];
                }
            }];
        } else {
            [weakSelf removeFromSuperview];
        }
    }];
}

#pragma mark - public
+ (void)showAnimationWithConfig:(TFY_EasyNoticeBarConfig *)config
{
    TFY_EasyNoticeBar *picker_noticeBar = [[self alloc] initWithConfig:config];
    [picker_noticeBar showWithDuration:2.0];
}

+ (void)hideAll
{
    UIWindow *keyWindow = TFYAppWindow();
    NSArray *subviews = keyWindow.subviews;
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[self class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Override

- (void)removeFromSuperview {
    [UIApplication sharedApplication].statusBarStyle = self.currentStatusBarStyle;
    
    [super removeFromSuperview];
}


#pragma mark - private

- (void)updateLayoutSubviews
{
    BOOL isVerticalScreen = [UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height;
    CGFloat navigationBarHeight = isVerticalScreen ? 44.0 : 34.0;
    CGFloat statusBarHeight = isVerticalScreen ? 20.0 : 0.0;
    
    CGFloat imageWidth = 30.0;
    CGFloat imageOriginX = _config.margin + 10.0 + TFYEasyNoticeBarWidenSize;
    if (@available(iOS 11.0, *)) {
        statusBarHeight = self.safeAreaInsets.top;
    }
    CGFloat imageOriginY = statusBarHeight + (navigationBarHeight-imageWidth)/2 + TFYEasyNoticeBarWidenSize;
    [_imageView setFrame:CGRectMake(imageOriginX, imageOriginY, imageWidth, imageWidth)];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width + TFYEasyNoticeBarWidenSize*2;
    
    CGFloat titleLabelOriginX = CGRectGetMaxX(_imageView.frame) + 10;
    CGFloat titleLabelOriginY = statusBarHeight + TFYEasyNoticeBarWidenSize;
    CGFloat titleLabelWidth = screenWidth - titleLabelOriginX - 10;
    CGFloat titleLabelHeight = navigationBarHeight;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [_titleLabel setFrame:CGRectMake(titleLabelOriginX, titleLabelOriginY, titleLabelWidth, titleLabelHeight)];
    
    self.frame = CGRectMake(-TFYEasyNoticeBarWidenSize, -TFYEasyNoticeBarWidenSize, screenWidth, statusBarHeight+navigationBarHeight+TFYEasyNoticeBarWidenSize);
}

@end
