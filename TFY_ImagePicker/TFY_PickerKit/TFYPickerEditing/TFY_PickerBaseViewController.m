//
//  TFY_PickerBaseViewController.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PickerBaseViewController.h"
#import "TFYItools.h"
#import <AVFoundation/AVFoundation.h>
#import "TFY_ImagePickerController.h"

@interface TFY_PickerBaseViewController ()

@end

@implementation TFY_PickerBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    [imagePickerVc hideProgressHUD];
}

- (CGFloat)navigationHeight
{
    CGFloat top = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    return top;
}

- (CGRect)viewFrameWithoutNavigation
{
    CGFloat top = [self navigationHeight];
    CGFloat height = self.view.frame.size.height - top;
    
    return CGRectMake(0, top, self.view.frame.size.width, height);
}

- (void)popToViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return self.isHiddenStatusBar;
}

#pragma mark - 权限
- (void)requestAccessForCameraCompletionHandler:(void (^)(void))handler
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            if (handler) {
                                handler();
                            }
                        } else {
                            // 无权限 做一个友好的提示
                            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
                            if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
                            NSString *message = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_audioLibraryAuthorityTipText"],appName];
                            [imagePickerVc showAlertWithTitle:nil cancelTitle:[NSBundle picker_localizedStringForKey:@"_cameraLibraryAuthorityCancelTitle"] message:message complete:^{
                                if (@available(iOS 8.0, *)){
                                    if (@available(iOS 10.0, *)){
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                                    }
                                } else {
                                    NSString *message = [NSBundle picker_localizedStringForKey:@"_PrivacyAuthorityJumpTipText"];
                                    [imagePickerVc showAlertWithTitle:nil message:message complete:nil];
                                }
                            }];
                        }
                    });
                }];
            } else {
                // 无权限 做一个友好的提示
                NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
                if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
                NSString *message = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_cameraLibraryAuthorityTipText"],appName];
                [imagePickerVc showAlertWithTitle:nil cancelTitle:[NSBundle picker_localizedStringForKey:@"_cameraLibraryAuthorityCancelTitle"] message:message complete:^{
                    if (@available(iOS 8.0, *)){
                        if (@available(iOS 10.0, *)){
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                        }
                    } else {
                        NSString *message = [NSBundle picker_localizedStringForKey:@"_PrivacyAuthorityJumpTipText"];
                        [imagePickerVc showAlertWithTitle:nil message:message complete:nil];
                    }
                }];
            }
        });
    }];
}
@end
