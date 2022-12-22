//
//  TFY_SafeAreaMaskView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_SafeAreaMaskView.h"
#import "TFY_GridMaskLayer.h"

@interface TFY_SafeAreaMaskView ()
@property (nonatomic, weak) TFY_GridMaskLayer *gridMaskLayer;
@end

@implementation TFY_SafeAreaMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    /** 遮罩 */
    TFY_GridMaskLayer *gridMaskLayer = [[TFY_GridMaskLayer alloc] init];
    gridMaskLayer.frame = self.bounds;
    gridMaskLayer.maskColor = [UIColor colorWithWhite:.0f alpha:.5f].CGColor;
    [self.layer addSublayer:gridMaskLayer];
    self.gridMaskLayer = gridMaskLayer;
}

- (void)setMaskRect:(CGRect)maskRect
{
    _maskRect = maskRect;
    if (self.showMaskLayer) {
        [self.gridMaskLayer setMaskRect:maskRect animated:YES];
    }
}

- (void)setShowMaskLayer:(BOOL)showMaskLayer
{
    if (_showMaskLayer != showMaskLayer) {
        _showMaskLayer = showMaskLayer;
        if (showMaskLayer) {
            /** 还原遮罩 */
            [self.gridMaskLayer setMaskRect:self.maskRect animated:YES];
        } else {
            /** 扩大遮罩范围 */
            [self.gridMaskLayer clearMaskWithAnimated:YES];
        }
    }
}


@end
