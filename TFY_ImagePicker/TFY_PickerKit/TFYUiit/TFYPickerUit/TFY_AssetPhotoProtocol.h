//
//  TFY_AssetPhotoProtocol.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TFY_AssetPhotoProtocol <NSObject>
@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, strong) UIImage *thumbnailImage;
@end

NS_ASSUME_NONNULL_END
