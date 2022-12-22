//
//  TFY_PhotoPreviewCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PhotoPreviewCell.h"
#import "TFY_AssetManager.h"
#import "TFY_PhotoEditManager.h"
#import "TFY_PhotoEdit.h"

@interface TFY_PhotoPreviewCell () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UITapGestureRecognizer *tap1;
@property (nonatomic, strong) UITapGestureRecognizer *tap2;
@property (nonatomic, assign) BOOL isFinalData;
@end

@implementation TFY_PhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 3.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self.contentView addSubview:_scrollView];
        
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [_scrollView addSubview:_imageContainerView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_imageContainerView addSubview:_imageView];
        UIView *view = [self subViewInitDisplayView];
        if (view) {
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_imageContainerView addSubview:view];
        }
        
        _tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:_tap1];
        _tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        _tap2.numberOfTapsRequired = 2;
        [_tap1 requireGestureRecognizerToFail:_tap2];
        [self addGestureRecognizer:_tap2];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resizeSubviews];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self subViewReset];
    _isFinalData = NO;
    _model = nil;
}

- (UIImage *)previewImage
{
    if (self.isFinalData) {
        return self.imageView.image;
    }
    return nil;
}

- (void)setPreviewImage:(UIImage *)previewImage
{
    self.imageView.image = previewImage;
    [self resizeSubviews];
}

- (void)setModel:(TFY_PickerAsset *)model
{
    _model = model;
    if (model.type == TFYAssetMediaTypePhoto) {
        /** 优先显示编辑图片 */
        TFY_PhotoEdit *photoEdit = [[TFY_PhotoEditManager manager] photoEditForAsset:model];
        if (photoEdit.editPreviewImage) {
            self.previewImage = photoEdit.editPreviewImage;
        } else
            if (model.previewImage) { /** 显示自定义图片 */
                self.previewImage = model.previewImage;
            } else {
                void (^completion)(id data,NSDictionary *info,BOOL isDegraded) = ^(id data,NSDictionary *info,BOOL isDegraded){
                    if ([model isEqual:self.model]) {
                        if (!isDegraded) {
                            self.isFinalData = YES;
                        }
                        if ([data isKindOfClass:[UIImage class]]) { /** image */
                            self.previewImage = (UIImage *)data;
                        } else if ([data isKindOfClass:[NSData class]]) {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                UIImage *image = [UIImage imageWithData:data];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.previewImage = image;
                                });
                            });
                        }
                    }
                };
                [self subViewSetModel:model completeHandler:completion progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {}];
            }
    } else {
        void (^completion)(id data,NSDictionary *info,BOOL isDegraded) = ^(id data,NSDictionary *info,BOOL isDegraded){
            if ([model isEqual:self.model]) {
                if ([data isKindOfClass:[UIImage class]]) { /** image */
                    self.previewImage = (UIImage *)data;
                } else if ([data isKindOfClass:[NSData class]]) {
                    self.previewImage = [UIImage imageWithData:data];
                }
            }
        };
        [self subViewSetModel:model completeHandler:completion progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {}];
    }
}

- (void)willDisplayCell{}

- (void)didDisplayCell{}

- (void)willEndDisplayCell{}

- (void)didEndDisplayCell
{
    [self resizeSubviews];
}

