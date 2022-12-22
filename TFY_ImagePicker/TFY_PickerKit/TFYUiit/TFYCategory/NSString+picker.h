//
//  NSString+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSString (picker)

/** 计算文字大小 */
- (CGSize)picker_boundingSizeWithSize:(CGSize)size font:(UIFont *)font;


- (CGSize)picker_boundingSizeWithSize:(CGSize)size attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;
- (CGSize)picker_boundingSizeWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;
- (CGSize)picker_boundingSizeWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes context:(nullable NSStringDrawingContext *)context;

@end

NS_ASSUME_NONNULL_END
