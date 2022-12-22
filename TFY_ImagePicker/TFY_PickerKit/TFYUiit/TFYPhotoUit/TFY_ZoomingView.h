//
//  TFY_ZoomingView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import "TFY_EditingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ZoomingView : UIView <TFY_EditingProtocol>

@property (nonatomic, strong) UIImage *image;

- (void)setImage:(UIImage *)image durations:(NSArray <NSNumber *> *)durations;

/** 获取除图片以外的编辑图层 */
- (UIImage *)editOtherImagesInRect:(CGRect)rect rotate:(CGFloat)rotate;

/** 贴图是否需要移到屏幕中心 */
@property (nonatomic, copy) BOOL(^moveCenter)(CGRect rect);

@end

NS_ASSUME_NONNULL_END
