//
//  TFY_ResultImage.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_ResultImage.h"

@implementation TFY_ResultImage
- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
   _thumbnailImage = thumbnailImage;
}

- (void)setThumbnailData:(NSData *)thumbnailData
{
   _thumbnailData = thumbnailData;
}

- (void)setOriginalImage:(UIImage *)originalImage
{
   _originalImage = originalImage;
}

- (void)setOriginalData:(NSData *)originalData
{
   _originalData = originalData;
}

- (void)setSubMediaType:(TFYImagePickerSubMediaType)subMediaType
{
   _subMediaType = subMediaType;
}

@end
