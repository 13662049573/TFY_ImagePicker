//
//  TFY_EditingProtocol.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_EditingProtocol.h"
#import <objc/runtime.h>
#import "TFYCategory.h"
#import "TFYItools.h"
#import "TFY_StickerView.h"
#import "TFY_FilterGifView.h"
#import "TFY_FilterDataProtocol.h"


static const char * TFYEditingProtocolProtocolxecutorKey = "TFYEditingProtocolProtocolxecutorKey";
static const char * TFYEditingProtocolEditDelegateKey = "TFYEditingProtocolEditDelegateKey";

static const char * TFYEditingProtocolDrawViewKey = "TFYEditingProtocolDrawViewKey";
static const char * TFYEditingProtocolStickerViewKey = "TFYEditingProtocolStickerViewKey";
static const char * TFYEditingProtocolSplashViewKey = "TFYEditingProtocolSplashViewKey";

static const char * TFYEditingProtocolDisplayViewKey = "TFYEditingProtocolDisplayViewKey";

static const char * TFYEditingProtocolEditEnableKey = "TFYEditingProtocolEditEnableKey";
static const char * TFYEditingProtocolDrawViewEnableKey = "TFYEditingProtocolDrawViewEnableKey";
static const char * TFYEditingProtocolStickerViewEnableKey = "TFYEditingProtocolStickerViewEnableKey";
static const char * TFYEditingProtocolSplashViewEnableKey = "TFYEditingProtocolSplashViewEnableKey";

static const char * TFYEditingProtocolDrawLineWidthKey = "TFYEditingProtocolDrawLineWidthKey";
static const char * TFYEditingProtocolDrawLineColorKey = "TFYEditingProtocolDrawLineColorKey";
static const char * TFYEditingProtocolSplashLineWidthKey = "TFYEditingProtocolSplashLineWidthKey";

@interface UIView (TFY_EditingProtocolPrivate)
/** 记录编辑层是否可控 */
@property (nonatomic, assign) BOOL picker_editEnable;
@property (nonatomic, assign) BOOL picker_drawViewEnable;
@property (nonatomic, assign) BOOL picker_stickerViewEnable;
@property (nonatomic, assign) BOOL picker_splashViewEnable;

/** 记录画笔的宽度 */
@property (nonatomic, assign) CGFloat picker_drawLineWidth;
@property (nonatomic, assign) CGFloat picker_splashLineWidth;

@end

@implementation UIView (TFY_EditingProtocol)

#pragma mark - property
// 协议执行者
- (UIView <TFY_EditingProtocol>*)picker_protocolxecutor
{
    return objc_getAssociatedObject(self, TFYEditingProtocolProtocolxecutorKey);
}

- (void)setPicker_protocolxecutor:(UIView<TFY_EditingProtocol> *)picker_protocolxecutor
{
    objc_setAssociatedObject(self, TFYEditingProtocolProtocolxecutorKey, picker_protocolxecutor, OBJC_ASSOCIATION_ASSIGN);
}

- (TFY_DrawView *)picker_drawView
{
    return objc_getAssociatedObject(self, TFYEditingProtocolDrawViewKey);
}

- (void)setPicker_drawView:(TFY_DrawView *)drawView
{
    objc_setAssociatedObject(self, TFYEditingProtocolDrawViewKey, drawView, OBJC_ASSOCIATION_ASSIGN);
}

- (TFY_StickerView *)picker_stickerView
{
    return objc_getAssociatedObject(self, TFYEditingProtocolStickerViewKey);
}
- (void)setPicker_stickerView:(TFY_StickerView *)stickerView
{
    objc_setAssociatedObject(self, TFYEditingProtocolStickerViewKey, stickerView, OBJC_ASSOCIATION_ASSIGN);
}

- (TFY_DrawView *)picker_splashView
{
    return objc_getAssociatedObject(self, TFYEditingProtocolSplashViewKey);
}

- (void)setPicker_splashView:(TFY_DrawView *)splashView
{
    objc_setAssociatedObject(self, TFYEditingProtocolSplashViewKey, splashView, OBJC_ASSOCIATION_ASSIGN);
}

- (id<TFY_FilterDataProtocol>)picker_displayView
{
    return objc_getAssociatedObject(self, TFYEditingProtocolDisplayViewKey);
}
- (void)setPicker_displayView:(id<TFY_FilterDataProtocol>)picker_displayView
{
    objc_setAssociatedObject(self, TFYEditingProtocolDisplayViewKey, picker_displayView, OBJC_ASSOCIATION_ASSIGN);
}

