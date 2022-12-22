//
//  TFY_EditingView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_PickerScrollView.h"
#import <UIKit/UIKit.h>
#import "TFY_EditingProtocol.h"
#import "TFY_FilterDataProtocol.h"

@class TFY_EditingView;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYEditingViewDelegate <NSObject>
/** 开始编辑目标 */
- (void)picker_EditingViewWillBeginEditing:(TFY_EditingView *)EditingView;
/** 停止编辑目标 */
- (void)picker_EditingViewDidEndEditing:(TFY_EditingView *)EditingView;

@optional
/** 即将进入剪切界面 */
- (void)picker_EditingViewWillAppearClip:(TFY_EditingView *)EditingView;
/** 进入剪切界面 */
- (void)picker_EditingViewDidAppearClip:(TFY_EditingView *)EditingView;
/** 即将离开剪切界面 */
- (void)picker_EditingViewWillDisappearClip:(TFY_EditingView *)EditingView;
/** 离开剪切界面 */
- (void)picker_EditingViewDidDisappearClip:(TFY_EditingView *)EditingView;

@end

@interface TFY_EditingView : TFY_PickerScrollView <TFY_EditingProtocol>

@property (nonatomic, strong) UIImage *image;
- (void)setImage:(UIImage *)image durations:(NSArray <NSNumber *> *)durations;

/** 代理 */
@property (nonatomic, weak) id<TFYEditingViewDelegate> clippingDelegate;

/** 最小尺寸 CGSizeMake(80, 80) */
@property (nonatomic, assign) CGSize clippingMinSize;
/** 最大尺寸 CGRectInset(self.bounds , 20, 20) */
@property (nonatomic, assign) CGRect clippingMaxRect;

/** 开关编辑模式 */
@property (nonatomic, assign, getter=isClipping) BOOL clipping;
- (void)setClipping:(BOOL)clipping animated:(BOOL)animated;

/** 取消剪裁 */
- (void)cancelClipping:(BOOL)animated;
/** 还原 isClipping=YES 的情况有效 */
- (void)reset;
- (BOOL)canReset;
/** 旋转 isClipping=YES 的情况有效 */
- (void)rotate;
/** 默认长宽比例 */
@property (nonatomic, assign) NSUInteger defaultAspectRatioIndex;
/** 重写比例配置 */
@property (nonatomic, strong) NSArray <id <TFY_ExtraAspectRatioProtocol>>*extraAspectRatioList;
/**
 固定长宽比例
 若为true，以下方法将失效：
 1、aspectRatioDescs;
 2、setAspectRatioIndex:
 3、aspectRatioIndex;
 */
@property (nonatomic, assign) BOOL fixedAspectRatio;
/** 长宽比例 */
- (NSArray <NSString *>*)aspectRatioDescs;
- (void)setAspectRatioIndex:(NSUInteger)aspectRatioIndex;
- (NSUInteger)aspectRatioIndex;

/** 创建编辑图片 */
- (void)createEditImage:(void (^)(UIImage *editImage))complete;


@end

NS_ASSUME_NONNULL_END
