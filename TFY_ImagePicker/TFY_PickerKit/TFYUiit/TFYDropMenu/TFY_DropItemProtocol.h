//
//  TFY_DropItemProtocol.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TFYDropMainMenuDirection)
{
    TFYDropMainMenuDirectionAuto = -1,
    TFYDropMainMenuDirectionTop = 0,
    TFYDropMainMenuDirectionBottom = 2,
};

@protocol TFY_DropItemProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TFYDropItemTapHandler)(id <TFY_DropItemProtocol> item);
typedef void(^TFYDropItemDoubleTapHandler)(id <TFY_DropItemProtocol> item);
typedef void(^TFYDropItemLongPressHandler)(id <TFY_DropItemProtocol> item);

@protocol TFY_DropItemProtocol <NSObject>

@required
@property (nonatomic, readonly) UIView *displayView;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, copy, nullable) TFYDropItemTapHandler tapHandler;
@property (nonatomic, copy, nullable) TFYDropItemDoubleTapHandler doubleTapHandler;
@property (nonatomic, copy, nullable) TFYDropItemLongPressHandler longPressHandler;

@end

NS_ASSUME_NONNULL_END
