//
//  TFY_PhotoPreviewController.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PhotoPreviewController.h"
#import <PhotosUI/PhotosUI.h>
#import "TFY_ImagePickerController.h"
#import "TFY_ImagePickerController+property.h"
#import "TFYPickerUit.h"
#import "TFYCategory.h"
#import "TFYPhotoEditing.h"
#import "TFYVideoEditing.h"
#import "TFYItools.h"

CGFloat const cellMargin = 20.f;
CGFloat const livePhotoSignMargin = 10.f;
CGFloat const toolbarDefaultHeight = 50.f;
CGFloat const previewBarDefaultHeight = 88.f;
CGFloat const naviTipsViewDefaultHeight = 30.f;

@interface TFY_PhotoPreviewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,TFYPhotoPreviewCellDelegate, UIAdaptivePresentationControllerDelegate, UIGestureRecognizerDelegate, TFYPhotoEditingControllerDelegate, TFYVideoEditingControllerDelegate>
{
    UIView *_naviBar;
    UIView *_naviSubBar;
    UIButton *_backButton;
    UILabel *_titleLabel;
    UIButton *_selectButton;
    
    UIView *_toolBar;
    UIView *_toolSubBar;
    UIButton *_doneButton;
    
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    UIButton *_editButton;
    
    UIButton *_videoPlayButton;
    
    UIView *_livePhotoSignView;
    UIButton *_livePhotobadgeImageButton;
    
    UIView *_naviTipsView;
    UILabel *_naviTipsLabel;
    
    UIView *_previewMainBar;
    TFY_PickerPreviewBar *_previewBar;
    
    /** 下拉手势记录点 */
    CGPoint _originalPoint;
    CGPoint _beginPoint;
    CGPoint _endPoint;
    BOOL _isPullBegan;
    BOOL _isPulling;
    int _pullTimes;//允许尝试次数
    UIView *_pullSnapshotView;
}

@property (nonatomic, weak) UIView *backgroundView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray <TFY_PickerAsset *>*models;                  ///< All photo models / 所有图片模型数组
@property (nonatomic, assign) NSInteger currentIndex;           ///< Index of the photo user click / 用户点击的图片的索引

@property (nonatomic, assign) BOOL isHideMyNaviBar;
/** 手动滑动标记 */
@property (nonatomic, assign) BOOL isMTScroll;

/** 首次加载的标记 */
@property (nonatomic, assign) BOOL isFirstLoad;

/** 3DTouch预览状态 */
@property (nonatomic, assign) BOOL isPreviewing;
@property (nonatomic, weak) TFY_ImagePickerController *previewNavi;

/** 下拉手势 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIView *pullBackgroundView;
@property (nonatomic, weak) UIView *pullSnapshotSuperView; // 下拉时获取cell的展示视图，结束后要还回去。

@end

@implementation TFY_PhotoPreviewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isFirstLoad = YES;
        self.isHiddenNavBar = YES;
        /** 刘海屏的顶部一直会存在安全区域，window的显示区域不在刘海屏范围，调整window的层级无法遮挡状态栏。 */
        if (@available(iOS 11.0, *)) {
            if (hasSafeArea) {
                self.isHiddenStatusBar = YES;
            }
        }
    }
    return self;
}

- (instancetype)initWithModels:(NSArray <TFY_PickerAsset *>*)models index:(NSInteger)index
{
    self = [self init];
    if (self) {
        if (models) {
            _models = [NSMutableArray arrayWithArray:models];
            _currentIndex = index;
        }
    }
    return self;
}
- (instancetype)initWithPhotos:(NSArray <TFY_PickerAsset *>*)photos index:(NSInteger)index
{
    self = [self init];
    if (self) {
        if (photos) {
            _models = [photos mutableCopy];
            _currentIndex = index;
            _isPhotoPreview = YES;
        }
    }
    return self;
}

/** 3DTouch */
- (void)beginPreviewing:(UINavigationController *)navi
{
    _previewNavi = (TFY_ImagePickerController *)navi;
    _isPreviewing = YES;
}
- (void)endPreviewing
{
    _previewNavi = nil;
    _isPreviewing = NO;
    if (_naviBar == nil) {
        [self configCustomNaviBar];
        [self configBottomToolBar];
        [self configPreviewBar];
        [self configNaviTipsView];
        [self configLivePhotoSign];
        [self configPullDown];
        
        [self refreshNaviBarAndBottomBarState];
    }
}

- (TFY_ImagePickerController *)navi
{
    return _isPreviewing ? _previewNavi : (TFY_ImagePickerController *)self.navigationController;
}

