//
//  TFY_StickerItem+views.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_StickerItem+views.h"
#import "TFY_MEGifView.h"
#import "TFY_MEVideoView.h"

@implementation TFY_StickerItem (views)

- (UIView * __nullable)displayView
{
    if (self.image) {
        TFY_MEGifView *view = [[TFY_MEGifView alloc] initWithFrame:(CGRect){CGPointZero, self.displayImage.size}];
        view.image = self.displayImage;
        return view;
    } else if (self.asset) {
        CGSize videoSize = CGSizeZero;
        NSArray *assetVideoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
        if (assetVideoTracks.count > 0)
        {
            // Insert the tracks in the composition's tracks
            AVAssetTrack *track = [assetVideoTracks firstObject];
            
            CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
            videoSize = CGSizeMake(fabs(dimensions.width), fabs(dimensions.height));
        } else {
            NSLog(@"Error reading the transformed video track");
        }
        if (!CGSizeEqualToSize(CGSizeZero, videoSize)) {
            CGSize size = CGSizeZero;
            size.width = [UIScreen mainScreen].bounds.size.width;
            size.height = size.width*videoSize.height/videoSize.width;
            videoSize = size;
        }
        TFY_MEVideoView *view = [[TFY_MEVideoView alloc] initWithFrame:(CGRect){CGPointZero, videoSize}];
        view.asset = self.asset;
        return view;
    } else if (self.text) {
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.displayImage.size}];
        view.layer.contents = (__bridge id _Nullable)(self.displayImage.CGImage);
        return view;
    }
    NSLog(@"%@ has no displayview available", self);
    return nil;
}


@end