- (void)resizeSubviews {
    
    if (_imageContainerView.superview != self.scrollView) {
        return;
    }
    
    [self.scrollView setZoomScale:1.f];
    _imageContainerView.frame = self.scrollView.bounds;
    
    CGSize imageSize = [self subViewImageSize];
    
    if (!CGSizeEqualToSize(imageSize, CGSizeZero)) {
        UIEdgeInsets ios11Safeinsets = UIEdgeInsetsZero;
        CGSize scrollViewSize = self.scrollView.frame.size;
        scrollViewSize.height -= (ios11Safeinsets.top+ios11Safeinsets.bottom);
        /** 定义最小尺寸,判断为长图，则使用放大处理 */
        CGSize newSize = [UIImage picker_scaleImageSizeBySize:imageSize targetSize:scrollViewSize isBoth:NO];
        
        BOOL isLongImage = self.model.subType == TFYAssetSubMediaTypePhotoPiiic;
        if (isLongImage) { /** 长图 */
            newSize = [UIImage picker_imageSizeBySize:imageSize maxWidth:self.scrollView.frame.size.width];
        }
        
        CGRect _imageContainerViewRect = _imageContainerView.frame;
        _imageContainerViewRect.size = newSize;
        if (isLongImage && newSize.height > self.scrollView.frame.size.height-(ios11Safeinsets.top+ios11Safeinsets.bottom)) {
            _imageContainerViewRect.origin = CGPointMake(0, 0);
            _imageContainerView.frame = _imageContainerViewRect;
            self.scrollView.showsVerticalScrollIndicator = YES;
            [self.scrollView setContentOffset:CGPointMake(0, -ios11Safeinsets.top)];
        } else {
            _imageContainerView.frame = _imageContainerViewRect;
            _imageContainerView.center = self.scrollView.center;
            self.scrollView.showsVerticalScrollIndicator = NO;
        }
        self.scrollView.contentSize = _imageContainerView.frame.size;
        
        _imageView.frame = _imageContainerView.bounds;
        UIView *view = [self subViewInitDisplayView];
        view.frame = _imageContainerView.bounds;
    }
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(picker_photoPreviewCellSingleTapHandler:)]) {
        [self.delegate picker_photoPreviewCellSingleTapHandler:self];
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    UIEdgeInsets ios11Safeinsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        ios11Safeinsets = self.safeAreaInsets;
    }
    if (self.imageContainerView.frame.size.height < self.scrollView.frame.size.height-(ios11Safeinsets.top+ios11Safeinsets.bottom)) {
        CGFloat offsetX = (_scrollView.frame.size.width > _scrollView.contentSize.width) ? ((_scrollView.frame.size.width - _scrollView.contentSize.width) * 0.5) : 0.0;
        CGFloat offsetY = (_scrollView.frame.size.height > _scrollView.contentSize.height) ? ((_scrollView.frame.size.height - _scrollView.contentSize.height) * 0.5) : 0.0;
        self.imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
    }
}

/** 创建显示视图 */
- (UIView *)subViewInitDisplayView
{
    return nil;
}

/** 图片大小 */
- (CGSize)subViewImageSize
{
    return self.imageView.image.size;
}

/** 重置视图 */
- (void)subViewReset
{
    self.imageView.image = nil;
}

/** 设置数据 */
- (void)subViewSetModel:(TFY_PickerAsset *)model completeHandler:(void (^)(id data,NSDictionary *info,BOOL isDegraded))completeHandler progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    /** 普通图片处理 */
    if (model.type == TFYAssetMediaTypePhoto) {
        // 先获取缩略图
        PHImageRequestID imageRequestID = [[TFY_AssetManager manager] getPhotoWithAsset:model.asset photoWidth:self.bounds.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            
            if (completeHandler) {
                completeHandler(photo, info, YES);
            }
            
        }];
        /** 透明背景的png使用image的加载方式会丢失透明通道。 */
        [[TFY_AssetManager manager] getPhotoDataWithAsset:model.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {

            [[TFY_AssetManager manager] cancelImageRequest:imageRequestID];

            if (completeHandler) {
                completeHandler(data, info, isDegraded);
            }

        } progressHandler:progressHandler networkAccessAllowed:YES];
    } else {
        [[TFY_AssetManager manager] getPhotoWithAsset:model.asset photoWidth:self.bounds.size.width*[UIScreen mainScreen].scale completion:completeHandler progressHandler:progressHandler networkAccessAllowed:YES];
    }
}


@end


