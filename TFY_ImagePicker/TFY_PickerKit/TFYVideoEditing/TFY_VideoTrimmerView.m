//
//  TFY_VideoTrimmerView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_VideoTrimmerView.h"
#import "TFYCategory.h"
#import "TFY_VideoTrimmerGridView.h"

#define TFYVideoTrimmerView_timeLabel_height 11.f

/** 视频时间（取整：四舍五入） */
NSTimeInterval picker_videoDuration(NSTimeInterval duration)
{
    return (NSInteger)(duration+0.5f)*1.f;
}

@interface TFY_VideoTrimmerView ()<TFYVideoTrimmerGridViewDelegate>
/** 视频图片解析器 */
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

/** 内容容器 */
@property (nonatomic, weak) UIView *contentView;
/** 起始时间 */
@property (nonatomic, weak) UILabel *startTimeLabel;
/** 结束时间 */
@property (nonatomic, weak) UILabel *endTimeLabel;
/** 总时间 */
@property (nonatomic, weak) UILabel *totalTimeLabel;

/** 控制操作视图 */
@property (nonatomic, weak) TFY_VideoTrimmerGridView *gridView;

/** 视频总时长 */
@property (nonatomic, assign) double totalDuration;
@end

@implementation TFY_VideoTrimmerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    _maxImageCount = 15;
    
    /** 时间标签 */
    CGRect timeLabelRect = CGRectMake(0, 0, 60, TFYVideoTrimmerView_timeLabel_height);
    UILabel *startTimeLabel = [self timeLabel];
    startTimeLabel.frame = timeLabelRect;
    startTimeLabel.text = NSLocalizedString(@"00:00", nil);
    [self addSubview:startTimeLabel];
    _startTimeLabel = startTimeLabel;
    
    UILabel *endTimeLabel = [self timeLabel];
    timeLabelRect.origin.x = CGRectGetWidth(self.frame)-timeLabelRect.size.width;
    endTimeLabel.frame = timeLabelRect;
    endTimeLabel.textAlignment = NSTextAlignmentRight;
    endTimeLabel.text = NSLocalizedString(@"00:00", nil);
    [self addSubview:endTimeLabel];
    _endTimeLabel = endTimeLabel;
    
    UILabel *totalTimeLabel = [self timeLabel];
    timeLabelRect.origin.x = (CGRectGetWidth(self.frame)-timeLabelRect.size.width)/2;
    timeLabelRect.origin.y = CGRectGetHeight(self.frame)-timeLabelRect.size.height;
    totalTimeLabel.frame = timeLabelRect;
    totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    totalTimeLabel.text = NSLocalizedString(@"00:00", nil);
    [self addSubview:totalTimeLabel];
    _totalTimeLabel = totalTimeLabel;
    
    
    /** 每帧图片的容器 */
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, TFYVideoTrimmerView_timeLabel_height+1, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-2*(TFYVideoTrimmerView_timeLabel_height+1))];
    contentView.clipsToBounds = YES;
    [self addSubview:contentView];
    _contentView = contentView;
    
    /** 时间轴 */
    TFY_VideoTrimmerGridView *gridView = [[TFY_VideoTrimmerGridView alloc] initWithFrame:contentView.frame];
    gridView.delegate = self;
    [self addSubview:gridView];
    _gridView = gridView;
}

- (UILabel *)timeLabel
{
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont boldSystemFontOfSize:10.f];
    timeLabel.numberOfLines = 1.f;
    return timeLabel;
}

- (BOOL)isEnabledLeftCorner
{
    return self.gridView.isEnabledLeftCorner;
}

- (void)setEnabledLeftCorner:(BOOL)enabledLeftCorner
{
    self.gridView.enabledLeftCorner = enabledLeftCorner;
}

- (BOOL)isEnabledRightCorner
{
    return self.gridView.isEnabledRightCorner;
}

- (void)setEnabledRightCorner:(BOOL)enabledRightCorner
{
    self.gridView.enabledRightCorner = enabledRightCorner;
}

- (void)setMaxImageCount:(NSInteger)maxImageCount
{
    if (maxImageCount > 0) {
        _maxImageCount = maxImageCount;
    }
}

- (void)setControlMinWidth:(CGFloat)controlMinWidth
{
    if (controlMinWidth > self.gridView.controlMaxWidth) {
        controlMinWidth = self.gridView.controlMaxWidth;
    }
    self.gridView.controlMinWidth = MAX(controlMinWidth,1);
}

- (CGFloat)controlMinWidth
{
    return self.gridView.controlMinWidth;
}

- (void)setControlMaxWidth:(CGFloat)controlMaxWidth
{
    if (controlMaxWidth < self.gridView.controlMinWidth) {
        controlMaxWidth = self.gridView.controlMinWidth;
    }
    self.gridView.controlMaxWidth = MIN(controlMaxWidth,self.gridView.bounds.size.width);
}

- (CGFloat)controlMaxWidth
{
    return self.gridView.controlMaxWidth;
}

- (void)setAsset:(AVAsset *)asset
{
    _asset = asset;
    [self analysisVideo];
}

- (void)setProgress:(double)progress
{
    self.gridView.progress = progress;
}

- (double)progress
{
    return self.gridView.progress;
}

- (void)setHiddenProgress:(BOOL)hidden
{
    [self.gridView setHiddenProgress:hidden];
}

/** 重设控制区域 */
- (void)setGridRange:(NSRange)gridRange animated:(BOOL)animated
{
    [self.gridView setGridRect:CGRectMake(gridRange.location, 0, gridRange.length, self.gridView.frame.size.height) animated:animated];
    [self calcTime];
}

