//
//  TFY_VideoEditingView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_VideoEditingView.h"
#import "TFY_ImageCoder.h"
#import "TFYCategory.h"
#import "TFY_VideoClippingView.h"
#import "TFY_VideoTrimmerView.h"
#import <AVFoundation/AVFoundation.h>
#import "TFY_FilterVideoExportSession.h"
#import "TFY_AudioTrackBar.h"

/** 默认剪辑尺寸 */
#define kClipZoom_margin 20.f

#define kVideoTrimmer_tb_margin 10.f
#define kVideoTrimmer_lr_margin 50.f
#define kVideoTrimmer_h 80.f

NSString *const kTFYVideoEditingViewData = @"TFYVideoEditingViewData";
NSString *const kTFYVideoEditingViewData_clipping = @"TFYVideoEditingViewData_clipping";

NSString *const kTFYVideoEditingViewData_audioUrlList = @"TFYVideoEditingViewData_audioUrlList";

NSString *const kTFYVideoEditingViewData_audioUrl = @"TFYVideoEditingViewData_audioUrl";
NSString *const kTFYVideoEditingViewData_audioTitle = @"TFYVideoEditingViewData_audioTitle";
NSString *const kTFYVideoEditingViewData_audioOriginal = @"TFYVideoEditingViewData_audioOriginal";
NSString *const kTFYVideoEditingViewData_audioEnable = @"TFYVideoEditingViewData_audioEnable";

@interface TFY_VideoEditingView ()<TFYVideoClippingViewDelegate, TFYVideoTrimmerViewDelegate>

/** 视频剪辑 */
@property (nonatomic, weak) TFY_VideoClippingView *clippingView;

/** 视频时间轴 */
@property (nonatomic, weak) TFY_VideoTrimmerView *trimmerView;

/** 剪裁尺寸 */
@property (nonatomic, assign) CGRect clippingRect;

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) TFY_FilterVideoExportSession *exportSession;

/* 底部栏高度 默认44 */
@property (nonatomic, assign) CGFloat editToolbarDefaultHeight;

@end

@implementation TFY_VideoEditingView

