//
//  TFY_PhotoPickerController.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PhotoPickerController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "TFY_ImagePickerController.h"
#import "TFY_ImagePickerController+property.h"
#import "TFY_PhotoPreviewController.h"
#import "TFYPickerUit.h"
#import "TFYPhotoUit.h"
#import "TFYItools.h"

CGFloat const bottomToolBarHeight = 50.f;

@interface TFY_CollectionView : UICollectionView
/** 记录屏幕旋转前的数据 */
@property (nonatomic, assign) CGPoint oldContentOffset;
@property (nonatomic, assign) CGSize oldContentSize;
@property (nonatomic, assign) CGRect oldCollectionViewRect;
@end

@implementation TFY_CollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ( [view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end

@interface TFY_PhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, TFYPhotoPreviewControllerPullDelegate, UIViewControllerPreviewingDelegate, PHPhotoLibraryChangeObserver, UIAdaptivePresentationControllerDelegate>
{
    
    UIView *_bottomSubToolBar;
    UIButton *_editButton;
    UIButton *_previewButton;
    UIButton *_doneButton;
    
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    
}
@property (nonatomic, weak) UIView *nonePhotoView;
@property (nonatomic, weak) TFY_CollectionView *collectionView;
@property (nonatomic, weak) UIView *bottomToolBar;

@property (nonatomic, weak) TFY_PickerAlbumTitleView *titleView;

@property (nonatomic, strong) NSMutableArray <TFY_PickerAlbum *>*albumArr;
@property (nonatomic, strong) NSMutableArray <TFY_PickerAsset *>*models;

@property (nonatomic, assign) BOOL isPhotoPreview;
@property (nonatomic, copy) void (^doneButtonClickBlock)(void);

/** 加载动画延时 */
@property (nonatomic, assign) float animtionDelayTime;
/** 记录动画次数 */
@property (nonatomic, assign) int animtionTimes;
/** 记录动画完成次数 */
@property (nonatomic, assign) int animtionFinishTimes;


@end

@implementation TFY_PhotoPickerController

/** 图片预览模式 */
- (instancetype)initWithPhotos:(NSArray <TFY_PickerAsset *>*)photos completeBlock:(void (^)(void))completeBlock
{
    self = [super init];
    if (self) {
        _isPhotoPreview = YES;
        _models = [NSMutableArray arrayWithArray:photos];
        _doneButtonClickBlock = completeBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    self.view.backgroundColor = imagePickerVc.contentBgColor;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:imagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
#pragma clang diagnostic pop
    
    if (!imagePickerVc.isPreview) { /** 非预览模式 */
        [imagePickerVc showProgressHUD];
        
        __weak typeof(self) weakSelf = self;
        dispatch_globalQueue_async_safe(^{
            
            long long start = [[NSDate date] timeIntervalSince1970] * 1000;
            void (^initDataHandle)(void) = ^{
                
                [weakSelf loadAlbumData:^{
                    picker_dispatch_main_async_safe(^{
                        [weakSelf checkDefaultSelectedModels];
                        long long end = [[NSDate date] timeIntervalSince1970] * 1000;
                        NSLog(@"%lu Photo loading time-consuming: %lld milliseconds", (unsigned long)self.models.count, end - start);
                        [weakSelf initSubviews];
                    });
                }];
            };
            
            if (self.model == nil) { /** 没有指定相册，默认显示相片胶卷 */
                
                [[TFY_AssetManager manager] getAllAlbums:^(NSArray<TFY_PickerAlbum *> *models) {
                    
                    if (imagePickerVc.defaultAlbumName) {
                        for (TFY_PickerAlbum *album in models) {
                            if (album.count) {
                                if ([[imagePickerVc.defaultAlbumName lowercaseString] isEqualToString:[album.name lowercaseString]]) {
                                    weakSelf.model = album;
                                    break;
                                }
                            }
                        }
                    } else {
                        weakSelf.model = models.firstObject;
                    }
                    weakSelf.albumArr = [NSMutableArray arrayWithArray:models];
                    
                    long long end = [[NSDate date] timeIntervalSince1970] * 1000;
                    NSLog(@"Loading all album time-consuming: %lld milliseconds", end - start);
                    initDataHandle();
                    
                }];
            } else { /** 已存在相册数据 */
                initDataHandle();
            }
        });
        
        if (imagePickerVc.syncAlbum) {
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];    //创建监听者
        }
    } else if (self.isPhotoPreview) {
        [self checkDefaultSelectedModels];
        [self initSubviews];
    }
    
}

- (void)loadAlbumData:(void (^)(void))complete
{
    if (complete == nil) return;
    
    if (self.model) {
        if (self.model.models.count) { /** 使用缓存数据 */
            self.models = [NSMutableArray arrayWithArray:self.model.models];
            complete();
        } else {
            [[TFY_AssetManager manager] getAssetsFromFetchResult:self.model.result fetchLimit:0 completion:^(NSArray<TFY_PickerAsset *> *models) {
                /** 缓存数据 */
                self.model.models = models;
                self.models = [NSMutableArray arrayWithArray:models];
                complete();
            }];
        }
    } else {
        complete();
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat toolbarHeight = bottomToolBarHeight;
    if (@available(iOS 11.0, *)) {
        toolbarHeight += self.view.safeAreaInsets.bottom;
    }
    
    CGRect collectionViewRect = [self viewFrameWithoutNavigation];
    collectionViewRect.size.height -= toolbarHeight;
    if (@available(iOS 11.0, *)) {
        collectionViewRect.origin.x += self.view.safeAreaInsets.left;
        collectionViewRect.size.width -= self.view.safeAreaInsets.left + self.view.safeAreaInsets.right;
    }
    _collectionView.frame = collectionViewRect;
    
    /* 适配底部栏 */
    CGFloat yOffset = self.view.frame.size.height - toolbarHeight;
    _bottomToolBar.frame = CGRectMake(0, yOffset, self.view.frame.size.width, toolbarHeight);
    
    CGRect bottomToolbarRect = _bottomToolBar.bounds;
    if (@available(iOS 11.0, *)) {
        bottomToolbarRect.origin.x += self.view.safeAreaInsets.left;
        bottomToolbarRect.size.width -= self.view.safeAreaInsets.left + self.view.safeAreaInsets.right;
    }
    _bottomSubToolBar.frame = bottomToolbarRect;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (@available(iOS 13.0, *)) {
        TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
        if (imagePickerVc.modalPresentationStyle == UIModalPresentationPageSheet) {
            imagePickerVc.presentationController.delegate = self;
            // 手动接收dismiss
            self.modalInPresentation = YES;
        }
    }
}

- (void)viewDidDealloc
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    if (imagePickerVc.syncAlbum) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];    //移除监听者
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)initSubviews {
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    if (!imagePickerVc.isPreview) {
        if (imagePickerVc.defaultAlbumName && !_model) {
            [imagePickerVc showAlertWithTitle:[NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_noDefaultAlbumName"], imagePickerVc.defaultAlbumName]];
        }
    }
    
    if (self.model) {
        /** 创建titleView */
        NSInteger index = [self.albumArr indexOfObject:self.model];
        TFY_PickerAlbumTitleView *titleView = [[TFY_PickerAlbumTitleView alloc] initWithContentViewController:self index:index];
        titleView.albumArr = self.albumArr;
        titleView.selectImageName = imagePickerVc.ablumSelImageName;
        titleView.title = imagePickerVc.defaultAlbumName;
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(imagePickerVc) weakImagePickerVc = imagePickerVc;
        titleView.didSelected = ^(TFY_PickerAlbum * _Nonnull album, NSInteger index) {
            if (![weakSelf.model isEqual:album]) {
                weakSelf.model = album;
                [weakSelf loadAlbumData:^{
                    weakSelf.animtionDelayTime = 0.015;
                    [weakSelf.collectionView reloadData];
                    [weakSelf scrollCollectionViewToBottom];
                    if (weakSelf.models.count == 0 && !weakImagePickerVc.allowTakePicture) {
                        // 添加没有图片的提示
                        [weakSelf configNonePhotoView];
                    } else {
                        [weakSelf removeNonePhotoView];
                    }
                }];
            }
        };
        self.navigationItem.titleView = titleView;
        _titleView = titleView;
    }
    
    [imagePickerVc hideProgressHUD];
    
    
    [self configCollectionView];
    [self configBottomToolBar];
    [self scrollCollectionViewToBottom];
    
    if (_models.count == 0 && !imagePickerVc.allowTakePicture) {
        // 添加没有图片的提示
        [self configNonePhotoView];
    } else {
        [self removeNonePhotoView];
    }
    
    // 监听屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)configNonePhotoView {
    
    if (_nonePhotoView) {
        return;
    }
    
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    CGRect frame = [self viewFrameWithoutNavigation];
    frame.size.height -= _bottomToolBar.frame.size.height;
    
    UIView *nonePhotoView = [[UIView alloc] initWithFrame:frame];
    nonePhotoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    nonePhotoView.backgroundColor = [UIColor clearColor];
    
    NSString *text = [NSBundle picker_localizedStringForKey:@"_LFPhotoPickerController_noMediaTipText"];
    if (imagePickerVc.allowPickingType == TFYPickingMediaTypeVideo) { // only video
        text = [NSBundle picker_localizedStringForKey:@"_LFPhotoPickerController_noVideoTipText"];
    } else if (imagePickerVc.allowPickingType > 0 && !(imagePickerVc.allowPickingType & TFYPickingMediaTypeVideo)) { // only photo
        text = [NSBundle picker_localizedStringForKey:@"_LFPhotoPickerController_noPhotoTipText"];
    }
    
    CGFloat textWidth = nonePhotoView.bounds.size.width - 20*2;
    CGSize textSize = [text picker_boundingSizeWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) font:imagePickerVc.contentTipsFont];
    textSize.height += 10;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(nonePhotoView.frame)-textWidth)/2, (CGRectGetHeight(nonePhotoView.frame)-textSize.height)/2, textWidth, textSize.height)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = imagePickerVc.contentTipsFont;
    label.text = text;
    label.textColor = imagePickerVc.contentTipsTextColor;
    
    [nonePhotoView addSubview:label];
    
    TFYPhotoAuthorizationStatus status = [[TFY_AssetManager manager] picker_authorizationStatus];
    if (status == TFYPhotoAuthorizationStatusLimited) {
        NSString *title = [NSBundle picker_localizedStringForKey:@"_LFPhotoPickerController_buttonTipTitle"];
        CGSize textSize = [title picker_boundingSizeWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) font:imagePickerVc.contentTipsTitleFont];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, textSize.width, textSize.height);
        button.center = CGPointMake(label.center.x, label.center.y + label.bounds.size.height + 5);
        button.titleLabel.font = imagePickerVc.contentTipsTitleFont;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:imagePickerVc.contentTipsTitleColorNormal forState:UIControlStateNormal];
        [button setTitleColor:[imagePickerVc.contentTipsTitleColorNormal colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(changedPhotoLimited) forControlEvents:UIControlEventTouchUpInside];
        [nonePhotoView addSubview:button];
    }
    
    if (_collectionView) {
        [self.view insertSubview:nonePhotoView aboveSubview:_collectionView];
    } else {
        [self.view addSubview:nonePhotoView];
    }
    _nonePhotoView = nonePhotoView;
}

