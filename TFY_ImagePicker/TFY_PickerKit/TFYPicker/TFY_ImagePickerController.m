//
//  TFY_ImagePickerController.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_ImagePickerController.h"
#import "TFYPickerUit.h"
#import "TFYCategory.h"
#import "TFY_PhotoEdit.h"
#import "TFY_VideoEdit.h"
#import "TFY_PhotoPickerController.h"
#import "TFY_PhotoPickerController+preview.h"
#import "TFY_PhotoPreviewController.h"


@interface TFY_ImagePickerController ()
{
    BOOL _didPushPhotoPickerVc;
}

@property (nonatomic, weak) UIView *tipView;
@property (nonatomic, weak) UIButton *tip_cancelBtn;

/** 预览模式，临时存储 */
@property (nonatomic, strong) TFY_PhotoPreviewController *previewVc;
@property (nonatomic, strong) TFY_PhotoPickerController *photoPickerVc;
@property (nonatomic, assign) BOOL isSystemAsset;

@property (nonatomic, strong) NSMutableArray<TFY_PickerAsset *> *selectedModels;

@property (nonatomic, readonly) BOOL defaultSelectOriginalPhoto;
@end

@implementation TFY_ImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.allowPickingType != TFYPickingMediaTypeNone, @"allowPickingType cann‘t be set to TFYPickingMediaTypeNone.");
    
    self.view.backgroundColor = self.contentBgColor;
    // simple
    [TFY_AssetManager manager].sortAscendingByCreateDate = self.sortAscendingByCreateDate;
    [TFY_AssetManager manager].allowPickingType = self.allowPickingType;
    [TFY_AssetManager manager].autoPlayLivePhoto = self.autoPlayLivePhoto;
    
    TFYPhotoAuthorizationStatus status = [[TFY_AssetManager manager] picker_authorizationStatusAndRequestAuthorization:^(TFYPhotoAuthorizationStatus status) {
        
        BOOL isAuthorized = (status == TFYPhotoAuthorizationStatusLimited || status == TFYPhotoAuthorizationStatusAuthorized);
        
        if (isAuthorized) {
            [self.tipView removeFromSuperview];
            [self pushPhotoPickerVc];
        }
    }];
    
    BOOL isAuthorized = (status == TFYPhotoAuthorizationStatusLimited || status == TFYPhotoAuthorizationStatusAuthorized);
    if (!isAuthorized) {
        
        UIView *tipView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        
        NSString *tipText = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_photoLibraryAuthorityTipText"],appName];
        CGFloat textWidth = self.view.frame.size.width - 16;
        CGSize textSize = [tipText picker_boundingSizeWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) font:self.contentTipsFont];
        
        UILabel *_tipLabel = [[UILabel alloc] init];
        _tipLabel.frame = CGRectMake(8, 120, textWidth, textSize.height);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 0;
        _tipLabel.font = self.contentTipsFont;
        _tipLabel.textColor = self.contentTipsTextColor;
        _tipLabel.text = tipText;
        [tipView addSubview:_tipLabel];
        
        CGSize titleSize = [self.settingBtnTitleStr picker_boundingSizeWithSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX) font:self.contentTipsTitleFont];
        
        UIButton *_settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingBtn.frame = CGRectMake((CGRectGetWidth(self.view.frame)-titleSize.width)/2, CGRectGetMaxY(_tipLabel.frame)+10, titleSize.width, titleSize.height);
        [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
        [_settingBtn setTitleColor:self.contentTipsTitleColorNormal forState:UIControlStateNormal];
        [_settingBtn setTitleColor:[self.contentTipsTitleColorNormal colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateHighlighted];
        _settingBtn.titleLabel.font = self.contentTipsTitleFont;
        [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [tipView addSubview:_settingBtn];
        
        CGFloat naviBarHeight = CGRectGetHeight(self.navigationBar.frame);
        
        CGFloat cancelWidth = [self.cancelBtnTitleStr picker_boundingSizeWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.barItemTextFont].width + 2 + 32;
        
        UIButton *_cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(self.view.frame.size.width-cancelWidth, 0, cancelWidth, naviBarHeight);
        [_cancelBtn setTitle:self.cancelBtnTitleStr forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:self.barItemTextColor forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[self.barItemTextColor colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateHighlighted];
        _cancelBtn.titleLabel.font = self.barItemTextFont;
        [_cancelBtn addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [tipView addSubview:_cancelBtn];
        _tip_cancelBtn = _cancelBtn;
        
        [self.view addSubview:tipView];
        _tipView = tipView;
    } else {
        [self pushPhotoPickerVc];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_tip_cancelBtn) {
        CGFloat naviBarHeight = 0, naviSubBarHeight = 0;;
        naviBarHeight = naviSubBarHeight = CGRectGetHeight(self.navigationBar.frame);
        if (@available(iOS 11.0, *)) {
            naviBarHeight += self.view.safeAreaInsets.top;
        } else {
            naviBarHeight += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        }
        CGRect frame = _tip_cancelBtn.frame;
        frame.origin.y = naviBarHeight-naviSubBarHeight;
        frame.size.height = naviSubBarHeight;
        _tip_cancelBtn.frame = frame;
    }
}

- (void)dealloc
{
    /** 清空单例 */
    [TFY_AssetManager free];
    [TFY_PhotoEditManager free];
    [TFY_VideoEditManager free];
}

- (instancetype)initWithMaxImagesCount:(NSUInteger)maxImagesCount delegate:(id<TFYImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate];
}

- (instancetype)initWithMaxImagesCount:(NSUInteger)maxImagesCount columnNumber:(NSUInteger)columnNumber delegate:(id<TFYImagePickerControllerDelegate>)delegate {
    
    self = [super init];
    if (self) {
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        [self defaultConfig];
        if (maxImagesCount > 0) self.maxImagesCount = maxImagesCount; // Default is 9 / 默认最大可选9张图片
        self.maxVideosCount = self.maxImagesCount;
        self.pickerDelegate = delegate;
        
        self.columnNumber = columnNumber;
    }
    return self;
}

- (instancetype)initWithSelectedAssets:(NSArray /**<PHAsset *>*/*)selectedAssets index:(NSUInteger)index
{
    NSAssert(selectedAssets.count > index, @"index 0 beyond bounds for selectedAssets count.");
    self = [super init];
    if (self) {
        [self defaultConfig];
        _isSystemAsset = YES;
        _isPreview = YES;
        NSMutableArray *models = [NSMutableArray array];
        for (id asset in selectedAssets) {
            TFY_PickerAsset *model = [[TFY_PickerAsset alloc] initWithAsset:asset];
            if (model.subType == TFYAssetSubMediaTypeLivePhoto) {
                model.closeLivePhoto = !self.autoPlayLivePhoto;
            }
            [models addObject:model];
        }
        _previewVc = [[TFY_PhotoPreviewController alloc] initWithPhotos:models index:index];
    }
    return self;
}

- (instancetype)initWithSelectedImageObjects:(NSArray <id<TFY_AssetImageProtocol>>*)selectedPhotos index:(NSUInteger)index complete:(void (^)(NSArray <id<TFY_AssetImageProtocol>>* photos))complete
{
    NSAssert(selectedPhotos.count > index, @"index 0 beyond bounds for selectedPhotos count.");
    self = [super init];
    if (self) {
        [self defaultConfig];
        _isPreview = YES;
        /** 关闭原图选项 */
        _allowPickingOriginalPhoto = NO;
        
        NSMutableArray *models = [NSMutableArray array];
        for (id<TFY_AssetImageProtocol> asset in selectedPhotos) {
            TFY_PickerAsset *model = [[TFY_PickerAsset alloc] initWithObject:asset];
            [models addObject:model];
        }

        __weak typeof(self) weakSelf = self;
        _previewVc = [[TFY_PhotoPreviewController alloc] initWithPhotos:models index:index];
        
        [_previewVc setDoneButtonClickBlock:^{
            
            [weakSelf showProgressHUD];
            
            dispatch_globalQueue_async_safe(^{
                NSMutableArray *photos = [@[] mutableCopy];
                for (TFY_PickerAsset *model in weakSelf.selectedModels) {
                    if (model.type == TFYAssetMediaTypePhoto) {
                        TFY_PhotoEdit *photoEdit = [[TFY_PhotoEditManager manager] photoEditForAsset:model];
                        if (photoEdit.editPreviewImage) {
                            if ([model.asset conformsToProtocol:@protocol(TFY_AssetImageProtocol)]) {
                                ((id<TFY_AssetImageProtocol>)model.asset).assetImage = photoEdit.editPreviewImage;
                            }
                            [photos addObject:model.asset];
                        } else {
                            if (model.previewImage) {
                                [photos addObject:model.asset];
                            }
                        }
                    }
                }
                picker_dispatch_main_async_safe(^{
                    [weakSelf hideProgressHUD];
                    if (weakSelf.autoDismiss) {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            if (complete) complete(photos);
                        }];
                    } else {
                        if (complete) complete(photos);
                    }
                });
            });
        }];

    }
    return self;
}

