//
//  TFY_VideoEditingController.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_VideoEditingController.h"
#import "TFYItools.h"
#import "TFYCategory.h"
#import "TFY_MECancelBlock.h"
#import "TFY_VideoEditingView.h"
#import "TFY_EditToolbar.h"
#import "TFY_StickerBar.h"
#import "TFY_TextBar.h"
#import "TFY_VideoClipToolbar.h"
#import "TFY_AudioTrackBar.h"
#import "TFY_FilterBar.h"
#import "TFY_FilterSuiteUtils.h"

/************************ Attributes ************************/
/** NSNumber containing LFVideoEditOperationSubType, default 0 */
TFYVideoEditOperationStringKey const TFYVideoEditDrawColorAttributeName = @"TFYVideoEditDrawColorAttributeName";
/** NSNumber containing LFVideoEditOperationSubType, default 0 */
TFYVideoEditOperationStringKey const TFYVideoEditDrawBrushAttributeName = @"TFYVideoEditDrawBrushAttributeName";
/** NSString containing string path, default nil. sticker resource path. */
TFYVideoEditOperationStringKey const TFYVideoEditStickerAttributeName = @"TFYVideoEditStickerAttributeName";
/** NSArray containing NSArray<LFStickerContent *>, default @[[TFY_StickerContent stickerContentWithTitle:@"默认" contents:@[TFY_StickerContentDefaultSticker]]]. */
TFYVideoEditOperationStringKey const TFYVideoEditStickerContentsAttributeName = @"TFYVideoEditStickerContentsAttributeName";
/** NSNumber containing LFVideoEditOperationSubType, default 0 */
TFYVideoEditOperationStringKey const TFYVideoEditTextColorAttributeName = @"TFYVideoEditTextColorAttributeName";
/** NSNumber containing BOOL, default false: default audioTrack ,true: mute. */
TFYVideoEditOperationStringKey const TFYVideoEditAudioMuteAttributeName = @"TFYVideoEditAudioMuteAttributeName";
/** NSArray  containing NSURL(fileURLWithPath:), default nil. audio resource paths. */
TFYVideoEditOperationStringKey const TFYVideoEditAudioUrlsAttributeName = @"TFYVideoEditAudioUrlsAttributeName";
/** NSNumber containing LFVideoEditOperationSubType, default 0 */
TFYVideoEditOperationStringKey const TFYVideoEditFilterAttributeName = @"TFYVideoEditFilterAttributeName";
/** NSNumber containing double, default 1, Range of 0.5 to 2.0. */
TFYVideoEditOperationStringKey const TFYVideoEditRateAttributeName = @"TFYVideoEditRateAttributeName";
/** NSNumber containing double, default 1.0. Must be greater than 0 and less than TFYVideoEditClipMaxDurationAttributeName, otherwise invalid. */
TFYVideoEditOperationStringKey const TFYVideoEditClipMinDurationAttributeName = @"TFYVideoEditClipMinDurationAttributeName";
/** NSNumber containing double, default 0. Must be greater than min, otherwise invalid. 0 is not limited. */
TFYVideoEditOperationStringKey const TFYVideoEditClipMaxDurationAttributeName = @"TFYVideoEditClipMaxDurationAttributeName";
/************************ Attributes ************************/

@interface TFY_VideoEditingController () <TFYEditToolbarDelegate, TFYStickerBarDelegate, TFYPickerTextBarDelegate, TFYFilterBarDelegate, TFYFilterBarDataSource, TFYAudioTrackBarDelegate, TFYVideoClipToolbarDelegate, TFY_PhotoEditDelegate, UIGestureRecognizerDelegate, TFYVideoEditingPlayerDelegate>
{
    /** 编辑模式 */
    TFY_VideoEditingView *_EditingView;
    
    UIView *_edit_naviBar;
    /** 底部栏菜单 */
    TFY_EditToolbar *_edit_toolBar;
    
    /** 贴图菜单 */
    TFY_StickerBar *_edit_sticker_toolBar;
    /** 滤镜菜单 */
    TFY_FilterBar *_edit_filter_toolBar;
    /** 剪切菜单 */
    TFY_VideoClipToolbar *_edit_clipping_toolBar;
    
    /** 单击手势 */
    UITapGestureRecognizer *singleTapRecognizer;
}

/** 隐藏控件 */
@property (nonatomic, assign) BOOL isHideNaviBar;
/** 初始化以选择的功能类型，已经初始化过的将被去掉类型，最终类型为0 */
@property (nonatomic, assign) TFYVideoEditOperationType initSelectedOperationType;

@property (nonatomic, copy) picker_me_dispatch_cancelable_block_t delayCancelBlock;

/** 滤镜缩略图 */
@property (nonatomic, strong) UIImage *filterSmallImage;

@property (nonatomic, strong, nullable) NSDictionary *editData;

@property (nonatomic, strong, nullable) id stickerBarCacheResource;

@end

@implementation TFY_VideoEditingController

- (instancetype)initWithOrientation:(UIInterfaceOrientation)orientation
{
    self = [super initWithOrientation:orientation];
    if (self) {
        _operationType = TFYVideoEditOperationType_All;
    }
    return self;
}

- (void)setVideoURL:(NSURL *)url placeholderImage:(UIImage *)image;
{
    AVAsset *asset = [AVURLAsset assetWithURL:url];
    [self setVideoAsset:asset placeholderImage:image];
}

- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image
{
    _asset = asset;
    _placeholderImage = image;
}

- (void)setVideoEdit:(TFY_VideoEdit *)videoEdit
{
    [self setVideoAsset:videoEdit.editAsset placeholderImage:videoEdit.editPreviewImage];
    _editData = videoEdit.editData;
}

- (void)setMinClippingDuration:(double)minClippingDuration
{
    if (minClippingDuration > 0.999) {
        _EditingView.minClippingDuration = minClippingDuration;
    }
}