- (void)removeNonePhotoView {
    if (_nonePhotoView) {
        [_nonePhotoView removeFromSuperview];
        _nonePhotoView = nil;
    }
}

- (void)configCollectionView {
    
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = isiPad ? 15 : 2;
    CGFloat screenWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat itemWH = (screenWidth - (imagePickerVc.columnNumber + 1) * margin) / imagePickerVc.columnNumber;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    
    CGRect collectionViewRect = [self viewFrameWithoutNavigation];
    CGFloat toolbarHeight = bottomToolBarHeight;
    if (@available(iOS 11.0, *)) {
        toolbarHeight += self.view.safeAreaInsets.bottom;
    }
    collectionViewRect.size.height -= toolbarHeight;
    
    TFY_CollectionView *collectionView = [[TFY_CollectionView alloc] initWithFrame:collectionViewRect collectionViewLayout:layout];
    [collectionView registerClass:[TFY_PickerAssetCell class] forCellWithReuseIdentifier:@"TFY_AssetPhotoCell"];
    [collectionView registerClass:[TFY_PickerAssetCell class] forCellWithReuseIdentifier:@"TFY_AssetVideoCell"];
    [collectionView registerClass:[TFY_PickerAssetCameraCell class] forCellWithReuseIdentifier:@"TFY_PickerAssetCameraCell"];
    
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.alwaysBounceHorizontal = NO;
    collectionView.alwaysBounceVertical = YES;
    collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    collectionView.dataSource = self;
    collectionView.delegate = self;

    //    self.animtionDelayTime = 0.015;
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)configBottomToolBar {
    
    if (_bottomToolBar) {
        [_bottomToolBar removeFromSuperview];
    }
    
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    
    CGFloat height = bottomToolBarHeight;
    if (@available(iOS 11.0, *)) {
        height += self.view.safeAreaInsets.bottom;
    }
    CGFloat yOffset = self.view.frame.size.height - height;
    
    UIColor *toolbarBGColor = imagePickerVc.toolbarBgColor;
    UIColor *toolbarTitleColorNormal = imagePickerVc.toolbarTitleColorNormal;
    UIColor *toolbarTitleColorDisabled = imagePickerVc.toolbarTitleColorDisabled;
    UIFont *toolbarTitleFont = imagePickerVc.toolbarTitleFont;
    
    UIView *bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, self.view.frame.size.width, height)];
    bottomToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    bottomToolBar.backgroundColor = toolbarBGColor;
    
    UIView *bottomSubToolBar = [[UIView alloc] initWithFrame:bottomToolBar.bounds];
    bottomSubToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [bottomToolBar addSubview:bottomSubToolBar];
    _bottomSubToolBar = bottomSubToolBar;
    
    CGFloat buttonX = 12;
    
    if (imagePickerVc.allowPreview) {
        CGSize previewSize = [imagePickerVc.previewBtnTitleStr picker_boundingSizeWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:toolbarTitleFont];
        previewSize.width += 10.f;
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.frame = CGRectMake(buttonX, 0, previewSize.width, bottomToolBarHeight);
        _previewButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _previewButton.titleLabel.font = toolbarTitleFont;
        [_previewButton setTitle:imagePickerVc.previewBtnTitleStr forState:UIControlStateNormal];
        [_previewButton setTitle:imagePickerVc.previewBtnTitleStr forState:UIControlStateDisabled];
        [_previewButton setTitleColor:toolbarTitleColorNormal forState:UIControlStateNormal];
        [_previewButton setTitleColor:[toolbarTitleColorNormal colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateHighlighted];
        [_previewButton setTitleColor:toolbarTitleColorDisabled forState:UIControlStateDisabled];
        _previewButton.enabled = imagePickerVc.selectedModels.count;
    }
    
    
    if (imagePickerVc.allowPickingOriginalPhoto && imagePickerVc.isPreview==NO) {
        CGFloat fullImageWidth = [imagePickerVc.fullImageBtnTitleStr picker_boundingSizeWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:toolbarTitleFont].width;
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat originalButtonW = fullImageWidth + 56;
        _originalPhotoButton.frame = CGRectMake((CGRectGetWidth(bottomToolBar.frame)-originalButtonW)/2, 0, originalButtonW, bottomToolBarHeight);
        _originalPhotoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = toolbarTitleFont;
        [_originalPhotoButton setTitle:imagePickerVc.fullImageBtnTitleStr forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:imagePickerVc.fullImageBtnTitleStr forState:UIControlStateSelected];
        [_originalPhotoButton setTitle:imagePickerVc.fullImageBtnTitleStr forState:UIControlStateDisabled];
        [_originalPhotoButton setTitleColor:toolbarTitleColorNormal forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[toolbarTitleColorNormal colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateHighlighted];
        [_originalPhotoButton setTitleColor:toolbarTitleColorNormal forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[toolbarTitleColorNormal colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateSelected|UIControlStateHighlighted];
        [_originalPhotoButton setTitleColor:toolbarTitleColorDisabled forState:UIControlStateDisabled];
        [_originalPhotoButton setImage:bundleImageNamed(imagePickerVc.photoOriginDefImageName) forState:UIControlStateNormal];
        [_originalPhotoButton setImage:bundleImageNamed(imagePickerVc.photoOriginSelImageName) forState:UIControlStateSelected];
        [_originalPhotoButton setImage:bundleImageNamed(imagePickerVc.photoOriginSelImageName) forState:UIControlStateSelected|UIControlStateHighlighted];
        [_originalPhotoButton setImage:bundleImageNamed(imagePickerVc.photoOriginDefImageName) forState:UIControlStateDisabled];
        _originalPhotoButton.adjustsImageWhenHighlighted = NO;
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 46, 0, 80, bottomToolBarHeight);
        _originalPhotoLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = toolbarTitleFont;
        _originalPhotoLabel.textColor = toolbarTitleColorNormal;
        
        [_originalPhotoButton addSubview:_originalPhotoLabel];
    }
    
    
    CGSize doneSize = [[imagePickerVc.doneBtnTitleStr stringByAppendingFormat:@"(%ld)", (long)imagePickerVc.maxImagesCount] picker_boundingSizeWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:toolbarTitleFont];
    doneSize.height = MIN(MAX(doneSize.height, height), 30);
    doneSize.width += 10;
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(self.view.frame.size.width - doneSize.width - 12, (bottomToolBarHeight-doneSize.height)/2, doneSize.width, doneSize.height);
    _doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _doneButton.titleLabel.font = toolbarTitleFont;
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:imagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
    [_doneButton setTitle:imagePickerVc.doneBtnTitleStr forState:UIControlStateDisabled];
    [_doneButton setTitleColor:toolbarTitleColorNormal forState:UIControlStateNormal];
    [_doneButton setTitleColor:[toolbarTitleColorNormal colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateHighlighted];
    [_doneButton setTitleColor:toolbarTitleColorDisabled forState:UIControlStateDisabled];
    _doneButton.layer.cornerRadius = CGRectGetHeight(_doneButton.frame)*0.2;
    _doneButton.layer.masksToBounds = YES;
    _doneButton.enabled = imagePickerVc.selectedModels.count;
    _doneButton.backgroundColor = _doneButton.enabled ? imagePickerVc.oKButtonTitleColorNormal : imagePickerVc.oKButtonTitleColorDisabled;
    
    UIView *divide = [[UIView alloc] init];
    divide.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.1f];
    divide.frame = CGRectMake(0, 0, self.view.frame.size.width, 1);
    divide.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    [bottomSubToolBar addSubview:_editButton];
    [bottomSubToolBar addSubview:_previewButton];
    [bottomSubToolBar addSubview:_originalPhotoButton];
    [bottomSubToolBar addSubview:_doneButton];
    [bottomSubToolBar addSubview:divide];
    [self.view addSubview:bottomToolBar];
    _bottomToolBar = bottomToolBar;
    
    [self refreshBottomToolBarStatus];
}

#pragma mark - Click Event
- (void)changedPhotoLimited {
    if (@available(iOS 14, *)) {
        [[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:self];
    }
}

- (void)previewButtonClick {
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    NSArray *models = [imagePickerVc.selectedModels copy];
    TFY_PhotoPreviewController *photoPreviewVc = [[TFY_PhotoPreviewController alloc] initWithModels:models index:0];
    photoPreviewVc.alwaysShowPreviewBar = YES;
    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)originalPhotoButtonClick {
    
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    imagePickerVc.isSelectOriginalPhoto = _originalPhotoButton.isSelected;;
    if (_originalPhotoButton.selected) {
        [self getSelectedPhotoBytes];
        [self checkSelectedPhotoBytes];
    } else {
        _originalPhotoLabel.text = nil;
    }
    
}

- (void)doneButtonClick {
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    
    // 判断是否满足最小必选张数的限制
    if (imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount && imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypeVideo) {
        
        if (imagePickerVc.minVideosCount && imagePickerVc.selectedModels.count < imagePickerVc.minVideosCount) {
            NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_minSelectVideoTipText"], imagePickerVc.minVideosCount];
            [imagePickerVc showAlertWithTitle:title];
            return;
        }
        
    } else {
        if (imagePickerVc.minImagesCount && imagePickerVc.selectedModels.count < imagePickerVc.minImagesCount) {
            NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_minSelectPhotoTipText"], imagePickerVc.minImagesCount];
            [imagePickerVc showAlertWithTitle:title];
            return;
        }
    }
    
    if (self.doneButtonClickBlock) {
        self.doneButtonClickBlock();
    } else {
        if (imagePickerVc.selectedModels.count == 1) {
            [imagePickerVc showProgressHUD];
        } else {
            [imagePickerVc showNeedProgressHUD];
        }
        NSMutableArray *resultArray = [NSMutableArray array];
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_globalQueue_async_safe(^{
            
            if (imagePickerVc.selectedModels.count) {
                
                for (NSInteger i = 0; i < imagePickerVc.selectedModels.count; i++) { [resultArray addObject:@0];}
                
                dispatch_group_t _group = dispatch_group_create();
                int limitQueueCount = 1;
                __block int queueCount = 0;
                __block CGFloat process = 0.f;

                void (^resultComplete)(TFY_ResultObject *, NSInteger) = ^(TFY_ResultObject *result, NSInteger index) {
                    if (result) {
                        [resultArray replaceObjectAtIndex:index withObject:result];
                    } else {
                        TFY_PickerAsset *model = [imagePickerVc.selectedModels objectAtIndex:index];
                        TFY_ResultObject *object = [TFY_ResultObject errorResultObject:model.asset];
                        [resultArray replaceObjectAtIndex:index withObject:object];
                    }
                    picker_dispatch_main_async_safe(^{
                        process += 1.f;
                        [imagePickerVc setProcess:process/resultArray.count];
                    });
                    dispatch_group_leave(_group);
                    queueCount--;
                };
                for (NSInteger i = 0; i < imagePickerVc.selectedModels.count; i++) {
                    TFY_PickerAsset *model = imagePickerVc.selectedModels[i];
                    dispatch_group_enter(_group);
                    queueCount++;
                    if (model.type == TFYAssetMediaTypePhoto) {
                        TFY_PhotoEdit *photoEdit = [[TFY_PhotoEditManager manager] photoEditForAsset:model];
                        if (photoEdit) {
                            [[TFY_PhotoEditManager manager] getPhotoWithAsset:model
                                                                 isOriginal:imagePickerVc.isSelectOriginalPhoto
                                                               compressSize:imagePickerVc.imageCompressSize
                                                      thumbnailCompressSize:imagePickerVc.thumbnailCompressSize
                                                                 completion:^(TFY_ResultImage *resultImage) {
                                                                     
                                                                     if (imagePickerVc.autoSavePhotoAlbum) {
                                                                         /** 编辑图片保存到相册 */
                                                                         [[TFY_AssetManager manager] saveImageToCustomPhotosAlbumWithTitle:nil imageDatas:@[resultImage.originalData] complete:nil];
                                                                     }
                                                                     resultComplete(resultImage, i);
                                                                 }];
                        } else {
                            if (imagePickerVc.allowPickingType & TFYPickingMediaTypeLivePhoto && model.subType == TFYAssetSubMediaTypeLivePhoto && model.closeLivePhoto == NO) {
                                [[TFY_AssetManager manager] getLivePhotoWithAsset:model.asset
                                                                     isOriginal:imagePickerVc.isSelectOriginalPhoto
                                                                  needThumbnail:(imagePickerVc.thumbnailCompressSize>0)
                                                                     completion:^(TFY_ResultImage *resultImage) {
                                                                         
                                                                         resultComplete(resultImage, i);
                                                                     }];
                            } else {
                                [[TFY_AssetManager manager] getPhotoWithAsset:model.asset
                                                                 isOriginal:imagePickerVc.isSelectOriginalPhoto
                                                                 pickingGif:imagePickerVc.allowPickingType & TFYPickingMediaTypeGif
                                                               compressSize:imagePickerVc.imageCompressSize
                                                      thumbnailCompressSize:imagePickerVc.thumbnailCompressSize
                                                                 completion:^(TFY_ResultImage *resultImage) {
                                                                     
                                                                     resultComplete(resultImage, i);
                                                                 }];
                            }
                        }
                    } else if (model.type == TFYAssetMediaTypeVideo) {
                        TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:model];
                        if (videoEdit) {
                            [[TFY_VideoEditManager manager] getVideoWithAsset:model presetName:imagePickerVc.videoCompressPresetName completion:^(TFY_ResultVideo *resultVideo) {
                                if (imagePickerVc.autoSavePhotoAlbum) {
                                    /** 编辑视频保存到相册 */
                                    [[TFY_AssetManager manager] saveVideoToCustomPhotosAlbumWithTitle:nil videoURLs:@[resultVideo.url] complete:nil];
                                }
                                resultComplete(resultVideo, i);
                            }];
                        } else {
                            [[TFY_AssetManager manager] getVideoResultWithAsset:model.asset presetName:imagePickerVc.videoCompressPresetName cache:imagePickerVc.autoVideoCache completion:^(TFY_ResultVideo *resultVideo) {
                                resultComplete(resultVideo, i);
                            }];
                        }
                    }
                    if (queueCount == limitQueueCount) {
                        dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
                    }
                }
                dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [imagePickerVc hideProgressHUD];
                        if (imagePickerVc.autoDismiss) {
                            [imagePickerVc dismissViewControllerAnimated:YES completion:^{
                                [weakSelf callDelegateMethodWithResults:resultArray];
                            }];
                        } else {
                            [weakSelf callDelegateMethodWithResults:resultArray];
                        }
                    });
                });
            } else {
                picker_dispatch_main_async_safe(^{
                    [imagePickerVc hideProgressHUD];
                    if (imagePickerVc.autoDismiss) {
                        [imagePickerVc dismissViewControllerAnimated:YES completion:^{
                            [weakSelf callDelegateMethodWithResults:resultArray];
                        }];
                    } else {
                        [weakSelf callDelegateMethodWithResults:resultArray];
                    }
                });
            }
        });
    }
}