- (instancetype)initWithSelectedPhotoObjects:(NSArray <id/* <TFY_AssetPhotoProtocol/TFY_AssetVideoProtocol> */>*)selectedPhotos complete:(void (^)(NSArray <id/* <TFY_AssetPhotoProtocol/TFY_AssetVideoProtocol> */>* photos))complete
{
    self = [super init];
    if (self) {
        [self defaultConfig];
        _isPreview = YES;
        /** 关闭原图选项 */
        _allowPickingOriginalPhoto = NO;
        
        NSMutableArray *models = [NSMutableArray array];
        for (id asset in selectedPhotos) {
            TFY_PickerAsset *model = [[TFY_PickerAsset alloc] initWithObject:asset];
            [models addObject:model];
        }
        
        __weak typeof(self) weakSelf = self;
        _photoPickerVc = [[TFY_PhotoPickerController alloc] initWithPhotos:models completeBlock:^{
            [weakSelf showProgressHUD];
            
            dispatch_globalQueue_async_safe(^{
                NSMutableArray *photos = [@[] mutableCopy];
                for (TFY_PickerAsset *model in weakSelf.selectedModels) {
                    if (model.type == TFYAssetMediaTypePhoto) {
                        TFY_PhotoEdit *photoEdit = [[TFY_PhotoEditManager manager] photoEditForAsset:model];
                        if (photoEdit.editPreviewImage) {
                            if ([model.asset conformsToProtocol:@protocol(TFY_AssetPhotoProtocol)]) {
                                ((id<TFY_AssetPhotoProtocol>)model.asset).thumbnailImage = photoEdit.editPosterImage;
                                ((id<TFY_AssetPhotoProtocol>)model.asset).originalImage = photoEdit.editPreviewImage;
                            }
                            [photos addObject:model.asset];
                        } else {
                            if (model.previewImage) {
                                [photos addObject:model.asset];
                            }
                        }
                    } else if (model.type == TFYAssetMediaTypeVideo) {
                        TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:model];
                        if (videoEdit.editFinalURL) {
                            if ([model.asset conformsToProtocol:@protocol(TFY_AssetVideoProtocol)]) {
                                ((id<TFY_AssetVideoProtocol>)model.asset).thumbnailImage = videoEdit.editPosterImage;
                                ((id<TFY_AssetVideoProtocol>)model.asset).videoUrl = videoEdit.editFinalURL;
                            }
                            [photos addObject:model.asset];
                        } else {
                            if (model.previewVideoUrl) {
                                [photos addObject:model.asset];
                            }
                        }
                    }
                }
                picker_dispatch_main_async_safe(^{
                    [weakSelf hideProgressHUD];
                    if (weakSelf.autoDismiss) {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            if (complete) complete(photos);
                        }];
                    } else {
                        if (complete) complete(photos);
                    }
                });
            });
        }];
        
    }
    return self;
}

