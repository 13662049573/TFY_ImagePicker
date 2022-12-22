//
//  TFY_DataImageView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_DataImageView.h"
#import "TFYItools.h"
#import "TFYCategory.h"
#import "TFY_ConfigTool.h"

@implementation TFY_DataImageView
@synthesize isGif = _isGif;

- (void)picker_dataForImage:(nullable NSData *)data
{
    _isGif = NO;
    if (data) {
        CGImageSourceRef _imgSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
        if (_imgSourceRef) {
            NSUInteger count = CGImageSourceGetCount(_imgSourceRef);
            if (count > 0) {
                _isGif = count > 1;
                CGSize size = self.frame.size;
                UIViewContentMode mode = self.contentMode;
                dispatch_queue_t queue = [TFY_ConfigTool shareInstance].concurrentQueue;
                __weak typeof(self) weakSelf = self;
                dispatch_async(queue, ^{
                    if (weakSelf != nil) {
                        UIImage *image = [data picker_dataDecodedImageWithSize:size mode:mode];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.image = image;
                        });
                    }
                });
            }
            CFRelease(_imgSourceRef);
        }
    } else {
        self.image = nil;
    }
}

- (BOOL)isGif
{
    return _isGif;
}

@end
