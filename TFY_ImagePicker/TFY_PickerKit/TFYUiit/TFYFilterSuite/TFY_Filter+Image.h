//
//  TFY_Filter+Image.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Filter.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_Filter (Image)
/**
 Returns a UIImage by processing this filter into the given UIImage
 */
- (UIImage *__nullable)UIImageByProcessingUIImage:(UIImage *__nullable)image atTime:(CFTimeInterval)time;

/**
 Returns a UIImage by processing this filter into the given UIImage
 */
- (UIImage *__nullable)UIImageByProcessingUIImage:(UIImage *__nullable)image;

/**
 Returns a UIImage by processing this filter into the given animated UIImage
 */
- (UIImage *__nullable)UIImageByProcessingAnimatedUIImage:(UIImage *__nullable)image;

@end

NS_ASSUME_NONNULL_END
