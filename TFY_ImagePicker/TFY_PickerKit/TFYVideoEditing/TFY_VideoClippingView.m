//
//  TFY_VideoClippingView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_VideoClippingView.h"
#import "TFY_PickerVideoPlayer.h"
#import "TFYCategory.h"
#import "TFY_ImageCoder.h"

/** 编辑功能 */
#import "TFY_DrawView.h"
#import "TFY_StickerView.h"

/** 滤镜框架 */
#import "TFY_DataFilterVideoView.h"

NSString *const kTFYVideoCLippingViewData = @"TFYVideoCLippingViewData";

NSString *const kTFYVideoCLippingViewData_startTime = @"TFYVideoCLippingViewData_startTime";
NSString *const kTFYVideoCLippingViewData_endTime = @"TFYVideoCLippingViewData_endTime";
NSString *const kTFYVideoCLippingViewData_rate = @"TFYVideoCLippingViewData_rate";

NSString *const kTFYVideoCLippingViewData_draw = @"TFYVideoCLippingViewData_draw";
NSString *const kTFYVideoCLippingViewData_sticker = @"TFYVideoCLippingViewData_sticker";
NSString *const kTFYVideoCLippingViewData_filter = @"TFYVideoCLippingViewData_filter";

@interface TFY_VideoClippingView ()<TFYVideoPlayerDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) TFY_DataFilterVideoView *playerView;
@property (nonatomic, strong) TFY_PickerVideoPlayer *videoPlayer;

/** 原始坐标 */
@property (nonatomic, assign) CGRect originalRect;

/** 缩放视图 */
@property (nonatomic, weak) UIView *zoomingView;

/** 绘画 */
@property (nonatomic, weak) TFY_DrawView *drawView;
/** 贴图 */
@property (nonatomic, weak) TFY_StickerView *stickerView;


@property (nonatomic, assign) BOOL muteOriginal;
@property (nonatomic, strong) NSArray <NSURL *>*audioUrls;
@property (nonatomic, strong) AVAsset *asset;



#pragma mark 编辑数据
/** 开始播放时间 */
@property (nonatomic, assign) double old_startTime;
/** 结束播放时间 */
@property (nonatomic, assign) double old_endTime;

@end

@implementation TFY_VideoClippingView
@synthesize rate = _rate;

/*
 1、播放功能（无限循环）
 2、暂停／继续功能
 3、视频编辑功能
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _originalRect = frame;
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.backgroundColor = [UIColor clearColor];
    self.scrollEnabled = NO;
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    /** 缩放视图 */
    UIView *zoomingView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:zoomingView];
    _zoomingView = zoomingView;
    
    
    /** 播放视图 */
    TFY_DataFilterVideoView *playerView = [[TFY_DataFilterVideoView alloc] initWithFrame:self.bounds];
    playerView.contentMode = UIViewContentModeScaleAspectFit;
    [self.zoomingView addSubview:playerView];
    _playerView = playerView;
    
    /** 绘画 */
    TFY_DrawView *drawView = [[TFY_DrawView alloc] initWithFrame:self.bounds];
    /**
     默认画笔
     */
    drawView.brush = [TFY_PaintBrush new];
    /** 默认不能触发绘画 */
    drawView.userInteractionEnabled = NO;
    [self.zoomingView addSubview:drawView];
    self.drawView = drawView;
    
    /** 贴图 */
    TFY_StickerView *stickerView = [[TFY_StickerView alloc] initWithFrame:self.bounds];
    __weak typeof(self) weakSelf = self;
    stickerView.moveCenter = ^BOOL(CGRect rect) {
        /** 判断缩放后贴图是否超出边界线 */
        CGRect newRect = [weakSelf.zoomingView convertRect:rect toView:weakSelf];
        CGRect clipTransRect = CGRectApplyAffineTransform(weakSelf.frame, weakSelf.transform);
        CGRect screenRect = (CGRect){weakSelf.contentOffset, clipTransRect.size};
        screenRect = CGRectInset(screenRect, 44, 44);
        return !CGRectIntersectsRect(screenRect, newRect);
    };
    /** 禁止后，贴图将不能拖到，设计上，贴图是永远可以拖动的 */
    //    stickerView.userInteractionEnabled = NO;
    [self.zoomingView addSubview:stickerView];
    self.stickerView = stickerView;
    
    // 实现TFY_EditingProtocol协议
    {
        self.picker_displayView = self.playerView;
        self.picker_drawView = self.drawView;
        self.picker_stickerView = self.stickerView;
    }
}

- (void)dealloc
{
    [self pauseVideo];
    self.videoPlayer.delegate = nil;
    self.videoPlayer = nil;
    self.playerView = nil;
    // 释放LFEditingProtocol协议
    [self clearProtocolxecutor];
}

- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image
{
    _asset = asset;
    [self.playerView setImageByUIImage:image];
    if (self.videoPlayer == nil) {
        self.videoPlayer = [TFY_PickerVideoPlayer new];
        self.videoPlayer.delegate = self;
    }
    [self.videoPlayer setAsset:asset];
    [self.videoPlayer setAudioUrls:self.audioUrls];
    if (_rate > 0 && !(_rate + FLT_EPSILON > 1.0 && _rate - FLT_EPSILON < 1.0)) {
        self.videoPlayer.rate = _rate;
    }
    
    /** 重置编辑UI位置 */
    CGSize videoSize = self.videoPlayer.size;
    if (CGSizeEqualToSize(CGSizeZero, videoSize) || isnan(videoSize.width) || isnan(videoSize.height)) {
        videoSize = self.zoomingView.picker_size;
    }
    CGRect editRect = AVMakeRectWithAspectRatioInsideRect(videoSize, self.originalRect);
    
    /** 参数取整，否则可能会出现1像素偏差 */
    editRect = TFYMediaEditProundRect(editRect);
    
    self.frame = editRect;
    _zoomingView.picker_size = editRect.size;
    
    /** 子控件更新 */
    [[self.zoomingView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = self.zoomingView.bounds;
    }];
}

- (void)setCropRect:(CGRect)cropRect
{
    _cropRect = cropRect;
    
    self.frame = cropRect;
//    _playerLayerView.center = _drawView.center = _splashView.center = _stickerView.center = self.center;
    
    /** 重置最小缩放比例 */
    CGRect rotateNormalRect = CGRectApplyAffineTransform(self.originalRect, self.transform);
    CGFloat minimumZoomScale = MAX(CGRectGetWidth(self.frame) / CGRectGetWidth(rotateNormalRect), CGRectGetHeight(self.frame) / CGRectGetHeight(rotateNormalRect));
    self.minimumZoomScale = minimumZoomScale;
    self.maximumZoomScale = minimumZoomScale;
    
    [self setZoomScale:minimumZoomScale];
}

/** 保存 */
- (void)save
{
    self.old_startTime = self.startTime;
    self.old_endTime = self.endTime;
}
/** 取消 */
- (void)cancel
{
    self.startTime = self.old_startTime;
    self.endTime = self.old_endTime;
}

/** 播放 */
- (void)playVideo
{
    [self.videoPlayer play];
    [self seekToTime:self.startTime];
    if ([self.clipDelegate respondsToSelector:@selector(picker_videoClippingViewPlay:)]) {
        [self.clipDelegate picker_videoClippingViewPlay:self];
    }
}

/** 暂停 */
- (void)pauseVideo
{
    [self.videoPlayer pause];
    if ([self.clipDelegate respondsToSelector:@selector(picker_videoClippingViewPause:)]) {
        [self.clipDelegate picker_videoClippingViewPause:self];
    }
}

/** 静音原音 */
- (void)muteOriginalVideo:(BOOL)mute
{
    _muteOriginal = mute;
    self.videoPlayer.muteOriginalSound = mute;
}

- (float)rate
{
    return self.videoPlayer.rate ?: 1.0;
}

- (void)setRate:(float)rate
{
    _rate = rate;
    self.videoPlayer.rate = rate;
}

/** 是否播放 */
- (BOOL)isPlaying
{
    return [self.videoPlayer isPlaying];
}

/** 重新播放 */
- (void)replayVideo
{
    [self.videoPlayer resetDisplay];
    if (![self.videoPlayer isPlaying]) {
        [self playVideo];
    } else {
        [self seekToTime:self.startTime];
    }
}

/** 重置视频 */
- (void)resetVideoDisplay
{
    [self.videoPlayer pause];
    [self.videoPlayer resetDisplay];
    [self seekToTime:self.startTime];
    if ([self.clipDelegate respondsToSelector:@selector(picker_videoClippingViewPause:)]) {
        [self.clipDelegate picker_videoClippingViewPause:self];
    }
}

/** 增加音效 */
- (void)setAudioMix:(NSArray <NSURL *>*)audioMix
{
    _audioUrls = audioMix;
    [self.videoPlayer setAudioUrls:self.audioUrls];
}

/** 移动到某帧 */
- (void)seekToTime:(CGFloat)time
{
    [self.videoPlayer seekToTime:time];
}

- (void)beginScrubbing
{
    _isScrubbing = YES;
    [self.videoPlayer beginScrubbing];
}

- (void)endScrubbing
{
    _isScrubbing = NO;
    [self.videoPlayer endScrubbing];
}

/** 是否存在水印 */
- (BOOL)hasWatermark
{
    return self.drawView.canUndo || self.stickerView.subviews.count;
}

- (UIView *)overlayView
{
    if (self.hasWatermark) {
        
        UIView *copyZoomView = [[UIView alloc] initWithFrame:self.zoomingView.bounds];
        copyZoomView.backgroundColor = [UIColor clearColor];
        copyZoomView.userInteractionEnabled = NO;
        
        if (self.drawView.canUndo) {
            /** 绘画 */
            UIView *drawView = [[UIView alloc] initWithFrame:copyZoomView.bounds];
            drawView.layer.contents = (__bridge id _Nullable)([self.drawView picker_captureImage].CGImage);
            [copyZoomView addSubview:drawView];
        }
        
        if (self.stickerView.subviews.count) {
            /** 贴图 */
            UIView *stickerView = [[UIView alloc] initWithFrame:copyZoomView.bounds];
            stickerView.layer.contents = (__bridge id _Nullable)([self.stickerView picker_captureImage].CGImage);
            [copyZoomView addSubview:stickerView];
        }
        
        return copyZoomView;
    }
    return nil;
}

