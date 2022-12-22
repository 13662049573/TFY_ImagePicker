//
//  NSString+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "NSString+picker.h"
#import <UIKit/UIKit.h>
@implementation NSString (picker)

- (CGSize)picker_boundingSizeWithSize:(CGSize)size font:(UIFont *)font
{
    // 换行符
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    return [self picker_boundingSizeWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName: paragraphStyle} context:nil];
}

- (CGSize)picker_boundingSizeWithSize:(CGSize)size attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes
{
    return [self picker_boundingSizeWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil];
}

- (CGSize)picker_boundingSizeWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes
{
    return [self picker_boundingSizeWithSize:size options:options attributes:attributes context:nil];
}

- (CGSize)picker_boundingSizeWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes context:(nullable NSStringDrawingContext *)context
{
    return [self boundingRectWithSize:size options:options attributes:attributes context:context].size;
}

@end
