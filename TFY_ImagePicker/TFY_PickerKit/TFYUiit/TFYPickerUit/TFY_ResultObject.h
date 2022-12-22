//
//  TFY_ResultObject.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>
#import "TFY_PickerResultInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ResultObject : NSObject

/** PHAsset or ALAsset 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象 */
@property (nonatomic, readonly) id asset;
/** 详情 */
@property (nonatomic, readonly) TFY_PickerResultInfo *info;
/** 错误 */
@property (nonatomic, readonly) NSError *error;

+ (TFY_ResultObject *)errorResultObject:(id)asset;

@end

NS_ASSUME_NONNULL_END
