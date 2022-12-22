//
//  TFY_PickerAlbumCell.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <UIKit/UIKit.h>

@class TFY_PickerAlbum;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PickerAlbumCell : UITableViewCell

@property (nonatomic, strong) TFY_PickerAlbum *album;
/** 封面 */
@property (nonatomic, setter=setPosterImage:,nullable) UIImage *posterImage;

/** 设置选中图片 */
@property(nonatomic , strong, nullable)UIImage *selectedPickerImage;

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
