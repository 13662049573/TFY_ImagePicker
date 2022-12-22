//
//  TFY_DataFilterImageView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_DataFilterImageView.h"

NSString *const kTFYDataFilterImageViewData = @"TFYDataFilterImageViewData";

@implementation TFY_DataFilterImageView

- (void)setType:(TFYFilterNameType)type
{
    _type = type;
    self.filter = picker_filterWithType(type);
}

#pragma mark  - 数据
- (NSDictionary * __nullable)data
{
    if (self.type != TFYFilterNameType_None) {
        return @{kTFYDataFilterImageViewData:@(self.type)};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    self.type = [data[kTFYDataFilterImageViewData] integerValue];
}

@end
