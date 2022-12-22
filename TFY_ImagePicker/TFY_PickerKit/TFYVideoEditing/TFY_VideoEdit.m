//
//  TFY_VideoEdit.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_VideoEdit.h"
#import <AVFoundation/AVFoundation.h>
#import "TFYUiit.h"

@implementation TFY_VideoEdit

- (instancetype)initWithEditAsset:(AVAsset *)editAsset editFinalURL:(NSURL *)editFinalURL data:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _editAsset = editAsset;
        _editFinalURL = editFinalURL;
        _editData = data;
        [self createfirstImage];
    }
    return self;
}

- (void)createfirstImage
{
    AVAsset *asset = nil;
    if (self.editFinalURL) {
        asset = [[AVURLAsset alloc] initWithURL:self.editFinalURL options:nil];
    } else {
        asset = self.editAsset;
    }
    _duration = CMTimeGetSeconds(asset.duration);
    _editPreviewImage = [asset picker_firstImage:nil];
    CGFloat width = 80.f * 2.f;
    CGSize size = [UIImage picker_scaleImageSizeBySize:_editPreviewImage.size targetSize:CGSizeMake(width, width) isBoth:YES];
    _editPosterImage = [_editPreviewImage picker_scaleToFitSize:size];
}

@end
