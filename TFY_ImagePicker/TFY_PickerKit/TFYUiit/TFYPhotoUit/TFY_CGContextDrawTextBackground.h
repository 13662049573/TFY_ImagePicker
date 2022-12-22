//
//  TFY_CGContextDrawTextBackground.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * TFYCGContextDrawTextBackgroundStringKey NS_EXTENSIBLE_STRING_ENUM;

OBJC_EXTERN TFYCGContextDrawTextBackgroundStringKey const TFYCGContextDrawTextBackgroundTypeName;
OBJC_EXTERN TFYCGContextDrawTextBackgroundStringKey const TFYCGContextDrawTextBackgroundColorName;
OBJC_EXTERN TFYCGContextDrawTextBackgroundStringKey const TFYCGContextDrawTextBackgroundRadiusName;
OBJC_EXTERN TFYCGContextDrawTextBackgroundStringKey const TFYCGContextDrawTextBackgroundLineUsedRectsName;
OBJC_EXTERN TFYCGContextDrawTextBackgroundStringKey const TFYCGContextDrawTextBackgroundTextContainerSizeName;

typedef NS_ENUM(NSInteger, TFYCGContextDrawTextBackgroundType) {
    /** 无背景 */
    TFYCGContextDrawTextBackgroundTypeNone,
    /** 边框 */
    TFYCGContextDrawTextBackgroundTypeBorder,
    /** 填充 */
    TFYCGContextDrawTextBackgroundTypeSolid
};

CG_EXTERN void picker_CGContextDrawTextBackground(CGContextRef cg_nullable c, UIColor  * _Nullable backgroundColor, CGFloat radius, NSArray <NSValue *>*usedRects, TFYCGContextDrawTextBackgroundType type);

CG_EXTERN void picker_CGContextDrawTextBackgroundData(CGContextRef cg_nullable c, CGSize size, NSDictionary *data);

NS_ASSUME_NONNULL_END
