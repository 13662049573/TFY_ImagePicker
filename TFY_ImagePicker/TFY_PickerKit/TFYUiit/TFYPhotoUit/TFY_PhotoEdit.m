//
//  TFY_PhotoEdit.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_PhotoEdit.h"
#import "TFYCategory.h"
#import <UIKit/UIKit.h>

@implementation TFY_PhotoEdit

/** 初始化 */
- (instancetype)initWithEditImage:(UIImage *)image previewImage:(UIImage *)previewImage data:(NSDictionary *)data
{
    return [self initWithEditImage:image previewImage:previewImage durations:nil data:data];
}

- (instancetype)initWithEditImage:(UIImage *)image previewImage:(UIImage *)previewImage durations:(NSArray<NSNumber *> * __nullable)durations data:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        [self setEditingImage:previewImage durations:durations];
        _editImage = image;
        _editData = data;
    }
    return self;
}

#pragma mark - private
- (void)setEditingImage:(UIImage *)editPreviewImage durations:(NSArray<NSNumber *> *)durations
{
    _editPreviewImage = editPreviewImage;
    _durations = durations;
    /** 设置编辑封面 */
    CGFloat width = MIN(80.f * 2.f, MIN(editPreviewImage.size.width, editPreviewImage.size.height));
    CGSize size = [UIImage picker_scaleImageSizeBySize:editPreviewImage.size targetSize:CGSizeMake(width, width) isBoth:YES];
    NSData *editPreviewData = nil;
    if (editPreviewImage.images.count) {
        _editPosterImage = [editPreviewImage.images.firstObject picker_scaleToFitSize:size];
        if (durations && durations.count == editPreviewImage.images.count) {
            editPreviewData = picker_UIImageGIFRepresentation(editPreviewImage, durations, 0, nil);
        } else {
            editPreviewData = picker_UIImageGIFRepresentation(editPreviewImage);
        }
    } else {
        _editPosterImage = [editPreviewImage picker_scaleToFitSize:size];
        editPreviewData = picker_UIImageJPEGRepresentation(editPreviewImage);
    }
    _editPreviewData = editPreviewData;
}


@end
