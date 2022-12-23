//
//  TFY_StickerBar.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import "TFY_StickerContent.h"

NS_ASSUME_NONNULL_BEGIN

@class TFY_StickerBar;

extern CGFloat const picker_stickerSize;
extern CGFloat const picker_stickerMargin;

@protocol TFYStickerBarDelegate <NSObject>
- (void)picker_stickerBar:(TFY_StickerBar *)picker_stickerBar didSelectImage:(UIImage *)image;
@end

@interface TFY_StickerBar : UIView
@property (nonatomic, weak) id <TFYStickerBarDelegate> delegate;

/** 缓存数据，可避免下次重新加载时触发的网络处理 */
@property (nonatomic, strong) id cacheResources;

- (instancetype)initWithFrame:(CGRect)frame resources:(NSArray <TFY_StickerContent *>*)resources;

- (instancetype)initWithFrame:(CGRect)frame cacheResources:(id)cacheResources;

@end

NS_ASSUME_NONNULL_END
