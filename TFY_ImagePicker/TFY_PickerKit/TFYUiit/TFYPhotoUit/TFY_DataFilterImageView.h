//
//  TFY_DataFilterImageView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_FilterGifView.h"
#import "TFY_FilterDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_DataFilterImageView : TFY_FilterGifView<TFY_FilterDataProtocol>
@property (nonatomic, assign) TFYFilterNameType type;
/** 数据 */
@property (nonatomic, strong, nullable) NSDictionary *data;
@end

NS_ASSUME_NONNULL_END