- (void)callDelegateMethodWithResults:(NSArray <TFY_ResultObject *>*)results {
    
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    id <TFYImagePickerControllerDelegate> pickerDelegate = (id <TFYImagePickerControllerDelegate>)imagePickerVc.pickerDelegate;
    
    if (imagePickerVc.didFinishPickingResultHandle) {
        imagePickerVc.didFinishPickingResultHandle(results);
    } else if ([pickerDelegate respondsToSelector:@selector(picker_imagePickerController:didFinishPickingResult:)]) {
        [pickerDelegate picker_imagePickerController:imagePickerVc didFinishPickingResult:results];
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    if (imagePickerVc.allowTakePicture) {
        return _models.count + 1;
    }
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // the cell lead to take a picture / 去拍照的cell
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    if (((imagePickerVc.sortAscendingByCreateDate && indexPath.row >= _models.count) || (!imagePickerVc.sortAscendingByCreateDate && indexPath.row == 0)) && imagePickerVc.allowTakePicture) {
        TFY_PickerAssetCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFY_PickerAssetCameraCell" forIndexPath:indexPath];
        cell.posterImage = bundleImageNamed(imagePickerVc.takePictureImageName);
        
        return cell;
    }
    // the cell dipaly photo or video / 展示照片或视频的cell
    TFY_PickerAssetCell *cell = nil;
    
    NSInteger index = indexPath.row - 1;
    if (imagePickerVc.sortAscendingByCreateDate || !imagePickerVc.allowTakePicture) {
        index = indexPath.row;
    }
    TFY_PickerAsset *model = _models[index];
    
    if (model.type == TFYAssetMediaTypePhoto) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFY_AssetPhotoCell" forIndexPath:indexPath];
    } else if (model.type == TFYAssetMediaTypeVideo) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFY_AssetVideoCell" forIndexPath:indexPath];
    }
    
    if (@available(iOS 9.0, *)){
        /** 给cell注册 3DTouch的peek（预览）和pop功能 */
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:self sourceView:cell];
        }
    }

    [self configCell:cell model:model reloadModel:YES];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(imagePickerVc) weakImagePickerVc = imagePickerVc;
    cell.didSelectPhotoBlock = ^(BOOL isSelected, TFY_PickerAsset *cellModel, TFY_PickerAssetCell *weakCell) {
        // 1. cancel select / 取消选择
        if (!isSelected) {
            [weakImagePickerVc.selectedModels removeObject:cellModel];
            
            [weakSelf refreshBottomToolBarStatus];
            
            if (weakImagePickerVc.maxImagesCount != weakImagePickerVc.maxVideosCount) {
                
                BOOL refreshWithoutSelf = NO;
                if (cellModel.type == TFYAssetMediaTypePhoto) {
                    if (weakImagePickerVc.selectedModels.count == weakImagePickerVc.maxImagesCount-1) {
                        refreshWithoutSelf = YES;
                    }
                } else if (cellModel.type == TFYAssetMediaTypeVideo) {
                    if (weakImagePickerVc.selectedModels.count == weakImagePickerVc.maxVideosCount-1) {
                        refreshWithoutSelf = YES;
                    }
                }
                
                if (refreshWithoutSelf) {
                    /** 刷新除自己所有的cell */
                    [weakSelf refreshAllCellWithoutCell:weakCell];
                } else if (weakImagePickerVc.selectedModels.count == 0) {
                    if (cellModel.type == TFYAssetMediaTypePhoto) {
                        [weakSelf refreshVideoCell];
                    } else {
                        [weakSelf refreshImageCell];
                    }
                } else {
                    [weakSelf refreshSelectedCell];
                }
            } else {
                if (weakImagePickerVc.selectedModels.count == weakImagePickerVc.maxImagesCount-1) {
                    /** 取消选择为最大数量-1时，显示其他可选 */
                    [weakSelf refreshAllCellWithoutCell:weakCell];
                } else if (weakImagePickerVc.selectedModels.count == 0 && weakImagePickerVc.maxImagesCount != weakImagePickerVc.maxVideosCount) {
                    
                    if (cellModel.type == TFYAssetMediaTypePhoto) {
                        [weakSelf refreshVideoCell];
                    } else {
                        [weakSelf refreshImageCell];
                    }
                } else {
                    [weakSelf refreshSelectedCell];
                }
            }
            
            [weakCell selectPhoto:NO index:0 animated:NO];
            
        } else {
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            if ([weakSelf addLFAsset:cellModel refreshCell:YES]) {
                [weakCell selectPhoto:YES index:weakImagePickerVc.selectedModels.count animated:YES];
            }
        }
    };
    return cell;
}

