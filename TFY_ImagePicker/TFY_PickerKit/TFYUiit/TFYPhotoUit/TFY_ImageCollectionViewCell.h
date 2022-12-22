//
//  TFY_ImageCollectionViewCell.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_BaseCollectionViewCell.h"
#import "TFY_MEGifView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TFY_ImageCollectionViewCell : TFY_BaseCollectionViewCell
@property (readonly, nonatomic, nonnull) UIImage *image;

- (void)setCellData:(nullable id)data;

- (void)showMaskLayer:(BOOL)isShow;

- (void)resetForDownloadFail;
@end

NS_ASSUME_NONNULL_END
