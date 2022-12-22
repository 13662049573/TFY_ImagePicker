//
//  UIDevice+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "UIDevice+picker.h"

@implementation UIDevice (picker)

//调用私有方法实现
+ (void)picker_setOrientation:(UIInterfaceOrientation)orientation {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@", @"se",@"tOr",@"ientation:"]);
    if ([[self currentDevice] respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[self currentDevice]];
        NSInteger val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

@end
