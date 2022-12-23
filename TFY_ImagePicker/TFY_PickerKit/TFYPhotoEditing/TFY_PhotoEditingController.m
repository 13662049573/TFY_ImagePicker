//
//  TFY_PhotoEditingController.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_PhotoEditingController.h"
#import "TFYItools.h"
#import "TFYCategory.h"
#import "TFY_MECancelBlock.h"
#import "TFY_EditingView.h"
#import "TFY_EditToolbar.h"
#import "TFY_StickerBar.h"
#import "TFY_PickerTextBar.h"
#import "TFY_ClipToolbar.h"
#import "TFY_FilterBar.h"
#import "TFY_SafeAreaMaskView.h"
#import "TFY_FilterSuiteUtils.h"

/************************ Attributes ************************/
/** 绘画颜色 NSNumber containing TFYPhotoEditOperationSubType, default 0 */
TFYPhotoEditOperationStringKey const TFYPhotoEditDrawColorAttributeName = @"TFYPhotoEditDrawColorAttributeName";
/** 绘画笔刷 NSNumber containing TFYPhotoEditOperationSubType, default 0 */
TFYPhotoEditOperationStringKey const TFYPhotoEditDrawBrushAttributeName = @"TFYPhotoEditDrawBrushAttributeName";
/** 自定义贴图资源路径 NSString containing string path, default nil. sticker resource path. */
TFYPhotoEditOperationStringKey const TFYPhotoEditStickerAttributeName = @"TFYPhotoEditStickerAttributeName";
/** NSArray containing NSArray<TFYStickerContent *>, default @[[TFYStickerContent stickerContentWithTitle:@"默认" contents:@[TFYStickerContentDefaultSticker]]]. */
TFYPhotoEditOperationStringKey const TFYPhotoEditStickerContentsAttributeName = @"TFYPhotoEditStickerContentsAttributeName";
/** 文字颜色 NSNumber containing TFYPhotoEditOperationSubType, default 0 */
TFYPhotoEditOperationStringKey const TFYPhotoEditTextColorAttributeName = @"TFYPhotoEditTextColorAttributeName";
/** 模糊类型 NSNumber containing TFYPhotoEditOperationSubType, default 0 */
TFYPhotoEditOperationStringKey const TFYPhotoEditSplashAttributeName = @"TFYPhotoEditSplashAttributeName";
/** 滤镜类型 NSNumber containing TFYPhotoEditOperationSubType, default 0 */
TFYPhotoEditOperationStringKey const TFYPhotoEditFilterAttributeName = @"TFYPhotoEditFilterAttributeName";
/** 剪切比例 NSNumber containing TFYPhotoEditOperationSubType, default 0 */
TFYPhotoEditOperationStringKey const TFYPhotoEditCropAspectRatioAttributeName = @"TFYPhotoEditCropAspectRatioAttributeName";
/** 允许剪切旋转 NSNumber containing TFYPhotoEditOperationSubType, default YES */
TFYPhotoEditOperationStringKey const TFYPhotoEditCropCanRotateAttributeName = @"TFYPhotoEditCropCanRotateAttributeName";
/** 允许剪切比例 NSNumber containing TFYPhotoEditOperationSubType, default YES */
TFYPhotoEditOperationStringKey const TFYPhotoEditCropCanAspectRatioAttributeName = @"TFYPhotoEditCropCanAspectRatioAttributeName";
/** 自定义剪切比例。NSArray containing NSArray<id <TFYExtraAspectRatioProtocol>>, default nil. */
TFYPhotoEditOperationStringKey const TFYPhotoEditCropExtraAspectRatioAttributeName = @"TFYPhotoEditCropExtraAspectRatioAttributeName";
/************************ Attributes ************************/

@interface TFY_PhotoEditingController ()<TFYEditToolbarDelegate, TFYStickerBarDelegate, TFYFilterBarDelegate, TFYFilterBarDataSource, TFYClipToolbarDelegate, TFYEditToolbarDataSource, TFYPickerTextBarDelegate, TFY_PhotoEditDelegate, TFYEditingViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>
{
    /** 编辑模式 */
    TFY_EditingView *_EditingView;
    
    UIView *_edit_naviBar;
    /** 底部栏菜单 */
    TFY_EditToolbar *_edit_toolBar;
    /** 剪切菜单 */
    TFY_ClipToolbar *_edit_clipping_toolBar;
    /** 安全区域涂层 */
    TFY_SafeAreaMaskView *_edit_clipping_safeAreaMaskView;
    
