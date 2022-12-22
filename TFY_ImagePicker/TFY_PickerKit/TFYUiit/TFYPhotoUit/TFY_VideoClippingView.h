//
//  TFY_VideoClippingView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_PickerScrollView.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TFY_EditingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class TFY_Filter,TFY_VideoClippingView;

@protocol TFYVideoClippingViewDelegate <NSObject>

/** 视频准备完毕，可以获取相关属性与操作 */
- (void)picker_videoClippingViewReadyToPlay:(TFY_VideoClippingView *_Nonnull)clippingView;
/** 错误回调 */
- (void)picker_videoClippingViewFailedToPrepare:(TFY_VideoClippingView *_Nonnull)clippingView error:(NSError *_Nullable)error;
/** 进度回调 */
- (void)picker_videoClippingView:(TFY_VideoClippingView *_Nonnull)clippingView duration:(double)duration;
/** 进度长度 */
- (CGFloat)picker_videoClippingViewProgressWidth:(TFY_VideoClippingView *_Nonnull)clippingView;

@optional
/** 播放视频 */
- (void)picker_videoClippingViewPlay:(TFY_VideoClippingView *_Nonnull)clippingView;
/** 暂停视频 */
- (void)picker_videoClippingViewPause:(TFY_VideoClippingView *_Nonnull)clippingView;
/** 播放完毕 */
- (void)picker_videoClippingViewPlayToEndTime:(TFY_VideoClippingView *_Nonnull)clippingView;

@end

@interface TFY_VideoClippingView : TFY_PickerScrollView <TFY_EditingProtocol>

@property (nonatomic, weak) id<TFYVideoClippingViewDelegate> _Nullable clipDelegate;


/** 开始播放时间 */
@property (nonatomic, assign) double startTime;
/** 结束播放时间 */
@property (nonatomic, assign) double endTime;
/** 视频总时长 */
@property (nonatomic, readonly) double totalDuration;
/** 是否正在设置进度 */
@property (nonatomic, readonly) BOOL isScrubbing;
/** 是否存在水印 */
@property (nonatomic, readonly) BOOL hasWatermark;
/** 水印层 */
@property (nonatomic, weak, readonly) UIView * _Nullable overlayView;
/** 滤镜 */
@property (nonatomic, readonly, nullable) TFY_Filter *filter;

/** 数据 */
- (void)setVideoAsset:(AVAsset *_Nonnull)asset placeholderImage:(UIImage *_Nonnull)image;

/** 剪切范围 */
@property (nonatomic, assign) CGRect cropRect;

/** 播放速率 */
@property (nonatomic, assign) float rate;

/** 保存 */
- (void)save;
/** 取消 */
- (void)cancel;

/** 播放 */
- (void)playVideo;
/** 暂停 */
- (void)pauseVideo;
/** 静音原音 */
- (void)muteOriginalVideo:(BOOL)mute;
/** 是否播放 */
- (BOOL)isPlaying;
/** 重新播放 */
- (void)replayVideo;
/** 重置视频 */
- (void)resetVideoDisplay;
/** 增加音效 */
- (void)setAudioMix:(NSArray <NSURL *>*_Nullable)audioMix;

/** 移动到某帧 */
- (void)beginScrubbing;
- (void)seekToTime:(CGFloat)time;
- (void)endScrubbing;

@end

NS_ASSUME_NONNULL_END
