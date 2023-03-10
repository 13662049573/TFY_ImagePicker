//
//  TFY_VideoTrimmerView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class TFY_VideoTrimmerView;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYVideoTrimmerViewDelegate <NSObject>

- (void)picker_videoTrimmerViewDidBeginResizing:(TFY_VideoTrimmerView *_Nonnull)trimmerView gridRange:(NSRange)gridRange;
- (void)picker_videoTrimmerViewDidResizing:(TFY_VideoTrimmerView *_Nonnull)trimmerView gridRange:(NSRange)gridRange;
- (void)picker_videoTrimmerViewDidEndResizing:(TFY_VideoTrimmerView *_Nonnull)trimmerView gridRange:(NSRange)gridRange;

@end

@interface TFY_VideoTrimmerView : UIView

/** 视频对象 */
@property (nonatomic, strong) AVAsset *asset;
/** 最大图片数量 默认10张 */
@property (nonatomic, assign) NSInteger maxImageCount;
/** 最小尺寸 */
@property (nonatomic, assign) CGFloat controlMinWidth;
/** 最大尺寸 */
@property (nonatomic, assign) CGFloat controlMaxWidth;

/** 起始时间 */
@property (nonatomic, readonly) double startTime;
/** 结束时间 */
@property (nonatomic, readonly) double endTime;

@property (nonatomic, getter=isEnabledLeftCorner) BOOL enabledLeftCorner;
@property (nonatomic, getter=isEnabledRightCorner) BOOL enabledRightCorner;

/** 进度 */
@property (nonatomic, assign) double progress;
- (void)setHiddenProgress:(BOOL)hidden;

/** 重设控制区域 */
- (void)setGridRange:(NSRange)gridRange animated:(BOOL)animated;

/** 代理 */
@property (nonatomic, weak) id delegate;

@end

NS_ASSUME_NONNULL_END