    /** 贴图菜单 */
    TFY_StickerBar *_edit_sticker_toolBar;
    
    /** 滤镜菜单 */
    TFY_FilterBar *_edit_filter_toolBar;
    
    /** 单击手势 */
    UITapGestureRecognizer *singleTapRecognizer;
}

/** 隐藏控件 */
@property (nonatomic, assign) BOOL isHideNaviBar;
/** 初始化以选择的功能类型，已经初始化过的将被去掉类型，最终类型为0 */
@property (nonatomic, assign) TFYPhotoEditOperationType initSelectedOperationType;

@property (nonatomic, copy) picker_me_dispatch_cancelable_block_t delayCancelBlock;

/** 滤镜缩略图 */
@property (nonatomic, strong) UIImage *filterSmallImage;
/**
 GIF每帧的持续时间
 */
@property (nonatomic, strong) NSArray<NSNumber *> *durations;

@property (nonatomic, strong, nullable) NSDictionary *editData;

@property (nonatomic, strong, nullable) id stickerBarCacheResource;


@end

@implementation TFY_PhotoEditingController

- (instancetype)initWithOrientation:(UIInterfaceOrientation)orientation
{
    self = [super initWithOrientation:orientation];
    if (self) {
        _operationType = TFYPhotoEditOperationType_All;
    }
    return self;
}

- (void)setEditImage:(UIImage *)editImage
{
    [self setEditImage:editImage durations:nil];
}

- (void)setEditImage:(UIImage *)editImage durations:(nullable NSArray<NSNumber *> *)durations
{
    _editImage = editImage;
    _durations = durations;
    
    if (_editImage.images.count) {
        /** gif不能使用模糊功能 */
        if (_operationType & TFYPhotoEditOperationType_splash) {
            _operationType ^= TFYPhotoEditOperationType_splash;
        }
    }
}

- (void)setPhotoEdit:(TFY_PhotoEdit *)photoEdit
{
    [self setEditImage:photoEdit.editImage durations:photoEdit.durations];
    _editData = photoEdit.editData;
}

- (void)setDefaultOperationType:(TFYPhotoEditOperationType)defaultOperationType
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
    [self configScrollView];
    [self configCustomNaviBar];
    [self configBottomToolBar];
    [self configDefaultOperation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_EditingView == nil) {
        [self configScrollView];
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
    [self configUserGuide];
}
#pragma mark - 创建视图
- (void)configScrollView
{
    CGRect editRect = self.view.bounds;
    _EditingView = [[TFY_EditingView alloc] initWithFrame:editRect];
    _EditingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _EditingView.editDelegate = self;
    _EditingView.clippingDelegate = self;
    _EditingView.fixedAspectRatio = ![self operationBOOLForKey:TFYPhotoEditCropCanAspectRatioAttributeName];
    _EditingView.extraAspectRatioList = [self operationArrayForKey:TFYPhotoEditCropExtraAspectRatioAttributeName];
    
    /** 单击的 Recognizer */
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singlePressed)];
    /** 点击的次数 */
    singleTapRecognizer.numberOfTapsRequired = 1; // 单击
    singleTapRecognizer.delegate = self;
    /** 给view添加一个手势监测 */
    [self.view addGestureRecognizer:singleTapRecognizer];
    self.view.exclusiveTouch = YES;
    
    [self.view addSubview:_EditingView];
    
    [_EditingView setImage:self.editImage durations:self.durations];
    if (self.editData) {
        // 设置编辑数据
        _EditingView.photoEditData = self.editData;
        // 释放销毁
        self.editData = nil;
    } else {
        /** 设置默认滤镜 */
        if (@available(iOS 9.0, *)) {
            if (self.operationType&TFYPhotoEditOperationType_filter) {
                TFYPhotoEditOperationSubType subType = [self operationSubTypeForKey:TFYPhotoEditFilterAttributeName];
                NSInteger index = 0;
                switch (subType) {
                    case TFYPhotoEditOperationSubTypeLinearCurveFilter:
                    case TFYPhotoEditOperationSubTypeChromeFilter:
                    case TFYPhotoEditOperationSubTypeFadeFilter:
                    case TFYPhotoEditOperationSubTypeInstantFilter:
                    case TFYPhotoEditOperationSubTypeMonoFilter:
                    case TFYPhotoEditOperationSubTypeNoirFilter:
                    case TFYPhotoEditOperationSubTypeProcessFilter:
                    case TFYPhotoEditOperationSubTypeTonalFilter:
                    case TFYPhotoEditOperationSubTypeTransferFilter:
                    case TFYPhotoEditOperationSubTypeCurveLinearFilter:
                    case TFYPhotoEditOperationSubTypeInvertFilter:
                    case TFYPhotoEditOperationSubTypeMonochromeFilter:
                        index = subType % 400 + 1;
                    default:
                        break;
                }
                
                if (index > 0) {
                    [_EditingView changeFilterType:index];
                }
            }
        }
        
        /** 设置默认剪裁比例 */
        if (self.operationType&TFYPhotoEditOperationType_crop) {
            TFYPhotoEditOperationSubType subType = [self operationSubTypeForKey:TFYPhotoEditCropAspectRatioAttributeName];
            NSInteger index = 0;
            if (_EditingView.extraAspectRatioList) {
                if (subType >= 500) {
                    index = subType % 500 + 1;
                }
            } else {
                switch (subType) {
                    case TFYPhotoEditOperationSubTypeCropAspectRatioOriginal:
                    case TFYPhotoEditOperationSubTypeCropAspectRatio1x1:
                    case TFYPhotoEditOperationSubTypeCropAspectRatio3x2:
                    case TFYPhotoEditOperationSubTypeCropAspectRatio4x3:
                    case TFYPhotoEditOperationSubTypeCropAspectRatio5x3:
                    case TFYPhotoEditOperationSubTypeCropAspectRatio15x9:
                    case TFYPhotoEditOperationSubTypeCropAspectRatio16x9:
                    case TFYPhotoEditOperationSubTypeCropAspectRatio16x10:
                        index = subType % 500 + 1;
                        break;
                    default:
                        break;
                }
            }
            
            _EditingView.defaultAspectRatioIndex = index;
        }
    }
}