- (void)setPulldelegate:(id<TFYPhotoPreviewControllerPullDelegate>)pulldelegate
{
    _pulldelegate = pulldelegate;
    if ([pulldelegate respondsToSelector:@selector(picker_PhotoPreviewControllerPullBlackgroundView)]) {
        self.pullBackgroundView = [pulldelegate picker_PhotoPreviewControllerPullBlackgroundView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:backgroundView];
    _backgroundView = backgroundView;
    
    [self checkDefaultSelectedModels];
    
    [self configCollectionView];
    if (self.isPreviewing == NO) {
        [self configCustomNaviBar];
        [self configBottomToolBar];
        [self configPreviewBar];
        [self configNaviTipsView];
        [self configLivePhotoSign];
        [self configPullDown];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏状态栏而不改变安全区域的高度
    TFYAppWindow().windowLevel = UIWindowLevelStatusBar + 1;
    [self refreshNaviBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    TFYAppWindow().windowLevel = UIWindowLevelNormal;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (@available(iOS 13.0, *)) {
        TFY_ImagePickerController *imagePickerVc = [self navi];
        if (imagePickerVc.modalPresentationStyle == UIModalPresentationPageSheet) {
            imagePickerVc.presentationController.delegate = self;
            // 手动接收dismiss
            self.modalInPresentation = YES;
        }
    }
    if (self.isFirstLoad) {
        self.isFirstLoad = NO;
        // 首次启动，设置cell为播放状态。
        [[_collectionView visibleCells] makeObjectsPerformSelector:@selector(didDisplayCell)];
    }
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (_isPulling) return;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    _panGesture.enabled = (orientation == UIInterfaceOrientationPortrait);
    
    UIEdgeInsets ios11Safeinsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        ios11Safeinsets = self.view.safeAreaInsets;
    }
    /* 适配导航栏 */
    CGFloat naviBarHeight = 0, naviSubBarHeight = 0;
    naviBarHeight = naviSubBarHeight = CGRectGetHeight([self navi].navigationBar.frame);
    if (@available(iOS 11.0, *)) {
        naviBarHeight += ios11Safeinsets.top;
    } else {
        naviBarHeight += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    }

    _naviBar.frame = CGRectMake(0, 0, self.view.frame.size.width, naviBarHeight);
    CGRect naviSubBarRect = CGRectMake(0, naviBarHeight-naviSubBarHeight, self.view.frame.size.width, naviSubBarHeight);
    if (@available(iOS 11.0, *)) {
        naviSubBarRect.origin.x += ios11Safeinsets.left;
        naviSubBarRect.size.width -= ios11Safeinsets.left + ios11Safeinsets.right;
    }
    _naviSubBar.frame = naviSubBarRect;
    
    {
        CGRect tmpRect = _backButton.frame;
        tmpRect.size.height = CGRectGetHeight(_naviSubBar.frame);
        _backButton.frame = tmpRect;
    }
    {
        CGRect tmpRect = _selectButton.frame;
        tmpRect.origin.y = (CGRectGetHeight(_naviSubBar.frame)-CGRectGetHeight(_selectButton.frame))/2;
        _selectButton.frame = tmpRect;
    }
    {
        CGRect tmpRect = _titleLabel.frame;
        tmpRect.origin.y = (CGRectGetHeight(_naviSubBar.frame)-CGRectGetHeight(_titleLabel.frame))/2;
        _titleLabel.frame = tmpRect;
    }
    
    /** 适配提示栏 */
    _naviTipsView.frame = CGRectMake(0, CGRectGetMaxY(_naviBar.frame), self.view.frame.size.width, naviTipsViewDefaultHeight);
    
    /* 适配标记图标 */
    CGFloat livePhotoSignViewY = (_naviTipsView.alpha == 0) ? CGRectGetMaxY(_naviBar.frame) : CGRectGetMaxY(_naviTipsView.frame);
    {
        CGRect tempRect = _livePhotoSignView.frame;
        tempRect.origin.x = CGRectGetMinX(_naviBar.frame) + livePhotoSignMargin + ios11Safeinsets.left;
        tempRect.origin.y = livePhotoSignViewY + livePhotoSignMargin;
        _livePhotoSignView.frame = tempRect;
    }
    
    /* 适配底部栏 */
    CGFloat toolbarHeight = toolbarDefaultHeight;
    if (@available(iOS 11.0, *)) {
        toolbarHeight += self.view.safeAreaInsets.bottom;
    }
    _toolBar.frame = CGRectMake(0, self.view.frame.size.height - toolbarHeight, self.view.frame.size.width, toolbarHeight);
    CGRect toolbarRect = _toolBar.bounds;
    if (@available(iOS 11.0, *)) {
        toolbarRect.origin.x += self.view.safeAreaInsets.left;
        toolbarRect.size.width -= self.view.safeAreaInsets.left + self.view.safeAreaInsets.right;
    }
    _toolSubBar.frame = toolbarRect;
    
    /* 适配预览栏 */
    _previewMainBar.frame = CGRectMake(0, _toolBar.frame.origin.y - previewBarDefaultHeight, self.view.frame.size.width, previewBarDefaultHeight);
    CGRect previewBarRect = _previewMainBar.bounds;
    if (@available(iOS 11.0, *)) {
        previewBarRect.origin.x += self.view.safeAreaInsets.left;
        previewBarRect.size.width -= self.view.safeAreaInsets.left + self.view.safeAreaInsets.right;
    }
    _previewBar.frame = previewBarRect;

    _backgroundView.frame = self.view.bounds;
    /** 重新排版 */
    [_collectionView.collectionViewLayout invalidateLayout];
    /* 适配宫格视图 */
    _collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width+cellMargin, self.view.frame.size.height);
    _collectionView.contentSize = CGSizeMake(_models.count * (_collectionView.frame.size.width), 0);
    if (_models.count) [_collectionView setContentOffset:CGPointMake((_collectionView.frame.size.width) * _currentIndex, 0) animated:NO];
}

- (void)dealloc
{
    [TFY_GifPlayerManager free];
}

- (void)configCustomNaviBar {
    TFY_ImagePickerController *imagePickerVc = [self navi];
    CGFloat naviBarHeight = 0, naviSubBarHeight = 0;
    naviBarHeight = naviSubBarHeight = CGRectGetHeight([self navi].navigationBar.frame);
    if (@available(iOS 11.0, *)) {
        naviBarHeight += self.view.safeAreaInsets.top;
    }
    
    _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, naviBarHeight)];
    _naviBar.backgroundColor = imagePickerVc.previewNaviBgColor;
    
    _naviSubBar = [[UIView alloc] initWithFrame:CGRectMake(0, naviBarHeight-naviSubBarHeight, self.view.frame.size.width, naviSubBarHeight)];
    [_naviBar addSubview:_naviSubBar];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, CGRectGetHeight(_naviSubBar.frame))];
    _backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    /** 判断是否预览模式 */
    if (self.isPhotoPreview) {
        /** 取消 */
        [_backButton setTitle:imagePickerVc.cancelBtnTitleStr forState:UIControlStateNormal];
        _backButton.titleLabel.font = imagePickerVc.barItemTextFont;
        CGFloat editCancelWidth = [imagePickerVc.cancelBtnTitleStr picker_boundingSizeWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:_backButton.titleLabel.font].width + 2;
        {
            CGRect tempRect = _backButton.frame;
            tempRect.size.width = editCancelWidth+8;
            _backButton.frame = tempRect;
        }
        _backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    } else {
        UIImage *image = bundleImageNamed(@"navigationbar_back_arrow");
        [_backButton setImage:image forState:UIControlStateNormal];
        _backButton.imageEdgeInsets = UIEdgeInsetsMake(0, image.size.width-50+8*2, 0, 0);
    }
    [_backButton setTitleColor:imagePickerVc.barItemTextColor forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_naviSubBar addSubview:_backButton];
    
    _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_naviSubBar.frame) - 30 - 8, (CGRectGetHeight(_naviSubBar.frame)-30)/2, 30, 30)];
    _selectButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_selectButton setImage:bundleImageNamed(imagePickerVc.photoDefImageName) forState:UIControlStateNormal];
    [_selectButton setImage:bundleImageNamed(imagePickerVc.photoSelImageName) forState:UIControlStateSelected];
    [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    [_naviSubBar addSubview:_selectButton];
    
    if (imagePickerVc.displayImageFilename) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = imagePickerVc.naviTitleFont;
        CGFloat height = [@"A" picker_boundingSizeWithSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(_naviSubBar.frame)) font:_titleLabel.font].height;
        
        CGFloat titleMargin = MAX(_backButton.frame.size.width, _selectButton.frame.size.width) + 8;
        
        _titleLabel.frame = CGRectMake(titleMargin, (CGRectGetHeight(_naviSubBar.frame)-height)/2, CGRectGetWidth(_naviSubBar.frame) - titleMargin * 2, height);
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_naviSubBar addSubview:_titleLabel];
    }
    
    [self.view addSubview:_naviBar];
}

