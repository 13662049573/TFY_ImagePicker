//
//  TFY_StickerItem.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "TFY_PickerText.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_StickerItem : NSObject<NSSecureCoding>

@property (nonatomic, assign, readonly, getter=isMain) BOOL main;

/** image/gif */
@property (nonatomic, strong) UIImage *image;

/** text */
@property (nonatomic, strong) TFY_PickerText *text;

/** video */
@property (nonatomic, strong) AVAsset *asset;

/** display(image/text) */
- (UIImage * __nullable)displayImage;
- (UIImage * __nullable)displayImageAtTime:(NSTimeInterval)time;

/** main view */
+ (instancetype)mainWithImage:(UIImage *)image;
+ (instancetype)mainWithVideo:(AVAsset *)asset;

@end

NS_ASSUME_NONNULL_END