- (void)configCustomNaviBar
{
    CGFloat margin = 8, topbarHeight = 0;
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
    if (self.operationType&TFYPhotoEditOperationType_draw) {
        toolbarType |= TFYEditToolbarType_draw;
    }
    if (self.operationType&TFYPhotoEditOperationType_sticker) {
        toolbarType |= TFYEditToolbarType_sticker;
    }
    if (self.operationType&TFYPhotoEditOperationType_text) {
        toolbarType |= TFYEditToolbarType_text;
    }
    if (self.operationType&TFYPhotoEditOperationType_splash) {
        toolbarType |= TFYEditToolbarType_splash;
    }
    if (self.operationType&TFYPhotoEditOperationType_crop) {
        toolbarType |= TFYEditToolbarType_crop;
    }
    if (@available(iOS 9.0, *)) {
        if (self.operationType&TFYPhotoEditOperationType_filter) {
            toolbarType |= TFYEditToolbarType_filter;
        }
    }
    
    _edit_toolBar = [[TFY_EditToolbar alloc] initWithType:toolbarType];
    _edit_toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _edit_toolBar.delegate = self;
    
//    if (self.operationType&TFYPhotoEditOperationType_draw) {
//        __weak typeof(_edit_toolBar) weakToolBar = _edit_toolBar;
//        if (![TFYEraserBrush eraserBrushCache]) {
//            [_edit_toolBar setDrawBrushWait:YES];
//            CGSize canvasSize = AVMakeRectWithAspectRatioInsideRect(self.editImage.size, _EditingView.bounds).size;
//            [TFYEraserBrush loadEraserImage:self.editImage canvasSize:canvasSize useCache:YES complete:^(BOOL success) {
//                [weakToolBar setDrawBrushWait:NO];
//            }];
//        }
//    }
    
    if (self.operationType&TFYPhotoEditOperationType_splash) {
        __weak typeof(_edit_toolBar) weakToolBar = _edit_toolBar;
        /** 加载涂抹相关画笔 */
        if (![TFY_MosaicBrush mosaicBrushCache]) {
            [_edit_toolBar setSplashWait:YES index:TFYSplashStateType_Mosaic];
            CGSize canvasSize = AVMakeRectWithAspectRatioInsideRect(self.editImage.size, _EditingView.bounds).size;
            [TFY_MosaicBrush loadBrushImage:self.editImage scale:15.0 canvasSize:canvasSize useCache:YES complete:^(BOOL success) {
                [weakToolBar setSplashWait:NO index:TFYSplashStateType_Mosaic];
            }];
        }
        if (![TFY_BlurryBrush blurryBrushCache]) {
            [_edit_toolBar setSplashWait:YES index:TFYSplashStateType_Blurry];
            CGSize canvasSize = AVMakeRectWithAspectRatioInsideRect(self.editImage.size, _EditingView.bounds).size;
            [TFY_BlurryBrush loadBrushImage:self.editImage radius:5.0 canvasSize:canvasSize useCache:YES complete:^(BOOL success) {
                [weakToolBar setSplashWait:NO index:TFYSplashStateType_Blurry];
            }];
        }
        if (![TFY_SmearBrush smearBrushCache]) {
            [_edit_toolBar setSplashWait:YES index:TFYSplashStateType_Smear];
            CGSize canvasSize = AVMakeRectWithAspectRatioInsideRect(self.editImage.size, _EditingView.bounds).size;
            [TFY_SmearBrush loadBrushImage:self.editImage canvasSize:canvasSize useCache:YES complete:^(BOOL success) {
                [weakToolBar setSplashWait:NO index:TFYSplashStateType_Smear];
            }];
        }
    }
    
    NSInteger index = 2; /** 红色 */
    
    /** 设置默认绘画颜色 */
    if (self.operationType&TFYPhotoEditOperationType_draw) {
        TFYPhotoEditOperationSubType subType = [self operationSubTypeForKey:TFYPhotoEditDrawColorAttributeName];
        switch (subType) {
            case TFYPhotoEditOperationSubTypeDrawWhiteColor:
            case TFYPhotoEditOperationSubTypeDrawBlackColor:
            case TFYPhotoEditOperationSubTypeDrawRedColor:
            case TFYPhotoEditOperationSubTypeDrawLightYellowColor:
            case TFYPhotoEditOperationSubTypeDrawYellowColor:
            case TFYPhotoEditOperationSubTypeDrawLightGreenColor:
            case TFYPhotoEditOperationSubTypeDrawGreenColor:
            case TFYPhotoEditOperationSubTypeDrawAzureColor:
            case TFYPhotoEditOperationSubTypeDrawRoyalBlueColor:
            case TFYPhotoEditOperationSubTypeDrawBlueColor:
            case TFYPhotoEditOperationSubTypeDrawPurpleColor:
            case TFYPhotoEditOperationSubTypeDrawLightPinkColor:
            case TFYPhotoEditOperationSubTypeDrawVioletRedColor:
            case TFYPhotoEditOperationSubTypeDrawPinkColor:
                index = subType - 1;
                break;
            default:
                break;
        }
        [_edit_toolBar setDrawSliderColorAtIndex:index];
        
        subType = [self operationSubTypeForKey:TFYPhotoEditDrawBrushAttributeName];

        TFYEditToolbarBrushType brushType = 0;
        TFYEditToolbarStampBrushType stampBrushType = 0;
        switch (subType) {
            case TFYPhotoEditOperationSubTypeDrawPaintBrush:
            case TFYPhotoEditOperationSubTypeDrawHighlightBrush:
            case TFYPhotoEditOperationSubTypeDrawChalkBrush:
            case TFYPhotoEditOperationSubTypeDrawFluorescentBrush:
                brushType = subType % 50;
                break;
            case TFYPhotoEditOperationSubTypeDrawStampAnimalBrush:
                brushType = TFYEditToolbarBrushTypeStamp;
                stampBrushType = TFYEditToolbarStampBrushTypeAnimal;
                break;
            case TFYPhotoEditOperationSubTypeDrawStampFruitBrush:
                brushType = TFYEditToolbarBrushTypeStamp;
                stampBrushType = TFYEditToolbarStampBrushTypeFruit;
                break;
            case TFYPhotoEditOperationSubTypeDrawStampHeartBrush:
                brushType = TFYEditToolbarBrushTypeStamp;
                stampBrushType = TFYEditToolbarStampBrushTypeHeart;
                break;
            default:
                break;
        }
        [_edit_toolBar setDrawBrushAtIndex:brushType subIndex:stampBrushType];
    }
    
    /** 设置默认模糊 */
    if (self.operationType&TFYPhotoEditOperationType_splash) {
        /** 重置 */
        index = 0;
        TFYPhotoEditOperationSubType subType = [self operationSubTypeForKey:TFYPhotoEditSplashAttributeName];
        switch (subType) {
            case TFYPhotoEditOperationSubTypeSplashMosaic:
            case TFYPhotoEditOperationSubTypeSplashBlurry:
            case TFYPhotoEditOperationSubTypeSplashPaintbrush:
                index = subType % 300;
                break;
            default:
                break;
        }
        [_edit_toolBar setSplashIndex:index];
    }
    
    
    [self.view addSubview:_edit_toolBar];
}