- (void)configBottomToolBar {
    
    TFY_ImagePickerController *imagePickerVc = [self navi];
    UIColor *toolbarBGColor = imagePickerVc.toolbarBgColor;
    UIColor *toolbarTitleColorNormal = imagePickerVc.toolbarTitleColorNormal;
    UIColor *toolbarTitleColorDisabled = imagePickerVc.toolbarTitleColorDisabled;
    UIFont *toolbarTitleFont = imagePickerVc.toolbarTitleFont;
    
    CGFloat toolbarHeight = toolbarDefaultHeight;
    if (@available(iOS 11.0, *)) {
        toolbarHeight += self.view.safeAreaInsets.bottom;
    }
    
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - toolbarHeight, self.view.frame.size.width, toolbarHeight)];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _toolBar.backgroundColor = toolbarBGColor;
    
    UIView *toolSubBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, toolbarDefaultHeight)];
    toolSubBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _toolSubBar = toolSubBar;
    if (imagePickerVc.allowEditing) {
        CGFloat editWidth = [imagePickerVc.editBtnTitleStr picker_boundingSizeWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:toolbarTitleFont].width + 10;
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(12, 0, editWidth, CGRectGetHeight(_toolSubBar.frame));
        _editButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _editButton.titleLabel.font = toolbarTitleFont;
        [_editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_editButton setTitle:imagePickerVc.editBtnTitleStr forState:UIControlStateNormal];
        [_editButton setTitleColor:toolbarTitleColorNormal forState:UIControlStateNormal];
        [_editButton setTitleColor:[toolbarTitleColorNormal colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateHighlighted];
        [_editButton setTitleColor:toolbarTitleColorDisabled forState:UIControlStateDisabled];
    }
    if (imagePickerVc.allowPickingOriginalPhoto) {
        CGFloat fullImageWidth = [imagePickerVc.fullImageBtnTitleStr picker_boundingSizeWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:toolbarTitleFont].width;
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = fullImageWidth + 56;
        BOOL allowEditing = imagePickerVc.allowEditing;
        if (!allowEditing) { /** 非编辑模式 原图显示在左边 */
            _originalPhotoButton.frame = CGRectMake(0, 0, width, CGRectGetHeight(_toolSubBar.frame));
            _originalPhotoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        } else {
            _originalPhotoButton.frame = CGRectMake((CGRectGetWidth(_toolSubBar.frame)-width)/2, 0, width, CGRectGetHeight(_toolSubBar.frame));
            _originalPhotoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        }
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        _originalPhotoButton.backgroundColor = [UIColor clearColor];
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = toolbarTitleFont;
        [_originalPhotoButton setTitle:imagePickerVc.fullImageBtnTitleStr forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:imagePickerVc.fullImageBtnTitleStr forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:toolbarTitleColorNormal forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[toolbarTitleColorNormal colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateHighlighted];
        [_originalPhotoButton setTitleColor:toolbarTitleColorNormal forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[toolbarTitleColorNormal colorWithAlphaComponent:kControlStateHighlightedAlpha] forState:UIControlStateSelected|UIControlStateHighlighted];
        [_originalPhotoButton setTitleColor:toolbarTitleColorDisabled forState:UIControlStateDisabled];
        [_originalPhotoButton setImage:bundleImageNamed(imagePickerVc.photoOriginDefImageName) forState:UIControlStateNormal];
        [_originalPhotoButton setImage:bundleImageNamed(imagePickerVc.photoOriginSelImageName) forState:UIControlStateSelected];
        [_originalPhotoButton setImage:bundleImageNamed(imagePickerVc.photoOriginSelImageName) forState:UIControlStateSelected|UIControlStateHighlighted];
        _originalPhotoButton.adjustsImageWhenHighlighted = NO;
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 42, 0, 80, CGRectGetHeight(_toolSubBar.frame));
        if (!allowEditing) { /** 非编辑模式 原图显示在左边 */
            _originalPhotoLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        } else {
            _originalPhotoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        }
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = toolbarTitleFont;
        _originalPhotoLabel.textColor = toolbarTitleColorNormal;
        _originalPhotoLabel.backgroundColor = [UIColor clearColor];
        [_originalPhotoButton addSubview:_originalPhotoLabel];
    }
    
    _videoPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _videoPlayButton.frame = CGRectMake((CGRectGetWidth(_toolSubBar.frame)-CGRectGetHeight(_toolSubBar.frame))/2, 0, CGRectGetHeight(_toolSubBar.frame), CGRectGetHeight(_toolSubBar.frame));
    _videoPlayButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [_videoPlayButton setImage:bundleImageNamed(imagePickerVc.videoPlayImageName) forState:UIControlStateNormal];
    [_videoPlayButton setImage:bundleImageNamed(imagePickerVc.videoPlayImageName) forState:UIControlStateNormal];
    [_videoPlayButton setImage:bundleImageNamed(imagePickerVc.videoPauseImageName) forState:UIControlStateSelected];
    [_videoPlayButton setImage:bundleImageNamed(imagePickerVc.videoPauseImageName) forState:UIControlStateSelected|UIControlStateHighlighted];
    [_videoPlayButton addTarget:self action:@selector(videoPlayButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _videoPlayButton.selected = YES; // 默认播放
    _videoPlayButton.hidden = YES;
    
    CGSize doneSize = [[imagePickerVc.doneBtnTitleStr stringByAppendingFormat:@"(%d)", (int)imagePickerVc.maxImagesCount] picker_boundingSizeWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:toolbarTitleFont];
    doneSize.height = MIN(MAX(doneSize.height, CGRectGetHeight(_toolSubBar.frame)), 30);
    doneSize.width += 10;
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(CGRectGetWidth(_toolSubBar.frame) - doneSize.width - 12, (CGRectGetHeight(_toolSubBar.frame)-doneSize.height)/2, doneSize.width, doneSize.height);
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
    
    [toolSubBar addSubview:_editButton];
    [toolSubBar addSubview:_originalPhotoButton];
    [toolSubBar addSubview:_videoPlayButton];
    [toolSubBar addSubview:_doneButton];
    [toolSubBar addSubview:divide];
    [_toolBar addSubview:toolSubBar];
    [self.view addSubview:_toolBar];
}

- (void)configPreviewBar {
    
    TFY_ImagePickerController *imagePickerVc = [self navi];
    UIView *previewMainBar = [[UIView alloc] initWithFrame:CGRectMake(0, _toolBar.frame.origin.y - previewBarDefaultHeight, self.view.frame.size.width, previewBarDefaultHeight)];
    previewMainBar.backgroundColor = imagePickerVc.toolbarBgColor;
    _previewMainBar = previewMainBar;
    
    _previewBar = [[TFY_PickerPreviewBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, previewBarDefaultHeight)];
    _previewBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _previewBar.backgroundColor = [UIColor clearColor];
    _previewBar.borderWidth = 4.f;
    _previewBar.borderColor = imagePickerVc.oKButtonTitleColorNormal;
    _previewBar.dataSource = [imagePickerVc.selectedModels copy];
    /** 预览栏默认全选 */
    _previewBar.selectedDataSource = imagePickerVc.selectedModels;
    _previewBar.selectAsset = [self.models objectAtIndex:self.currentIndex];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(imagePickerVc) weakImagePickerVc = imagePickerVc;
    _previewBar.didSelectItem = ^(TFY_PickerAsset *asset) {
        NSInteger index = [weakSelf.models indexOfObject:asset];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            weakSelf.isMTScroll = YES;
            [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    };
    
    _previewBar.didMoveItem = ^(TFY_PickerAsset *asset, NSInteger sourceIndex, NSInteger destinationIndex) {
        
        if ([weakImagePickerVc.selectedModels containsObject:asset]) {
            //取出移动row数据
            TFY_PickerAsset *asset = weakImagePickerVc.selectedModels[sourceIndex];
            //从数据源中移除该数据
            [weakImagePickerVc.selectedModels removeObject:asset];
            //将数据插入到数据源中的目标位置
            [weakImagePickerVc.selectedModels insertObject:asset atIndex:destinationIndex];
        }
        
        if (weakSelf.alwaysShowPreviewBar) {
            //取出移动row数据
            TFY_PickerAsset *asset = weakSelf.models[sourceIndex];
            //从数据源中移除该数据
            [weakSelf.models removeObject:asset];
            //将数据插入到数据源中的目标位置
            [weakSelf.models insertObject:asset atIndex:destinationIndex];
            
            NSInteger index = weakSelf.currentIndex;
            if (weakSelf.currentIndex == sourceIndex) {
                weakSelf.currentIndex = destinationIndex;
            } else if (sourceIndex > weakSelf.currentIndex && destinationIndex <= weakSelf.currentIndex) {
                weakSelf.currentIndex ++;
            } else if (sourceIndex < weakSelf.currentIndex && destinationIndex >= weakSelf.currentIndex) {
                weakSelf.currentIndex --;
            }
            [weakSelf.collectionView reloadData];
            if (index != weakSelf.currentIndex) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
                weakSelf.isMTScroll = YES;
                [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            }
        }
        
        [weakSelf refreshNaviBarAndBottomBarState];
    };
    [_previewMainBar addSubview:_previewBar];
    
    _previewMainBar.alpha = imagePickerVc.selectedModels.count;
    
    [self.view addSubview:_previewMainBar];
}

- (void)configLivePhotoSign
{
    CGFloat livePhotoSignViewHeight = 30.0;
    _livePhotoSignView = [[UIView alloc] initWithFrame:CGRectMake(livePhotoSignMargin, livePhotoSignMargin + CGRectGetHeight(_naviBar.frame), livePhotoSignViewHeight, livePhotoSignViewHeight)];
    _livePhotoSignView.backgroundColor = [UIColor colorWithWhite:.8f alpha:.8f];
//    _livePhotoSignView.alpha = 0.8f;
    _livePhotoSignView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _livePhotoSignView.layer.masksToBounds = YES;
    _livePhotoSignView.layer.cornerRadius = livePhotoSignViewHeight * 0.2f;
    [self.view addSubview:_livePhotoSignView];
    
    UIImageView *badgeImageView = [[UIImageView alloc] initWithFrame:_livePhotoSignView.bounds];
    badgeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [badgeImageView setImage:[PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent]];
    CALayer *maskLayer = badgeImageView.layer;
    
    
    UIButton *badgeImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    badgeImageButton.frame = _livePhotoSignView.bounds;
    badgeImageButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    badgeImageButton.layer.masksToBounds = YES;
    badgeImageButton.layer.mask = maskLayer;
    
    UIImage *badgeImage = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
    [badgeImageButton setImage:badgeImage forState:UIControlStateNormal];
    [badgeImageButton setImage:badgeImage forState:UIControlStateHighlighted];
    [badgeImageButton setImage:badgeImage forState:UIControlStateSelected | UIControlStateHighlighted];
    [badgeImageButton addTarget:self action:@selector(livePhotoSignButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_livePhotoSignView addSubview:badgeImageButton];
    _livePhotobadgeImageButton = badgeImageButton;
    
    [_livePhotoSignView addSubview:badgeImageView];
    
    _livePhotoSignView.alpha = 0.f;
    
    [self selectedLivePhotobadgeImageButton:YES];
}

- (void)configNaviTipsView {
    
    TFY_ImagePickerController *imagePickerVc = [self navi];
    _naviTipsView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_naviBar.frame), self.view.frame.size.width, naviTipsViewDefaultHeight)];
    _naviTipsView.backgroundColor = imagePickerVc.previewNaviBgColor;
    _naviTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-20, naviTipsViewDefaultHeight)];
    _naviTipsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _naviTipsLabel.font = imagePickerVc.naviTipsFont;
    _naviTipsLabel.textColor = imagePickerVc.naviTipsTextColor;
    _naviTipsLabel.numberOfLines = 1.f;
    _naviTipsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_naviTipsView addSubview:_naviTipsLabel];
    
    UIView *divide = [[UIView alloc] init];
    divide.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.1f];
    divide.frame = CGRectMake(0, 0, self.view.frame.size.width, 1);
    divide.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [_naviTipsView addSubview:divide];
    
    [self.view addSubview:_naviTipsView];
    
    _naviTipsView.alpha = 0.f;
}

