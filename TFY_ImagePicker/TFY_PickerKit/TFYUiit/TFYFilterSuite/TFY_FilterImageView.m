//
//  TFY_FilterImageView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_FilterImageView.h"

@implementation TFY_FilterImageView

- (CIImage *)renderedCIImageInRect:(CGRect)rect {
    CIImage *image = [super renderedCIImageInRect:rect];
    if (image != nil) {
        if (_filter != nil) {
            image = [_filter imageByProcessingImage:image atTime:self.CIImageTime];
        }
    }
    return image;
}

- (void)setFilter:(TFY_Filter *)filter {
    _filter = filter;
    [self setNeedsDisplay];
}

@end