- (void)setDefaultOperationType:(TFYVideoEditOperationType)defaultOperationType
{
    _defaultOperationType = defaultOperationType;
    _initSelectedOperationType = defaultOperationType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /** 为了适配iOS13的UIModalPresentationPageSheet模态，它会在viewDidLoad之后对self.view的大小调整，迫不得已暂时只能在viewWillAppear加载视图 */
    if (@available(iOS 13.0, *)) {
        if (isiPhone && self.presentingViewController && self.navigationController.modalPresentationStyle == UIModalPresentationPageSheet) {
            return;
        }
    }
    
    [self configEditingView];
    [self configCustomNaviBar];
    [self configBottomToolBar];
    [self configDefaultOperation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_EditingView == nil) {
        [self configEditingView];
        [self configCustomNaviBar];
        [self configBottomToolBar];
        [self configDefaultOperation];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        _edit_naviBar.picker_height = kCustomTopbarHeight_iOS11;
    } else {
        _edit_naviBar.picker_height = kCustomTopbarHeight;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // 部分视图需要获取安全区域。统一在这里执行用户指引；
    [self configUserGuide];
}

#pragma mark - 创建视图
- (void)configEditingView
{
    CGRect editRect = self.view.bounds;
    
//    if (@available(iOS 11.0, *)) {
//        if (hasSafeArea) {
//            editRect.origin.x += self.navigationController.view.safeAreaInsets.left;
//            editRect.origin.y += self.navigationController.view.safeAreaInsets.top;
//            editRect.size.width -= (self.navigationController.view.safeAreaInsets.left+self.navigationController.view.safeAreaInsets.right);
//            editRect.size.height -= (self.navigationController.view.safeAreaInsets.top+self.navigationController.view.safeAreaInsets.bottom);
//        }
//    }
    
    _EditingView = [[TFY_VideoEditingView alloc] initWithFrame:editRect];
    _EditingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _EditingView.editDelegate = self;
    _EditingView.playerDelegate = self;
    
    /** 单击的 Recognizer */
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singlePressed)];
    /** 点击的次数 */
    singleTapRecognizer.numberOfTapsRequired = 1; // 单击
    singleTapRecognizer.delegate = self;
    /** 给view添加一个手势监测 */
    [self.view addGestureRecognizer:singleTapRecognizer];
    
    [self.view addSubview:_EditingView];
    
    double minClippingDuration = [self operationDoubleForKey:TFYVideoEditClipMinDurationAttributeName];
    double maxClippingDuration = [self operationDoubleForKey:TFYVideoEditClipMaxDurationAttributeName];
    _EditingView.minClippingDuration = minClippingDuration;
    _EditingView.maxClippingDuration = maxClippingDuration;
    
    [_EditingView setVideoAsset:_asset placeholderImage:_placeholderImage];
    if (self.editData) {
        // 设置编辑数据
        _EditingView.photoEditData = self.editData;
        // 释放销毁
        self.editData = nil;
    } else {
        
        /** default audio urls */
        NSMutableArray *m_audioUrls = [_EditingView.audioUrls mutableCopy];
        for (TFY_AudioItem *audioItem in m_audioUrls) {
            if (audioItem.isOriginal) {
                audioItem.isEnable = ![self operationBOOLForKey:TFYVideoEditAudioMuteAttributeName];
                break;
            }
        }
        /** 音频资源 */
        NSArray <NSURL *>*defaultAudioUrls = [self operationArrayURLForKey:TFYVideoEditAudioUrlsAttributeName];
        
        if (defaultAudioUrls.count) {
            for (NSURL *url in defaultAudioUrls) {
                if ([url isKindOfClass:[NSURL class]]) {
                    TFY_AudioItem *item = [TFY_AudioItem new];
                    item.title = [url.lastPathComponent stringByDeletingPathExtension];;
                    item.url = url;
                    item.isEnable = YES;
                    [m_audioUrls addObject:item];
                }
            }
            _EditingView.audioUrls = m_audioUrls;
        }
        
        /** 设置默认滤镜 */
        if (@available(iOS 9.0, *)) {
            if (self.operationType&TFYVideoEditOperationType_filter) {
                TFYVideoEditOperationSubType subType = [self operationSubTypeForKey:TFYVideoEditFilterAttributeName];
                NSInteger index = 0;
                switch (subType) {
                    case TFYVideoEditOperationSubTypeLinearCurveFilter:
                    case TFYVideoEditOperationSubTypeChromeFilter:
                    case TFYVideoEditOperationSubTypeFadeFilter:
                    case TFYVideoEditOperationSubTypeInstantFilter:
                    case TFYVideoEditOperationSubTypeMonoFilter:
                    case TFYVideoEditOperationSubTypeNoirFilter:
                    case TFYVideoEditOperationSubTypeProcessFilter:
                    case TFYVideoEditOperationSubTypeTonalFilter:
                    case TFYVideoEditOperationSubTypeTransferFilter:
                    case TFYVideoEditOperationSubTypeCurveLinearFilter:
                    case TFYVideoEditOperationSubTypeInvertFilter:
                    case TFYVideoEditOperationSubTypeMonochromeFilter:
                        index = subType % 400 + 1;
                        break;
                    default:
                        break;
                }
                
                if (index > 0) {
                    [_EditingView changeFilterType:index];
                }
            }
        }
    }
}

- (void)configCustomNaviBar
{
    CGFloat margin = 5, topbarHeight = 0;
    if (@available(iOS 11.0, *)) {
        topbarHeight = kCustomTopbarHeight_iOS11;
    } else {
        topbarHeight = kCustomTopbarHeight;
    }
    CGFloat naviHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    
    _edit_naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.picker_width, topbarHeight)];
    _edit_naviBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _edit_naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    UIView *naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight-naviHeight, _edit_naviBar.frame.size.width, naviHeight)];
    naviBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_edit_naviBar addSubview:naviBar];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat editCancelWidth = [[NSBundle picker_localizedStringForKey:@"_LFME_cancelButtonTitle"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 30;
    UIButton *_edit_cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, 0, editCancelWidth, naviHeight)];
    _edit_cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_edit_cancelButton setTitle:[NSBundle picker_localizedStringForKey:@"_LFME_cancelButtonTitle"] forState:UIControlStateNormal];
    _edit_cancelButton.titleLabel.font = font;
    [_edit_cancelButton setTitleColor:self.cancelButtonTitleColorNormal forState:UIControlStateNormal];
    [_edit_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [naviBar addSubview:_edit_cancelButton];
    
    CGFloat editOkWidth = [[NSBundle picker_localizedStringForKey:@"_LFME_oKButtonTitle"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 30;
    
    UIButton *_edit_finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.picker_width - editOkWidth-margin, 0, editOkWidth, naviHeight)];
    _edit_finishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_edit_finishButton setTitle:[NSBundle picker_localizedStringForKey:@"_LFME_oKButtonTitle"] forState:UIControlStateNormal];
    _edit_finishButton.titleLabel.font = font;
    [_edit_finishButton setTitleColor:self.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_edit_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [naviBar addSubview:_edit_finishButton];
    
    [self.view addSubview:_edit_naviBar];
}

