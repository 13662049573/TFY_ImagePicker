//
//  TFY_DataImageView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_DataImageView : UIImageView
- (void)picker_dataForImage:(nullable NSData *)data;
@property (nonatomic, readonly) BOOL isGif;
@end

NS_ASSUME_NONNULL_END