- (void)clearProtocolxecutor
{
    objc_removeAssociatedObjects(self);
}

#pragma mark - TFY_EditingProtocolPrivate property
- (BOOL)picker_editEnable
{
    NSNumber *num = objc_getAssociatedObject(self, TFYEditingProtocolEditEnableKey);
    if (num != nil) {
        return [num boolValue];
    }
    return YES;
}
- (void)setPicker_editEnable:(BOOL)editEnable
{
    objc_setAssociatedObject(self, TFYEditingProtocolEditEnableKey, @(editEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)picker_drawViewEnable
{
    return [objc_getAssociatedObject(self, TFYEditingProtocolDrawViewEnableKey) boolValue];
}
- (void)setPicker_drawViewEnable:(BOOL)drawViewEnable
{
    objc_setAssociatedObject(self, TFYEditingProtocolDrawViewEnableKey, @(drawViewEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)picker_stickerViewEnable
{
    return [objc_getAssociatedObject(self, TFYEditingProtocolStickerViewEnableKey) boolValue];
}
- (void)setPicker_stickerViewEnable:(BOOL)stickerViewEnable
{
    objc_setAssociatedObject(self, TFYEditingProtocolStickerViewEnableKey, @(stickerViewEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)picker_splashViewEnable
{
    return [objc_getAssociatedObject(self, TFYEditingProtocolSplashViewEnableKey) boolValue];
}
- (void)setPicker_splashViewEnable:(BOOL)splashViewEnable
{
    objc_setAssociatedObject(self, TFYEditingProtocolSplashViewEnableKey, @(splashViewEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)picker_drawLineWidth
{
    return [objc_getAssociatedObject(self, TFYEditingProtocolDrawLineWidthKey) floatValue];
}

- (void)setPicker_drawLineWidth:(CGFloat)picker_drawLineWidth
{
    objc_setAssociatedObject(self, TFYEditingProtocolDrawLineWidthKey, @(picker_drawLineWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)picker_drawLineColor
{
    return objc_getAssociatedObject(self, TFYEditingProtocolDrawLineColorKey);
}
- (void)setPicker_drawLineColor:(UIColor *)picker_drawLineColor
{
    objc_setAssociatedObject(self, TFYEditingProtocolDrawLineColorKey, picker_drawLineColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)picker_splashLineWidth
{
    return [objc_getAssociatedObject(self, TFYEditingProtocolSplashLineWidthKey) floatValue];
}
- (void)setPicker_splashLineWidth:(CGFloat)picker_splashLineWidth
{
    objc_setAssociatedObject(self, TFYEditingProtocolSplashLineWidthKey, @(picker_splashLineWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - TFY_EditingProtocol

- (void)setEditDelegate:(id<TFY_PhotoEditDelegate>)editDelegate
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setEditDelegate:editDelegate];
        return;
    }
    objc_setAssociatedObject(self, TFYEditingProtocolEditDelegateKey, editDelegate, OBJC_ASSOCIATION_ASSIGN);
    /** 设置代理回调 */
    __weak typeof(self) weakSelf = self;
    
    if (self.editDelegate) {
        /** 绘画 */
        self.picker_drawView.drawBegan = ^{
            if ([weakSelf.editDelegate respondsToSelector:@selector(picker_photoEditDrawBegan)]) {
                [weakSelf.editDelegate picker_photoEditDrawBegan];
            }
        };
        
        self.picker_drawView.drawEnded = ^{
            if ([weakSelf.editDelegate respondsToSelector:@selector(picker_photoEditDrawEnded)]) {
                [weakSelf.editDelegate picker_photoEditDrawEnded];
            }
        };
        
        /** 贴图 */
        self.picker_stickerView.tapEnded = ^(TFY_StickerItem *item, BOOL isActive) {
            if ([weakSelf.editDelegate respondsToSelector:@selector(picker_photoEditStickerDidSelectViewIsActive:)]) {
                [weakSelf.editDelegate picker_photoEditStickerDidSelectViewIsActive:isActive];
            }
        };
        self.picker_stickerView.movingBegan = ^(TFY_StickerItem * _Nonnull item) {
            if ([weakSelf.editDelegate respondsToSelector:@selector(picker_photoEditStickerMovingBegan)]) {
                [weakSelf.editDelegate picker_photoEditStickerMovingBegan];
            }
        };
        self.picker_stickerView.movingEnded = ^(TFY_StickerItem * _Nonnull item) {
            if ([weakSelf.editDelegate respondsToSelector:@selector(picker_photoEditStickerMovingEnded)]) {
                [weakSelf.editDelegate picker_photoEditStickerMovingEnded];
            }
        };
        
        /** 模糊 */
        self.picker_splashView.drawBegan = ^{
            if ([weakSelf.editDelegate respondsToSelector:@selector(picker_photoEditSplashBegan)]) {
                [weakSelf.editDelegate picker_photoEditSplashBegan];
            }
        };
        
        self.picker_splashView.drawEnded = ^{
            if ([weakSelf.editDelegate respondsToSelector:@selector(picker_photoEditSplashEnded)]) {
                [weakSelf.editDelegate picker_photoEditSplashEnded];
            }
        };
    } else {
        self.picker_drawView.drawBegan = nil;
        self.picker_drawView.drawEnded = nil;
        self.picker_stickerView.tapEnded = nil;
        self.picker_splashView.drawBegan = nil;
        self.picker_splashView.drawEnded = nil;
    }
}

- (id<TFY_PhotoEditDelegate>)editDelegate
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor editDelegate];
    }
    return objc_getAssociatedObject(self, TFYEditingProtocolEditDelegateKey);
}

/** 禁用其他功能 */
- (void)photoEditEnable:(BOOL)enable
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor photoEditEnable:enable];
        return;
    }
    if (self.picker_editEnable != enable) {
        self.picker_editEnable = enable;
        if (enable) {
            self.picker_drawView.userInteractionEnabled = self.picker_drawViewEnable;
            self.picker_splashView.userInteractionEnabled = self.picker_splashViewEnable;
            self.picker_stickerView.userInteractionEnabled = self.picker_stickerViewEnable;
        } else {
            self.picker_drawViewEnable = self.picker_drawView.userInteractionEnabled;
            self.picker_splashViewEnable = self.picker_splashView.userInteractionEnabled;
            self.picker_stickerViewEnable = self.picker_stickerView.userInteractionEnabled;
            self.picker_drawView.userInteractionEnabled = NO;
            self.picker_splashView.userInteractionEnabled = NO;
            self.picker_stickerView.userInteractionEnabled = NO;
        }
    }
}

#pragma mark - 滤镜功能
/** 滤镜类型 */
- (void)changeFilterType:(NSInteger)cmType
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor changeFilterType:cmType];
        return;
    }
    self.picker_displayView.type = cmType;
}
/** 当前使用滤镜类型 */
- (NSInteger)getFilterType
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor getFilterType];
    }
    return self.picker_displayView.type;
}
/** 获取滤镜图片 */
- (UIImage *)getFilterImage
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor getFilterImage];
    }
    if ([self.picker_displayView isKindOfClass:[TFY_FilterGifView class]]) {
        return [(TFY_FilterGifView *)self.picker_displayView renderedAnimatedUIImage];
    } else if ([self.picker_displayView isKindOfClass:[TFY_ContextImageView class]]) {
        return [(TFY_ContextImageView *)self.picker_displayView renderedUIImage];
    }
    return nil;
}

