//
//  TFY_ContextImageView+private.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_ContextImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ContextImageView ()
- (void)commonInit;
- (UIImage *)renderedUIImageInCIImage:(CIImage * __nullable)image;
@end

NS_ASSUME_NONNULL_END