- (void)configCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentSize = CGSizeMake(_models.count * (_collectionView.frame.size.width), 0);
    [_collectionView setContentOffset:CGPointMake(_collectionView.frame.size.width * _currentIndex, 0) animated:NO];

    [_collectionView registerClass:[TFY_PhotoPreviewCell class] forCellWithReuseIdentifier:@"TFY_PhotoPreviewCell"];
    [_collectionView registerClass:[TFY_PhotoPreviewGifCell class] forCellWithReuseIdentifier:@"TFY_PhotoPreviewGifCell"];
    [_collectionView registerClass:[TFY_PhotoPreviewLivePhotoCell class] forCellWithReuseIdentifier:@"TFY_PhotoPreviewLivePhotoCell"];
    [_collectionView registerClass:[TFY_PhotoPreviewVideoCell class] forCellWithReuseIdentifier:@"TFY_PhotoPreviewVideoCell"];
    
    [self.view addSubview:_collectionView];
}

- (void)configPullDown
{
    if (self.pullBackgroundView) {
        /** 创建下拉手势 */
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        _panGesture.delegate = self;
        [self.view addGestureRecognizer:_panGesture];
        [self.view insertSubview:self.pullBackgroundView belowSubview:self.backgroundView];
    }
}

#pragma mark - Click Event

