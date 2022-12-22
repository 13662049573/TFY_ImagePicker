//
//  TFY_ZoomingView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_ZoomingView.h"
#import <AVFoundation/AVFoundation.h>
#import "TFYCategory.h"
#import "TFY_DataFilterImageView.h"
#import "TFYDrawView.h"
#import "TFY_StickerView.h"

NSString *const kTFYZoomingViewData_draw = @"TFYZoomingViewData_draw";
NSString *const kTFYZoomingViewData_sticker = @"TFYZoomingViewData_sticker";
NSString *const kTFYZoomingViewData_splash = @"TFYZoomingViewData_splash";
NSString *const kTFYZoomingViewData_filter = @"TFYZoomingViewData_filter";

@interface TFY_ZoomingView ()
@property (nonatomic, weak) TFY_DataFilterImageView *imageView;

/** 绘画 */
@property (nonatomic, weak) TFY_DrawView *drawView;
/** 贴图 */
@property (nonatomic, weak) TFY_StickerView *stickerView;
/** 模糊（马赛克、高斯模糊、涂抹） */
@property (nonatomic, weak) TFY_DrawView *splashView;
@end

@implementation TFY_ZoomingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    TFY_DataFilterImageView *imageView = [[TFY_DataFilterImageView alloc] initWithFrame:self.bounds];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    self.imageView = imageView;
    
    /** 模糊，实际上它是一个绘画层。设计上它与绘画层的操作不一样。 */
    TFY_DrawView *splashView = [[TFY_DrawView alloc] initWithFrame:self.bounds];
    /** 默认画笔 */
    splashView.brush = [TFY_MosaicBrush new];
    /** 默认不能涂抹 */
    splashView.userInteractionEnabled = NO;
    [self addSubview:splashView];
    self.splashView = splashView;
    
    /** 绘画 */
    TFY_DrawView *drawView = [[TFY_DrawView alloc] initWithFrame:self.bounds];
    /** 默认画笔 */
    drawView.brush = [TFY_PaintBrush new];
    /** 默认不能触发绘画 */
    drawView.userInteractionEnabled = NO;
    [self addSubview:drawView];
    self.drawView = drawView;
    
    /** 贴图 */
    TFY_StickerView *stickerView = [[TFY_StickerView alloc] initWithFrame:self.bounds];
    /** 禁止后，贴图将不能拖到，设计上，贴图是永远可以拖动的 */
//    stickerView.userInteractionEnabled = NO;
    [self addSubview:stickerView];
    self.stickerView = stickerView;
    
    // 实现TFY_EditingProtocol协议
    {
        self.picker_displayView = self.imageView;
        self.picker_drawView = self.drawView;
        self.picker_stickerView = self.stickerView;
        self.picker_splashView = self.splashView;
    }
}

- (void)dealloc
{
    // 释放LFEditingProtocol协议
    [self clearProtocolxecutor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /** 子控件更新 */
    [[self subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = self.bounds;
    }];
}

- (void)setImage:(UIImage *)image
{
    [self setImage:image durations:nil];
}

- (void)setImage:(UIImage *)image durations:(nullable NSArray <NSNumber *> *)durations
{
    _image = image;
    CGSize imageSize = image.size;
    
    if (image) {
        /** 判断是否大图、长图之类的图片，暂时规定超出当前手机屏幕的n倍就是大图了 */
        CGFloat scale = 12.5f;
        BOOL isLongImage = MAX(imageSize.height/imageSize.width, imageSize.width/imageSize.height) > scale;
        if (image.images.count == 0 && (isLongImage || (imageSize.width > [UIScreen mainScreen].bounds.size.width * scale || imageSize.height > [UIScreen mainScreen].bounds.size.height * scale))) { // 长图UIView -> CATiledLayer
            self.imageView.contextType = TFYContextTypeLargeImage;
        } else { //正常图UIView
            self.imageView.contextType = TFYContextTypeDefault;
        }
    }
    [self.imageView setImageByUIImage:image durations:durations];
}

/** 获取除图片以外的编辑图层 */
- (UIImage *)editOtherImagesInRect:(CGRect)rect rotate:(CGFloat)rotate
{
    UIImage *image = nil;
    NSMutableArray *array = nil;
    
    for (UIView *subView in self.subviews) {
        
        if (subView == self.imageView) {
            continue;
        } else if ([subView isKindOfClass:[TFY_DrawView class]]) {
            if (((TFY_DrawView *)subView).count  == 0) {
                continue;
            }
        } else if ([subView isKindOfClass:[TFY_StickerView class]]) {
            if (((TFY_StickerView *)subView).count  == 0) {
                continue;
            }
        }
        if (array == nil) {
            array = [NSMutableArray arrayWithCapacity:3];
        }
        [array addObject:[subView picker_captureImageAtFrame:rect]];
        
    }
    
    if (array.count) {
        image = [UIImage picker_mergeimages:array];
        if (rotate) {
            image = [image picker_imageRotatedByRadians:rotate];
        }
    }
    return image;
}

- (void)setMoveCenter:(BOOL (^)(CGRect))moveCenter
{
    _moveCenter = moveCenter;
    if (moveCenter) {
        _stickerView.moveCenter = moveCenter;
    } else {
        _stickerView.moveCenter = nil;
    }
}

#pragma mark - TFY_EditingProtocol

#pragma mark - 数据
- (NSDictionary *)photoEditData
{
    NSDictionary *drawData = _drawView.data;
    NSDictionary *stickerData = _stickerView.data;
    NSDictionary *splashData = _splashView.data;
    NSDictionary *filterData = _imageView.data;
    
    NSMutableDictionary *data = [@{} mutableCopy];
    if (drawData) [data setObject:drawData forKey:kTFYZoomingViewData_draw];
    if (stickerData) [data setObject:stickerData forKey:kTFYZoomingViewData_sticker];
    if (splashData) [data setObject:splashData forKey:kTFYZoomingViewData_splash];
    if (filterData) [data setObject:filterData forKey:kTFYZoomingViewData_filter];
    
    if (data.count) {
        return data;
    }
    return nil;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    _drawView.data = photoEditData[kTFYZoomingViewData_draw];
    _stickerView.data = photoEditData[kTFYZoomingViewData_sticker];
    _splashView.data = photoEditData[kTFYZoomingViewData_splash];
    _imageView.data = photoEditData[kTFYZoomingViewData_filter];
}


@end