- (void)configBottomToolBar
{
    TFYEditToolbarType toolbarType = 0;
    if (self.operationType&TFYVideoEditOperationType_draw) {
        toolbarType |= TFYEditToolbarType_draw;
    }
    if (self.operationType&TFYVideoEditOperationType_sticker) {
        toolbarType |= TFYEditToolbarType_sticker;
    }
    if (self.operationType&TFYVideoEditOperationType_text) {
        toolbarType |= TFYEditToolbarType_text;
    }
    if (self.operationType&TFYVideoEditOperationType_audio) {
        toolbarType |= TFYEditToolbarType_audio;
    }
    if (@available(iOS 9.0, *)) {
        if (self.operationType&TFYVideoEditOperationType_filter) {
            toolbarType |= TFYEditToolbarType_filter;
        }
    }
    if (self.operationType&TFYVideoEditOperationType_rate) {
        toolbarType |= TFYEditToolbarType_rate;
    }
    if (self.operationType&TFYVideoEditOperationType_clip) {
        toolbarType |= TFYEditToolbarType_clip;
    }
    
    _edit_toolBar = [[TFY_EditToolbar alloc] initWithType:toolbarType];
    _edit_toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _edit_toolBar.delegate = self;
    
    NSInteger index = 2; /** 红色 */
    
    /** 设置默认绘画颜色 */
    if (self.operationType&TFYVideoEditOperationType_draw) {
        TFYVideoEditOperationSubType subType = [self operationSubTypeForKey:TFYVideoEditDrawColorAttributeName];
        switch (subType) {
            case TFYVideoEditOperationSubTypeDrawWhiteColor:
            case TFYVideoEditOperationSubTypeDrawBlackColor:
            case TFYVideoEditOperationSubTypeDrawRedColor:
            case TFYVideoEditOperationSubTypeDrawLightYellowColor:
            case TFYVideoEditOperationSubTypeDrawYellowColor:
            case TFYVideoEditOperationSubTypeDrawLightGreenColor:
            case TFYVideoEditOperationSubTypeDrawGreenColor:
            case TFYVideoEditOperationSubTypeDrawAzureColor:
            case TFYVideoEditOperationSubTypeDrawRoyalBlueColor:
            case TFYVideoEditOperationSubTypeDrawBlueColor:
            case TFYVideoEditOperationSubTypeDrawPurpleColor:
            case TFYVideoEditOperationSubTypeDrawLightPinkColor:
            case TFYVideoEditOperationSubTypeDrawVioletRedColor:
            case TFYVideoEditOperationSubTypeDrawPinkColor:
                index = subType - 1;
                break;
            default:
                break;
        }
        [_edit_toolBar setDrawSliderColorAtIndex:index];
        
        subType = [self operationSubTypeForKey:TFYVideoEditDrawBrushAttributeName];

        TFYEditToolbarBrushType brushType = 0;
        TFYEditToolbarStampBrushType stampBrushType = 0;
        switch (subType) {
            case TFYVideoEditOperationSubTypeDrawPaintBrush:
            case TFYVideoEditOperationSubTypeDrawHighlightBrush:
            case TFYVideoEditOperationSubTypeDrawChalkBrush:
            case TFYVideoEditOperationSubTypeDrawFluorescentBrush:
                brushType = subType % 50;
                break;
            case TFYVideoEditOperationSubTypeDrawStampAnimalBrush:
                brushType = TFYEditToolbarBrushTypeStamp;
                stampBrushType = TFYEditToolbarStampBrushTypeAnimal;
                break;
            case TFYVideoEditOperationSubTypeDrawStampFruitBrush:
                brushType = TFYEditToolbarBrushTypeStamp;
                stampBrushType = TFYEditToolbarStampBrushTypeFruit;
                break;
            case TFYVideoEditOperationSubTypeDrawStampHeartBrush:
                brushType = TFYEditToolbarBrushTypeStamp;
                stampBrushType = TFYEditToolbarStampBrushTypeHeart;
                break;
            default:
                break;
        }
        [_edit_toolBar setDrawBrushAtIndex:brushType subIndex:stampBrushType];
    }
    
    
    /** 设置默认速率 */
    if (self.operationType&TFYVideoEditOperationType_rate && _EditingView.rate == 1.f) {
        double rate = [self operationDoubleForKey:TFYVideoEditRateAttributeName];
        [_edit_toolBar setRate:rate];
        [_EditingView setRate:rate];
    }
    
    [self.view addSubview:_edit_toolBar];
}

- (void)configDefaultOperation
{
    if (self.initSelectedOperationType > 0) {
        
        __weak typeof(self) weakSelf = self;
        BOOL (^containOperation)(TFYVideoEditOperationType type) = ^(TFYVideoEditOperationType type){
            if (weakSelf.operationType&type && weakSelf.initSelectedOperationType&type) {
                weakSelf.initSelectedOperationType ^= type;
                return YES;
            }
            return NO;
        };
        
        if (containOperation(TFYVideoEditOperationType_clip)) {
            [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_clip];
        } else {
            if (containOperation(TFYVideoEditOperationType_draw)) {
                [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_draw];
            } else if (containOperation(TFYVideoEditOperationType_sticker)) {
                [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_sticker];
            } else if (containOperation(TFYVideoEditOperationType_text)) {
                [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_text];
            } else if (containOperation(TFYVideoEditOperationType_audio)) {
                [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_audio];
            } else {
                BOOL isDoIt = YES;
                if (@available(iOS 9.0, *)) {
                    if (containOperation(TFYVideoEditOperationType_filter)) {
                        [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_filter];
                        isDoIt = NO;
                    }
                }
                if (isDoIt) {
                    if (containOperation(TFYVideoEditOperationType_rate)) {
                        [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_rate];
                    }
                }
            }
            self.initSelectedOperationType = 0;
        }
    }
}