- (void)select:(UIButton *)selectButton {
    TFY_ImagePickerController *imagePickerVc = [self navi];
    TFY_PickerAsset *model = _models[_currentIndex];
    if (!selectButton.isSelected) {
        void (^selectedItem)(void) = ^{
            /** 检测是否超过视频最大时长 */
            if (model.type == TFYAssetMediaTypeVideo) {
                TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:model];
                NSTimeInterval duration = videoEdit.editPreviewImage ? videoEdit.duration : model.duration;
                if (picker_videoDuration(duration) > imagePickerVc.maxVideoDuration) {
                    if (imagePickerVc.maxVideoDuration < 60) {
                        [imagePickerVc showAlertWithTitle:[NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText_second"], (int)imagePickerVc.maxVideoDuration]];
                    } else {
                        [imagePickerVc showAlertWithTitle:[NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText_minute"], (int)imagePickerVc.maxVideoDuration/60]];
                    }
                    return;
                }
            }
            if (self.alwaysShowPreviewBar) {
                NSArray *dataSource = self->_previewBar.dataSource;
                NSInteger index = [dataSource indexOfObject:model];
                if (imagePickerVc.selectedModels.count == 0) {
                    [imagePickerVc.selectedModels addObject:model];
                } else {
                    for (NSInteger k=0; k<imagePickerVc.selectedModels.count; k++) {
                        TFY_PickerAsset *selectedModel = imagePickerVc.selectedModels[k];
                        NSInteger selectedIndex = [dataSource indexOfObject:selectedModel];
                        if (selectedIndex > index) {
                            [imagePickerVc.selectedModels insertObject:model atIndex:k];
                            break;
                        } else if (k == imagePickerVc.selectedModels.count-1) {
                            [imagePickerVc.selectedModels addObject:model];
                            break;
                        }
                    }
                }
            } else {
                [imagePickerVc.selectedModels addObject:model];
            }
        };
        
        if (imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount && model.type == TFYAssetMediaTypeVideo) {
            // 1. select:check if over the maxVideosCount / 选择视频,检查是否超过了最大个数的限制
            if (imagePickerVc.selectedModels.count >= imagePickerVc.maxVideosCount) {
                NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText"], imagePickerVc.maxVideosCount];
                [imagePickerVc showAlertWithTitle:title];
                return;
            } else {
                // 2. if not over the maxImagesCount / 如果没有超过最大个数限制
                selectedItem();
            }
        } else {
            // 1. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            if (imagePickerVc.selectedModels.count >= imagePickerVc.maxImagesCount) {
                NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectPhotoTipText"], imagePickerVc.maxImagesCount];
                [imagePickerVc showAlertWithTitle:title];
                return;
            } else {
                // 2. if not over the maxImagesCount / 如果没有超过最大个数限制
                selectedItem();
            }
        }
        
    } else {
        
        [imagePickerVc.selectedModels removeObject:model];
    }
    
    /** 非总是显示模式，添加对象 */
    if (!self.alwaysShowPreviewBar) {
        if ([imagePickerVc.selectedModels containsObject:model]) {
            [_previewBar addAssetInDataSource:model];
        } else {
            [_previewBar removeAssetInDataSource:model];
        }
    }
    
    [self refreshNaviBarAndBottomBarState];
    if ([imagePickerVc.selectedModels containsObject:model]) {
        [UIView showOscillatoryAnimationWithLayer:selectButton.imageView.layer type:OscillatoryAnimationToBigger];
    }
}

- (void)backButtonClick {
    TFY_ImagePickerController *imagePickerVc = [self navi];
    /** 判断是否预览模式 */
    if (self.isPhotoPreview) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([imagePickerVc respondsToSelector:@selector(cancelButtonClick)]) {
            [imagePickerVc performSelector:@selector(cancelButtonClick)];
        }
#pragma clang diagnostic pop
    } else {
        [imagePickerVc popViewControllerAnimated:YES];
        if (self.backButtonClickBlock) {
            self.backButtonClickBlock();
            _backButtonClickBlock = nil;
        }
    }
}

- (void)doneButtonClick {
    TFY_ImagePickerController *imagePickerVc = [self navi];
    // 如果没有选中过照片 点击确定时选中当前预览的照片
    if (imagePickerVc.autoSelectCurrentImage && imagePickerVc.selectedModels.count == 0) {
        TFY_PickerAsset *model = _models[_currentIndex];
        NSUInteger selectedCount = imagePickerVc.minImagesCount;
        if (imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount && model.type == TFYAssetMediaTypeVideo) {
            selectedCount = imagePickerVc.minVideosCount;
        }
        if (selectedCount == 0) {
            /** 检测是否超过视频最大时长 */
            if (model.type == TFYAssetMediaTypeVideo) {
                TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:model];
                NSTimeInterval duration = videoEdit.editPreviewImage ? videoEdit.duration : model.duration;
                if (picker_videoDuration(duration) > imagePickerVc.maxVideoDuration) {
                    if (imagePickerVc.maxVideoDuration < 60) {
                        [imagePickerVc showAlertWithTitle:[NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText_second"], (int)imagePickerVc.maxVideoDuration]];
                    } else {
                        [imagePickerVc showAlertWithTitle:[NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText_minute"], (int)imagePickerVc.maxVideoDuration/60]];
                    }
                    return;
                }
            }
            [imagePickerVc.selectedModels addObject:model];
        } else {
            // 判断是否满足最小必选张数的限制
            if (model.type == TFYAssetMediaTypeVideo) {
                NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_minSelectVideoTipText"], imagePickerVc.minVideosCount];
                [imagePickerVc showAlertWithTitle:title];
                
                return;
            } else if (model.type == TFYAssetMediaTypePhoto) {
                NSString *title = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_minSelectPhotoTipText"], imagePickerVc.minImagesCount];
                [imagePickerVc showAlertWithTitle:title];
                return;
            }
        }
    }

    if (self.doneButtonClickBlock) {
        self.doneButtonClickBlock();
        _doneButtonClickBlock = nil;
    }
}

- (void)editButtonClick {
    if (self.models.count > self.currentIndex) {
        TFY_ImagePickerController *imagePickerVc = [self navi];
        /** 获取缓存编辑对象 */
        TFY_PickerAsset *model = [self.models objectAtIndex:self.currentIndex];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
        TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        TFY_BaseEditingController *editingVC = nil;
        
        if (model.type == TFYAssetMediaTypePhoto) {
            TFY_PhotoEditingController *photoEditingVC = [[TFY_PhotoEditingController alloc] init];
            editingVC = photoEditingVC;
            
            TFY_PhotoEdit *photoEdit = [[TFY_PhotoEditManager manager] photoEditForAsset:model];
            if (photoEdit) {
                photoEditingVC.photoEdit = photoEdit;
            } else {
                /** 当前显示的图片 */
                UIImage *image = cell.previewImage;
                if (image == nil) {
                    [imagePickerVc showAlertWithTitle:[NSBundle picker_localizedStringForKey:@"_LFPhotoPreviewController_EditPhotoTipText"] complete:^{}];
                    return;
                }
                photoEditingVC.editImage = image;
            }
            photoEditingVC.delegate = self;
            if (imagePickerVc.photoEditLabrary) {
                imagePickerVc.photoEditLabrary(photoEditingVC);
            }
        } else if (model.type == TFYAssetMediaTypeVideo) {
            TFY_VideoEditingController *videoEditingVC = [[TFY_VideoEditingController alloc] init];
            editingVC = videoEditingVC;
            videoEditingVC.operationAttrs = @{TFYVideoEditClipMinDurationAttributeName:@(3.f)};
            
            TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:model];
            if (videoEdit) {
                videoEditingVC.videoEdit = videoEdit;
            } else {
                /** 当前显示的视频 */
                AVAsset *asset = nil;
                if ([cell isKindOfClass:TFY_PhotoPreviewVideoCell.class]) {
                    asset = ((TFY_PhotoPreviewVideoCell *)cell).asset;
                }
                if (asset == nil) {
                    [imagePickerVc showAlertWithTitle:[NSBundle picker_localizedStringForKey:@"_LFPhotoPreviewController_EditVideoTipText"] complete:^{}];
                    return;
                }
                [videoEditingVC setVideoAsset:asset placeholderImage:cell.previewImage];
            }

            NSTimeInterval duration = videoEdit.editPreviewImage ? videoEdit.duration : model.duration;
            
            if (picker_videoDuration(duration) > imagePickerVc.maxVideoDuration) {
                videoEditingVC.defaultOperationType = TFYVideoEditOperationType_clip;
                videoEditingVC.operationAttrs = @{TFYVideoEditClipMaxDurationAttributeName:@(imagePickerVc.maxVideoDuration)};
            }
            
            videoEditingVC.delegate = self;
            if (imagePickerVc.videoEditLabrary) {
                imagePickerVc.videoEditLabrary(videoEditingVC);
            }
        }
        
        if (editingVC) {
            [imagePickerVc pushViewController:editingVC animated:NO];
            [cell willEndDisplayCell]; // 暂停
            [cell didEndDisplayCell]; // 停止
        }
    }
}

- (void)originalPhotoButtonClick {
    
    TFY_ImagePickerController *imagePickerVc = [self navi];
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    imagePickerVc.isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_originalPhotoButton.selected) {
        if (!_selectButton.isSelected) {
            // 如果当前已选择照片张数 < 最大可选张数 && 最大可选张数大于1，就选中该张图
            if (imagePickerVc.selectedModels.count < imagePickerVc.maxImagesCount) {
                [self select:_selectButton];
            }
        }
        [self showPhotoBytes];
        [self checkSelectedPhotoBytes];
    } else {
        _originalPhotoLabel.text = nil;
    }
}

- (void)videoPlayButtonClick
{
    TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    if ([cell isKindOfClass:TFY_PhotoPreviewVideoCell.class]) {
        TFY_PhotoPreviewVideoCell *videoCell = (TFY_PhotoPreviewVideoCell *)cell;
        if (_videoPlayButton.isSelected) {
            [videoCell didPauseCell];
        } else {
            [videoCell didPlayCell];
        }
    }
}

- (void)livePhotoSignButtonClick:(UIButton *)button
{
    [self selectedLivePhotobadgeImageButton:!button.isSelected];
    TFY_PickerAsset *model = _models[_currentIndex];
    model.closeLivePhoto = !model.closeLivePhoto;
    TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    if ([cell isKindOfClass:TFY_PhotoPreviewLivePhotoCell.class]) {
        TFY_PhotoPreviewLivePhotoCell *livephotoCell = (TFY_PhotoPreviewLivePhotoCell *)cell;
        if (model.closeLivePhoto) {
            [livephotoCell didStopCell];
        } else {
            [livephotoCell didPlayCell];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isMTScroll = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_isMTScroll) {
        CGFloat offSetWidth = scrollView.contentOffset.x;
        offSetWidth = offSetWidth +  (_collectionView.frame.size.width/2);
        
        NSInteger currentIndex = offSetWidth / (_collectionView.frame.size.width);
        
        if (currentIndex < _models.count && _currentIndex != currentIndex) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
            TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell willEndDisplayCell];
            
            _currentIndex = currentIndex;
            
            indexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
            cell = (TFY_PhotoPreviewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell didDisplayCell];
            
            [self refreshNaviBarAndBottomBarState];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _isMTScroll = NO;
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TFY_PhotoPreviewCell *cell = nil;
    TFY_PickerAsset *model = _models[indexPath.row];
    TFY_ImagePickerController *imagePickerVc = [self navi];
    if (model.type == TFYAssetMediaTypeVideo) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFY_PhotoPreviewVideoCell" forIndexPath:indexPath];
    } else {
        if (imagePickerVc.allowPickingType & TFYPickingMediaTypeGif && model.subType == TFYAssetSubMediaTypeGIF) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFY_PhotoPreviewGifCell" forIndexPath:indexPath];
        } else if (imagePickerVc.allowPickingType & TFYPickingMediaTypeLivePhoto && model.subType == TFYAssetSubMediaTypeLivePhoto) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFY_PhotoPreviewLivePhotoCell" forIndexPath:indexPath];
        } else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFY_PhotoPreviewCell" forIndexPath:indexPath];
        }
    }
    cell.delegate = self;
    cell.model = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [(TFY_PhotoPreviewCell *)cell willDisplayCell];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [(TFY_PhotoPreviewCell *)cell didEndDisplayCell];
}

