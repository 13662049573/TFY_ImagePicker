//
//  TFY_MutableFilter+Initialize.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_MutableFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_MutableFilter ()
/**
 Creates and returns a filter containg the given sub LFFilters.
 */
+ (instancetype)filterWithFilters:(NSArray <TFY_Filter *>*)filters;

@end

NS_ASSUME_NONNULL_END
