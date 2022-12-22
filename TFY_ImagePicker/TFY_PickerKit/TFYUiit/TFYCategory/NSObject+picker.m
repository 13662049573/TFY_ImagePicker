//
//  NSObject+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "NSObject+picker.h"
#import "TFY_TipsGuideManager.h"
#import "TFY_TipsGuideView.h"

@implementation NSObject (picker)

- (void)picker_showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr
{
    [self picker_showInView:view maskViews:views withTips:tipsArr times:1];
}
- (void)picker_showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times
{
    if ([self.class isKindOfClass:[TFY_TipsGuideManager class]]) {
        return;
    }
    [[TFY_TipsGuideManager manager] writeClass:self.class maskViews:views withTips:tipsArr times:times];
    if ([[TFY_TipsGuideManager manager] isValidWithClass:self.class maskViews:views withTips:tipsArr]) {
        TFY_TipsGuideView *guide = [TFY_TipsGuideView new];
        [guide showInView:view maskViews:views withTips:tipsArr];
    }
}
- (void)picker_showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr
{
    [self picker_showInView:view maskRects:rects withTips:tipsArr times:1];
}
- (void)picker_showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times
{
    if ([self.class isKindOfClass:[TFY_TipsGuideManager class]]) {
        return;
    }
    [[TFY_TipsGuideManager manager] writeClass:self.class maskRects:rects withTips:tipsArr times:times];
    if ([[TFY_TipsGuideManager manager] isValidWithClass:self.class maskRects:rects withTips:tipsArr]) {
        TFY_TipsGuideView *guide = [TFY_TipsGuideView new];
        [guide showInView:view maskRects:rects withTips:tipsArr];
    }
}

@end
