//
//  TFY_MEGifView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_MEGifView : UIView
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) NSData *data;

/**
 Whether this instance play gif.
 */
- (void)playGif;
/**
 Whether this instance stop gif.
 */
- (void)stopGif;
@end

NS_ASSUME_NONNULL_END
