//
//  TFY_ImagePickerPublic.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_ImagePickerPublic.h"

BOOL picker_isPiiic(CGSize imageSize)
{
    // 高度超出屏幕高度
    static CGFloat width = 0;
    if (width == 0) {
        width = [UIScreen mainScreen].bounds.size.width*[UIScreen mainScreen].scale;
    }
    static CGFloat height = 0;
    if (height == 0) {
        height = [UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale;
    }
    if (imageSize.height > height) {
        // 宽度大于屏幕宽度
        if (imageSize.width > width) {
            // 先比例缩放为屏幕大小的高度
            CGFloat height = width * imageSize.height / imageSize.width;
            
            return height > MAX(height, width);
        }
        return YES;
    }
    // 宽度小于高度的5倍
    return imageSize.width * 5 < imageSize.height;
}

BOOL picker_isHor(CGSize imageSize)
{
    static CGFloat width = 0;
    if (width == 0) {
        width = [UIScreen mainScreen].bounds.size.width*[UIScreen mainScreen].scale;
    }
    static CGFloat height = 0;
    if (height == 0) {
        height = [UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale/2;
    }
    if (imageSize.width > width) {
        if (imageSize.height > height) {
            CGFloat width = height * imageSize.width / imageSize.height;
            return width > MAX(height, width);
        }
        return YES;
    }
    return imageSize.width > imageSize.height * 5;
}


/** 标清图压缩大小 */
float const kCompressSize = 100.f;
/** 缩略图压缩大小 */
float const kThumbnailCompressSize = 10.f;
/** 图片最大大小 */
float const kMaxPhotoBytes = 6*1024*1024.f;
/** 视频最大时长 */
float const kMaxVideoDurationze = 5*60.f;
/** UIControlStateHighlighted 高亮透明度 */
float const kControlStateHighlightedAlpha = 0.5f;



