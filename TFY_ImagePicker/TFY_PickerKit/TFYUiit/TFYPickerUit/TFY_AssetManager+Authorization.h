//
//  TFY_AssetManager+Authorization.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_AssetManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TFYPhotoAuthorizationStatus) {
    /** 未询问过的 */
    TFYPhotoAuthorizationStatusNotDetermined = 0,
    /** 被限制的 */
    TFYPhotoAuthorizationStatusRestricted,
    /** 拒绝的 */
    TFYPhotoAuthorizationStatusDenied,
    /** 允许访问所有 */
    TFYPhotoAuthorizationStatusAuthorized,
    /** 允许访问部分 */
    TFYPhotoAuthorizationStatusLimited
};

@interface TFY_AssetManager (Authorization)

- (TFYPhotoAuthorizationStatus)picker_authorizationStatusAndRequestAuthorization:(void(^)(TFYPhotoAuthorizationStatus status))handler;
- (TFYPhotoAuthorizationStatus)picker_authorizationStatus;

@end

NS_ASSUME_NONNULL_END