- (void)defaultConfig
{
    _selectedModels = [NSMutableArray array];
    self.columnNumber = 4;
    self.maxImagesCount = 9;
    self.maxVideosCount = self.maxImagesCount;
    self.minImagesCount = 0;
    self.minVideosCount = self.minImagesCount;
    self.autoSelectCurrentImage = YES;
    self.allowPickingOriginalPhoto = YES;
    self.allowPickingType = TFYPickingMediaTypePhoto | TFYPickingMediaTypeVideo;
    self.allowTakePicture = YES;
    self.allowPreview = YES;
    self.allowEditing = YES;
    self.sortAscendingByCreateDate = YES;
    self.autoVideoCache = YES;
    self.autoDismiss = YES;
    self.supportAutorotate = NO;
    self.imageCompressSize = kCompressSize;
    self.thumbnailCompressSize = kThumbnailCompressSize;
    self.maxPhotoBytes = kMaxPhotoBytes;
    self.videoCompressPresetName = AVAssetExportPreset1280x720;
    self.maxVideoDuration = kMaxVideoDurationze;
    self.autoSavePhotoAlbum = YES;
    self.displayImageFilename = NO;
    self.syncAlbum = YES;
    self.autoPlayLivePhoto = YES;
}


- (void)observeAuthrizationStatusChange {
    TFYPhotoAuthorizationStatus status = [[TFY_AssetManager manager] picker_authorizationStatus];
    BOOL isAuthorized = (status == TFYPhotoAuthorizationStatusLimited || status == TFYPhotoAuthorizationStatusAuthorized);
    if (isAuthorized) {
        [_tipView removeFromSuperview];
        [self pushPhotoPickerVc];
    }
}

