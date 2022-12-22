//
//  TFY_DataFilterVideoView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_DataFilterVideoView.h"

NSString *const kTFYDataFilterVideoViewData = @"TFYDataFilterVideoViewData";

@implementation TFY_DataFilterVideoView

- (void)setType:(TFYFilterNameType)type
{
    _type = type;
    self.filter = picker_filterWithType(type);
}

#pragma mark  - 数据
- (NSDictionary *)data
{
    if (self.type != TFYFilterNameType_None) {
        return @{kTFYDataFilterVideoViewData:@(self.type)};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    self.type = [data[kTFYDataFilterVideoViewData] integerValue];
}
@end