- (void)configCell:(TFY_PickerAssetCell *)cell model:(TFY_PickerAsset *)model reloadModel:(BOOL)reloadModel
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    cell.photoDefImageName = imagePickerVc.photoDefImageName;
    cell.photoSelImageName = imagePickerVc.photoSelImageName;
    cell.displayGif = imagePickerVc.allowPickingType&TFYPickingMediaTypeGif;
    cell.displayLivePhoto = imagePickerVc.allowPickingType&TFYPickingMediaTypeLivePhoto;
    cell.displayPhotoName = imagePickerVc.displayImageFilename;
    cell.onlySelected = !imagePickerVc.allowPreview;
    /** 优先级低属性，当最大数量为1时只能点击 */
    /** 最大数量时，非选择部分显示不可选 */
    if (imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount) {
        /** 不能混合选择的情况 */
        if (imagePickerVc.selectedModels.count) {
            if (imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypePhoto) {
                cell.noSelected = (imagePickerVc.selectedModels.count == imagePickerVc.maxImagesCount && ![imagePickerVc.selectedModels containsObject:model]);
            } else if (imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypeVideo){
                cell.noSelected = (imagePickerVc.selectedModels.count == imagePickerVc.maxVideosCount && ![imagePickerVc.selectedModels containsObject:model]);
            }
            if (model.type != imagePickerVc.selectedModels.firstObject.type) {
                cell.noSelected = YES;
            }
        } else {
            cell.noSelected = NO;
        }
    } else {
        cell.noSelected = (imagePickerVc.selectedModels.count == imagePickerVc.maxImagesCount && ![imagePickerVc.selectedModels containsObject:model]);
    }
    
    if (reloadModel) {
        cell.model = model;
    }
    
    [cell selectPhoto:[imagePickerVc.selectedModels containsObject:model]
                index:[imagePickerVc.selectedModels indexOfObject:model]+1
             animated:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // take a photo / 去拍照
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    if (((imagePickerVc.sortAscendingByCreateDate && indexPath.row >= _models.count) || (!imagePickerVc.sortAscendingByCreateDate && indexPath.row == 0)) && imagePickerVc.allowTakePicture)  {
        [self takePhoto];
        return;
    }
    // preview phote or video / 预览照片或视频
    NSInteger index = indexPath.row;
    if (!imagePickerVc.sortAscendingByCreateDate && imagePickerVc.allowTakePicture) {
        index = indexPath.row - 1;
    }
    TFY_PhotoPreviewController *photoPreviewVc = [[TFY_PhotoPreviewController alloc] initWithModels:[_models copy] index:index];
    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.animtionDelayTime > 0) {
        cell.alpha = 0;
        [UIView animateWithDuration:0.25 delay:self.animtionTimes++ * self.animtionDelayTime options:UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.animtionFinishTimes++;
            if (self.animtionTimes == self.animtionFinishTimes) {
                // finish
                self.animtionDelayTime = 0;
                self.animtionTimes = 0;
                self.animtionFinishTimes = 0;
            }
        }];
    }
}

