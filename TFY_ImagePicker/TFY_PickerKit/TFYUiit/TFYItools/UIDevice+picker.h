//
//  UIDevice+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (picker)
/**
 强制旋转设备
 */
+ (void)picker_setOrientation:(UIInterfaceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