/*
 1、播放功能（无限循环）
 2、暂停／继续功能
 3、视频水印功能
 4、视频编辑功能
    4.1、涂鸦
    4.2、贴图
    4.3、文字
    4.4、马赛克
    4.5、视频剪辑功能
*/


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)dealloc
{
    [self.exportSession cancelExport];
    // 释放TFY_EditingProtocol协议
    [self clearProtocolxecutor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat toolbarHeight = self.editToolbarDefaultHeight;
    
    if (@available(iOS 11.0, *)) {
        toolbarHeight += self.safeAreaInsets.bottom;
    }
    
    self.trimmerView.frame = CGRectMake(kVideoTrimmer_lr_margin, CGRectGetHeight(self.bounds)-kVideoTrimmer_h-toolbarHeight-kVideoTrimmer_tb_margin, self.bounds.size.width-kVideoTrimmer_lr_margin*2, kVideoTrimmer_h);
}

- (void)customInit
{
    self.backgroundColor = [UIColor blackColor];
    _minClippingDuration = 1.f;
    _maxClippingDuration = 0.f;
    _editToolbarDefaultHeight = 44.f;
    
    TFY_VideoClippingView *clippingView = [[TFY_VideoClippingView alloc] initWithFrame:self.bounds];
    clippingView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    clippingView.clipDelegate = self;
    [self addSubview:clippingView];
    _clippingView = clippingView;
    
    TFY_VideoTrimmerView *trimmerView = [[TFY_VideoTrimmerView alloc] initWithFrame:CGRectMake(kVideoTrimmer_lr_margin, CGRectGetHeight(self.bounds)-kVideoTrimmer_h-self.editToolbarDefaultHeight-kVideoTrimmer_tb_margin, self.bounds.size.width-kVideoTrimmer_lr_margin*2, kVideoTrimmer_h)];
    trimmerView.hidden = YES;
    trimmerView.delegate = self;
    [self addSubview:trimmerView];
    _trimmerView = trimmerView;
    
    // 实现TFY_EditingProtocol协议
    {
        self.picker_protocolxecutor = self.clippingView;
    }
    
    /** 默认绘画线粗 */
    [self setDrawLineWidth:5.0];
    /** 屏幕缩放率 */
    [self setScreenScale:1.0];
}

- (UIEdgeInsets)refer_clippingInsets
{
    CGFloat top = kClipZoom_margin;
    CGFloat left = kClipZoom_margin;
    CGFloat bottom = self.editToolbarDefaultHeight + kVideoTrimmer_h + kVideoTrimmer_tb_margin*2;
    CGFloat right = kClipZoom_margin;
    
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (CGRect)refer_clippingRect
{
    UIEdgeInsets insets = [self refer_clippingInsets];
    
    CGRect referRect = self.bounds;
    referRect.origin.x += insets.left;
    referRect.origin.y += insets.top;
    referRect.size.width -= (insets.left+insets.right);
    referRect.size.height -= (insets.top+insets.bottom);
    
    return referRect;
}

- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    self.clippingView.cropRect = clippingRect;
}

- (void)setIsClipping:(BOOL)isClipping
{
    [self setIsClipping:isClipping animated:NO];
}
- (void)setIsClipping:(BOOL)isClipping animated:(BOOL)animated
{
    /** 获取总时长才进行记录，否则等待总时长获取后再操作 */
    if (self.clippingView.totalDuration) {
        [self.clippingView save];
        [self.clippingView replayVideo];
        CGFloat x = self.clippingView.startTime/self.clippingView.totalDuration*self.trimmerView.picker_width;
        CGFloat width = self.clippingView.endTime/self.clippingView.totalDuration*self.trimmerView.picker_width-x;
        [self.trimmerView setGridRange:NSMakeRange(x, width) animated:NO];
    }
    _isClipping = isClipping;
    if (isClipping) {
        /** 动画切换 */
        if (animated) {
            self.trimmerView.hidden = NO;
            self.trimmerView.alpha = 0.f;
            CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.picker_size, [self refer_clippingRect]);
            [UIView animateWithDuration:0.25f animations:^{
                self.clippingRect = rect;
                self.trimmerView.alpha = 1.f;
            } completion:^(BOOL finished) {
                if (self.trimmerView.asset == nil) {
                    self.trimmerView.asset = self.asset;
                }
            }];
        } else {
            CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.picker_size, [self refer_clippingRect]);
            self.clippingRect = rect;
            self.trimmerView.hidden = NO;
            if (self.trimmerView.asset == nil) {
                self.trimmerView.asset = self.asset;
            }
        }
    } else {
        /** 重置最大缩放 */
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.picker_size, self.bounds);
                self.clippingRect = cropRect;
                self.trimmerView.alpha = 0.f;
            } completion:^(BOOL finished) {
                self.trimmerView.alpha = 1.f;
                self.trimmerView.hidden = YES;
            }];
        } else {
            CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.picker_size, self.bounds);
            self.clippingRect = cropRect;
            self.trimmerView.hidden = YES;
        }
    }
}

/** 取消剪裁 */
- (void)cancelClipping:(BOOL)animated
{
    [self.clippingView cancel];
    [self setIsClipping:NO animated:animated];
}

- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image
{
    if (self.audioUrls == nil) {
        /** 创建默认音轨 */
        TFY_AudioItem *item = [TFY_AudioItem defaultAudioItem];
        self.audioUrls = @[item];
    }
    self.asset = asset;
    [self.clippingView setVideoAsset:asset placeholderImage:image];
    
//    [self setNeedsDisplay];
}

