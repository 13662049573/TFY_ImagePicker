//
//  TFY_FilterSuiteUtils.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class TFY_Filter;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYFilterNameType) {
    TFYFilterNameType_None = 0,
    TFYFilterNameType_LinearCurve,
    TFYFilterNameType_Chrome,
    TFYFilterNameType_Fade,
    TFYFilterNameType_Instant,
    TFYFilterNameType_Mono,
    TFYFilterNameType_Noir,
    TFYFilterNameType_Process,
    TFYFilterNameType_Tonal,
    TFYFilterNameType_Transfer,
    TFYFilterNameType_CurveLinear,
    TFYFilterNameType_Invert,
    TFYFilterNameType_Monochrome,
};

OBJC_EXTERN NSString *picker_descWithType(TFYFilterNameType type);

OBJC_EXTERN NSString *picker_filterNameWithType(TFYFilterNameType type);

OBJC_EXTERN TFY_Filter *picker_filterWithType(TFYFilterNameType type);

OBJC_EXTERN UIImage *picker_filterImageWithType(UIImage *image, TFYFilterNameType type);


NS_ASSUME_NONNULL_END