- (void)configDefaultOperation
{
    if (self.initSelectedOperationType > 0) {
        __weak typeof(self) weakSelf = self;
        BOOL (^containOperation)(TFYPhotoEditOperationType type) = ^(TFYPhotoEditOperationType type){
            if (weakSelf.operationType&type && weakSelf.initSelectedOperationType&type) {
                weakSelf.initSelectedOperationType ^= type;
                return YES;
            }
            return NO;
        };
        
        if (containOperation(TFYPhotoEditOperationType_crop)) {
            [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_crop];
        } else {
            if (containOperation(TFYPhotoEditOperationType_draw)) {
                [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_draw];
            } else if (containOperation(TFYPhotoEditOperationType_sticker)) {
                [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_sticker];
            } else if (containOperation(TFYPhotoEditOperationType_text)) {
                [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_text];
            } else if (containOperation(TFYPhotoEditOperationType_splash)) {
                [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_splash];
            } else {
                if (@available(iOS 9.0, *)) {
                    if (containOperation(TFYPhotoEditOperationType_filter)) {
                        [_edit_toolBar selectMainMenuIndex:TFYEditToolbarType_filter];
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
    if (self.defaultOperationType&TFYPhotoEditOperationType_crop && _EditingView.isClipping) {
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
    if ([self.delegate respondsToSelector:@selector(picker_PhotoEditingControllerDidCancel:)]) {
        [self.delegate picker_PhotoEditingControllerDidCancel:self];
    }
}

- (void)finishButtonClick
{
    [self showProgressHUD];
    /** 取消贴图激活 */
    [_EditingView stickerDeactivated];
    
    /** 处理编辑图片 */
    __block TFY_PhotoEdit *photoEdit = nil;
    NSDictionary *data = [_EditingView photoEditData];
    __weak typeof(self) weakSelf = self;
    
    void (^finishImage)(UIImage *) = ^(UIImage *image){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (data) {
                photoEdit = [[TFY_PhotoEdit alloc] initWithEditImage:weakSelf.editImage previewImage:image durations:weakSelf.durations data:data];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(picker_PhotoEditingController:didFinishPhotoEdit:)]) {
                    [weakSelf.delegate picker_PhotoEditingController:self didFinishPhotoEdit:photoEdit];
                }
                [weakSelf hideProgressHUD];
            });
        });
    };
    
    if (data) {
        [_EditingView createEditImage:^(UIImage *editImage) {
            finishImage(editImage);
        }];
    } else {
        finishImage(nil);
    }
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
        case TFYEditToolbarType_filter:
        {
            [self singlePressed];
            [self changeFilterMenu:YES animated:YES];
        }
            break;
        case TFYEditToolbarType_crop:
        {
            [_EditingView setClipping:YES animated:YES];
            [self changeClipMenu:YES];
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
        case TFYEditToolbarType_crop:
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
        {
            [_EditingView setSplashStateType:(TFYSplashStateType)indexPath.row];
        }
            break;
        case TFYEditToolbarType_crop:
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
        case TFYEditToolbarType_crop:
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

#pragma mark - 剪切底部栏（懒加载）
- (UIView *)edit_clipping_toolBar
{
    if (_edit_clipping_toolBar == nil) {
        UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            safeAreaInsets = self.navigationController.view.safeAreaInsets;
        }
        CGFloat h = 44.f + safeAreaInsets.bottom;
        _edit_clipping_toolBar = [[TFY_ClipToolbar alloc] initWithFrame:CGRectMake(0, self.view.picker_height - h, self.view.picker_width, h)];
        _edit_clipping_toolBar.alpha = 0.f;
        _edit_clipping_toolBar.delegate = self;
        _edit_clipping_toolBar.dataSource = self;
        
        /** 判断是否需要创建安全区域涂层 */
        if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, safeAreaInsets)) {
            _edit_clipping_safeAreaMaskView = [[TFY_SafeAreaMaskView alloc] initWithFrame:self.view.bounds];
            _edit_clipping_safeAreaMaskView.maskRect = _EditingView.frame;
            _edit_clipping_safeAreaMaskView.userInteractionEnabled = NO;
            [self.view insertSubview:_edit_clipping_safeAreaMaskView belowSubview:_EditingView];
        }
    }
    /** 默认不能重置，待进入剪切界面后重新获取 */
    _edit_clipping_toolBar.enableReset = NO;
    _edit_clipping_toolBar.selectAspectRatio = [_EditingView aspectRatioIndex] > 0;
    return _edit_clipping_toolBar;
}

