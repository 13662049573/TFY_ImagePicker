//
//  CALayer+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "CALayer+picker.h"
#import <objc/runtime.h>

static const char * TFYBrushLayerLevelKey = "TFYBrushLayerLevelKey";

@implementation CALayer (picker)

- (void)setPicker_level:(NSInteger)picker_level {
    objc_setAssociatedObject(self, TFYBrushLayerLevelKey, @(picker_level), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)picker_level {
    NSNumber *num = objc_getAssociatedObject(self, TFYBrushLayerLevelKey);
    if (num != nil) {
        return [num integerValue];
    }
    return 0;
}

@end