#pragma mark - 绘画功能
/** 启用绘画功能 */
- (void)setDrawEnable:(BOOL)drawEnable
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setDrawEnable:drawEnable];
        return;
    }
    self.picker_drawView.userInteractionEnabled = drawEnable;
}
- (BOOL)drawEnable
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor drawEnable];
    }
    return self.picker_drawView.userInteractionEnabled;
}
/** 正在绘画 */
- (BOOL)isDrawing
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor isDrawing];
    }
    return self.picker_drawView.isDrawing;
}

- (BOOL)drawCanUndo
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor drawCanUndo];
    }
    return self.picker_drawView.canUndo;
}
- (void)drawUndo
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor drawUndo];
        return;
    }
    [self.picker_drawView undo];
}
/** 设置绘画画笔 */
- (void)setDrawBrush:(TFY_Brush *)brush
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setDrawBrush:brush];
        return;
    }
    if (brush) {
        self.picker_drawView.brush = brush;
        [self setDrawLineWidth:self.picker_drawLineWidth];
        [self setDrawColor:self.picker_drawLineColor];
    }
}
/** 设置绘画颜色 */
- (void)setDrawColor:(UIColor *)color
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setDrawColor:color];
        return;
    }
    self.picker_drawLineColor = color;
    if ([self.picker_drawView.brush isKindOfClass:[TFY_BlurryBrush class]]) {
        // TFY_BlurryBrush 不因颜色而改变效果。
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_MosaicBrush class]]) {
        // TFY_MosaicBrush 不因颜色而改变效果。
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_EraserBrush class]]) {
        // TFY_EraserBrush 不因颜色而改变效果。
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_FluorescentBrush class]]) {
        ((TFY_FluorescentBrush *)self.picker_drawView.brush).lineColor = color;
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_HighlightBrush class]]) {
        ((TFY_HighlightBrush *)self.picker_drawView.brush).outerLineColor = color;
        ((TFY_HighlightBrush *)self.picker_drawView.brush).lineColor = ([color isEqual:[UIColor whiteColor]]) ? [UIColor blackColor] : [UIColor whiteColor];
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_PaintBrush class]]) {
        ((TFY_PaintBrush *)self.picker_drawView.brush).lineColor = color;
    }
}