- (void)configUserGuide
{
    // 设置首次启动其他功能，需要返回后再提示
    if (self.defaultOperationType&TFYVideoEditOperationType_clip && _EditingView.isClipping) {
        return;
    }
    
    UIView *mainView = self.navigationController.view;
    {
        if (_edit_toolBar.items > kToolbar_MaxItems) {
            CGFloat height = kToolbar_MainHeight;
            if (@available(iOS 11.0, *)) {
                height += self.view.safeAreaInsets.bottom;
            }
            CGRect toolbarFrame = CGRectMake(0, CGRectGetHeight(self.view.frame)-height, CGRectGetWidth(self.view.frame), height);
            [self picker_showInView:mainView maskRects:@[[NSValue valueWithCGRect:toolbarFrame]] withTips:@[[NSBundle picker_localizedStringForKey:@"_LFME_UserGuide_ToolBar_Scroll"]]];
        }
    }
}

#pragma mark - 顶部栏(action)
- (void)singlePressed
{
    [self singlePressedWithAnimated:YES];
}
- (void)singlePressedWithAnimated:(BOOL)animated
{
    if (!(_EditingView.isDrawing || _EditingView.isSplashing)) {
        _isHideNaviBar = !_isHideNaviBar;
        [self changedBarStateWithAnimated:animated];
    }
}
- (void)cancelButtonClick
{
    [_EditingView pauseVideo];
    /** 恢复原来的音频 */
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if ([self.delegate respondsToSelector:@selector(picker_VideoEditingControllerDidCancel:)]) {
        [self.delegate picker_VideoEditingControllerDidCancel:self];
    }
}

- (void)finishButtonClick
{
    [self showProgressVideoHUD];
    /** 取消贴图激活 */
    [_EditingView stickerDeactivated];
    /** 处理编辑图片 */
    __block TFY_VideoEdit *videoEdit = nil;
    NSDictionary *data = [_EditingView photoEditData];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf->_EditingView exportAsynchronouslyWithTrimVideo:^(NSURL *trimURL, NSError *error) {
                    if (error) {
                        [weakSelf showErrorMessage:error.description];
                    } else {
                        videoEdit = [[TFY_VideoEdit alloc] initWithEditAsset:weakSelf.asset editFinalURL:trimURL data:data];
                        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                        if ([weakSelf.delegate respondsToSelector:@selector(picker_VideoEditingController:didFinishPhotoEdit:)]) {
                            [weakSelf.delegate picker_VideoEditingController:weakSelf didFinishPhotoEdit:videoEdit];
                        }
                    }
                    [weakSelf hideProgressHUD];
                } progress:^(float progress) {
                    [weakSelf setProgress:progress];
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf->_EditingView pauseVideo];
                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                if ([weakSelf.delegate respondsToSelector:@selector(picker_VideoEditingController:didFinishPhotoEdit:)]) {
                    [weakSelf.delegate picker_VideoEditingController:weakSelf didFinishPhotoEdit:videoEdit];
                }
                [weakSelf hideProgressHUD];
            });
        }
    });
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_EditingView]) {
        return YES;
    }
    return NO;
}

#pragma mark - TFYEditToolbarDelegate 底部栏(action)

/** 一级菜单点击事件 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar mainDidSelectAtIndex:(NSUInteger)index
{
    /** 取消贴图激活 */
    [_EditingView stickerDeactivated];
    
    switch (index) {
        case TFYEditToolbarType_draw:
        {
            /** 关闭涂抹 */
            _EditingView.splashEnable = NO;
            /** 打开绘画 */
            _EditingView.drawEnable = !_EditingView.drawEnable;
        }
            break;
        case TFYEditToolbarType_sticker:
        {
            [self singlePressed];
            [self changeStickerMenu:YES animated:YES];
        }
            break;
        case TFYEditToolbarType_text:
        {
            [self showTextBarController:nil];
        }
            break;
        case TFYEditToolbarType_splash:
        {
            /** 关闭绘画 */
            _EditingView.drawEnable = NO;
            /** 打开涂抹 */
            _EditingView.splashEnable = !_EditingView.splashEnable;
        }
            break;
        case TFYEditToolbarType_audio:
        {
            /** 音轨编辑UI */
            [self showAudioTrackBar];
        }
            break;
        case TFYEditToolbarType_filter:
        {
            [self singlePressed];
            [self changeFilterMenu:YES animated:YES];
        }
            break;
        case TFYEditToolbarType_clip:
        {
            [_EditingView setIsClipping:YES animated:YES];
            [self changeClipMenu:YES];
        }
            break;
        case TFYEditToolbarType_rate:
        {
            editToolbar.rate = _EditingView.rate;
        }
            break;
        default:
            break;
    }
}
/** 二级菜单点击事件-撤销 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar subDidRevokeAtIndex:(NSUInteger)index
{
    switch (index) {
        case TFYEditToolbarType_draw:
        {
            [_EditingView drawUndo];
        }
            break;
        case TFYEditToolbarType_sticker:
            break;
        case TFYEditToolbarType_text:
            break;
        case TFYEditToolbarType_splash:
        {
            [_EditingView splashUndo];
        }
            break;
        case TFYEditToolbarType_audio:
            break;
        case TFYEditToolbarType_clip:
            break;
        default:
            break;
    }
}
/** 二级菜单点击事件-按钮 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar subDidSelectAtIndex:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case TFYEditToolbarType_draw:
            break;
        case TFYEditToolbarType_sticker:
            break;
        case TFYEditToolbarType_text:
            break;
        case TFYEditToolbarType_splash:
            break;
        case TFYEditToolbarType_audio:
            break;
        case TFYEditToolbarType_clip:
            break;
        default:
            break;
    }
}
/** 撤销允许权限获取 */
- (BOOL)picker_editToolbar:(TFY_EditToolbar *)editToolbar canRevokeAtIndex:(NSUInteger)index
{
    BOOL canUndo = NO;
    switch (index) {
        case TFYEditToolbarType_draw:
        {
            canUndo = [_EditingView drawCanUndo];
        }
            break;
        case TFYEditToolbarType_sticker:
            break;
        case TFYEditToolbarType_text:
            break;
        case TFYEditToolbarType_splash:
        {
            canUndo = [_EditingView splashCanUndo];
        }
            break;
        case TFYEditToolbarType_audio:
            break;
        case TFYEditToolbarType_clip:
            break;
        default:
            break;
    }
    
    return canUndo;
}
/** 二级菜单滑动事件-绘画 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar drawColorDidChange:(UIColor *)color
{
    [_EditingView setDrawColor:color];
}
/** 二级菜单笔刷事件-绘画 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar drawBrushDidChange:(TFY_Brush *)brush
{
    [_EditingView setDrawBrush:brush];
}
/** 二级菜单滑动事件-速率 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar rateDidChange:(float)value
{
    _EditingView.rate = value;
}

#pragma mark - TFYStickerBarDelegate
- (void)picker_stickerBar:(TFY_StickerBar *)lf_stickerBar didSelectImage:(UIImage *)image
{
    if (image) {
        TFY_StickerItem *item = [TFY_StickerItem new];
        item.image = image;
        [_EditingView createSticker:item];
    }
    [self singlePressed];
}

#pragma mark - TFYTextBarDelegate
/** 完成回调 */
- (void)picker_textBarController:(TFY_TextBar *)textBar didFinishText:(TFY_Text *)text
{
    if (text) {
        TFY_StickerItem *item = [TFY_StickerItem new];
        item.text = text;
        /** 判断是否更改文字 */
        if (textBar.showText) {
            [_EditingView changeSelectSticker:item];
        } else {
            [_EditingView createSticker:item];
        }
    } else {
        if (textBar.showText) { /** 文本被清除，删除贴图 */
            [_EditingView removeSelectStickerView];
        }
    }
    [self picker_textBarControllerDidCancel:textBar];
}
/** 取消回调 */
- (void)picker_textBarControllerDidCancel:(TFY_TextBar *)textBar
{
    /** 显示顶部栏 */
    _isHideNaviBar = NO;
    [self changedBarState];
    /** 更改文字情况才重新激活贴图 */
    if (textBar.showText) {
        [_EditingView activeSelectStickerView];
    }
    [textBar resignFirstResponder];
    
    [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
        textBar.picker_y = self.view.picker_height;
    } completion:^(BOOL finished) {
        [textBar removeFromSuperview];
    }];
}