#pragma mark - TFYEditToolbarDataSource
- (BOOL)picker_clipToolbarCanRotate:(TFY_ClipToolbar *)clipToolbar
{
    return [self operationBOOLForKey:TFYPhotoEditCropCanRotateAttributeName];
}

- (BOOL)picker_clipToolbarCanAspectRatio:(TFY_ClipToolbar *)clipToolbar
{
    return [self operationBOOLForKey:TFYPhotoEditCropCanAspectRatioAttributeName];
}

#pragma mark - TFYClipToolbarDelegate
/** 取消 */
- (void)picker_clipToolbarDidCancel:(TFY_ClipToolbar *)clipToolbar
{
    if (self.initSelectedOperationType == 0 && self.operationType == TFYPhotoEditOperationType_crop && self.defaultOperationType == TFYPhotoEditOperationType_crop) { /** 证明initSelectedOperationType已消耗完毕，defaultOperationType是有值的。只有TFYPhotoEditOperationType_crop的情况，无需返回，直接完成整个编辑 */
        [self cancelButtonClick];
    } else {
        [_EditingView cancelClipping:YES];
        [self changeClipMenu:NO];
        _edit_clipping_toolBar.selectAspectRatio = [_EditingView aspectRatioIndex] > 0;
        [self configDefaultOperation];
        [self configUserGuide];
    }
}
/** 完成 */
- (void)picker_clipToolbarDidFinish:(TFY_ClipToolbar *)clipToolbar
{
    if (self.initSelectedOperationType == 0 && self.operationType == TFYPhotoEditOperationType_crop && self.defaultOperationType == TFYPhotoEditOperationType_crop) { /** 证明initSelectedOperationType已消耗完毕，defaultOperationType是有值的。只有TFYPhotoEditOperationType_crop的情况，无需返回，直接完成整个编辑 */
        [_EditingView setClipping:NO animated:NO];
        [self finishButtonClick];
    } else {
        [_EditingView setClipping:NO animated:YES];
        [self changeClipMenu:NO];
        _edit_clipping_toolBar.selectAspectRatio = [_EditingView aspectRatioIndex] > 0;
        [self configDefaultOperation];
        [self configUserGuide];
    }
}
/** 重置 */
- (void)picker_clipToolbarDidReset:(TFY_ClipToolbar *)clipToolbar
{
    [_EditingView reset];
    _edit_clipping_toolBar.enableReset = _EditingView.canReset;
    _edit_clipping_toolBar.selectAspectRatio = NO;
}
/** 旋转 */
- (void)picker_clipToolbarDidRotate:(TFY_ClipToolbar *)clipToolbar
{
    [_EditingView rotate];
    _edit_clipping_toolBar.enableReset = _EditingView.canReset;
}
/** 长宽比例 */
- (void)picker_clipToolbarDidAspectRatio:(TFY_ClipToolbar *)clipToolbar
{
    if (_edit_clipping_toolBar.selectAspectRatio) {
        _edit_clipping_toolBar.selectAspectRatio = NO;
        [_EditingView setAspectRatioIndex:0];
        return;
    }
    NSArray *items = [_EditingView aspectRatioDescs];
    if (NSClassFromString(@"UIAlertController")) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle picker_localizedStringForKey:@"_LFME_cancelButtonTitle"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self->_edit_clipping_toolBar.selectAspectRatio = NO;
            [self->_EditingView setAspectRatioIndex:0];
        }]];
        
        //Add each item to the alert controller
        NSString *languageName = nil;
        NSString *item = nil;
        for (NSInteger i=0; i<items.count; i++) {
            item = items[i];
            languageName = [@"_LFME_ratio_" stringByAppendingString:item];
            UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle picker_localizedStringForKey:languageName value:item] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self->_edit_clipping_toolBar.selectAspectRatio = YES;
                [self->_EditingView setAspectRatioIndex:i+1];
            }];
            [alertController addAction:action];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            alertController.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *presentationController = [alertController popoverPresentationController];
            presentationController.sourceView = clipToolbar;
            presentationController.sourceRect = clipToolbar.clickViewRect;
        }
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        //TODO: Completely overhaul this once iOS 7 support is dropped
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:[NSBundle picker_localizedStringForKey:@"_LFME_cancelButtonTitle"]
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        for (NSString *item in items) {
            [actionSheet addButtonWithTitle:item];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [actionSheet showFromRect:clipToolbar.frame inView:clipToolbar animated:YES];
        else
            [actionSheet showInView:self.view];
#pragma clang diagnostic pop
    }
}