/** 设置绘画线粗 */
- (void)setDrawLineWidth:(CGFloat)lineWidth
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setDrawLineWidth:lineWidth];
        return;
    }
    self.picker_drawLineWidth = lineWidth;
    if ([self.picker_drawView.brush isKindOfClass:[TFY_SmearBrush class]]) {
        // 对涂抹画笔的线粗相对调整
        self.picker_drawView.brush.lineWidth = lineWidth*20;
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_ChalkBrush class]]) {
        // 对粉笔的线粗相对调整
        self.picker_drawView.brush.lineWidth = lineWidth*2.5;
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_FluorescentBrush class]]) {
        // 对荧光笔的线粗相对调整
        self.picker_drawView.brush.lineWidth = lineWidth*4.5;
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_BlurryBrush class]]) {
        // 对模糊笔的线粗相对调整
        self.picker_drawView.brush.lineWidth = lineWidth*5;
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_MosaicBrush class]]) {
        // 对马赛克笔的线粗相对调整
        self.picker_drawView.brush.lineWidth = lineWidth*5;
    } else if ([self.picker_drawView.brush isKindOfClass:[TFY_EraserBrush class]]) {
        // 对橡皮擦笔的线粗相对调整
        self.picker_drawView.brush.lineWidth = lineWidth+4;
    } else {
        self.picker_drawView.brush.lineWidth = lineWidth;
        if ([self.picker_drawView.brush isKindOfClass:[TFY_HighlightBrush class]]) {
            // 对高亮画笔的外边线粗相对调整
            ((TFY_HighlightBrush *)self.picker_drawView.brush).outerLineWidth = lineWidth/1.6;
        }
    }
}

#pragma mark - 贴图功能
/** 贴图启用 */
- (BOOL)stickerEnable
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor stickerEnable];
    }
    return [self.picker_stickerView isEnable];
}
/** 取消激活贴图 */
- (void)stickerDeactivated
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor stickerDeactivated];
        return;
    }
    [TFY_StickerView stickerViewDeactivated];
}
/** 激活选中的贴图 */
- (void)activeSelectStickerView
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor activeSelectStickerView];
        return;
    }
    [self.picker_stickerView activeSelectStickerView];
}
/** 删除选中贴图 */
- (void)removeSelectStickerView
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor removeSelectStickerView];
        return;
    }
    [self.picker_stickerView removeSelectStickerView];
}
/** 屏幕缩放率 */
- (void)setScreenScale:(CGFloat)scale
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setScreenScale:scale];
        return;
    }
    self.picker_stickerView.screenScale = scale;
}
- (CGFloat)screenScale
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor screenScale];
    }
    return self.picker_stickerView.screenScale;
}