/** 输入数量已经达到最大值 */
- (void)picker_textBarControllerDidReachMaximumLimit:(TFY_TextBar *)textBar
{
    [self showInfoMessage:[NSBundle picker_localizedStringForKey:@"_LFME_reachMaximumLimitTitle"]];
}

#pragma mark - TFYAudioTrackBarDelegate
/** 完成回调 */
- (void)picker_audioTrackBar:(TFY_AudioTrackBar *)audioTrackBar didFinishAudioUrls:(NSArray <TFY_AudioItem *> *)audioUrls
{
    _EditingView.audioUrls = audioUrls;
    [self picker_audioTrackBarDidCancel:audioTrackBar];
}
/** 取消回调 */
- (void)picker_audioTrackBarDidCancel:(TFY_AudioTrackBar *)audioTrackBar
{
    [_EditingView playVideo];
    /** 显示顶部栏 */
    _isHideNaviBar = NO;
    [self changedBarState];
    
    [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
        audioTrackBar.picker_y = self.view.picker_height;
    } completion:^(BOOL finished) {
        [audioTrackBar removeFromSuperview];
        
        self->singleTapRecognizer.enabled = YES;
    }];
}

#pragma mark - TFYVideoClipToolbarDelegate
/** 取消 */
- (void)picker_videoClipToolbarDidCancel:(TFY_VideoClipToolbar *)clipToolbar
{
    if (self.initSelectedOperationType == 0 && self.operationType == TFYVideoEditOperationType_clip && self.defaultOperationType == TFYVideoEditOperationType_clip) { /** 证明initSelectedOperationType已消耗完毕，defaultOperationType是有值的。只有LFVideoEditOperationType_clip的情况，无需返回，直接完成整个编辑 */
        [self cancelButtonClick];
    } else {
        [_EditingView cancelClipping:YES];
        [self changeClipMenu:NO];
        [self configDefaultOperation];
        [self configUserGuide];
    }
}
/** 完成 */
- (void)picker_videoClipToolbarDidFinish:(TFY_VideoClipToolbar *)clipToolbar
{
    if (self.initSelectedOperationType == 0 && self.operationType == TFYVideoEditOperationType_clip && self.defaultOperationType == TFYVideoEditOperationType_clip) { /** 证明initSelectedOperationType已消耗完毕，defaultOperationType是有值的。只有LFVideoEditOperationType_clip的情况，无需返回，直接完成整个编辑 */
        [self finishButtonClick];
    } else {
        [_EditingView setIsClipping:NO animated:YES];
        [self changeClipMenu:NO];
        [self configDefaultOperation];
        [self configUserGuide];
    }
}

#pragma mark - TFYPhotoEditDelegate
#pragma mark - TFYPhotoEditDrawDelegate
/** 开始绘画 */
- (void)picker_photoEditDrawBegan
{
    _isHideNaviBar = YES;
    [self changedBarState];
}
/** 结束绘画 */
- (void)picker_photoEditDrawEnded
{
    /** 撤销生效 */
    if (_EditingView.drawCanUndo) [_edit_toolBar setRevokeAtIndex:TFYEditToolbarType_draw];
    
    __weak typeof(self) weakSelf = self;
    picker_me_dispatch_cancel(self.delayCancelBlock);
    self.delayCancelBlock = picker_dispatch_block_t(1.f, ^{
        weakSelf.isHideNaviBar = NO;
        [weakSelf changedBarState];
    });
}

