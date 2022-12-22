//
//  UIViewController+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "UIViewController+picker.h"
#import <objc/runtime.h>

@interface TFYPresentationDropShadowViewProperty : NSObject
@property (nonatomic, weak) UIPanGestureRecognizer *picker_dropShadowPanGestureRecognizer;
@end

@implementation TFYPresentationDropShadowViewProperty
@end

static const char * TFYPresentationDropItemListKey = "TFYPresentationDropItemListKey";

@implementation UIViewController (picker)

- (UIPanGestureRecognizer *)picker_dropShadowPanGestureRecognizer
{
    NSMapTable *dropShadowPropertys = [UIViewController picker_presentationDropList];
    UIPanGestureRecognizer *pan = nil;
    for (UIView *view in dropShadowPropertys) {
        if ([self.view isDescendantOfView:view]) {
            TFYPresentationDropShadowViewProperty *item = [dropShadowPropertys objectForKey:view];
            pan = item.picker_dropShadowPanGestureRecognizer;
            break;
        }
    }
    return pan;
}

#pragma mark - previate
+ (NSMapTable *)picker_presentationDropList{
    NSMapTable *list = objc_getAssociatedObject(self, TFYPresentationDropItemListKey);
    if (list == nil) {
        list = [NSMapTable weakToStrongObjectsMapTable];
        objc_setAssociatedObject(self, TFYPresentationDropItemListKey, list, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return list;
}

@end

@interface UIView (picker)
@end

@implementation UIView (picker)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
            SEL originalSelector = @selector(addGestureRecognizer:);
            SEL swizzledSelector = NSSelectorFromString([NSString stringWithFormat:@"picker_presentation_track_%@", NSStringFromSelector(originalSelector)]);
            [self TFYPresentation_swizzledSelector:originalSelector swizzledSelector:swizzledSelector];
        }
    });
}

+ (void)TFYPresentation_swizzledSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)picker_presentation_track_addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    [self picker_presentation_track_addGestureRecognizer:gestureRecognizer];
    NSArray *privateStrArr = @[@"View", @"Shadow", @"Drop", @"I", @"U"];
    NSString *className =  [[[privateStrArr reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
    if ([self isKindOfClass:NSClassFromString(className)]) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            TFYPresentationDropShadowViewProperty *item = [TFYPresentationDropShadowViewProperty new];
            item.picker_dropShadowPanGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
            [[UIViewController picker_presentationDropList] setObject:item forKey:self];
        }
    }
}

@end
