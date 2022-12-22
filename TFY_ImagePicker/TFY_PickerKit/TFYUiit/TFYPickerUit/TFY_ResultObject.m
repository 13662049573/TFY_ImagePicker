//
//  TFY_ResultObject.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_ResultObject.h"

@implementation TFY_ResultObject

- (void)setAsset:(id)asset
{
    _asset = asset;
}

- (void)setInfo:(TFY_PickerResultInfo *)info
{
    _info = info;
}

- (void)setError:(NSError *)error
{
    _error = error;
}

+ (TFY_ResultObject *)errorResultObject:(id)asset
{
    TFY_ResultObject *object = [[TFY_ResultObject alloc] init];
    object.asset = asset;
    object.error = [NSError errorWithDomain:@"asset error" code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Asset:%@ cannot extract data", asset]}];
    return object;
}


@end