#pragma mark - Haptic Touch - UIContextMenuInteractionDelegate
- (nullable UIContextMenuConfiguration *)collectionView:(UICollectionView *)collectionView contextMenuConfigurationForItemAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point API_AVAILABLE(ios(13.0))
{
    __weak typeof(self) weakSelf = self;
    UIContextMenuConfiguration *configuration = [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:^UIViewController * _Nullable{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)strongSelf.navigationController;
        NSInteger index = indexPath.row;
        if (!imagePickerVc.sortAscendingByCreateDate && imagePickerVc.allowTakePicture) {
            index = indexPath.row - 1;
        }
        TFY_PhotoPreviewController *photoPreviewVc = [[TFY_PhotoPreviewController alloc] initWithModels:[strongSelf.models copy] index:index];
        [photoPreviewVc beginPreviewing:imagePickerVc];
        
        TFY_PickerAsset *model = strongSelf.models[indexPath.row];
        PHAsset *phAsset = model.asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat pixelWidth = [UIScreen mainScreen].bounds.size.width * 2.0f;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);

        CGSize contentSize = [UIImage picker_scaleImageSizeBySize:imageSize targetSize:CGSizeMake(strongSelf.view.bounds.size.width, strongSelf.view.bounds.size.height) isBoth:NO];
        
        BOOL isLongImage = model.subType == TFYAssetSubMediaTypePhotoPiiic;
        if (isLongImage) { /** 长图 */
            contentSize = [UIImage picker_imageSizeBySize:imageSize maxWidth:strongSelf.view.bounds.size.width];
            if (contentSize.height > strongSelf.view.bounds.size.height) {
                contentSize.height = strongSelf.view.bounds.size.height;
            }
        }
        
        photoPreviewVc.preferredContentSize = CGSizeMake(contentSize.width, contentSize.height);
        return photoPreviewVc;
    } actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        return nil;
    }];
    return configuration;
}

- (void)collectionView:(UICollectionView *)collectionView willPerformPreviewActionForMenuWithConfiguration:(UIContextMenuConfiguration *)configuration animator:(id<UIContextMenuInteractionCommitAnimating>)animator API_AVAILABLE(ios(13.0))
{
    
    animator.preferredCommitStyle = UIContextMenuInteractionCommitStylePop;
    TFY_PhotoPreviewController *photoPreviewVc = (TFY_PhotoPreviewController *)animator.previewViewController;
    __weak typeof(self) weakSelf = self;
    [animator addCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf pushPhotoPrevireViewController:photoPreviewVc];
        [photoPreviewVc endPreviewing];
    }];
}

#pragma mark - 拍照图片后执行代理
#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    [imagePickerVc showProgressHUDText:nil isTop:YES];
    
    BOOL hasUsingMedia = NO;
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        if (chosenImage) {
            hasUsingMedia = YES;
            [self cameraPhoto:chosenImage completionHandler:^(NSError *error) {
                if (error) {
                    [imagePickerVc showAlertWithTitle:[NSBundle picker_localizedStringForKey:@"_cameraTakePhotoError"] message:error.localizedDescription complete:nil];
                }
                [picker dismissViewControllerAnimated:YES completion:^{
                }];
            }];
        }
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {
            hasUsingMedia = YES;
            [self cameraVideo:videoUrl completionHandler:^(NSError *error) {
                if (error) {
                    [imagePickerVc showAlertWithTitle:[NSBundle picker_localizedStringForKey:@"_cameraTakeVideoError"] message:error.localizedDescription complete:nil];
                }
                [picker dismissViewControllerAnimated:YES completion:^{
                }];
            }];
        }
    }
    
    if (!hasUsingMedia) {
        [imagePickerVc hideProgressHUD];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerPreviewingDelegate
/** peek(预览) */
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    //获取按压的cell所在行，[previewingContext sourceView]就是按压的那个视图
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    
    TFY_PickerAssetCell *cell = (TFY_PickerAssetCell* )[previewingContext sourceView];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (indexPath) {
        // preview phote or video / 预览照片或视频
        NSInteger index = indexPath.row;
        if (!imagePickerVc.sortAscendingByCreateDate && imagePickerVc.allowTakePicture) {
            index = indexPath.row - 1;
        }
        TFY_PhotoPreviewController *photoPreviewVc = [[TFY_PhotoPreviewController alloc] initWithModels:[_models copy] index:index];
        [photoPreviewVc beginPreviewing:imagePickerVc];
        
        PHAsset *phAsset = cell.model.asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat pixelWidth = [UIScreen mainScreen].bounds.size.width * 2.0f;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
        
        CGSize contentSize = [UIImage picker_scaleImageSizeBySize:imageSize targetSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) isBoth:NO];
        BOOL isLongImage = cell.model.subType == TFYAssetSubMediaTypePhotoPiiic;
        if (isLongImage) { /** 长图 */
            contentSize = [UIImage picker_imageSizeBySize:imageSize maxWidth:self.view.bounds.size.width];
            if (contentSize.height > self.view.bounds.size.height) {
                contentSize.height = self.view.bounds.size.height;
            }
        }
        
        photoPreviewVc.preferredContentSize = CGSizeMake(contentSize.width, contentSize.height);
        return photoPreviewVc;
    }
    return nil;
}

/** pop（按用点力进入） */
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    TFY_PhotoPreviewController *photoPreviewVc = (TFY_PhotoPreviewController *)viewControllerToCommit;
    [self pushPhotoPrevireViewController:photoPreviewVc];
    [photoPreviewVc endPreviewing];
}

#pragma mark - TFYPhotoPreviewControllerPullDelegate
- (UIView *)picker_PhotoPreviewControllerPullBlackgroundView;
{
    return [self.navigationController.view snapshotViewAfterScreenUpdates:YES];
}
- (CGRect)picker_PhotoPreviewControllerPullItemRect:(TFY_PickerAsset *)asset
{
    if (asset) {
        if (asset.type == TFYAssetMediaTypePhoto) { // 仅处理图片
            NSInteger index = [self.models indexOfObject:asset];
            if (index != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                if (cell) {
                    CGRect rect = [self.collectionView convertRect:cell.frame toView:self.view];
                    // 过滤顶部与底部遮挡的部分
                    if (CGRectContainsRect(self.collectionView.frame, rect)) {
                        return rect;
                    }
                }
            }
        }
    }
    return CGRectZero;
}

#pragma mark - UIAdaptivePresentationControllerDelegate
- (void)presentationControllerDidAttemptToDismiss:(UIPresentationController *)presentationController
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    if (_doneButton.enabled) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alert addAction:[UIAlertAction actionWithTitle:imagePickerVc.doneBtnTitleStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doneButtonClick];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:imagePickerVc.cancelBtnTitleStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:[NSBundle picker_localizedStringForKey:@"_discardTitleStr"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([imagePickerVc respondsToSelector:@selector(cancelButtonClick)]) {
                [imagePickerVc performSelector:@selector(cancelButtonClick)];
            }
#pragma clang diagnostic pop
        }]];
        
        // The popover should point at the Cancel button
        alert.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([imagePickerVc respondsToSelector:@selector(cancelButtonClick)]) {
            [imagePickerVc performSelector:@selector(cancelButtonClick)];
        }
        #pragma clang diagnostic pop
    }
}

#pragma mark - Private Method

