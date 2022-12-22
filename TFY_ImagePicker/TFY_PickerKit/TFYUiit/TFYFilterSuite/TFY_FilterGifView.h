//
//  TFY_FilterGifView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_FilterImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_FilterGifView : TFY_FilterImageView
@property (nonatomic, strong, nullable) NSData *gifData;

/**
 Set the CIImage using an animation UIImage(images)
 */
- (void)setImageByUIImage:(UIImage *__nullable)image;
/**
 Set the CIImage using an animation UIImage(images) and durations
 */
- (void)setImageByUIImage:(UIImage *__nullable)image durations:(NSArray <NSNumber *> *__nullable)durations;

/**
 The duration of each frame of gif played.
 */
@property (readonly, nonatomic, nullable) NSArray<NSNumber *> * durations;

/**
 Whether this instance is auto play.
 */
@property (assign, nonatomic) BOOL autoPlay;

/**
 Number of times gif played.
 */
@property (assign, nonatomic) NSUInteger loopCount;

/**
 Whether this instance play gif.
 */
- (void)playGif;
/**
 Whether this instance stop gif.
 */
- (void)stopGif;

/**
 Returns the rendered UIImage(gif) in its natural size.
 Subclass should not override this method.
 */
- (UIImage *__nullable)renderedAnimatedUIImage;
@end

NS_ASSUME_NONNULL_END
