//
//  TFY_VideoTrimmerGridView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

@class TFY_VideoTrimmerGridView;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYVideoTrimmerGridViewDelegate <NSObject>

- (void)picker_videoTrimmerGridViewDidBeginResizing:(TFY_VideoTrimmerGridView *)gridView;
- (void)picker_videoTrimmerGridViewDidResizing:(TFY_VideoTrimmerGridView *)gridView;
- (void)picker_videoTrimmerGridViewDidEndResizing:(TFY_VideoTrimmerGridView *)gridView;

@end

@interface TFY_VideoTrimmerGridView : UIView

@property (nonatomic, assign) CGRect gridRect;
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated;

/** 最小尺寸 */
@property (nonatomic, assign) CGFloat controlMinWidth;
/** 最大尺寸 */
@property (nonatomic, assign) CGFloat controlMaxWidth;

@property (nonatomic, getter=isEnabledLeftCorner) BOOL enabledLeftCorner;
@property (nonatomic, getter=isEnabledRightCorner) BOOL enabledRightCorner;

/** 进度 */
@property (nonatomic, assign) double progress;
- (void)setHiddenProgress:(BOOL)hidden;

@property (nonatomic, weak) id<TFYVideoTrimmerGridViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
