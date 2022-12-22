//
//  TFY_TextBar.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TFY_TextBar,TFY_Text;

@protocol TFYPickerTextBarDelegate <NSObject>

/** 完成回调 */
- (void)picker_textBarController:(TFY_TextBar *)textBar didFinishText:(TFY_Text *)text;
/** 取消回调 */
- (void)picker_textBarControllerDidCancel:(TFY_TextBar *)textBar;
/** 输入数量已经达到最大值 */
- (void)picker_textBarControllerDidReachMaximumLimit:(TFY_TextBar *)textBar;

@end

@interface TFY_TextBar : UIView

/** 需要显示的文字 */
@property (nonatomic, copy) TFY_Text *showText;

/** 样式 */
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *cancelButtonTitleColorNormal;
@property (nonatomic, copy) NSString *oKButtonTitle;
@property (nonatomic, copy) NSString *cancelButtonTitle;
/** 输入字符限制，默认150 */
@property (nonatomic, assign) NSUInteger maxLimitCount;

/** 布局，必须在layoutBlock时设置 */
@property (nonatomic, assign) CGFloat customTopbarHeight;
@property (nonatomic, assign) CGFloat naviHeight;


/** 代理 */
@property (nonatomic, weak) id<TFYPickerTextBarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame layout:(nullable void (^)(TFY_TextBar *textBar))layoutBlock;

/** 设置文本拾色器默认颜色 */
- (void)setTextSliderColor:(UIColor *)color;
- (void)setTextSliderColorAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
