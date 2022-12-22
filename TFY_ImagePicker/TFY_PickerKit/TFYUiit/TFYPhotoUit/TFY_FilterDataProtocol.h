//
//  TFY_FilterDataProtocol.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import "TFY_FilterSuiteUtils.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TFY_FilterDataProtocol <NSObject>
@property (nonatomic, assign) TFYFilterNameType type;
@end

@protocol TFY_ExtraAspectRatioProtocol <NSObject>
/** 横比例，例如9 */
@property (nonatomic, readonly) int picker_aspectWidth;
/** 纵比例，例如16 */
@property (nonatomic, readonly) int picker_aspectHeight;
/** 分隔符，默认x */
@property (nonatomic, copy, nullable, readonly) NSString *picker_aspectDelimiter;
/**
 适配视图纵横比例
 如果视图的宽度>高度，则纵横比例会反转。
 */
@property (nonatomic, readonly) BOOL autoAspectRatio;

@end

NS_ASSUME_NONNULL_END
