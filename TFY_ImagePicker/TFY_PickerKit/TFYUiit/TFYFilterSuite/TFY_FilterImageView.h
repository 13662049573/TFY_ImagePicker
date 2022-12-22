//
//  TFY_FilterImageView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_ContextImageView.h"
#import "TFY_Filter.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_FilterImageView : TFY_ContextImageView
/**
 The filter to apply when rendering. If nil is set, no filter will be applied
 */
@property (strong, nonatomic) TFY_Filter *__nullable filter;

@end

NS_ASSUME_NONNULL_END