#pragma mark -  UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIEdgeInsets ios11Safeinsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        ios11Safeinsets = self.view.safeAreaInsets;
    }
    return CGSizeMake(self.view.frame.size.width-ios11Safeinsets.left-ios11Safeinsets.right, self.view.frame.size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets ios11Safeinsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        ios11Safeinsets = self.view.safeAreaInsets;
    }
    return UIEdgeInsetsMake(0, ios11Safeinsets.left, 0, cellMargin+ios11Safeinsets.right);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets ios11Safeinsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        ios11Safeinsets = self.view.safeAreaInsets;
    }
    return cellMargin+ios11Safeinsets.left+ios11Safeinsets.right;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - TFYPhotoPreviewCellDelegate
- (void)picker_photoPreviewCellSingleTapHandler:(TFY_PhotoPreviewCell *)cell
{
    // show or hide naviBar / 显示或隐藏导航栏
    self.isHideMyNaviBar = !self.isHideMyNaviBar;
    CGFloat alpha = self.isHideMyNaviBar ? 0.f : 1.f;
    [self changedAplhaWithItem:cell.model alpha:alpha];
}

#pragma mark - TFYPhotoPreviewVideoCellDelegate
- (void)picker_photoPreviewVideoCellDidPlayHandler:(TFY_PhotoPreviewVideoCell *)cell
{
    _videoPlayButton.selected = YES;
}
- (void)picker_photoPreviewVideoCellDidStopHandler:(TFY_PhotoPreviewVideoCell *)cell
{
    _videoPlayButton.selected = NO;
}

#pragma mark - TFYPhotoEditingControllerDelegate
- (void)picker_PhotoEditingControllerDidCancel:(TFY_PhotoEditingController *)photoEditingVC
{

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
    TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [[self navi] popViewControllerAnimated:NO];
    [cell didDisplayCell];
}
- (void)picker_PhotoEditingController:(TFY_PhotoEditingController *)photoEditingVC didFinishPhotoEdit:(TFY_PhotoEdit *)photoEdit
{
    if (self.models.count > self.currentIndex) {
        TFY_PickerAsset *model = [self.models objectAtIndex:self.currentIndex];
        /** 缓存对象 */
        [[TFY_PhotoEditManager manager] setPhotoEdit:photoEdit forAsset:model];
        
        /** 当前页面只显示一张图片 */
        TFY_ImagePickerController *imagePickerVc = [self navi];
        BOOL pop = NO;
        __weak typeof(self) weakSelf = self;
        __weak typeof(imagePickerVc) weakImagePickerVc = imagePickerVc;
        if (photoEdit) { /** 编辑存在 */
            if (_collectionView) {
                pop = YES;
                [_collectionView performBatchUpdates:^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                } completion:^(BOOL finished) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
                    TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                    [weakImagePickerVc popViewControllerAnimated:NO];
                    [cell didDisplayCell];
                }];
            }
        } else { /** 编辑不存在 */
            if (_collectionView) { /** 不存在编辑不做reloadData操作，避免重新获取图片时会先获取模糊图片再到高清图片，可能出现闪烁的现象 */
                /** 还原编辑图片 */
                pop = YES;
                [_collectionView performBatchUpdates:^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                } completion:^(BOOL finished) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
                    TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                    [weakImagePickerVc popViewControllerAnimated:NO];
                    [cell didDisplayCell];
                }];
            }
        }
        
        if (!pop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
            TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
            [imagePickerVc popViewControllerAnimated:NO];
            [cell didDisplayCell];
        }
        
        if (imagePickerVc.maxImagesCount > 1) {
            /** 默认选中编辑后的图片 */
            if (photoEdit && !_selectButton.isSelected) {
                [self select:_selectButton];
            } else if (!photoEdit && _selectButton.isSelected) {
                /** 检测是否超过图片最大大小 */
                [self checkSelectedPhotoBytes];
            }
        }
    }
}

#pragma mark - TFYVideoEditingControllerDelegate
- (void)picker_VideoEditingControllerDidCancel:(TFY_VideoEditingController *)videoEditingVC
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
    TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [[self navi] popViewControllerAnimated:NO];
    [cell didDisplayCell];
    
}
- (void)picker_VideoEditingController:(TFY_VideoEditingController *)videoEditingVC didFinishPhotoEdit:(TFY_VideoEdit *)videoEdit
{
    TFY_ImagePickerController *imagePickerVc = [self navi];
    if (self.models.count > self.currentIndex) {
        TFY_PickerAsset *model = [self.models objectAtIndex:self.currentIndex];
        /** 缓存对象 */
        [[TFY_VideoEditManager manager] setVideoEdit:videoEdit forAsset:model];
        
        BOOL pop = NO;
        __weak typeof(self) weakSelf = self;
        __weak typeof(imagePickerVc) weakImagePickerVc = imagePickerVc;
        if (videoEdit) { /** 编辑存在 */
            if (_collectionView) {
                pop = YES;
                [_collectionView performBatchUpdates:^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                } completion:^(BOOL finished) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
                    TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                    [weakImagePickerVc popViewControllerAnimated:NO];
                    [cell didDisplayCell];
                }];
            }
        } else { /** 编辑不存在 */
            if (_collectionView) { /** 不存在编辑不做reloadData操作，避免重新获取图片时会先获取模糊图片再到高清图片，可能出现闪烁的现象 */
                /** 还原编辑图片 */
                pop = YES;
                [_collectionView performBatchUpdates:^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                } completion:^(BOOL finished) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
                    TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                    [weakImagePickerVc popViewControllerAnimated:NO];
                    [cell didDisplayCell];
                }];
            }
        }
        
        if (!pop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
            TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
            [imagePickerVc popViewControllerAnimated:NO];
            [cell didDisplayCell];
        }
        
        
        NSTimeInterval duration = videoEdit.editPreviewImage ? videoEdit.duration : model.duration;
        
        if (imagePickerVc.maxVideosCount > 1) {
            /** 默认选中编辑后的视频 */
            if (picker_videoDuration(duration) > imagePickerVc.maxVideoDuration && _selectButton.isSelected) {
                [self select:_selectButton];
            } else if (videoEdit.editPreviewImage && !_selectButton.isSelected) {
                if (picker_videoDuration(duration) <= imagePickerVc.maxVideoDuration) {
                    [self select:_selectButton];
                }
            }
        }
    }
}