/** 最小缩放率 */
- (void)setStickerMinScale:(CGFloat)stickerMinScale
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setStickerMinScale:stickerMinScale];
        return;
    }
    self.picker_stickerView.minScale = stickerMinScale;
}
- (CGFloat)stickerMinScale
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor stickerMinScale];
    }
    return self.picker_stickerView.minScale;
}
/** 最大缩放率 */
- (void)setStickerMaxScale:(CGFloat)stickerMaxScale
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setStickerMaxScale:stickerMaxScale];
        return;
    }
    self.picker_stickerView.maxScale = stickerMaxScale;
}
- (CGFloat)stickerMaxScale
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor stickerMaxScale];
    }
    return self.picker_stickerView.maxScale;
}
/** 创建贴图 */
- (void)createSticker:(TFY_StickerItem *)item
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor createSticker:item];
        return;
    }
    [self.picker_stickerView createStickerItem:item];
}
/** 获取选中贴图的内容 */
- (TFY_StickerItem *)getSelectSticker
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor getSelectSticker];
    }
    return [self.picker_stickerView getSelectStickerItem];
}
/** 更改选中贴图内容 */
- (void)changeSelectSticker:(TFY_StickerItem *)item
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor changeSelectSticker:item];
        return;
    }
    [self.picker_stickerView changeSelectStickerItem:item];
}

#pragma mark - 模糊功能
/** 启用模糊功能 */
- (void)setSplashEnable:(BOOL)splashEnable
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setSplashEnable:splashEnable];
        return;
    }
    self.picker_splashView.userInteractionEnabled = splashEnable;
}
- (BOOL)splashEnable
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor splashEnable];
    }
    return self.picker_splashView.userInteractionEnabled;
}
/** 正在模糊 */
- (BOOL)isSplashing
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor isSplashing];
    }
    return self.picker_splashView.isDrawing;
}
/** 是否可撤销 */
- (BOOL)splashCanUndo
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor splashCanUndo];
    }
    return self.picker_splashView.canUndo;
}
/** 撤销模糊 */
- (void)splashUndo
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor splashUndo];
        return;
    }
    [self.picker_splashView undo];
}

/** 设置模糊画笔 */
- (TFYSplashStateType)splashStateType
{
    if (self.picker_protocolxecutor) {
        return [self.picker_protocolxecutor splashStateType];
    }
    if ([self.picker_splashView.brush isKindOfClass:[TFY_MosaicBrush class]]) {
        return TFYSplashStateType_Mosaic;
    } else if ([self.picker_splashView.brush isKindOfClass:[TFY_BlurryBrush class]]) {
        return TFYSplashStateType_Blurry;
    } else if ([self.picker_splashView.brush isKindOfClass:[TFY_SmearBrush class]]) {
        return TFYSplashStateType_Smear;
    }
    return TFYSplashStateType_Mosaic;
}
- (void)setSplashStateType:(TFYSplashStateType)splashStateType
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setSplashStateType:splashStateType];
        return;
    }
    TFY_Brush *brush = nil;
    switch (splashStateType) {
        case TFYSplashStateType_Mosaic:
        {
            brush = [[TFY_MosaicBrush alloc] init];
        }
            break;
        case TFYSplashStateType_Blurry:
        {
            brush = [[TFY_BlurryBrush alloc] init];
        }
            break;
        case TFYSplashStateType_Smear:
        {
            brush = [[TFY_SmearBrush alloc] initWithImageName:@"brush/EditImageSmearBrush@2x.png"];
        }
            break;
    }
    if (brush) {
        brush.bundle = [NSBundle picker_mediaEditingBundle];
        [self.picker_splashView setBrush:brush];
        [self setSplashLineWidth:self.picker_splashLineWidth];
    }
}

/** 设置模糊线粗 */
- (void)setSplashLineWidth:(CGFloat)lineWidth
{
    if (self.picker_protocolxecutor) {
        [self.picker_protocolxecutor setSplashLineWidth:lineWidth];
        return;
    }
    self.picker_splashLineWidth = lineWidth;
    if ([self.picker_splashView.brush isKindOfClass:[TFY_SmearBrush class]]) {
        // 对涂抹画笔的线粗相对调整
        self.picker_splashView.brush.lineWidth = lineWidth*4;
    } else if ([self.picker_splashView.brush isKindOfClass:[TFY_BlurryBrush class]]) {
        // 对模糊笔的线粗相对调整
        self.picker_splashView.brush.lineWidth = lineWidth;
    } else if ([self.picker_splashView.brush isKindOfClass:[TFY_MosaicBrush class]]) {
        // 对马赛克笔的线粗相对调整
        self.picker_splashView.brush.lineWidth = lineWidth;
    }
}

@end

