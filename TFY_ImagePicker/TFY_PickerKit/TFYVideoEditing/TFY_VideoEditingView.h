//
//  TFY_VideoEditingView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TFY_EditingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class TFY_AudioItem,TFY_VideoEditingView;

@protocol TFYVideoEditingPlayerDelegate <NSObject>

@optional
/** 错误回调 */
- (void)picker_videoEditingViewFailedToPrepare:(TFY_VideoEditingView *)editingView error:(NSError *)error;
/** 播放视频 */
- (void)picker_videoEditingViewPlay:(TFY_VideoEditingView *)editingView;
/** 暂停视频 */
- (void)picker_videoEditingViewPause:(TFY_VideoEditingView *)editingView;
/** 播放完毕 */
- (void)picker_videoEditingViewPlayToEndTime:(TFY_VideoEditingView *)editingView;

@end

@interface TFY_VideoEditingView : UIView <TFY_EditingProtocol>

/** 代理 */
@property (nonatomic, weak) id<TFYVideoEditingPlayerDelegate> playerDelegate;

/** 音频数据 */
@property (nonatomic, strong) NSArray <TFY_AudioItem *>*audioUrls;

/** 开关剪辑模式 */
@property (nonatomic, assign) BOOL isClipping;
- (void)setIsClipping:(BOOL)isClipping animated:(BOOL)animated;

/** 允许剪辑的最小时长 1秒 */
@property (nonatomic, assign) double minClippingDuration;
/** 允许剪辑的最大时长 0秒，不限 */
@property (nonatomic, assign) double maxClippingDuration;

/** 播放速率 (0.5~2.0) 值为0则禁止播放，默认1 */
@property (nonatomic, assign) float rate;

/** 取消剪辑 */
- (void)cancelClipping:(BOOL)animated;

/** 数据 */
- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image;

/** 导出视频 */
- (void)exportAsynchronouslyWithTrimVideo:(void (^)(NSURL *trimURL, NSError *error))complete progress:(void (^)(float progress))progress;

/** 播放 */
- (void)playVideo;
/** 暂停 */
- (void)pauseVideo;
/** 重置视频 */
- (void)resetVideoDisplay;


@end

NS_ASSUME_NONNULL_END