- (void)analysisVideo
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    /** 适配获取张图以铺满内容 */
    NSInteger maxImageCount = self.maxImageCount;
    NSArray *assetVideoTracks = [_asset tracksWithMediaType:AVMediaTypeVideo];
    CGSize maximumSize = CGSizeMake(self.contentView.frame.size.height, self.contentView.frame.size.height);;
    if (assetVideoTracks.count > 0)
    {
        // Insert the tracks in the composition's tracks
        AVAssetTrack *track = [assetVideoTracks firstObject];
        CGSize size = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
        CGSize dimensions = CGSizeMake(fabs(size.width), fabs(size.height));
        
        CGFloat height = self.contentView.frame.size.height * [UIScreen mainScreen].scale;
        maximumSize = CGSizeMake(dimensions.width/dimensions.height*height, height);
    }
    if (maxImageCount * maximumSize.width < self.contentView.frame.size.width) {
        maxImageCount = self.contentView.frame.size.width / maximumSize.width + 1;
    }
    
    
    _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_asset];
    _imageGenerator.maximumSize = maximumSize;
    _imageGenerator.appliesPreferredTrackTransform = YES;
    
    CMTime duration = _asset.duration;
    self.totalDuration = CMTimeGetSeconds(duration);
    [self calcTime];
    
    NSInteger index = maxImageCount;
    CMTimeValue intervalSeconds = duration.value/index;
    CMTime time = CMTimeMake(0, duration.timescale);
    NSMutableArray *times = [NSMutableArray array];
    for (NSUInteger i = 0; i < index; i++) {
        [times addObject:[NSValue valueWithCMTime:time]];
        time = CMTimeAdd(time, CMTimeMake(intervalSeconds, duration.timescale));
    }
    
    CGFloat imageMargin = self.frame.size.width / (index * 1.0f);
    __block CGFloat maxContentWidth = 0;
    
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime,
                                                                                      CGImageRef cgImage,
                                                                                      CMTime actualTime,
                                                                                      AVAssetImageGeneratorResult result,
                                                                                      NSError *error) {
        UIImage *image = nil;
        if (cgImage) {
            image = [[UIImage alloc] initWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger imageIndex = [times indexOfObject:[NSValue valueWithCMTime:requestedTime]];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.layer.borderColor = [UIColor blackColor].CGColor;
            imageView.layer.borderWidth = .5f;
            CGFloat imageWidth = self.contentView.frame.size.height / image.size.height * image.size.width;
            CGFloat width = MIN(imageMargin, imageWidth);
            imageView.frame = CGRectMake(imageIndex*width, 0, imageWidth, self.contentView.frame.size.height);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:imageView];
            maxContentWidth = CGRectGetMaxX(imageView.frame);
        });
    }];
}

- (void)calcTime
{
    if (self.totalDuration) {

        double startTime = picker_videoDuration(MIN(self.gridView.gridRect.origin.x/self.picker_width*self.totalDuration, self.totalDuration));
        double endTime = picker_videoDuration(MIN((self.gridView.gridRect.origin.x+self.gridView.gridRect.size.width)/self.picker_width*self.totalDuration, self.totalDuration));
        
        _startTime = startTime;
        _endTime = endTime;
        self.startTimeLabel.text = [TFY_VideoTrimmerView getMMSSWithSecond:startTime];
        self.endTimeLabel.text = [TFY_VideoTrimmerView getMMSSWithSecond:endTime];
        self.totalTimeLabel.text = [TFY_VideoTrimmerView getMMSSWithSecond:endTime-startTime];
    }
}

+ (NSString *)getMMSSWithSecond:(NSInteger)second{
    NSString *tmpmm = [NSString stringWithFormat:@"%d",(int)(second/60)%60];
    if (tmpmm.length == 1) {
        tmpmm = [NSString stringWithFormat:@"0%@",tmpmm];
    }
    NSString *tmpss = [NSString stringWithFormat:@"%d",(int)second%60];
    if (tmpss.length == 1) {
        tmpss = [NSString stringWithFormat:@"0%@",tmpss];
    }
    return [NSString stringWithFormat:@"%@:%@",tmpmm,tmpss];
}

#pragma mark - TFYVideoTrimmerGridViewDelegate
- (void)picker_videoTrimmerGridViewDidBeginResizing:(TFY_VideoTrimmerGridView *)gridView
{
    if ([self.delegate respondsToSelector:@selector(picker_videoTrimmerViewDidBeginResizing:gridRange:)]) {
        [self.delegate picker_videoTrimmerViewDidBeginResizing:self gridRange:NSMakeRange(gridView.gridRect.origin.x, gridView.gridRect.size.width)];
    }
}
- (void)picker_videoTrimmerGridViewDidResizing:(TFY_VideoTrimmerGridView *)gridView
{
    if ([self.delegate respondsToSelector:@selector(picker_videoTrimmerViewDidResizing:gridRange:)]) {
        [self.delegate picker_videoTrimmerViewDidResizing:self gridRange:NSMakeRange(gridView.gridRect.origin.x, gridView.gridRect.size.width)];
    }
    [self calcTime];
}
- (void)picker_videoTrimmerGridViewDidEndResizing:(TFY_VideoTrimmerGridView *)gridView
{
    if ([self.delegate respondsToSelector:@selector(picker_videoTrimmerViewDidEndResizing:gridRange:)]) {
        [self.delegate picker_videoTrimmerViewDidEndResizing:self gridRange:NSMakeRange(gridView.gridRect.origin.x, gridView.gridRect.size.width)];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    BOOL isHit = [super pointInside:point withEvent:event];
    if (!isHit) {
        return [self.gridView pointInside:point withEvent:event];
    }
    return isHit;
}


@end