#pragma mark - TFYPhotoEditStickerDelegate
/** 点击贴图 isActive=YES 选中的情况下点击 */
- (void)picker_photoEditStickerDidSelectViewIsActive:(BOOL)isActive
{
    _isHideNaviBar = NO;
    [self changedBarState];
    if (isActive) { /** 选中的情况下点击 */
        TFY_StickerItem *item = [_EditingView getSelectSticker];
        if (item.text) {
            [_EditingView stickerDeactivated];
            [self showTextBarController:item.text];
        }
    }
}
/** 贴图移动开始，可以通过getSelectSticker获取选中贴图 */
- (void)picker_photoEditStickerMovingBegan
{
    _isHideNaviBar = YES;
    [self changedBarState];
}
/** 贴图移动结束，可以通过getSelectSticker获取选中贴图 */
- (void)picker_photoEditStickerMovingEnded
{
    _isHideNaviBar = NO;
    [self changedBarState];
}

#pragma mark - TFYPhotoEditSplashDelegate
/** 开始模糊 */
- (void)picker_photoEditSplashBegan
{
    _isHideNaviBar = YES;
    [self changedBarState];
}
/** 结束模糊 */
- (void)picker_photoEditSplashEnded
{
    /** 撤销生效 */
    if (_EditingView.splashCanUndo) [_edit_toolBar setRevokeAtIndex:TFYEditToolbarType_splash];
    
    __weak typeof(self) weakSelf = self;
    picker_me_dispatch_cancel(self.delayCancelBlock);
    self.delayCancelBlock = picker_dispatch_block_t(1.f, ^{
        weakSelf.isHideNaviBar = NO;
        [weakSelf changedBarState];
    });
}

#pragma mark - TFYVideoEditingPlayerDelegate
/** 错误回调 */
- (void)picker_videoEditingViewFailedToPrepare:(TFY_VideoEditingView *)editingView error:(NSError *)error
{
    [self showErrorMessage:error.localizedDescription];
}

#pragma mark - private
- (void)changedBarState
{
    [self changedBarStateWithAnimated:YES];
}
- (void)changedBarStateWithAnimated:(BOOL)animated
{
    picker_me_dispatch_cancel(self.delayCancelBlock);
    /** 隐藏贴图菜单 */
    [self changeStickerMenu:NO animated:animated];
    /** 隐藏滤镜菜单 */
    [self changeFilterMenu:NO animated:animated];
    
    if (animated) {
        [UIView animateWithDuration:.25f animations:^{
            CGFloat alpha = self->_isHideNaviBar ? 0.f : 1.f;
            self->_edit_naviBar.alpha = alpha;
            self->_edit_toolBar.alpha = alpha;
        }];
    } else {
        CGFloat alpha = _isHideNaviBar ? 0.f : 1.f;
        _edit_naviBar.alpha = alpha;
        _edit_toolBar.alpha = alpha;
    }
}

- (void)changeClipMenu:(BOOL)isChanged
{
    [self changeClipMenu:isChanged animated:YES];
}

- (void)changeClipMenu:(BOOL)isChanged animated:(BOOL)animated
{
    if (isChanged) {
        /** 关闭所有编辑 */
        [_EditingView photoEditEnable:NO];
        /** 切换菜单 */
        [self.view addSubview:self.edit_clipping_toolBar];
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                self->_edit_clipping_toolBar.alpha = 1.f;
            }];
        } else {
            _edit_clipping_toolBar.alpha = 1.f;
        }
        singleTapRecognizer.enabled = NO;
        [self singlePressedWithAnimated:animated];
    } else {
        if (_edit_clipping_toolBar.superview == nil) return;
        
        /** 开启编辑 */
        [_EditingView photoEditEnable:YES];
        
        singleTapRecognizer.enabled = YES;
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_clipping_toolBar.alpha = 0.f;
            } completion:^(BOOL finished) {
                [self->_edit_clipping_toolBar removeFromSuperview];
            }];
        } else {
            [_edit_clipping_toolBar removeFromSuperview];
        }
        
        [self singlePressedWithAnimated:animated];
    }
}

- (void)changeStickerMenu:(BOOL)isChanged animated:(BOOL)animated
{
    if (isChanged) {
        [self.view addSubview:self.edit_sticker_toolBar];
        CGRect frame = self.edit_sticker_toolBar.frame;
        frame.origin.y = self.view.picker_height-frame.size.height;
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_sticker_toolBar.frame = frame;
            }];
        } else {
            _edit_sticker_toolBar.frame = frame;
        }
    } else {
        if (_edit_sticker_toolBar.superview == nil) return;
        
        CGRect frame = self.edit_sticker_toolBar.frame;
        frame.origin.y = self.view.picker_height;
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_sticker_toolBar.frame = frame;
            } completion:^(BOOL finished) {
                self.stickerBarCacheResource = self->_edit_sticker_toolBar.cacheResources;
                [self->_edit_sticker_toolBar removeFromSuperview];
                self->_edit_sticker_toolBar = nil;
            }];
        } else {
            self.stickerBarCacheResource = self->_edit_sticker_toolBar.cacheResources;
            [_edit_sticker_toolBar removeFromSuperview];
            _edit_sticker_toolBar = nil;
        }
    }
}

