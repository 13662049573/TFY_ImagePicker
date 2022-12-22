//
//  UIAlertView+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^picker_AlertViewBlock)(UIAlertView *alertView, NSInteger buttonIndex);
typedef void (^picker_AlertViewDidShowBlock)(void);

@interface UIAlertView (picker)

- (id)picker_initWithTitle:(nullable NSString *)title
               message:(nullable NSString *)message
     cancelButtonTitle:(nullable NSString *)cancelButtonTitle
     otherButtonTitles:(nullable NSString*)otherButtonTitles
                 block:(nullable picker_AlertViewBlock)block;

/** block回调代理 弹出后回调 */
- (id)picker_initWithTitle:(nullable NSString *)title
               message:(nullable NSString *)message
     cancelButtonTitle:(nullable NSString *)cancelButtonTitle
     otherButtonTitles:(nullable NSString*)otherButtonTitles
                 block:(nullable picker_AlertViewBlock)block
          didShowBlock:(nullable picker_AlertViewDidShowBlock)didShowBlock;

/** block回调代理 文字左对齐 */
- (id)picker_initWithTitle:(nullable NSString *)title
           leftMessage:(nullable NSString *)message
     cancelButtonTitle:(nullable NSString *)cancelButtonTitle
     otherButtonTitles:(nullable NSString*)otherButtonTitles
                 block:(nullable picker_AlertViewBlock)block;


@end

NS_ASSUME_NONNULL_END
