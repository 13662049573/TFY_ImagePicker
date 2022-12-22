//
//  UIAlertView+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "UIAlertView+picker.h"
#import <objc/runtime.h>

static char picker_overAlertViewKey;
static char picker_overAlertViewKeyLeft;
static char picker_overAlertViewKeyDidShow;

@implementation UIAlertView (picker)

/** block回调代理 */
- (id)picker_initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles block:(picker_AlertViewBlock)block
{
    return [self picker_initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles block:block didShowBlock:nil];
}

/** block回调代理 弹出后回调 */
- (id)picker_initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles block:(picker_AlertViewBlock)block didShowBlock:(picker_AlertViewDidShowBlock)didShowBlock
{
    objc_setAssociatedObject(self, &picker_overAlertViewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &picker_overAlertViewKeyDidShow, didShowBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    return [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];//注意这里初始化父类的
}

/** block回调代理 文字左对齐 */
- (id)picker_initWithTitle:(NSString *)title
        leftMessage:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString*)otherButtonTitles
              block:(picker_AlertViewBlock)block
{
    objc_setAssociatedObject(self, &picker_overAlertViewKeyLeft, @(YES), OBJC_ASSOCIATION_ASSIGN);
    return [self picker_initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles block:block];
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //这里调用函数指针_block(要传进来的参数);
    picker_AlertViewBlock block = (picker_AlertViewBlock)objc_getAssociatedObject(self, &picker_overAlertViewKey);
    if (block) {
        block(alertView, buttonIndex);
        objc_setAssociatedObject(self, &picker_overAlertViewKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject(self, &picker_overAlertViewKeyLeft, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(self, &picker_overAlertViewKeyDidShow, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    BOOL isCenter = [((NSNumber *)objc_getAssociatedObject(self, &picker_overAlertViewKeyLeft)) boolValue];
    if (isCenter == NO) return;
    if (([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)) {
        
        NSString *message = alertView.message;
//        CGFloat margin = 20;
//        CGSize size = [message boundingRectWithSize:CGSizeMake(240-2*margin,400) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
//        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0,240, size.height)];
//        textLabel.font = [UIFont systemFontOfSize:14];
//        textLabel.textColor = [UIColor blackColor];
//        textLabel.backgroundColor = [UIColor clearColor];
//        textLabel.lineBreakMode =NSLineBreakByWordWrapping;
//        textLabel.numberOfLines =0;
//        textLabel.textAlignment =NSTextAlignmentLeft;
//        textLabel.text = message;
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 240, size.height+margin)];
//        [view addSubview:textLabel];
        UIView *view = [self picker_createView:message];
        [alertView setValue:view forKey:@"accessoryView"];
        
        alertView.message = @"";
    } else {
        NSInteger count = 0;
        for( UIView * view in alertView.subviews )
        {
            if( [view isKindOfClass:[UILabel class]] )
            {
                count ++;
                if ( count == 2 ) { //仅对message左对齐
                    UILabel* label = (UILabel*) view;
                    label.textAlignment =NSTextAlignmentLeft;
                }
            }
        }
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    picker_AlertViewDidShowBlock block = (picker_AlertViewDidShowBlock)objc_getAssociatedObject(self, &picker_overAlertViewKeyDidShow);
    if (block) {
        block();
    }
}

- (UIView *)picker_createView:(NSString *)message
{
    
    float textWidth = 260;
    
    float textMargin = 10;
    
    UIFont *textFont = [UIFont systemFontOfSize:15];
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    
    attrs[NSFontAttributeName] = textFont;
    
    CGSize maxSize = CGSizeMake(textWidth-textMargin*2, MAXFLOAT);
    
    CGSize size = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(textMargin, textMargin, textWidth, size.height)];
    
    textLabel.font = textFont;
    
    textLabel.textColor = [UIColor blackColor];
    
    textLabel.backgroundColor = [UIColor clearColor];
    
    textLabel.lineBreakMode =NSLineBreakByWordWrapping;
    
    textLabel.numberOfLines =0;
    
    textLabel.textAlignment =NSTextAlignmentLeft;
    
    textLabel.text = message;
    
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textWidth + textMargin * 2,CGRectGetMaxY(textLabel.frame)+textMargin)];
    
    [demoView addSubview:textLabel];
    
    return demoView;
    
}


@end
