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

- (id)picker_initWithTitle:(NSString *)title
               message:(NSString *)message
     cancelButtonTitle:(NSString *)cancelButtonTitle
     otherButtonTitles:(NSString*)otherButtonTitles
                 block:(picker_AlertViewBlock)block;

/** block回调代理 弹出后回调 */
- (id)picker_initWithTitle:(NSString *)title
               message:(NSString *)message
     cancelButtonTitle:(NSString *)cancelButtonTitle
     otherButtonTitles:(NSString*)otherButtonTitles
                 block:(picker_AlertViewBlock)block
          didShowBlock:(picker_AlertViewDidShowBlock)didShowBlock;

/** block回调代理 文字左对齐 */
- (id)picker_initWithTitle:(NSString *)title
           leftMessage:(NSString *)message
     cancelButtonTitle:(NSString *)cancelButtonTitle
     otherButtonTitles:(NSString*)otherButtonTitles
                 block:(picker_AlertViewBlock)block;


@end

NS_ASSUME_NONNULL_END