- (void)setAudioUrls:(NSArray<TFY_AudioItem *> *)audioUrls
{
    _audioUrls = audioUrls;
    NSMutableArray <NSURL *>*audioMixUrls = [@[] mutableCopy];
    BOOL isMuteOriginal = NO;
    for (TFY_AudioItem *item in audioUrls) {
        if (item.isOriginal) {
            isMuteOriginal = !item.isEnable;
        } else if (item.url && item.isEnable) {
            [audioMixUrls addObject:item.url];
        }
    }
    [self.clippingView setAudioMix:audioMixUrls];
    [self.clippingView muteOriginalVideo:isMuteOriginal];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (self.isClipping && view == self) {
        return self.trimmerView;
    }
    
    return view;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /** 解决部分机型在编辑期间会触发滑动导致无法编辑的情况 */
    if (self.isClipping) {
        /** 自身手势被触发、响应视图非自身、被触发手势为滑动手势 */
        return NO;
    } else if ([self drawEnable] && ![gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        /** 绘画时候，禁用滑动手势 */
        return NO;
    } else if ([self splashEnable] && ![gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        /** 模糊时候，禁用滑动手势 */
        return NO;
    } else if ([self stickerEnable] && ![gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        /** 贴图移动时候，禁用滑动手势 */
        return NO;
    }
    return YES;
}

- (float)rate
{
    return self.clippingView.rate;
}

- (void)setRate:(float)rate
{
    self.clippingView.rate = rate;
}

/** 播放 */
- (void)playVideo
{
    [self.clippingView playVideo];
}
/** 暂停 */
- (void)pauseVideo
{
    [self.clippingView pauseVideo];
}
/** 重置视频 */
- (void)resetVideoDisplay
{
    [self.clippingView resetVideoDisplay];
}

/** 导出视频 */
- (void)exportAsynchronouslyWithTrimVideo:(void (^)(NSURL *trimURL, NSError *error))complete progress:(void (^)(float progress))progress
{
    [self pauseVideo];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager new];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.LFMediaEditing.video"];
    BOOL exist = [fm fileExistsAtPath:path];
    
    /** 删除原来剪辑的视频 */
    if (exist) {
        if (![fm removeItemAtPath:path error:&error]) {
            NSLog(@"removeTrimPath error: %@ \n",[error localizedDescription]);
        }
    }
    if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"createMediaFolder error: %@ \n",[error localizedDescription]);
    }
    
    NSString *name = nil;
    
    if ([self.asset isKindOfClass:[AVURLAsset class]]) {
        name = ((AVURLAsset *)self.asset).URL.lastPathComponent;
    } if ([self.asset isKindOfClass:[AVComposition class]]) {
        AVCompositionTrack *avcompositionTrack = (AVCompositionTrack *)[self.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        AVCompositionTrackSegment *segment = avcompositionTrack.segments.firstObject;
        name = segment.sourceURL.lastPathComponent;
    }
    if (name.length == 0) {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        name = result;
    }
    
    
    NSString *trimPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Edit%d.mp4", [name stringByDeletingPathExtension], (int)[[NSDate date] timeIntervalSince1970]]];
    NSURL *trimURL = [NSURL fileURLWithPath:trimPath];
    
    /** 剪辑 */
    CMTime start = CMTimeMakeWithSeconds(self.clippingView.startTime, self.asset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(self.clippingView.endTime - self.clippingView.startTime, self.asset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    self.exportSession = [[TFY_FilterVideoExportSession alloc] initWithAsset:self.asset];
    // 输出路径
    self.exportSession.outputURL = trimURL;
    // 视频剪辑
    self.exportSession.timeRange = range;
    // 水印
    self.exportSession.overlayView = self.clippingView.overlayView;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if (@available(iOS 9.0, *)) {
        // 滤镜
        self.exportSession.filter = self.clippingView.filter;
    }
#pragma clang diagnostic pop
    // 速率
    self.exportSession.rate = self.rate;
    // 音频
    NSMutableArray *audioUrls = [@[] mutableCopy];
    for (TFY_AudioItem *item in self.audioUrls) {
        if (item.isEnable && item.url) {
            [audioUrls addObject:item.url];
        }
        if (item.isOriginal) {
            self.exportSession.isOrignalSound = item.isEnable;
        }
    }
    self.exportSession.audioUrls = audioUrls;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (error) {
            [self playVideo];
        }
        if (complete) complete(trimURL, error);
    } progress:progress];
}

#pragma mark - TFYVideoClippingViewDelegate
/** 视频准备完毕，可以获取相关属性与操作 */
- (void)picker_videoClippingViewReadyToPlay:(TFY_VideoClippingView *)clippingView
{
    self.trimmerView.controlMinWidth = self.trimmerView.picker_width * (self.minClippingDuration / clippingView.totalDuration);
    if (self.maxClippingDuration > 0) {
        self.trimmerView.controlMaxWidth = self.trimmerView.picker_width * (self.maxClippingDuration / clippingView.totalDuration);
        /** 处理剪辑时间超出范围的情况 */
        double differ = self.clippingView.endTime - self.clippingView.startTime - self.maxClippingDuration;
        if (differ > 0) {
            self.clippingView.endTime = MAX(self.clippingView.endTime - differ, self.clippingView.startTime);
            
        }
    }
    if (self.isClipping) {
        [self.clippingView save];
        CGFloat x = self.clippingView.startTime/self.clippingView.totalDuration*self.trimmerView.picker_width;
        CGFloat width = self.clippingView.endTime/self.clippingView.totalDuration*self.trimmerView.picker_width-x;
        [self.trimmerView setGridRange:NSMakeRange(x, width) animated:NO];
    }
}

/** 错误回调 */
- (void)picker_videoClippingViewFailedToPrepare:(TFY_VideoClippingView *_Nonnull)clippingView error:(NSError *)error
{
    if ([self.playerDelegate respondsToSelector:@selector(picker_videoEditingViewFailedToPrepare:error:)]) {
        [self.playerDelegate picker_videoEditingViewFailedToPrepare:self error:error];
    }
}

/** 进度回调 */
- (void)picker_videoClippingView:(TFY_VideoClippingView *)clippingView duration:(double)duration
{
    if (duration == 0) {
        self.trimmerView.progress = clippingView.startTime/clippingView.totalDuration;
    } else {
        self.trimmerView.progress = duration/clippingView.totalDuration;
    }
}

/** 进度长度 */
- (CGFloat)picker_videoClippingViewProgressWidth:(TFY_VideoClippingView *)clippingView
{
    return self.trimmerView.picker_width;
}

/** 播放视频 */
- (void)lf_videoClippingViewPlay:(TFY_VideoClippingView *_Nonnull)clippingView
{
    if ([self.playerDelegate respondsToSelector:@selector(picker_videoEditingViewPlay:)]) {
        [self.playerDelegate picker_videoEditingViewPlay:self];
    }
}
/** 暂停视频 */
- (void)picker_videoClippingViewPause:(TFY_VideoClippingView *_Nonnull)clippingView
{
    if ([self.playerDelegate respondsToSelector:@selector(picker_videoEditingViewPause:)]) {
        [self.playerDelegate picker_videoEditingViewPause:self];
    }
}
/** 播放完毕 */
- (void)lf_videoClippingViewPlayToEndTime:(TFY_VideoClippingView *_Nonnull)clippingView
{
    if ([self.playerDelegate respondsToSelector:@selector(picker_videoEditingViewPlayToEndTime:)]) {
        [self.playerDelegate picker_videoEditingViewPlayToEndTime:self];
    }
}

#pragma mark - TFYVideoTrimmerViewDelegate
- (void)picker_videoTrimmerViewDidBeginResizing:(TFY_VideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
    [self.clippingView pauseVideo];
    [self picker_videoTrimmerViewDidResizing:trimmerView gridRange:gridRange];
    [self.clippingView beginScrubbing];
    [trimmerView setHiddenProgress:YES];
    trimmerView.progress = self.clippingView.startTime/self.clippingView.totalDuration;
}
- (void)picker_videoTrimmerViewDidResizing:(TFY_VideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
//    double startTime = MIN(picker_videoDuration(gridRange.location/trimmerView.width*self.clippingView.totalDuration), self.clippingView.totalDuration);
//    double endTime = MIN(picker_videoDuration((gridRange.location+gridRange.length)/trimmerView.width*self.clippingView.totalDuration), self.clippingView.totalDuration);

    double startTime = gridRange.location/trimmerView.picker_width*self.clippingView.totalDuration;
    double endTime = (gridRange.location+gridRange.length)/trimmerView.picker_width*self.clippingView.totalDuration;
    
    [self.clippingView seekToTime:((self.clippingView.startTime != startTime) ? startTime : endTime)];
    
    self.clippingView.startTime = startTime;
    self.clippingView.endTime = endTime;
    
}
- (void)picker_videoTrimmerViewDidEndResizing:(TFY_VideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
    trimmerView.progress = self.clippingView.startTime/self.clippingView.totalDuration;
    [self.clippingView endScrubbing];
    [self.clippingView playVideo];
    [trimmerView setHiddenProgress:NO];
}

#pragma mark - TFY_EditingProtocol

#pragma mark - 数据
- (NSDictionary *)photoEditData
{
    NSDictionary *subData = self.clippingView.photoEditData;
    NSMutableDictionary *data = [@{} mutableCopy];
    if (subData) [data setObject:subData forKey:kTFYVideoEditingViewData_clipping];
    
    if (self.audioUrls.count) {
        NSMutableArray *audioDatas = [@[] mutableCopy];
        BOOL hasOriginal = NO;
        for (TFY_AudioItem *item in self.audioUrls) {
            
            NSMutableDictionary *myData = [@{} mutableCopy];
            if (item.title) {
                [myData setObject:item.title forKey:kTFYVideoEditingViewData_audioTitle];
            }
            if (item.url) {
                [myData setObject:item.url forKey:kTFYVideoEditingViewData_audioUrl];
            }
            [myData setObject:@(item.isOriginal) forKey:kTFYVideoEditingViewData_audioOriginal];
            [myData setObject:@(item.isEnable) forKey:kTFYVideoEditingViewData_audioEnable];
            if (item.isOriginal && item.isEnable) {
                hasOriginal = YES;
            }
            [audioDatas addObject:myData];
        }
        if (!(hasOriginal && audioDatas.count == 1)) { /** 只有1个并且是原音，忽略数据 */
            [data setObject:@{kTFYVideoEditingViewData_audioUrlList:audioDatas} forKey:kTFYVideoEditingViewData];
        }
    }
    if (data.count) {
        return data;
    }
    return nil;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    NSDictionary *myData = [photoEditData objectForKey:kTFYVideoEditingViewData];
    if (myData) {
        NSArray *audioUrlList = myData[kTFYVideoEditingViewData_audioUrlList];
        NSMutableArray <TFY_AudioItem *>*audioUrls = [@[] mutableCopy];
        for (NSDictionary *audioDict in audioUrlList) {
            TFY_AudioItem *item = [TFY_AudioItem new];
            item.title = audioDict[kTFYVideoEditingViewData_audioTitle];
            item.url = audioDict[kTFYVideoEditingViewData_audioUrl];
            item.isEnable = [audioDict[kTFYVideoEditingViewData_audioEnable] boolValue];
            [audioUrls addObject:item];
        }
        if (audioUrls.count) {
            self.audioUrls = [audioUrls copy];
        }
    }
    self.clippingView.photoEditData = photoEditData[kTFYVideoEditingViewData_clipping];
}


@end
