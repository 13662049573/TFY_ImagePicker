//
//  TFY_PickerVideoPlayer.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TFY_PickerVideoPlayer;

@protocol TFYVideoPlayerDelegate <NSObject>

/** 画面回调 */
- (void)picker_VideoPlayerLayerDisplay:(TFY_PickerVideoPlayer *)player avplayer:(AVPlayer *)avplayer;
/** 可以播放 */
- (void)picker_VideoPlayerReadyToPlay:(TFY_PickerVideoPlayer *)player duration:(double)duration;
@optional
/** 播放结束 */
- (void)picker_VideoPlayerPlayDidReachEnd:(TFY_PickerVideoPlayer *)player;
/** 进度回调1-自动实现 */
- (UISlider *)picker_VideoPlayerSyncScrub:(TFY_PickerVideoPlayer *)player;
/** 进度回调2-手动实现 */
- (void)picker_VideoPlayerSyncScrub:(TFY_PickerVideoPlayer *)player duration:(double)duration;
/** 进度长度 */
- (CGFloat)picker_VideoPlayerSyncScrubProgressWidth:(TFY_PickerVideoPlayer *)player;
/** 错误回调 */
- (void)picker_VideoPlayerFailedToPrepare:(TFY_PickerVideoPlayer *)player error:(NSError *)error;

@end

@interface TFY_PickerVideoPlayer : NSObject
{
    NSURL* mURL;
    
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL isSeeking;
}
/** 视频URL，初始化新对象将会重置以下所有参数 */
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) AVAsset *asset;

/** 代理 */
@property (nonatomic, weak) id<TFYVideoPlayerDelegate> delegate;

/** 音效 */
@property (nonatomic, strong) NSArray <NSURL *> *audioUrls;
/** 视频大小 */
@property (nonatomic, readonly) CGSize size;
/** 视频时长 */
@property (nonatomic, readonly) double totalDuration;
/** 当前播放时间 */
@property (nonatomic, readonly) double duration;
/** 针对原音轨静音 */
@property (nonatomic, assign) BOOL muteOriginalSound;
/** 播放速率 (0.5~2.0) 值为0则禁止播放，默认1 */
@property (nonatomic, assign) float rate;

/** 视频控制 */
- (void)play;
- (void)pause;
/** 静音 */
- (void)mute:(BOOL)mute;
- (BOOL)isPlaying;
/** 重置画面 */
- (void)resetDisplay;
/** 跳转到某帧 */
- (void)seekToTime:(CGFloat)time;

/** 进度处理 */
#pragma mark - 自动实现进度 拖动回调
/** 拖动开始调用 */
- (void)beginScrubbing;
/** 拖动进度改变入参 */
- (void)scrub:(UISlider *)slider;
/** 拖动结束调用 */
- (void)endScrubbing;

@end

NS_ASSUME_NONNULL_END
