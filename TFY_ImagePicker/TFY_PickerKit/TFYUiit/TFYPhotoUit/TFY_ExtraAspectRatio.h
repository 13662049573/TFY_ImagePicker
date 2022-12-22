//
//  TFY_ExtraAspectRatio.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import "TFY_FilterDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ExtraAspectRatio : NSObject<TFY_ExtraAspectRatioProtocol>

/** 横比例，例如9 */
@property (nonatomic, readonly) int picker_aspectWidth;
/** 纵比例，例如16 */
@property (nonatomic, readonly) int picker_aspectHeight;
/** 分隔符，默认x */
@property (nonatomic, copy, nullable, readonly) NSString *picker_aspectDelimiter;
/**
 适配视图纵横比例，默认YES
 如果视图的宽度>高度，则纵横比例会反转。
 */
@property (nonatomic, readonly) BOOL autoAspectRatio;

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height;

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height
                          autoAspectRatio:(BOOL)autoAspectRatio;

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height
                       andAspectDelimiter:(NSString * _Nullable)aspectDelimiter
                          autoAspectRatio:(BOOL)autoAspectRatio;

- (instancetype)initWithWidth:(int)width
                    andHeight:(int)height
           andAspectDelimiter:(NSString * _Nullable)aspectDelimiter
              autoAspectRatio:(BOOL)autoAspectRatio;

@end

NS_ASSUME_NONNULL_END