- (TFY_Filter *)filter
{
    return self.playerView.filter;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

#pragma mark - TFYVideoPlayerDelegate
/** 画面回调 */
- (void)picker_VideoPlayerLayerDisplay:(TFY_PickerVideoPlayer *)player avplayer:(AVPlayer *)avplayer
{
    if (self.startTime > 0) {
        [player seekToTime:self.startTime];
    }
    [self.playerView setPlayer:avplayer];
//    [self.playerLayerView setImage:nil];
}
/** 可以播放 */
- (void)picker_VideoPlayerReadyToPlay:(TFY_PickerVideoPlayer *)player duration:(double)duration
{
    if (_endTime == 0) { /** 读取配置优于视频初始化的情况 */
        _endTime = duration;
    }
    _totalDuration = duration;
    self.videoPlayer.muteOriginalSound = self.muteOriginal;
    [self playVideo];
    if ([self.clipDelegate respondsToSelector:@selector(picker_videoClippingViewReadyToPlay:)]) {
        [self.clipDelegate picker_videoClippingViewReadyToPlay:self];
    }
}

/** 播放结束 */
- (void)picker_VideoPlayerPlayDidReachEnd:(TFY_PickerVideoPlayer *)player
{
    if ([self.clipDelegate respondsToSelector:@selector(picker_videoClippingViewPlayToEndTime:)]) {
        [self.clipDelegate picker_videoClippingViewPlayToEndTime:self];
    }
    [self playVideo];
}
/** 错误回调 */
- (void)picker_VideoPlayerFailedToPrepare:(TFY_PickerVideoPlayer *)player error:(NSError *)error
{
    if ([self.clipDelegate respondsToSelector:@selector(picker_videoClippingViewFailedToPrepare:error:)]) {
        [self.clipDelegate picker_videoClippingViewFailedToPrepare:self error:error];
    }
}

/** 进度回调2-手动实现 */
- (void)picker_VideoPlayerSyncScrub:(TFY_PickerVideoPlayer *)player duration:(double)duration
{
    if (self.isScrubbing) return;
    if (duration > self.endTime) {
        [self replayVideo];
    } else {
        if ([self.clipDelegate respondsToSelector:@selector(picker_videoClippingView:duration:)]) {
            [self.clipDelegate picker_videoClippingView:self duration:duration];
        }
    }
}

/** 进度长度 */
- (CGFloat)picker_VideoPlayerSyncScrubProgressWidth:(TFY_PickerVideoPlayer *)player
{
    if ([self.clipDelegate respondsToSelector:@selector(picker_videoClippingViewProgressWidth:)]) {
        return [self.clipDelegate picker_videoClippingViewProgressWidth:self];
    }
    return [UIScreen mainScreen].bounds.size.width;
}


#pragma mark - TFY_EditingProtocol

#pragma mark - 数据
- (NSDictionary *)photoEditData
{
    NSDictionary *drawData = _drawView.data;
    NSDictionary *stickerData = _stickerView.data;
    NSDictionary *filterData = _playerView.data;
    
    NSMutableDictionary *data = [@{} mutableCopy];
    if (drawData) [data setObject:drawData forKey:kTFYVideoCLippingViewData_draw];
    if (stickerData) [data setObject:stickerData forKey:kTFYVideoCLippingViewData_sticker];
    if (filterData) [data setObject:filterData forKey:kTFYVideoCLippingViewData_filter];
    
    if (self.startTime > 0 || self.endTime < self.totalDuration || (_rate > 0 && !(_rate + FLT_EPSILON > 1.0 && _rate - FLT_EPSILON < 1.0))) {
        NSDictionary *myData = @{kTFYVideoCLippingViewData_startTime:@(self.startTime)
                                 , kTFYVideoCLippingViewData_endTime:@(self.endTime)
                                 , kTFYVideoCLippingViewData_rate:@(self.rate)};
        [data setObject:myData forKey:kTFYVideoCLippingViewData];
    }
    
    if (data.count) {
        return data;
    }
    return nil;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    NSDictionary *myData = photoEditData[kTFYVideoCLippingViewData];
    if (myData) {
        self.startTime = self.old_startTime = [myData[kTFYVideoCLippingViewData_startTime] doubleValue];
        self.endTime = self.old_endTime = [myData[kTFYVideoCLippingViewData_endTime] doubleValue];
        self.rate = [myData[kTFYVideoCLippingViewData_rate] floatValue];
    }
    _drawView.data = photoEditData[kTFYVideoCLippingViewData_draw];
    _stickerView.data = photoEditData[kTFYVideoCLippingViewData_sticker];
    _playerView.data = photoEditData[kTFYVideoCLippingViewData_filter];
}

@end
