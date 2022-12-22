//
//  TFY_BrushCache.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_BrushCache : NSCache
+ (instancetype)share;
+ (void)free;
/** 强制缓存对象，不会因数量超出负荷而自动释放 */
- (void)setForceObject:(id)obj forKey:(id)key;
@end

NS_ASSUME_NONNULL_END