#pragma mark - UIAdaptivePresentationControllerDelegate
- (void)presentationControllerDidAttemptToDismiss:(UIPresentationController *)presentationController
{
    TFY_ImagePickerController *imagePickerVc = [self navi];
    if (imagePickerVc.topViewController != self) return;
    
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

#pragma mark - 下拉手势处理
-(void)panGesture:(id)sender
{
    UIPanGestureRecognizer *panGesture = sender;

    CGPoint movePoint = [panGesture translationInView:self.view];
    
    /** 优先判断：
        1、下拉
        2、操作在2次内完成
     */
    if (panGesture.state == UIGestureRecognizerStateChanged && !_isPulling) {
        if (_pullTimes > 1) return;
        CGFloat offsetY = movePoint.y - _beginPoint.y;
        CGFloat offsetX = fabs(movePoint.x - _beginPoint.x);
        if (!(offsetY > offsetX)) {
            ++_pullTimes;
            return;
        }
    }
    
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:{
            
            // 缩放不触发
            TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
            if (cell.scrollView.zoomScale != 1.0) {
                return;
            }
            _isPullBegan = YES;
            _beginPoint = movePoint;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (_isPullBegan) {
                
                if (!_isPulling) { // 首次触发时，创建临时视图来实现拖动
                    TFY_PhotoPreviewCell *cell = (TFY_PhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
                    _pullSnapshotView = cell.imageContainerView;
                    _pullSnapshotSuperView = cell.imageContainerView.superview;
                    _pullSnapshotView.frame = [cell convertRect:cell.imageContainerView.frame toView:self.view];
                    [self.view insertSubview:_pullSnapshotView aboveSubview:self.collectionView];
                    self.collectionView.hidden = YES;
                }
                
                CGFloat pullSnapshotViewInnerMidX = _pullSnapshotView.bounds.size.width / 2;
                CGFloat pullSnapshotViewInnerMidY = _pullSnapshotView.bounds.size.height / 2;
                static CGFloat ratioX = 0;
                static CGFloat ratioY = 0;
                if (!_isPulling) { // 首次触发时，计算落点在视图的比例
                    CGPoint locationPoint = [panGesture locationInView:self.view];
                    CGFloat innerX = locationPoint.x - _pullSnapshotView.frame.origin.x;
                    CGFloat innerY = locationPoint.y - _pullSnapshotView.frame.origin.y;
                    /** 计算开始拖动的点在视图的比例位置，视图位置分别是：以中心为标准值0，top，left为1，bottom，right为-1 */
                    if (innerX > pullSnapshotViewInnerMidX) {
                        ratioX = -1 * (innerX - pullSnapshotViewInnerMidX) / pullSnapshotViewInnerMidX;
                    } else if (innerX < pullSnapshotViewInnerMidX) {
                        ratioX = (pullSnapshotViewInnerMidX - innerX) / pullSnapshotViewInnerMidX;
                    } else {
                        ratioX = 0;
                    }
                    if (innerY > pullSnapshotViewInnerMidY) {
                        ratioY = -1 * (innerY - pullSnapshotViewInnerMidY) / pullSnapshotViewInnerMidY;
                    } else if (innerY < pullSnapshotViewInnerMidY) {
                        ratioY = (pullSnapshotViewInnerMidY - innerY) / pullSnapshotViewInnerMidY;
                    } else {
                        ratioY = 0;
                    }
                }
                
                
                _isPulling = YES;
                
                CGFloat distance = 1.0;
                CGFloat minScale = 0.4;
                if (_beginPoint.y < movePoint.y) {
                    CGFloat length = self.view.frame.size.height * 0.65;
                    distance = (length - (movePoint.y - _beginPoint.y)) / length;
                    distance = MAX(distance, minScale);
                }
                
                CGFloat moveX = (movePoint.x - _beginPoint.x);
                CGFloat moveY = (movePoint.y - _beginPoint.y);
                
                
                CGAffineTransform t = CGAffineTransformIdentity;
                /** 跟随移动点移动 */
                t = CGAffineTransformTranslate(t, moveX, moveY);
                /** 缩放至原大小的distance倍 */
                t = CGAffineTransformScale(t, distance, distance);
                /** 缩放后移动点的位置会以中心为准，偏移到移动点的真实比例位置 */
                t = CGAffineTransformTranslate(t, ratioX * -pullSnapshotViewInnerMidX * (1-distance) / distance, ratioY * -pullSnapshotViewInnerMidY * (1-distance) / distance);
                _pullSnapshotView.transform = t;
                /** 通过距离计算alpha的变化 将1~0.4区间换算为1～0区间值 */
                CGFloat n = 100; // 分n等份
                CGFloat per = (1-minScale)/n; // 每等份的距离
                CGFloat m = (distance - minScale) / per; // 计算第几等份 (总数-最小区间)/每等份的距离
                CGFloat alpha = 1/n*m; // 1～0每等份的距离*第几等份=总数
                
                self.backgroundView.alpha = alpha;
                if (!self.isHideMyNaviBar) {
                    [self changedAplhaWithItem:self.models[self.currentIndex] alpha:alpha];
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            _originalPoint = _beginPoint = _endPoint = CGPointZero;
            if (_isPullBegan && _isPulling) { /** 有触发滑动情况 */
                panGesture.enabled = NO;
                if (_pullSnapshotView.frame.size.width/_pullSnapshotSuperView.frame.size.width < .95 && _pullSnapshotView.transform.a < .95) { // 返回上一个界面
                    CGRect targetRect = CGRectZero;
                    if ([self.pulldelegate respondsToSelector:@selector(picker_PhotoPreviewControllerPullItemRect:)]) {
                        targetRect = [self.pulldelegate picker_PhotoPreviewControllerPullItemRect:self.models[self.currentIndex]];
                    }
                    if (CGRectEqualToRect(CGRectZero, targetRect)) {
                        [UIView animateWithDuration:0.25 animations:^{
                            self.backgroundView.alpha = 0.0;
                            if (!self.isHideMyNaviBar) {
                                [self changedAplhaWithItem:self.models[self.currentIndex] alpha:0];
                            }
                            self->_pullSnapshotView.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            TFY_ImagePickerController *imagePickerVc = [self navi];
                            [imagePickerVc popViewControllerAnimated:NO];
                            if (self.backButtonClickBlock) {
                                self.backButtonClickBlock();
                                self->_backButtonClickBlock = nil;
                            }
                        }];
                    } else {
                        // 移动到目标位置
                        CGRect rect = _pullSnapshotView.frame;
                        _pullSnapshotView.transform = CGAffineTransformIdentity;
                        _pullSnapshotView.frame = rect;
                        [UIView animateWithDuration:0.25 animations:^{
                            self.backgroundView.alpha = 0.0;
                            if (!self.isHideMyNaviBar) {
                                [self changedAplhaWithItem:self.models[self.currentIndex] alpha:0];
                            }
                            self->_pullSnapshotView.frame = targetRect;
                        } completion:^(BOOL finished) {
                            TFY_ImagePickerController *imagePickerVc = [self navi];
                            [imagePickerVc popViewControllerAnimated:NO];
                            if (self.backButtonClickBlock) {
                                self.backButtonClickBlock();
                                self->_backButtonClickBlock = nil;
                            }
                        }];
                    }
                } else { // 还原界面
                    [UIView animateWithDuration:0.25 animations:^{
                        self->_pullSnapshotView.transform = CGAffineTransformIdentity;
                        self.backgroundView.alpha = 1.0;
                        if (!self.isHideMyNaviBar) {
                            [self changedAplhaWithItem:self.models[self.currentIndex] alpha:1.0];
                        }
                    } completion:^(BOOL finished) {
                        self.collectionView.hidden = NO;
                        [self.pullSnapshotSuperView addSubview:self->_pullSnapshotView];
                        self->_pullSnapshotView = nil;
                        self.pullSnapshotSuperView = nil;
                        panGesture.enabled = YES;
                    }];
                }
            }
            _isPullBegan = NO;
            _isPulling = NO;
            _pullTimes = 0;
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            _originalPoint = _beginPoint = _endPoint = CGPointZero;
            if (_isPullBegan && _isPulling) { /** 有触发滑动情况 */
                panGesture.enabled = NO;
                [UIView animateWithDuration:0.25 animations:^{
                    self->_pullSnapshotView.transform = CGAffineTransformIdentity;
                    self.backgroundView.alpha = 1.0;
                    if (!self.isHideMyNaviBar) {
                        [self changedAplhaWithItem:self.models[self.currentIndex] alpha:1.0];
                    }
                } completion:^(BOOL finished) {
                    self.collectionView.hidden = NO;
                    [self.pullSnapshotSuperView addSubview:self->_pullSnapshotView];
                    self->_pullSnapshotView = nil;
                    self.pullSnapshotSuperView = nil;
                    panGesture.enabled = YES;
                }];
            }
            _isPullBegan = NO;
            _isPulling = NO;
            _pullTimes = 0;
        }
            break;
        default:
            break;
            
    }
    _originalPoint = movePoint;
}

#pragma mark - Private Method

- (void)refreshNaviBarAndBottomBarState {
    TFY_ImagePickerController *imagePickerVc = [self navi];
    TFY_PickerAsset *model = _models[_currentIndex];
    _selectButton.selected = [imagePickerVc.selectedModels containsObject:model];
    if (_selectButton.selected) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)[imagePickerVc.selectedModels indexOfObject:model]+1];
        UIImage *image = [UIImage picker_mergeImage:bundleImageNamed(imagePickerVc.photoSelImageName) text:text];
        [_selectButton setImage:image forState:UIControlStateSelected];
    }
    _naviTipsLabel.text = nil;
    
    /** 视频超过限制的提示 */
    if (model.type == TFYAssetMediaTypeVideo) {
        TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:model];
        NSTimeInterval duration = videoEdit.editPreviewImage ? videoEdit.duration : model.duration;

        if (picker_videoDuration(duration) > imagePickerVc.maxVideoDuration) {
            if (imagePickerVc.maxVideoDuration < 60) {
                _naviTipsLabel.text = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText_second"], (int)imagePickerVc.maxVideoDuration];
            } else {
                _naviTipsLabel.text = [NSString stringWithFormat:[NSBundle picker_localizedStringForKey:@"_maxSelectVideoTipText_minute"], (int)imagePickerVc.maxVideoDuration/60];
            }
        }
    }
    
    /** 朋友圈的提示 */
    if (imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount) {
        if (imagePickerVc.selectedModels.count && model.type != imagePickerVc.selectedModels.firstObject.type) {
            if (model.type == TFYAssetMediaTypePhoto) {
                _naviTipsLabel.text = [NSBundle picker_localizedStringForKey:@"_mixedSelectionTipText_photo"];
            } else {
                _naviTipsLabel.text = [NSBundle picker_localizedStringForKey:@"_mixedSelectionTipText_video"];
            }
        }
    }
    /** 有提示显示 */
    BOOL showTip = _naviTipsLabel.text.length;
    if (showTip) {
        _selectButton.hidden = YES;
    } else {
        _selectButton.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self->_naviTipsView.alpha = self.isHideMyNaviBar ? 0.f : (showTip ? 1.f : 0.f);
        CGFloat livePhotoSignViewY = (self->_naviTipsView.alpha == 0) ? CGRectGetMaxY(self->_naviBar.frame) : CGRectGetMaxY(self->_naviTipsView.frame);
        {
            CGRect tempRect = self->_livePhotoSignView.frame;
            tempRect.origin.y = livePhotoSignViewY + livePhotoSignMargin;
            self->_livePhotoSignView.frame = tempRect;
        }
    }];
    
    if (self.alwaysShowPreviewBar) {
        _doneButton.enabled = imagePickerVc.selectedModels.count || imagePickerVc.autoSelectCurrentImage;
    } else if (_selectButton.hidden) {
        _doneButton.enabled = imagePickerVc.selectedModels.count || imagePickerVc.autoSelectCurrentImage || !showTip;
    } else {
        _doneButton.enabled = imagePickerVc.selectedModels.count || imagePickerVc.autoSelectCurrentImage;
    }
    _doneButton.backgroundColor = _doneButton.enabled ? imagePickerVc.oKButtonTitleColorNormal : imagePickerVc.oKButtonTitleColorDisabled;
    
    _titleLabel.text = [model.name stringByDeletingPathExtension];
    
    if (imagePickerVc.selectedModels.count) {
        [_doneButton setTitle:[NSString stringWithFormat:@"%@(%zd)", imagePickerVc.doneBtnTitleStr ,imagePickerVc.selectedModels.count] forState:UIControlStateNormal];
    } else {
        [_doneButton setTitle:imagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
    }
    
    _originalPhotoButton.hidden = model.type == TFYAssetMediaTypeVideo;
    _videoPlayButton.hidden = model.type != TFYAssetMediaTypeVideo;
    
    _originalPhotoButton.selected = imagePickerVc.isSelectOriginalPhoto;
    _originalPhotoLabel.hidden = !(_originalPhotoButton.selected && imagePickerVc.selectedModels.count > 0);
    if (!_originalPhotoLabel.hidden) {
        [self showPhotoBytes];
        [self checkSelectedPhotoBytes];
    }
    
    /** 关闭编辑 已选数量达到最大限度 && 非选中图片  */
    if (imagePickerVc.maxImagesCount != imagePickerVc.maxVideosCount) {
        
        if (imagePickerVc.selectedModels.count) {
            if (imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypePhoto) {
                _editButton.enabled = (imagePickerVc.selectedModels.count != imagePickerVc.maxImagesCount || [imagePickerVc.selectedModels containsObject:model]);
            } else if (imagePickerVc.selectedModels.firstObject.type == TFYAssetMediaTypeVideo){
                _editButton.enabled = (imagePickerVc.selectedModels.count != imagePickerVc.maxVideosCount || [imagePickerVc.selectedModels containsObject:model]);
            }
            if (model.type != imagePickerVc.selectedModels.firstObject.type) {
                _editButton.enabled = NO;
            }
        } else {
            _editButton.enabled = YES;
        }
    } else {
        _editButton.enabled = (imagePickerVc.selectedModels.count != imagePickerVc.maxImagesCount || [imagePickerVc.selectedModels containsObject:model]);
    }
    
    /** 预览栏动画 */
    if (!self.alwaysShowPreviewBar) {
        if (imagePickerVc.selectedModels.count) {
            [UIView animateWithDuration:0.25f animations:^{
                self->_previewMainBar.alpha = (self.isHideMyNaviBar ? 0.f : 1.f);
            }];
        } else {
            [UIView animateWithDuration:0.25f animations:^{
                self->_previewMainBar.alpha = 0.f;
            }];
        }
    }
    
    /** 预览栏选中与刷新 */
    _previewBar.selectAsset = model;
    
    /** live photo 标记 */
    if (imagePickerVc.allowPickingType & TFYPickingMediaTypeLivePhoto && model.subType == TFYAssetSubMediaTypeLivePhoto) {
        [self selectedLivePhotobadgeImageButton:!model.closeLivePhoto];
        if (self.isHideMyNaviBar) return;
        [UIView animateWithDuration:0.25f animations:^{
            self->_livePhotoSignView.alpha = 1.f;
        }];
    } else {
        [UIView animateWithDuration:0.25f animations:^{
            self->_livePhotoSignView.alpha = 0.f;
        }];
    }
}