- (void)showTextBarController:(TFY_Text *)text
{
    static NSInteger TFYTextBarTag = 32735;
    if ([self.view viewWithTag:TFYTextBarTag]) {
        return;
    }
    
    TFY_TextBar *textBar = [[TFY_TextBar alloc] initWithFrame:CGRectMake(0, self.view.picker_height, self.view.picker_width, self.view.picker_height) layout:^(TFY_TextBar *textBar) {
        textBar.oKButtonTitleColorNormal = self.oKButtonTitleColorNormal;
        textBar.cancelButtonTitleColorNormal = self.cancelButtonTitleColorNormal;
        textBar.oKButtonTitle = [NSBundle picker_localizedStringForKey:@"_LFME_oKButtonTitle"];
        textBar.cancelButtonTitle = [NSBundle picker_localizedStringForKey:@"_LFME_cancelButtonTitle"];
        textBar.customTopbarHeight = self->_edit_naviBar.picker_height;
        textBar.naviHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    }];
    textBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textBar.showText = text;
    textBar.delegate = self;
    textBar.tag = TFYTextBarTag;
    
    if (text == nil) {
        /** 设置默认文字颜色 */
        TFYVideoEditOperationSubType subType = [self operationSubTypeForKey:TFYVideoEditTextColorAttributeName];
        
        NSInteger index = 0;
        switch (subType) {
            case TFYVideoEditOperationSubTypeTextWhiteColor: index = 0; break;
            case TFYVideoEditOperationSubTypeTextBlackColor: index = 1; break;
            case TFYVideoEditOperationSubTypeTextRedColor: index = 2; break;
            case TFYVideoEditOperationSubTypeTextLightYellowColor: index = 3; break;
            case TFYVideoEditOperationSubTypeTextYellowColor: index = 4; break;
            case TFYVideoEditOperationSubTypeTextLightGreenColor: index = 5; break;
            case TFYVideoEditOperationSubTypeTextGreenColor: index = 6; break;
            case TFYVideoEditOperationSubTypeTextAzureColor: index = 7; break;
            case TFYVideoEditOperationSubTypeTextRoyalBlueColor: index = 8; break;
            case TFYVideoEditOperationSubTypeTextBlueColor: index = 9; break;
            case TFYVideoEditOperationSubTypeTextPurpleColor: index = 10; break;
            case TFYVideoEditOperationSubTypeTextLightPinkColor: index = 11; break;
            case TFYVideoEditOperationSubTypeTextVioletRedColor: index = 12; break;
            case TFYVideoEditOperationSubTypeTextPinkColor: index = 13; break;
            default:
                break;
        }
        [textBar setTextSliderColorAtIndex:index];
    }
    
    [self.view addSubview:textBar];
    
    [textBar becomeFirstResponder];
    [UIView animateWithDuration:0.25f animations:^{
        textBar.picker_y = 0;
    } completion:^(BOOL finished) {
        /** 隐藏顶部栏 */
        self->_isHideNaviBar = YES;
        [self changedBarState];
    }];
}

#pragma mark - 音轨菜单
- (void)showAudioTrackBar
{
    TFY_AudioTrackBar *audioTrackBar = [[TFY_AudioTrackBar alloc] initWithFrame:CGRectMake(0, self.view.picker_height, self.view.picker_width, self.view.picker_height) layout:^(TFY_AudioTrackBar *audioTrackBar) {
        audioTrackBar.oKButtonTitleColorNormal = self.oKButtonTitleColorNormal;
        audioTrackBar.cancelButtonTitleColorNormal = self.cancelButtonTitleColorNormal;
        audioTrackBar.oKButtonTitle = [NSBundle picker_localizedStringForKey:@"_LFME_oKButtonTitle"];
        audioTrackBar.cancelButtonTitle = [NSBundle picker_localizedStringForKey:@"_LFME_cancelButtonTitle"];
        audioTrackBar.customTopbarHeight = self->_edit_naviBar.picker_height;
        audioTrackBar.naviHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
        if (@available(iOS 11.0, *)) {
            audioTrackBar.customToolbarHeight = 44.f+self.navigationController.view.safeAreaInsets.bottom;
        } else {
            audioTrackBar.customToolbarHeight = 44.f;
        }
    }];
    
    audioTrackBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    audioTrackBar.delegate = self;
    audioTrackBar.audioUrls = _EditingView.audioUrls;
    
    [self.view addSubview:audioTrackBar];
    
    [UIView animateWithDuration:0.25f animations:^{
        audioTrackBar.picker_y = 0;
    } completion:^(BOOL finished) {
        /** 隐藏顶部栏 */
        self->_isHideNaviBar = YES;
        [self changedBarState];
        self->singleTapRecognizer.enabled = NO;
        [self->_EditingView resetVideoDisplay];
    }];
}

- (void)changeFilterMenu:(BOOL)isChanged animated:(BOOL)animated
{
    if (isChanged) {
        [self.view addSubview:self.edit_filter_toolBar];
        CGRect frame = self.edit_filter_toolBar.frame;
        frame.origin.y = self.view.picker_height-frame.size.height;
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_filter_toolBar.frame = frame;
            }];
        } else {
            _edit_filter_toolBar.frame = frame;
        }
    } else {
        if (_edit_filter_toolBar.superview == nil) return;
        
        CGRect frame = self.edit_filter_toolBar.frame;
        frame.origin.y = self.view.picker_height;
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_filter_toolBar.frame = frame;
            } completion:^(BOOL finished) {
                [self->_edit_filter_toolBar removeFromSuperview];
                self->_edit_filter_toolBar = nil;
            }];
        } else {
            [_edit_filter_toolBar removeFromSuperview];
            _edit_filter_toolBar = nil;
        }
    }
}

#pragma mark - 贴图菜单（懒加载）
- (TFY_StickerBar *)edit_sticker_toolBar
{
    if (_edit_sticker_toolBar == nil) {
        CGFloat row = 4;
        CGFloat w=self.view.picker_width, h=picker_stickerSize*row+picker_stickerMargin*(row+1);
        if (@available(iOS 11.0, *)) {
            h += self.navigationController.view.safeAreaInsets.bottom;
        }
        CGRect frame = CGRectMake(0, self.view.picker_height, w, h);
        
        if (self.stickerBarCacheResource) {
            _edit_sticker_toolBar = [[TFY_StickerBar alloc] initWithFrame:frame cacheResources:self.stickerBarCacheResource];
        } else {
            /** 设置默认贴图资源路径 */
            NSArray <TFY_StickerContent *>*stickerContents = [self operationArrayForKey:TFYVideoEditStickerContentsAttributeName];
            
            if (stickerContents == nil) {
                stickerContents = @[
                    [TFY_StickerContent stickerContentWithTitle:@"默认" contents:@[TFYStickerContentDefaultSticker]],
                    [TFY_StickerContent stickerContentWithTitle:@"相册" contents:@[TFYStickerContentAllAlbum]]
                ];
            }
            
            _edit_sticker_toolBar = [[TFY_StickerBar alloc] initWithFrame:frame resources:stickerContents];
        }
        
        _edit_sticker_toolBar.delegate = self;
    }
    return _edit_sticker_toolBar;
}

#pragma mark - 剪切底部栏（懒加载）
- (UIView *)edit_clipping_toolBar
{
    if (_edit_clipping_toolBar == nil) {
        CGFloat h = 44.f;
        if (@available(iOS 11.0, *)) {
            h += self.navigationController.view.safeAreaInsets.bottom;
        }
        _edit_clipping_toolBar = [[TFY_VideoClipToolbar alloc] initWithFrame:CGRectMake(0, self.view.picker_height - h, self.view.picker_width, h)];
        _edit_clipping_toolBar.alpha = 0.f;
        _edit_clipping_toolBar.delegate = self;
    }
    return _edit_clipping_toolBar;
}

