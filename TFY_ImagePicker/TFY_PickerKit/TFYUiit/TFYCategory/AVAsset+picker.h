//
//  AVAsset+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (picker)

- (UIImage *)picker_firstImage:(NSError **)error;
- (UIImage *)picker_firstImageWithSize:(CGSize)size error:(NSError **)error;
- (CGSize)picker_videoNaturalSize;

@end

NS_ASSUME_NONNULL_END
