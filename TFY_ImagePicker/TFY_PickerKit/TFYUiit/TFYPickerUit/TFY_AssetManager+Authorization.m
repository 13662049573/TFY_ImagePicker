//
//  TFY_AssetManager+Authorization.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_AssetManager+Authorization.h"
#import "TFY_ImagePickerPublic.h"

@implementation TFY_AssetManager (Authorization)

- (TFYPhotoAuthorizationStatus)picker_authorizationStatusAndRequestAuthorization:(void(^)(TFYPhotoAuthorizationStatus status))handler
{
    TFYPhotoAuthorizationStatus status = [self picker_authorizationStatus];
    if (status == TFYPhotoAuthorizationStatusNotDetermined) {
        /**
         * 当某些情况下AuthorizationStatus == AuthorizationStatusNotDetermined时，无法弹出系统首次使用的授权alertView，系统应用设置里亦没有相册的设置，此时将无法使用，故作以下操作，弹出系统首次使用的授权alertView
         */
        [self requestAuthorizationWhenNotDetermined:handler];
    }
    return status;
}

- (NSInteger)authorizationStatus {
    if (@available(iOS 14, *)) {
        return [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }
    else if (@available(iOS 8.0, *)){
        return [PHPhotoLibrary authorizationStatus];
    }
    return NO;
}

- (TFYPhotoAuthorizationStatus)picker_authorizationStatus {
    if (@available(iOS 14, *)) {
        return (TFYPhotoAuthorizationStatus)[PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }
    else if (@available(iOS 8.0, *)){
        return (TFYPhotoAuthorizationStatus)[PHPhotoLibrary authorizationStatus];
    }
    return TFYPhotoAuthorizationStatusNotDetermined;
}

//AuthorizationStatus == AuthorizationStatusNotDetermined 时询问授权弹出系统授权alertView
- (void)requestAuthorizationWhenNotDetermined:(void(^)(TFYPhotoAuthorizationStatus status))handler {
    if (@available(iOS 14, *)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                
                picker_dispatch_main_async_safe(^{
                    if (handler) {
                        handler((TFYPhotoAuthorizationStatus)status);
                    }
                });
            }];
        });
    }
    else if (@available(iOS 8.0, *)){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                picker_dispatch_main_async_safe(^{
                    if (handler) {
                        handler((TFYPhotoAuthorizationStatus)status);
                    }
                });
            }];
        });
    }
}

@end