#pragma mark - 滤镜菜单（懒加载）
- (TFY_FilterBar *)edit_filter_toolBar
{
    if (_edit_filter_toolBar == nil) {
        CGFloat w=self.view.picker_width, h=100.f;
        if (@available(iOS 11.0, *)) {
            h += self.navigationController.view.safeAreaInsets.bottom;
        }
        _edit_filter_toolBar = [[TFY_FilterBar alloc] initWithFrame:CGRectMake(0, self.view.picker_height, w, h) defalutEffectType:[_EditingView getFilterType] dataSource:@[
                                                                                                                                                                    @(TFYFilterNameType_None),
                                                                                                                                                                    @(TFYFilterNameType_LinearCurve),
                                                                                                                                                                    @(TFYFilterNameType_Chrome),
                                                                                                                                                                    @(TFYFilterNameType_Fade),
                                                                                                                                                                    @(TFYFilterNameType_Instant),
                                                                                                                                                                    @(TFYFilterNameType_Mono),
                                                                                                                                                                    @(TFYFilterNameType_Noir),
                                                                                                                                                                    @(TFYFilterNameType_Process),
                                                                                                                                                                    @(TFYFilterNameType_Tonal),
                                                                                                                                                                    @(TFYFilterNameType_Transfer),
                                                                                                                                                                    @(TFYFilterNameType_CurveLinear),
                                                                                                                                                                    @(TFYFilterNameType_Invert),
                                                                                                                                                                    @(TFYFilterNameType_Monochrome),                                                                                    ]];
        CGFloat rgb = 34 / 255.0;
        _edit_filter_toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.85];
        _edit_filter_toolBar.defaultColor = self.cancelButtonTitleColorNormal;
        _edit_filter_toolBar.selectColor = self.oKButtonTitleColorNormal;
        _edit_filter_toolBar.delegate = self;
        _edit_filter_toolBar.dataSource = self;
        
        
    }
    return _edit_filter_toolBar;
}

#pragma mark - TFYFilterBarDelegate
- (void)picker_filterBar:(TFY_FilterBar *)picker_filterBar didSelectImage:(UIImage *)image effectType:(NSInteger)effectType
{
    [_EditingView changeFilterType:effectType];
}

#pragma mark - TFYFilterBarDataSource
- (UIImage *)picker_async_filterBarImageForEffectType:(NSInteger)type
{
    if (_filterSmallImage == nil) {
        CGSize videoSize = [self.asset picker_videoNaturalSize];
        CGSize size = CGSizeZero;
        size.width = MIN(TFY_FilterBar_MAX_WIDTH*[UIScreen mainScreen].scale, videoSize.width);
        size.height = ((int)(videoSize.height*size.width/videoSize.width))*1.f;
        self.filterSmallImage = [self.asset picker_firstImageWithSize:size error:nil];
    }
    return picker_filterImageWithType(self.filterSmallImage, type);
}

- (NSString *)picker_filterBarNameForEffectType:(NSInteger)type
{
    NSString *defaultName = picker_descWithType(type);
    if (defaultName) {
        NSString *languageName = [@"_LFME_filter_" stringByAppendingString:defaultName];
        return [NSBundle picker_localizedStringForKey:languageName];
    }
    return @"";
}

#pragma mark - 配置数据
- (TFYVideoEditOperationSubType)operationSubTypeForKey:(TFYVideoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return (TFYVideoEditOperationSubType)[obj integerValue];
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:TFYVideoEditDrawColorAttributeName]
        || [key isEqualToString:TFYVideoEditDrawBrushAttributeName]
        || [key isEqualToString:TFYVideoEditTextColorAttributeName]
        || [key isEqualToString:TFYVideoEditFilterAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is TFYVideoEditOperationSubType", key);
        #pragma clang diagnostic pop
    }
    return 0;
}

- (BOOL)operationBOOLForKey:(TFYVideoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj boolValue];
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:TFYVideoEditAudioMuteAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is BOOL", key);
        #pragma clang diagnostic pop
    } else {
        if ([key isEqualToString:TFYVideoEditAudioMuteAttributeName]) {
            return NO;
        }
    }
    return NO;
}

- (double)operationDoubleForKey:(TFYVideoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        double value = [obj doubleValue];
        if ([key isEqualToString:TFYVideoEditRateAttributeName]) {
            if (value >= TFYMediaEditMinRate && value <= TFYMediaEditMaxRate) {
                return value;
            } else {
                return 1.f;
            }
        } else {
            return value;
        }
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:TFYVideoEditRateAttributeName]
        || [key isEqualToString:TFYVideoEditClipMinDurationAttributeName]
        || [key isEqualToString:TFYVideoEditClipMaxDurationAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is double", key);
        #pragma clang diagnostic pop
    } else {
        if ([key isEqualToString:TFYVideoEditRateAttributeName]) {
            return 1.f;
        } else if ([key isEqualToString:TFYVideoEditClipMinDurationAttributeName]) {
            return 1.f;
        } else if ([key isEqualToString:TFYVideoEditClipMaxDurationAttributeName]) {
            return 0;
        }
    }
    return 0;
}

- (NSArray *)operationArrayForKey:(TFYVideoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:TFYVideoEditStickerContentsAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is NSArray", key);
        #pragma clang diagnostic pop
    }
    return nil;
}

- (NSArray<NSURL *>*)operationArrayURLForKey:(TFYVideoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *identifiers = (NSArray *)obj;
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        NSPredicate *p = [NSPredicate predicateWithFormat:@"self isKindOfClass: %@",
                          [NSURL class]];
        NSArray *filtered = [identifiers filteredArrayUsingPredicate:p];
        NSAssert(filtered.count == identifiers.count,
                 @"The value of key %@ can only contain NSURL.", key);
        #pragma clang diagnostic pop
        return identifiers;
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:TFYVideoEditAudioUrlsAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is NSArray<NSURL *>*", key);
        #pragma clang diagnostic pop
    }
    return nil;
}

@end

