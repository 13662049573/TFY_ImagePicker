//
//  TFY_ClippingView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_PickerScrollView.h"
#import "TFY_EditingProtocol.h"

@class TFY_ClippingView;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYClippingViewDelegate <NSObject>

/** 同步缩放视图（调用zoomOutToRect才会触发） */
- (void (^)(CGRect))picker_clippingViewWillBeginZooming:(TFY_ClippingView *)clippingView;
- (void)picker_clippingViewDidZoom:(TFY_ClippingView *)clippingView;
- (void)picker_clippingViewDidEndZooming:(TFY_ClippingView *)clippingView;

/** 移动视图 */
- (void)picker_clippingViewWillBeginDragging:(TFY_ClippingView *)clippingView;
- (void)picker_clippingViewDidEndDecelerating:(TFY_ClippingView *)clippingView;

@end

@interface TFY_ClippingView : TFY_PickerScrollView <TFY_EditingProtocol>

@property (nonatomic, strong) UIImage *image;

- (void)setImage:(UIImage *)image durations:(NSArray <NSNumber *> *)durations;

/** 获取除图片以外的编辑图层 */
- (UIImage *)editOtherImagesInRect:(CGRect)rect rotate:(CGFloat)rotate;

@property (nonatomic, weak) id<TFYClippingViewDelegate> clippingDelegate;
/** 首次缩放后需要记录最小缩放值 */
@property (nonatomic, readonly) CGFloat first_minimumZoomScale;
/** 与父视图中心偏差坐标 */
@property (nonatomic, assign) CGPoint offsetSuperCenter;

/** 是否重置中 */
@property (nonatomic, readonly) BOOL isReseting;
/** 是否旋转中 */
@property (nonatomic, readonly) BOOL isRotating;
/** 旋转角度 */
@property (nonatomic, readonly) NSInteger angle;
/** 是否缩放中 */
//@property (nonatomic, readonly) BOOL isZooming;
/** 是否可还原 */
@property (nonatomic, readonly) BOOL canReset;
/** 以某个位置作为可还原的参照物 */
- (BOOL)canResetWithRect:(CGRect)trueFrame;

/** 可编辑范围 */
@property (nonatomic, assign) CGRect editRect;
/** 剪切范围 */
@property (nonatomic, assign) CGRect cropRect;
/** 手势开关，一般编辑模式下开启 默认NO */
@property (nonatomic, assign) BOOL useGesture;

/** 缩小到指定坐标 */
- (void)zoomOutToRect:(CGRect)toRect;
/** 放大到指定坐标(必须大于当前坐标) */
- (void)zoomInToRect:(CGRect)toRect;
/** 旋转 */
- (void)rotateClockwise:(BOOL)clockwise;
/** 还原 */
- (void)reset;
/** 还原到某个位置 */
- (void)resetToRect:(CGRect)rect;
/** 取消 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
