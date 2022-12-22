//
//  TFY_PhotoPreviewCell+property.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PhotoPreviewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PhotoPreviewCell ()

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) UIView *imageContainerView;

@property (nonatomic, readonly) UITapGestureRecognizer *tap1;
@property (nonatomic, readonly) UITapGestureRecognizer *tap2;

@property (nonatomic, readwrite) UIImage *previewImage;

@property (nonatomic, assign) BOOL isFinalData;

/** 重置视图 */
- (void)resizeSubviews;
@end

NS_ASSUME_NONNULL_END
