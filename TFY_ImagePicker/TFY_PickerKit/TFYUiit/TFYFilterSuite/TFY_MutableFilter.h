//
//  TFY_MutableFilter.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Filter.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_MutableFilter : TFY_Filter
/**
 Contains every added sub filters.
 */
@property (readonly, nonatomic) NSArray <TFY_Filter *>*__nonnull subFilters;

/**
 Add a sub filter. When processing an image, this TFY_Filter instance will first process the
 image using its attached CIFilter, then it will ask every sub filters added to process the
 given image.
 */
- (void)addSubFilter:(TFY_Filter *__nonnull)subFilter;

/**
 Remove a sub filter.
 */
- (void)removeSubFilter:(TFY_Filter *__nonnull)subFilter;

/**
 Remove a sub filter at a given index.
 */
- (void)removeSubFilterAtIndex:(NSUInteger)index;

/**
 Insert a sub filter at a given index.
 */
- (void)insertSubFilter:(TFY_Filter *__nonnull)subFilter atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
