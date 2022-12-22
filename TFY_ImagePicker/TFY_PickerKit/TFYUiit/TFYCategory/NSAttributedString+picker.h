//
//  NSAttributedString+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (picker)
/**
 *  计算文字大小
 */
- (CGSize)picker_sizeWithConstrainedToSize:(CGSize)size;

/**
 *  绘制文字
 */
- (void)picker_drawInContext:(CGContextRef)context withPosition:(CGPoint)p andHeight:(float)height andWidth:(float)width;

@end

NS_ASSUME_NONNULL_END
