//
//  TFY_VideoTrimmerGridLayer.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_VideoTrimmerGridLayer : CAShapeLayer
@property (nonatomic, assign) CGRect gridRect;
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;
@end

NS_ASSUME_NONNULL_END
