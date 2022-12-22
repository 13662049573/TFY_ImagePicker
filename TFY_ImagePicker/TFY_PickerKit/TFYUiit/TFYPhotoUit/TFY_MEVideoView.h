//
//  TFY_MEVideoView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface TFY_MEVideoView : UIView
/**
 The AVAsset used for displaying the video.
 */
@property (nonatomic, strong) AVAsset *__nullable asset;

/**
 The underlying AVPlayerLayer used for displaying the video.
 */
@property (nonatomic, readonly) AVPlayer *__nullable player;;

/**
 Whether this instance is currently playing.
 */
@property (readonly, nonatomic) BOOL isPlaying;

/**
 The actual item duration.
 */
@property (readonly, nonatomic) CMTime itemDuration;

/**
 The total currently loaded and playable time.
 */
@property (readonly, nonatomic) CMTime playableDuration;
@end

NS_ASSUME_NONNULL_END
