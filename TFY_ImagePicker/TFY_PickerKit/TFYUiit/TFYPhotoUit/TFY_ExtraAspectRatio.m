//
//  TFY_ExtraAspectRatio.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_ExtraAspectRatio.h"

@implementation TFY_ExtraAspectRatio

+ (instancetype)extraAspectRatioWithWidth:(int)width andHeight:(int)height
{
    return [self extraAspectRatioWithWidth:width andHeight:height andAspectDelimiter:nil autoAspectRatio:TRUE];
}

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height
                          autoAspectRatio:(BOOL)autoAspectRatio
{
    return [self extraAspectRatioWithWidth:width andHeight:height andAspectDelimiter:nil autoAspectRatio:autoAspectRatio];
}

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height
                       andAspectDelimiter:(NSString  * _Nullable)aspectDelimiter
                          autoAspectRatio:(BOOL)autoAspectRatio
{
    return [[self alloc] initWithWidth:width andHeight:height andAspectDelimiter:aspectDelimiter autoAspectRatio:autoAspectRatio];
}

- (instancetype)initWithWidth:(int)width
                    andHeight:(int)height
           andAspectDelimiter:(NSString  * _Nullable)aspectDelimiter
              autoAspectRatio:(BOOL)autoAspectRatio
{
    self = [super init];
    if (self) {
        _picker_aspectWidth = width;
        _picker_aspectHeight = height;
        _picker_aspectDelimiter = aspectDelimiter ?: @"x";
        _autoAspectRatio = autoAspectRatio;
    }
    return self;
}

@end
