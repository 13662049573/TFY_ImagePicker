//
//  TFY_TipsGuideManager.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TipsGuideManager : NSObject

+ (instancetype)manager;

/// 开启提示，默认开启。
@property (nonatomic, assign, getter=isEnable) BOOL enable;

- (BOOL)isValidWithClass:(Class)aClass maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr;
- (BOOL)isValidWithClass:(Class)aClass maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr;

- (void)writeClass:(Class)aClass maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times;
- (void)writeClass:(Class)aClass maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times;

- (void)removeClass:(Class)aClass maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr;
- (void)removeClass:(Class)aClass maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr;

- (void)removeClass:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