- (void)takePhoto {
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    
    if (imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount && imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypeVideo) {
        if (imagePickerVc.selectedModels.count >= imagePickerVc.maxVideosCount) {
            NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText"], imagePickerVc.maxVideosCount];
            [imagePickerVc showAlertWithTitle:title];
            return;
        }
    } else {
        if (imagePickerVc.selectedModels.count >= imagePickerVc.maxImagesCount) {
            NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectPhotoTipText"], imagePickerVc.maxImagesCount];
            [imagePickerVc showAlertWithTitle:title];
            return;
        }
    }
    
    BOOL onlyPhoto = NO;
    BOOL onlyVideo = NO;
    if (imagePickerVc.selectedModels.count) {
        onlyPhoto = imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount && imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypePhoto;
        onlyVideo = imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount && imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypeVideo;
    }
    UIImagePickerControllerSourceType srcType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: srcType]) {
        __weak typeof(self) weakSelf = self;
        __weak typeof(imagePickerVc) weakImagePickerVc = imagePickerVc;
        [self requestAccessForCameraCompletionHandler:^{
            
            picker_takePhotoHandler handler = ^(id media, NSString *mediaType, picker_takePhotoCallback callback) {
                
                [weakImagePickerVc showProgressHUDText:nil isTop:YES];
                
                if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
                    [weakSelf cameraPhoto:media completionHandler:^(NSError *error) {
                        [weakImagePickerVc hideProgressHUD];
                        if (callback) {
                            callback(weakImagePickerVc, error);
                        }
                    }];
                } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
                    [weakSelf cameraVideo:media completionHandler:^(NSError *error) {
                        [weakImagePickerVc hideProgressHUD];
                        if (callback) {
                            callback(weakImagePickerVc, error);
                        }
                    }];
                } else {
                    [weakImagePickerVc hideProgressHUD];
                    if (callback) {
                        NSError *error = [NSError errorWithDomain:@"TFY_ImagePickerController" code:101 userInfo:@{NSLocalizedDescriptionKey:@"Incorrect parameters."}];
                        callback(weakImagePickerVc, error);
                    }
                }
            };
            
            if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(picker_imagePickerController:takePhotoHandler:)]) {
                [imagePickerVc.pickerDelegate picker_imagePickerController:imagePickerVc takePhotoHandler:handler];
            } else if (imagePickerVc.imagePickerControllerTakePhotoHandle) {
                imagePickerVc.imagePickerControllerTakePhotoHandle(handler);
            } else {
                /** 调用内置相机模块 */
                UIImagePickerController *mediaPickerController = [[UIImagePickerController alloc] init];
                // set appearance / 改变相册选择页的导航栏外观
                {
                    mediaPickerController.navigationBar.barTintColor = imagePickerVc.navigationBar.barTintColor;
                    mediaPickerController.navigationBar.tintColor = imagePickerVc.navigationBar.tintColor;
                    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
                    UIBarButtonItem *barItem;
                    if (@available(iOS 9.0, *)){
                        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
                    }
                    textAttrs[NSForegroundColorAttributeName] = imagePickerVc.barItemTextColor;
                    textAttrs[NSFontAttributeName] = imagePickerVc.barItemTextFont;
                    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
                }
                mediaPickerController.sourceType = srcType;
                mediaPickerController.delegate = self;
                
                NSMutableArray *mediaTypes = [NSMutableArray array];
                
                if (imagePickerVc.allowPickingType & TFYPickingMediaTypePhoto && imagePickerVc.selectedModels.count < imagePickerVc.maxImagesCount && !onlyVideo) {
                    [mediaTypes addObject:(NSString *)kUTTypeImage];
                }
                if (imagePickerVc.allowPickingType & TFYPickingMediaTypeVideo && imagePickerVc.selectedModels.count < imagePickerVc.maxVideosCount && !onlyPhoto) {
                    [mediaTypes addObject:(NSString *)kUTTypeMovie];
                    mediaPickerController.videoMaximumDuration = imagePickerVc.maxVideoDuration;
                }
                
                mediaPickerController.mediaTypes = mediaTypes;
                
                /** warning：Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates. */
                [self presentViewController:mediaPickerController animated:YES completion:NULL];
            }
        }];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (BOOL)addLFAsset:(TFY_PickerAsset *)asset refreshCell:(BOOL)refreshCell
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(imagePickerVc) weakImagePickerVc = imagePickerVc;
    BOOL (^selectedItem)(TFY_PickerAsset *model, BOOL refresh) = ^BOOL (TFY_PickerAsset *model, BOOL refresh){
        /** 检测是否超过视频最大时长 */
        if (model.type == TFYAssetMediaTypeVideo) {
            TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:model];
            NSTimeInterval duration = videoEdit.editPreviewImage ? videoEdit.duration : model.duration;
            if (picker_videoDuration(duration) > weakImagePickerVc.maxVideoDuration) {
                if (weakImagePickerVc.maxVideoDuration < 60) {
                    [weakImagePickerVc showAlertWithTitle:[NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText_second"], (int)weakImagePickerVc.maxVideoDuration]];
                } else {
                    [weakImagePickerVc showAlertWithTitle:[NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText_minute"], (int)weakImagePickerVc.maxVideoDuration/60]];
                }
                return NO;
            }
        }
        [weakImagePickerVc.selectedModels addObject:model];
        [weakSelf refreshBottomToolBarStatus];
        
        if (refresh) {
            if (weakImagePickerVc.maxImagesCount != weakImagePickerVc.maxVideosCount) {
                
                BOOL refreshNoSelected = NO;
                if (weakImagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypePhoto) {
                    if (weakImagePickerVc.selectedModels.count == weakImagePickerVc.maxImagesCount) {
                        [weakSelf refreshNoSelectedCell];
                        refreshNoSelected = YES;
                    }
                } else {
                    if (weakImagePickerVc.selectedModels.count == weakImagePickerVc.maxVideosCount) {
                        [weakSelf refreshNoSelectedCell];
                        refreshNoSelected = YES;
                    }
                }
                
                /** refreshNoSelected后没有必要再次刷新 */
                if (weakImagePickerVc.selectedModels.count == 1 && !refreshNoSelected) {
                    if (weakImagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypePhoto) {
                        [weakSelf refreshVideoCell];
                    } else {
                        [weakSelf refreshImageCell];
                    }
                }
                
            } else if (weakImagePickerVc.selectedModels.count == weakImagePickerVc.maxImagesCount) {
                /** 选择到最大数量，禁止其他的可选显示 */
                [weakSelf refreshNoSelectedCell];
            }
        }
        return YES;
    };
    
    if (imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount && asset.type == TFYAssetMediaTypeVideo) {
        if (imagePickerVc.selectedModels.count < imagePickerVc.maxVideosCount) {
            return selectedItem(asset, refreshCell);
        } else {
            NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText"], imagePickerVc.maxVideosCount];
            [imagePickerVc showAlertWithTitle:title];
        }
        
    } else {
        if (imagePickerVc.selectedModels.count < imagePickerVc.maxImagesCount) {
            return selectedItem(asset, refreshCell);
        } else {
            NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectPhotoTipText"], imagePickerVc.maxImagesCount];
            [imagePickerVc showAlertWithTitle:title];
        }
    }
    return NO;
}

- (void)cameraPhoto:(UIImage *)image completionHandler:(void (^)(NSError *error))handler
{
    if (image && [image isKindOfClass:[UIImage class]]) {
        TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
        [[TFY_AssetManager manager] saveImageToCustomPhotosAlbumWithTitle:self.titleView.title images:@[image] complete:^(NSArray<id> *assets, NSError *error) {
            
            if (assets && !error) {
                TFY_PickerAsset *asset = [[TFY_PickerAsset alloc] initWithAsset:assets.lastObject];
                [self addLFAsset:asset refreshCell:NO];
                if (!imagePickerVc.syncAlbum) {
                    
                    [self manualSaveAsset:asset smartAlbum:TFYAlbumSmartAlbumUserLibrary];
                    /** refresh title view */
                    self.titleView.albumArr = self.albumArr;
                }
            }
            [imagePickerVc hideProgressHUD];
            
            if (handler) {
                handler(error);
            }
        }];
    } else {
        if (handler) {
            NSError *error = [NSError errorWithDomain:@"TFY_ImagePickerController" code:100 userInfo:@{NSLocalizedDescriptionKey:@"Incorrect parameters."}];
            handler(error);
        }
    }
}

- (void)cameraVideo:(NSURL *)videoUrl completionHandler:(void (^)(NSError *error))handler
{
    if (videoUrl && [videoUrl isKindOfClass:[NSURL class]]) {
        TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
        [[TFY_AssetManager manager] saveVideoToCustomPhotosAlbumWithTitle:self.titleView.title videoURLs:@[videoUrl] complete:^(NSArray<id> *assets, NSError *error) {
            if (assets && !error) {
                TFY_PickerAsset *asset = [[TFY_PickerAsset alloc] initWithAsset:assets.lastObject];
                [self addLFAsset:asset refreshCell:NO];
                if (!imagePickerVc.syncAlbum) {
                    [self manualSaveAsset:asset smartAlbum:TFYAlbumSmartAlbumUserLibrary];
                    [self manualSaveAsset:asset smartAlbum:TFYAlbumSmartAlbumVideos];
                    /** refresh title view */
                    self.titleView.albumArr = self.albumArr;
                }
            }
            [imagePickerVc hideProgressHUD];
            
            if (handler) {
                handler(error);
            }
        }];
    } else {
        if (handler) {
            NSError *error = [NSError errorWithDomain:@"TFY_ImagePickerController" code:100 userInfo:@{NSLocalizedDescriptionKey:@"Incorrect parameters."}];
            handler(error);
        }
    }
}

- (void)refreshSelectedCell
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray array];
    if (imagePickerVc.selectedModels.count) {
        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(TFY_PickerAssetCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cell isKindOfClass:[TFY_PickerAssetCell class]] && [imagePickerVc.selectedModels containsObject:cell.model]) {
                NSInteger index = [self->_models indexOfObject:cell.model];
                if (imagePickerVc.allowTakePicture && !imagePickerVc.sortAscendingByCreateDate) {
                    index += 1;
                }
                [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            }
        }];
        if (indexPaths.count) {
            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
        }
    }
}