#pragma mark - UIActionSheetDelegate
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        _edit_clipping_toolBar.selectAspectRatio = NO;
        [_EditingView setAspectRatioIndex:0];
    } else {
        _edit_clipping_toolBar.selectAspectRatio = YES;
        [_EditingView setAspectRatioIndex:buttonIndex];
    }
}
#pragma clang diagnostic pop

#pragma mark - 滤镜菜单（懒加载）
- (TFY_FilterBar *)edit_filter_toolBar
{
    if (_edit_filter_toolBar == nil) {
        CGFloat w=self.view.picker_width, h=100.f;
        if (@available(iOS 11.0, *)) {
            h += self.navigationController.view.safeAreaInsets.bottom;
        }
        _edit_filter_toolBar = [[TFY_FilterBar alloc] initWithFrame:CGRectMake(0, self.view.picker_height, w, h) defalutEffectType:[_EditingView getFilterType] dataSource:@[@(TFYFilterNameType_None),
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
                                                                         @(TFYFilterNameType_Monochrome),
                                                                         ]];
        CGFloat rgb = 34 / 255.0;
        _edit_filter_toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.85];
        _edit_filter_toolBar.defaultColor = self.cancelButtonTitleColorNormal;
        _edit_filter_toolBar.selectColor = self.oKButtonTitleColorNormal;
        _edit_filter_toolBar.delegate = self;
        _edit_filter_toolBar.dataSource = self;
    }
    return _edit_filter_toolBar;
}