- (void)checkSelectedPhotoBytes {
    __weak typeof(self) weakSelf = self;
    TFY_ImagePickerController *imagePickerVc = [self navi];
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

- (void)showPhotoBytes {
    if (/* DISABLES CODE */ (1)==0) {
        [[TFY_AssetManager manager] getPhotosBytesWithArray:@[_models[_currentIndex]] completion:^(NSString *totalBytesStr, NSInteger totalBytes) {
            self->_originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytesStr];
        }];
    }
}

- (void)selectedLivePhotobadgeImageButton:(BOOL)isSelected
{
    _livePhotobadgeImageButton.selected = isSelected;
    if (isSelected) {
        _livePhotobadgeImageButton.backgroundColor = [UIColor yellowColor];
    } else {
        _livePhotobadgeImageButton.backgroundColor = [UIColor whiteColor];
    }
}

- (void)changedAplhaWithItem:(TFY_PickerAsset *)item alpha:(CGFloat)alpha
{
    TFY_ImagePickerController *imagePickerVc = [self navi];
    [UIView animateWithDuration:0.25f animations:^{
        self->_naviBar.alpha = alpha;
        self->_toolBar.alpha = alpha;
        self->_naviTipsView.alpha = (self->_naviTipsLabel.text.length) ? alpha : 0.f;
        CGFloat livePhotoSignViewY = (self->_naviTipsView.alpha == 0) ? CGRectGetMaxY(self->_naviBar.frame) : CGRectGetMaxY(self->_naviTipsView.frame);
        {
            CGRect tempRect = self->_livePhotoSignView.frame;
            tempRect.origin.y = livePhotoSignViewY + livePhotoSignMargin;
            self->_livePhotoSignView.frame = tempRect;
        }
        /** 非总是显示模式，并且 预览栏数量为0时，已经是被隐藏，不能显示, 取反操作 */
        if (!(!self.alwaysShowPreviewBar && self->_previewBar.dataSource.count == 0)) {
            self->_previewMainBar.alpha = alpha;
        }
        
        /** live photo 标记 */
        if (imagePickerVc.allowPickingType & TFYPickingMediaTypeLivePhoto && item.subType == TFYAssetSubMediaTypeLivePhoto) {
            self->_livePhotoSignView.alpha = alpha;
        }
    }];
}

- (void)checkDefaultSelectedModels {
    
    TFY_ImagePickerController *imagePickerVc = (TFY_ImagePickerController *)[self navi];
    if (imagePickerVc.isPreview) {
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
}

@end