- (void)refreshNoSelectedCell
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    __weak typeof(self) weakSelf = self;
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray array];
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(TFY_PickerAssetCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[TFY_PickerAssetCell class]] && ![imagePickerVc.selectedModels containsObject:cell.model]) {
            NSInteger index = [weakSelf.models indexOfObject:cell.model];
            if (imagePickerVc.allowTakePicture && !imagePickerVc.sortAscendingByCreateDate) {
                index += 1;
            }
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }];
    if (indexPaths.count) {
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }
}

- (void)refreshAllCellWithoutCell:(TFY_PickerAssetCell *)myCell
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    __weak typeof(self) weakSelf = self;
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray array];
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(TFY_PickerAssetCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[TFY_PickerAssetCell class]] && ![cell isEqual:myCell]) {
            NSInteger index = [weakSelf.models indexOfObject:cell.model];
            if (imagePickerVc.allowTakePicture && !imagePickerVc.sortAscendingByCreateDate) {
                index += 1;
            }
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }];
    if (indexPaths.count) {
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }
}

- (void)refreshImageCell
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    __weak typeof(self) weakSelf = self;
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray array];
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(TFY_PickerAssetCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[TFY_PickerAssetCell class]] && cell.model.type == TFYAssetMediaTypePhoto) {
            NSInteger index = [weakSelf.models indexOfObject:cell.model];
            if (imagePickerVc.allowTakePicture && !imagePickerVc.sortAscendingByCreateDate) {
                index += 1;
            }
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }];
    if (indexPaths.count) {
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }
}
- (void)refreshVideoCell
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    __weak typeof(self) weakSelf = self;
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray array];
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(TFY_PickerAssetCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[TFY_PickerAssetCell class]] && cell.model.type == TFYAssetMediaTypeVideo) {
            NSInteger index = [weakSelf.models indexOfObject:cell.model];
            if (imagePickerVc.allowTakePicture && !imagePickerVc.sortAscendingByCreateDate) {
                index += 1;
            }
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }];
    if (indexPaths.count) {
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }
}

- (void)refreshBottomToolBarStatus {
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    
    _editButton.enabled = imagePickerVc.selectedModels.count == 1;
    _previewButton.enabled = imagePickerVc.selectedModels.count > 0;
//    _originalPhotoButton.enabled = imagePickerVc.selectedModels.count > 0;
    _doneButton.enabled = imagePickerVc.selectedModels.count;
    _doneButton.backgroundColor = _doneButton.enabled ? imagePickerVc.oKButtonTitleColorNormal : imagePickerVc.oKButtonTitleColorDisabled;
    
    if (imagePickerVc.selectedModels.count) {
        [_doneButton setTitle:[NSString stringWithFormat:@"%@(%zd)", imagePickerVc.doneBtnTitleStr ,imagePickerVc.selectedModels.count] forState:UIControlStateNormal];
    } else {
        [_doneButton setTitle:imagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
    }
    
    _originalPhotoButton.selected = imagePickerVc.isSelectOriginalPhoto;
    _originalPhotoLabel.hidden = !(_originalPhotoButton.selected && imagePickerVc.selectedModels.count > 0);
    if (!_originalPhotoLabel.hidden) {
        [self getSelectedPhotoBytes];
        [self checkSelectedPhotoBytes];
    }
}

- (void)pushPhotoPrevireViewController:(TFY_PhotoPreviewController *)photoPreviewVc {
    
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    if (imagePickerVc.modalPresentationStyle == UIModalPresentationFullScreen && !photoPreviewVc.isPhotoPreview) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait) { /** 除了竖屏进去时，其他状态也禁止它 */
            photoPreviewVc.pulldelegate = self;
        }
    }
    __weak typeof(self) weakSelf = self;
    [photoPreviewVc setBackButtonClickBlock:^{
        [weakSelf.collectionView reloadItemsAtIndexPaths:weakSelf.collectionView.indexPathsForVisibleItems];
        [weakSelf refreshBottomToolBarStatus];
    }];
    [photoPreviewVc setDoneButtonClickBlock:^{
        [weakSelf doneButtonClick];
    }];
    
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)checkSelectedPhotoBytes {
    __weak typeof(self) weakSelf = self;
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    __weak typeof(imagePickerVc) weakImagePickerVc = imagePickerVc;
    
    NSMutableArray *newSelectedModes = [NSMutableArray arrayWithCapacity:5];
    for (TFY_PickerAsset *asset in imagePickerVc.selectedModels) {
        if (asset.type == TFYAssetMediaTypePhoto) {
            /** 忽略图片被编辑的情况 */
            if (![[TFY_PhotoEditManager manager] photoEditForAsset:asset]) {
                [newSelectedModes addObject:asset];
            }
        }
    }
    
    [[TFY_AssetManager manager] checkPhotosBytesMaxSize:newSelectedModes maxBytes:imagePickerVc.maxPhotoBytes completion:^(BOOL isPass) {
        if (!isPass) {
            /** 重新修改原图选项 */
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf->_originalPhotoButton.selected) {
                [strongSelf originalPhotoButtonClick];
            }
            [weakImagePickerVc showAlertWithTitle:[NSBundle picker_localizedStringForKey:@"_selectPhotoSizeLimitTipText"]];
        }
    }];
}

- (void)getSelectedPhotoBytes {
    if (/* DISABLES CODE */ (1)==0) {
        TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
        [[TFY_AssetManager manager] getPhotosBytesWithArray:imagePickerVc.selectedModels completion:^(NSString *totalBytesStr, NSInteger totalBytes) {
            self->_originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytesStr];
        }];
    }
}