- (void)pushPhotoPickerVc {
    if (!_didPushPhotoPickerVc) {
        _didPushPhotoPickerVc = NO;
        
        TFY_PhotoPickerController *photoPickerVc = nil;
        if (self.photoPickerVc) {
            photoPickerVc = self.photoPickerVc;
        } else {
            photoPickerVc = [[TFY_PhotoPickerController alloc] init];
        }
        
        if (self.previewVc) {
            if (self.isSystemAsset) {
                // 系统相册解析
                [self setViewControllers:@[photoPickerVc] animated:NO];
                [photoPickerVc pushPhotoPrevireViewController:self.previewVc];
            } else {
                // 自定义block解析
                [self setViewControllers:@[photoPickerVc, self.previewVc] animated:YES];
            }
        } else {
            [self setViewControllers:@[photoPickerVc] animated:YES];
        }
        
        self.photoPickerVc = nil;
        self.previewVc = nil;

        _didPushPhotoPickerVc = YES;
    }
}

- (void)setColumnNumber:(NSUInteger)columnNumber {
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
}

- (void)setSelectedAssets:(NSArray /**<PHAsset/ALAsset/id<LFAssetImageProtocol> *>*/*)selectedAssets {
    
    if (!self.viewControllers.count) {
        /** 已经显示UI，不接受入参 */
        _selectedAssets = selectedAssets;
    }
}

- (NSArray<TFY_PickerAsset *> *)selectedObjects
{
    return [self.selectedModels copy];
}

- (void)setIsSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    if (!self.viewControllers.count) {
        /** 已经显示UI，不接受入参 */
        _defaultSelectOriginalPhoto = isSelectOriginalPhoto;
    }
}

- (void)settingBtnClick {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
        [self cancelButtonClickAnimated:NO];
    } else {
        NSString *message = [NSBundle picker_localizedStringForKey:@"_PrivacyAuthorityJumpTipText"];
        __weak typeof(self) weakSelf = self;
        [self showAlertWithTitle:[NSBundle picker_localizedStringForKey:@"_PrivacyAuthorityJumpCancelTitle"] message:message complete:^{
            [weakSelf cancelButtonClick];
        }];
    }
}

- (void)cancelButtonClickAnimated:(BOOL)animated {
    if (self.autoDismiss) {
        [self dismissViewControllerAnimated:animated completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self callDelegateMethod];
    }
}

#pragma mark - Public

- (void)cancelButtonClick {
    [self cancelButtonClickAnimated:YES];
}

- (void)callDelegateMethod {
    if ([self.pickerDelegate respondsToSelector:@selector(picker_imagePickerControllerDidCancel:)]) {
        [self.pickerDelegate picker_imagePickerControllerDidCancel:self];
    } else if (self.imagePickerControllerDidCancelHandle) {
        self.imagePickerControllerDidCancelHandle();
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    /**
     弹出的 UIAlertController 在销毁时也触发了 dismissViewControllerAnimated:completion
     防止弹出的Controller 调用 self.presentingViewController 来销毁，这里判断没有presentedViewController来解决。
     */
    if ([self presentedViewController] == nil) {
        for (UIViewController *childVC in self.childViewControllers) {
            if ([childVC respondsToSelector:@selector(viewDidDealloc)]) {
                [childVC performSelector:@selector(viewDidDealloc)];
            }
        }
    }
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)viewDidDealloc
{
    /** childViewControllers重写释放持有 */
}

/** 横屏 */
- (BOOL)shouldAutorotate
{
    return self.supportAutorotate ? [self.visibleViewController shouldAutorotate] : NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([self.visibleViewController isKindOfClass:[TFY_PickerBaseViewController class]]) {
        return self.supportAutorotate ? [self.visibleViewController supportedInterfaceOrientations] : UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}


@end
