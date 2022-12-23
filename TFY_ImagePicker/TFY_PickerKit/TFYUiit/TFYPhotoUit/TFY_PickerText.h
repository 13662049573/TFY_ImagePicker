//
//  TFY_PickerText.h
//  TFY_ImagePicker
//
//  Created by 田风有 on 2022/12/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PickerText : NSObject<NSSecureCoding>

@property (nonatomic, strong) NSAttributedString *attributedText;

@property (nonatomic, strong) NSDictionary *layoutData;
/**
 Default is CGRectNull.
 因为使用attributedText计算文字大小与实际在UITextView的大小会有差异，原因是UITextView -> NSTextContainer -> lineFragmentPadding 的默认值为5，导致计算的宽度相差10。高度也有差异，原因不明。这里直接使用UITextView返回的文字区域。
 */
@property (nonatomic, assign) CGRect usedRect;

@end

NS_ASSUME_NONNULL_END