#pragma mark - TFY_FilterBarDelegate
- (void)picker_filterBar:(TFY_FilterBar *)picker_filterBar didSelectImage:(UIImage *)image effectType:(NSInteger)effectType
{
    [_EditingView changeFilterType:effectType];
}

#pragma mark - TFY_FilterBarDataSource
- (UIImage *)picker_async_filterBarImageForEffectType:(NSInteger)type
{
    if (_filterSmallImage == nil) {
        CGSize size = CGSizeZero;
        CGSize imageSize = self.editImage.size;
        size.width = MIN(TFY_FilterBar_MAX_WIDTH*[UIScreen mainScreen].scale, imageSize.width);
        size.height = ((int)(imageSize.height*size.width/imageSize.width))*1.f;
        
        UIGraphicsBeginImageContext(size);
        [self.editImage drawInRect:(CGRect){CGPointZero, size}];
        self.filterSmallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
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

#pragma mark - 贴图菜单（懒加载）
- (TFY_StickerBar *)edit_sticker_toolBar
{
    if (_edit_sticker_toolBar == nil) {
        CGFloat row = 4;
        CGFloat w=self.view.picker_width, h = picker_stickerSize*row+picker_stickerMargin*(row+1);
        if (@available(iOS 11.0, *)) {
            h += self.navigationController.view.safeAreaInsets.bottom;
        }
        CGRect frame = CGRectMake(0, self.view.picker_height, w, h);
        
        if (self.stickerBarCacheResource) {
            _edit_sticker_toolBar = [[TFY_StickerBar alloc] initWithFrame:frame cacheResources:self.stickerBarCacheResource];
        } else {
            /** 设置默认贴图资源路径 */
            NSArray <TFY_StickerContent *>*stickerContents = [self operationArrayForKey:TFYPhotoEditStickerContentsAttributeName];
            
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

#pragma mark - TFYStickerBarDelegate
- (void)picker_stickerBar:(TFY_StickerBar *)picker_stickerBar didSelectImage:(UIImage *)image
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
- (void)picker_textBarController:(TFY_PickerTextBar *)textBar didFinishText:(TFY_PickerText *)text
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
- (void)picker_textBarControllerDidCancel:(TFY_PickerTextBar *)textBar
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
- (void)picker_textBarControllerDidReachMaximumLimit:(TFY_PickerTextBar *)textBar
{
    [self showInfoMessage:[NSBundle picker_localizedStringForKey:@"_LFME_reachMaximumLimitTitle"]];
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

#pragma mark - TFYEditingViewDelegate
/** 开始编辑目标 */
- (void)picker_EditingViewWillBeginEditing:(TFY_EditingView *)EditingView
{
    [UIView animateWithDuration:0.25f animations:^{
        self.edit_clipping_toolBar.alpha = 0.f;
    }];
    [_edit_clipping_safeAreaMaskView setShowMaskLayer:NO];
}
/** 停止编辑目标 */
- (void)picker_EditingViewDidEndEditing:(TFY_EditingView *)EditingView
{
    [UIView animateWithDuration:0.25f animations:^{
        self.edit_clipping_toolBar.alpha = 1.f;
    }];
    [_edit_clipping_safeAreaMaskView setShowMaskLayer:YES];
    _edit_clipping_toolBar.enableReset = EditingView.canReset;
}

/** 进入剪切界面 */
- (void)picker_EditingViewDidAppearClip:(TFY_EditingView *)EditingView
{
    _edit_clipping_toolBar.enableReset = EditingView.canReset;
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
        [_edit_clipping_safeAreaMaskView setShowMaskLayer:YES];
        singleTapRecognizer.enabled = NO;
        [self singlePressedWithAnimated:animated];
    } else {
        if (_edit_clipping_toolBar.superview == nil) return;

        /** 开启编辑 */
        [_EditingView photoEditEnable:YES];
        
        singleTapRecognizer.enabled = YES;
        [_edit_clipping_safeAreaMaskView setShowMaskLayer:NO];
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
            self.stickerBarCacheResource = _edit_sticker_toolBar.cacheResources;
            [_edit_sticker_toolBar removeFromSuperview];
            _edit_sticker_toolBar = nil;
        }
    }
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

- (void)showTextBarController:(TFY_PickerText *)text
{
    static NSInteger TFYTextBarTag = 32735;
    if ([self.view viewWithTag:TFYTextBarTag]) {
        return;
    }
    
    TFY_PickerTextBar *textBar = [[TFY_PickerTextBar alloc] initWithFrame:CGRectMake(0, self.view.picker_height, self.view.picker_width, self.view.picker_height) layout:^(TFY_PickerTextBar *textBar) {
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
        TFYPhotoEditOperationSubType subType = [self operationSubTypeForKey:TFYPhotoEditTextColorAttributeName];
        
        NSInteger index = 0;
        switch (subType) {
            case TFYPhotoEditOperationSubTypeTextWhiteColor: index = 0; break;
            case TFYPhotoEditOperationSubTypeTextBlackColor: index = 1; break;
            case TFYPhotoEditOperationSubTypeTextRedColor: index = 2; break;
            case TFYPhotoEditOperationSubTypeTextLightYellowColor: index = 3; break;
            case TFYPhotoEditOperationSubTypeTextYellowColor: index = 4; break;
            case TFYPhotoEditOperationSubTypeTextLightGreenColor: index = 5; break;
            case TFYPhotoEditOperationSubTypeTextGreenColor: index = 6; break;
            case TFYPhotoEditOperationSubTypeTextAzureColor: index = 7; break;
            case TFYPhotoEditOperationSubTypeTextRoyalBlueColor: index = 8; break;
            case TFYPhotoEditOperationSubTypeTextBlueColor: index = 9; break;
            case TFYPhotoEditOperationSubTypeTextPurpleColor: index = 10; break;
            case TFYPhotoEditOperationSubTypeTextLightPinkColor: index = 11; break;
            case TFYPhotoEditOperationSubTypeTextVioletRedColor: index = 12; break;
            case TFYPhotoEditOperationSubTypeTextPinkColor: index = 13; break;
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

#pragma mark - 配置数据
- (TFYPhotoEditOperationSubType)operationSubTypeForKey:(TFYPhotoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return (TFYPhotoEditOperationSubType)[obj integerValue];
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:TFYPhotoEditDrawColorAttributeName]
        || [key isEqualToString:TFYPhotoEditDrawBrushAttributeName]
        || [key isEqualToString:TFYPhotoEditTextColorAttributeName]
        || [key isEqualToString:TFYPhotoEditSplashAttributeName]
        || [key isEqualToString:TFYPhotoEditFilterAttributeName]
        || [key isEqualToString:TFYPhotoEditCropAspectRatioAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is TFYPhotoEditOperationSubType", key);
        #pragma clang diagnostic pop
    }
    return 0;
}

- (NSArray *)operationArrayForKey:(TFYPhotoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:TFYPhotoEditStickerContentsAttributeName]
        || [key isEqualToString:TFYPhotoEditCropExtraAspectRatioAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is NSArray", key);
        #pragma clang diagnostic pop
    }
    return nil;
}

- (BOOL)operationBOOLForKey:(TFYPhotoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj boolValue];
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
        BOOL isContain = [key isEqualToString:TFYPhotoEditCropCanRotateAttributeName]
        || [key isEqualToString:TFYPhotoEditCropCanAspectRatioAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is NSString", key);
        #pragma clang diagnostic pop
    } else {
        if ([key isEqualToString:TFYPhotoEditCropCanRotateAttributeName]) {
            return YES;
        } else if ([key isEqualToString:TFYPhotoEditCropCanAspectRatioAttributeName]) {
            return YES;
        }
    }
    return NO;
}

@end
