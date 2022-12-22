//
//  TFY_GridView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import "TFY_FilterDataProtocol.h"

@class TFY_GridView;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYGridViewAspectRatioType) {
    TFYGridViewAspectRatioType_None,
    TFYGridViewAspectRatioType_Original,
    TFYGridViewAspectRatioType_1x1,
    TFYGridViewAspectRatioType_3x2,
    TFYGridViewAspectRatioType_4x3,
    TFYGridViewAspectRatioType_5x3,
    TFYGridViewAspectRatioType_15x9,
    TFYGridViewAspectRatioType_16x9,
    TFYGridViewAspectRatioType_16x10,
    // 其它配置
    TFYGridViewAspectRatioType_Extra = 100,
};

@protocol TFYGridViewDelegate <NSObject>

- (void)picker_gridViewDidBeginResizing:(TFY_GridView *)gridView;
- (void)picker_gridViewDidResizing:(TFY_GridView *)gridView;
- (void)picker_gridViewDidEndResizing:(TFY_GridView *)gridView;

/** 调整长宽比例 */
- (void)picker_gridViewDidAspectRatio:(TFY_GridView *)gridView;
@end

@interface TFY_GridView : UIView

@property (nonatomic, assign) CGRect gridRect;
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated;
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer animated:(BOOL)animated;
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer animated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;
/** 最小尺寸 CGSizeMake(80, 80); */
@property (nonatomic, assign) CGSize controlMinSize;
/** 最大尺寸 CGRectInset(self.bounds, 20, 20) */
@property (nonatomic, assign) CGRect controlMaxRect;
/** 原图尺寸 */
@property (nonatomic, assign) CGSize controlSize;

/** 显示遮罩层（触发拖动条件必须设置为YES）default is YES */
@property (nonatomic, assign) BOOL showMaskLayer;

/** 是否正在拖动 */
@property(nonatomic,readonly,getter=isDragging) BOOL dragging;

/** 比例是否水平翻转 */
@property (nonatomic, assign) BOOL aspectRatioHorizontally;
/** 其它比例配置，将会完全重写比例配置 */
@property (nonatomic, strong) NSArray <id <TFY_ExtraAspectRatioProtocol>>*extraAspectRatioList;
/** 旋转系数 */
@property (nonatomic, assign) NSInteger angle;
/** 设置固定比例 */
@property (nonatomic, assign) TFYGridViewAspectRatioType aspectRatio;

- (void)setAspectRatio:(TFYGridViewAspectRatioType)aspectRatio animated:(BOOL)animated;

@property (nonatomic, weak) id<TFYGridViewDelegate> delegate;

/** 长宽比例描述 */
- (NSArray <NSString *>*)aspectRatioDescs;


@end

NS_ASSUME_NONNULL_END