- (void)scrollCollectionViewToBottom {
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    if (_models.count > 0 && imagePickerVc.sortAscendingByCreateDate && _collectionView) {
        NSInteger item = _models.count - 1;
        if (imagePickerVc.allowTakePicture) {
            item += 1;
        }
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)checkDefaultSelectedModels {
    
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    if (imagePickerVc.selectedAssets.count) {
        [imagePickerVc.selectedModels removeAllObjects];
        for (id object in imagePickerVc.selectedAssets) {
            TFY_PickerAsset *asset = nil;
            if ([object isKindOfClass:[PHAsset class]]) {
                asset = [[TFY_PickerAsset alloc] initWithAsset:object];
                if (asset.subType == TFYAssetSubMediaTypeLivePhoto) {
                    asset.closeLivePhoto = !imagePickerVc.autoPlayLivePhoto;
                }
            }
            else if ([object conformsToProtocol:@protocol(TFY_AssetImageProtocol)]) {
                asset = [[TFY_PickerAsset alloc] initWithObject:object];
            }
            else if ([object conformsToProtocol:@protocol(TFY_AssetPhotoProtocol)]) {
                asset = [[TFY_PickerAsset alloc] initWithObject:object];
            }
            if (asset) {
                NSUInteger index = [self.models indexOfObject:asset];
                if (index != NSNotFound) {
                    if (imagePickerVc.selectedModels.count && imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount) {
                        if (asset.type == imagePickerVc.selectedModels.firstObject.type) {
                            [imagePickerVc.selectedModels addObject:self.models[index]];
                        }
                    } else {
                        [imagePickerVc.selectedModels addObject:self.models[index]];
                    }
                }
                if (imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypePhoto) {
                    if (imagePickerVc.selectedModels.count >= imagePickerVc.maxImagesCount) {
                        break;
                    }
                } else if (imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypeVideo) {
                    if (imagePickerVc.selectedModels.count >= imagePickerVc.maxVideosCount) {
                        break;
                    }
                }
            }
        }
    }
    /** 只执行一次 */
    imagePickerVc.selectedAssets = nil;
}

- (void)manualSaveAsset:(TFY_PickerAsset *)asset smartAlbum:(TFYAlbumSmartAlbum)smartAlbum
{
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
    
    TFY_PickerAlbum *model = nil;
    for (TFY_PickerAlbum *album in self.albumArr) {
        if (album.smartAlbum == smartAlbum) {
            model = album;
            break;
        }
    }
    
    NSMutableArray *models = nil;
    if ([model isEqual:self.model]) {
        models = self.models;
    } else {
        models = [model.models mutableCopy];
    }
    
    if (imagePickerVc.sortAscendingByCreateDate) {
        [models addObject:asset];
    } else {
        [models insertObject:asset atIndex:0];
    }
    model.models = [models copy];
    if ([model isEqual:self.model]) {
        [self.collectionView reloadData];
    }
}


#pragma mark - PHPhotoLibraryChangeObserver
//相册变化回调
- (void)photoLibraryDidChange:(PHChange *)changeInfo {
    // Photos may call this method on a background queue;
    // switch to the main queue to update the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
        // Check for changes to the displayed album itself
        // (its existence and metadata, not its member assets).
        
        NSMutableArray *deleteObjects = [NSMutableArray array];
        NSMutableArray *changedObjects = [NSMutableArray array];
        
        BOOL wasDeletedAlbum = NO;
        PHFetchResultChangeDetails *currentCollectionChanges = nil;
        
        for (NSInteger i=0; i<self.albumArr.count; i++) {
            TFY_PickerAlbum *album = self.albumArr[i];
            PHObjectChangeDetails *albumChanges = [changeInfo changeDetailsForObject:album.album];
            if (albumChanges) {
                // Fetch the new album and update the UI accordingly.
                [album changedAlbum:[albumChanges objectAfterChanges]];
                
                if (albumChanges.objectWasDeleted) {
                    [deleteObjects addObject:album];
                    if ([album isEqual:self.model]) {
                        wasDeletedAlbum = YES;
                    }
                }
            }
            // Check for changes to the list of assets (insertions, deletions, moves, or updates).
            PHFetchResultChangeDetails *collectionChanges = [changeInfo changeDetailsForFetchResult:album.result];
            if (collectionChanges) {
                // Get the new fetch result for future change tracking.
                [album changedResult:collectionChanges.fetchResultAfterChanges];
                
                // iOS14 PHAuthorizationStatusLimited, BeforeChangesCount != AfterChangesCount
                if (collectionChanges.hasIncrementalChanges || collectionChanges.fetchResultAfterChanges.count !=  collectionChanges.fetchResultBeforeChanges.count)  {
                    // Tell the collection view to animate insertions/deletions/moves
                    // and to refresh any cells that have changed content.
                    // clean album cache
                    album.models = nil;
                    album.posterAsset = nil;
                    
                    [changedObjects addObject:album];
                    
                    if ([album isEqual:self.model]) {
                        currentCollectionChanges = collectionChanges;
                    }
                }
            }
        }
        
        if (deleteObjects.count || changedObjects.count) {
            if (deleteObjects.count) {
                [self.albumArr removeObjectsInArray:deleteObjects];
            }
            // update TitleView data && title
            self.titleView.title = self.model.name;
            self.titleView.albumArr = self.albumArr;
        }
        
        if (wasDeletedAlbum) {
            void (^showAlertView)(void) = ^{
                [imagePickerVc showAlertWithTitle:nil message:[NSBundle picker_localizedStringForKey:@"_LFPhotoPickerController_photoAlbunDeletedError"] complete:^{
                    if (imagePickerVc.viewControllers.count > 1) {
                        [imagePickerVc popToRootViewControllerAnimated:YES];
                    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                        if ([imagePickerVc respondsToSelector:@selector(cancelButtonClick)]) {
                            [imagePickerVc performSelector:@selector(cancelButtonClick)];
                        }
#pragma clang diagnostic pop
                    }
                }];
            };
            
            if (self.presentedViewController) {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
                    showAlertView();
                }];
            } else {
                showAlertView();
            }
            return ;
        }
        
        // Check for changes to the list of assets (insertions, deletions, moves, or updates).
        PHFetchResultChangeDetails *collectionChanges = currentCollectionChanges;
        if (collectionChanges) {
            // Reload data
            [self loadAlbumData:^{
                /** 更新已选数组 */
                if (imagePickerVc.selectedModels.count && collectionChanges.removedObjects.count) {
                    for (id object in collectionChanges.removedObjects) {
                        TFY_PickerAsset *asset = nil;
                        if ([object isKindOfClass:[PHAsset class]]) {
                            asset = [[TFY_PickerAsset alloc] initWithAsset:object];
                        }
                        if (asset) {
                            [imagePickerVc.selectedModels removeObject:asset];
                        }
                    }
                }
                [self.collectionView reloadData];
                [self scrollCollectionViewToBottom];
                if (self.models.count == 0 && !imagePickerVc.allowTakePicture) {
                    // 添加没有图片的提示
                    [self configNonePhotoView];
                } else {
                    [self removeNonePhotoView];
                }
            }];
            
            if (collectionChanges.removedObjects.count) {
                /** 刷新后返回当前UI */
                if (self.presentedViewController) {
                    [self.presentedViewController dismissViewControllerAnimated:NO completion:^{
                        if (imagePickerVc.viewControllers.lastObject != self) {
                            [imagePickerVc popToViewController:self animated:NO];
                        }
                    }];
                } else {
                    if (imagePickerVc.viewControllers.lastObject != self) {
                        [imagePickerVc popToViewController:self animated:NO];
                    }
                }
            }
        }
    });
}

#pragma mark - UIContentContainer
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    _collectionView.oldContentOffset = _collectionView.contentOffset;
    _collectionView.oldContentSize = _collectionView.contentSize;
    _collectionView.oldCollectionViewRect = _collectionView.frame;
}

#pragma mark - UIDeviceOrientationDidChangeNotification
- (void)orientationDidChange:(NSNotification *)notify
{
    if (UIDeviceOrientationIsValidInterfaceOrientation([[UIDevice currentDevice] orientation])) {
        TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)self.navigationController;
        if (_collectionView == nil) {
            return;
        }
        // 计算collectionView旋转后的相对位置
        CGRect collectionViewRect = _collectionView.frame;
        CGRect oldCollectionViewRect = _collectionView.oldCollectionViewRect;
        CGPoint oldContentOffset = _collectionView.oldContentOffset;
        CGSize oldContentSize = _collectionView.oldContentSize;
        
        if (!CGRectEqualToRect(oldCollectionViewRect, CGRectZero) && !CGRectEqualToRect(collectionViewRect, oldCollectionViewRect)) {
            UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;

            CGFloat itemWH = flowLayout.itemSize.width;
            CGFloat margin = flowLayout.minimumLineSpacing;
            // 一行的数量
            int columnNumber = (int)(collectionViewRect.size.width / (itemWH + margin));
            // 总数/每行的数量=总行数
            int lineNumber = (int)((_models.count + columnNumber - 1 + (imagePickerVc.allowTakePicture ? 1 : 0)) / columnNumber);
            // 总行数*每行高度+总行数之间的间距 (上下间距 不在contentSize范围内)
            CGFloat newContentSizeHeight = lineNumber * itemWH + (lineNumber - 1) * margin;// + margin * 2;

            CGFloat contentOffsetY = -_collectionView.contentInset.top;
            if (oldContentOffset.y+_collectionView.contentInset.top > 0) { // 临界点横屏时不用计算
                CGFloat ratio = (oldContentOffset.y + oldCollectionViewRect.size.height) / oldContentSize.height;
                contentOffsetY = newContentSizeHeight * ratio - collectionViewRect.size.height;
            }
            /** 限制有效范围 */
            contentOffsetY = MIN(MAX(-_collectionView.contentInset.top, contentOffsetY), newContentSizeHeight-collectionViewRect.size.height+_collectionView.contentInset.top);
            [_collectionView setContentOffset:CGPointMake(_collectionView.contentOffset.x, contentOffsetY) animated:NO];
        }
    }
}


@end
