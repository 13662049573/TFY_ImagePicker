//
//  TFY_DropItem.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import "TFY_DropItemProtocol.h"
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, TFYDropItemState) {
    TFYDropItemStateNormal,
    TFYDropItemStateSelected,
};

NS_ASSUME_NONNULL_BEGIN

@interface TFY_DropItem : NSObject<TFY_DropItemProtocol>

@property (nonatomic, copy) NSString *title;

- (void)setTitleColor:(nullable UIColor *)color forState:(TFYDropItemState)state;
- (void)setImage:(nullable UIImage *)image forState:(TFYDropItemState)state;

- (nullable UIColor *)colorForState:(TFYDropItemState)state;
- (nullable UIImage *)imageForState:(TFYDropItemState)state;

@end

NS_ASSUME_NONNULL_END
