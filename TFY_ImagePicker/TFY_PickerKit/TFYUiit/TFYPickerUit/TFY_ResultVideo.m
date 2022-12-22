//
//  TFY_ResultVideo.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_ResultVideo.h"

@implementation TFY_ResultVideo
- (void)setCoverImage:(UIImage *)coverImage
{
    _coverImage = coverImage;
}

- (void)setData:(NSData *)data
{
    _data = data;
}

- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
}

@end
