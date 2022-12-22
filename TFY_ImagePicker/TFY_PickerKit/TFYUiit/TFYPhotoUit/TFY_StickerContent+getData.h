//
//  TFY_StickerContent+getData.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_StickerContent.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TFY_StickerContent (getData)

- (void)picker_getData:(nullable void(^)(NSData * _Nullable data))completeBlock;

- (void)picker_getImage:(nullable void(^)(UIImage * _Nullable image, BOOL isDegraded))completeBlock;

- (void)picker_getImageAndData:(nullable void(^)(NSData * _Nullable data, UIImage * _Nullable image))completeBlock;

@end

NS_ASSUME_NONNULL_END
