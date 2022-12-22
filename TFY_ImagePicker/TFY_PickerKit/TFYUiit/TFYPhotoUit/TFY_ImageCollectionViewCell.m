//
//  TFY_ImageCollectionViewCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_ImageCollectionViewCell.h"
#import "UIView+TFY_DownloadManager.h"
#import "TFY_StickerProgressView.h"
#import "TFY_StickerContent.h"
#import "TFY_PHAssetManager.h"
#import "TFY_ConfigTool.h"
#import "TFY_DataImageView.h"
#import "TFY_ImageCoder.h"
#import "NSData+picker.h"

CGFloat const TFY_kVideoBoomHeight = 25.f;

@interface TFY_ImageCollectionViewCell ()
@property (weak, nonatomic) TFY_DataImageView *imageView;

@property (weak, nonatomic) TFY_StickerProgressView *progressView;

@property (weak, nonatomic) UIView *bottomView;

@property (weak, nonatomic) UILabel *bottomLab;

@property (strong, nonatomic) CAShapeLayer *maskLayer;
@end

@implementation TFY_ImageCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _initSubViewAndDataSources];
    } return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViewAndDataSources];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    self.progressView.center = self.contentView.center;
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - TFY_kVideoBoomHeight, CGRectGetWidth(self.contentView.bounds), TFY_kVideoBoomHeight);
    self.bottomLab.frame = CGRectInset(self.bottomView.bounds, 2.5f, 5.f);
    CGFloat markMargin = [TFY_ConfigTool shareInstance].itemMargin/2;
    CGRect markRect = CGRectInset(self.contentView.bounds, -markMargin, -markMargin);
    self.maskLayer.frame = markRect;
    self.maskLayer.cornerRadius = CGRectGetWidth(markRect) * 0.05;

}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
    self.progressView.progress = 0;
    self.progressView.hidden = YES;
}

- (void)dealloc
{
    [self picker_downloadCancel];
}

- (UIImage *)image
{
    return self.imageView.image;
}

#pragma mark - Public Methods
- (void)setCellData:(id)data
{
    [super setCellData:data];
    self.bottomView.hidden = YES;
    __block TFY_StickerContent *obj = (TFY_StickerContent *)data;
    if (obj.state == TFYStickerContentState_Fail) {
        self.imageView.image = [TFY_ConfigTool shareInstance].failureImage;
        return;
    }
    id itemData = obj.content;
    if (obj.type == TFYStickerContentType_URLForFile) {
        NSURL *fileURL = (NSURL *)itemData;
        NSData *localData = [NSData dataWithContentsOfURL:fileURL];
        if ([NSData picker_imageFormatForImageData:localData] == TFYImageFormatUndefined) {
            obj.state = TFYStickerContentState_Fail;
            self.imageView.image = [TFY_ConfigTool shareInstance].failureImage;
        } else {
            obj.state = TFYStickerContentState_Success;
#ifdef picker_NotSupperGif
            self.bottomView.hidden = YES;
#else
            self.bottomView.hidden =  !self.imageView.isGif;
#endif
            [self.imageView picker_dataForImage:localData];
        }
    } else if (obj.type == TFYStickerContentType_URLForHttp) {
        NSURL *httpURL = (NSURL *)itemData;
        NSData *httplocalData = [self picker_dataFromCacheWithURL:httpURL];
        if (httplocalData) {
            if ([NSData picker_imageFormatForImageData:httplocalData] == TFYImageFormatUndefined) {
                obj.state = TFYStickerContentState_Fail;
                self.imageView.image = [TFY_ConfigTool shareInstance].failureImage;
            } else {
                obj.state = TFYStickerContentState_Success;
                [self.imageView picker_dataForImage:httplocalData];
#ifdef picker_NotSupperGif
                self.bottomView.hidden = YES;
#else
                self.bottomView.hidden =  !self.imageView.isGif;
#endif
            }
        } else {
            [self _download:obj];
        }
    } else if (obj.type == TFYStickerContentType_PHAsset) {
        self.imageView.image = [TFY_ConfigTool shareInstance].normalImage;
        self.progressView.hidden = NO;
        self.progressView.progress = 0.f;
#ifdef picker_NotSupperGif
        self.bottomView.hidden = YES;
#else
        self.bottomView.hidden = ![TFY_PHAssetManager picker_IsGif:itemData];
#endif
        __weak typeof(self) weakSelf = self;
        [TFY_PHAssetManager picker_GetPhotoWithAsset:itemData photoWidth:self.frame.size.width completion:^(UIImage * _Nonnull result, NSDictionary * _Nonnull info, BOOL isDegraded) {
            weakSelf.progressView.hidden = YES;
            if (!result) {
                obj.state = TFYStickerContentState_Fail;
                weakSelf.imageView.image = [TFY_ConfigTool shareInstance].failureImage;
            } else {
                obj.state = TFYStickerContentState_Success;
                weakSelf.imageView.image = result;
            }
        } progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
            weakSelf.progressView.progress = progress;
        }];
    }
}


- (void)showMaskLayer:(BOOL)isShow
{
    self.maskLayer.hidden = !isShow;
}

- (void)resetForDownloadFail
{
    TFY_StickerContent *content = (TFY_StickerContent *)self.cellData;
    if (content.state == TFYStickerContentState_Fail) {
        content.state = TFYStickerContentState_Downloading;
        [self _download:content];
    }
}
#pragma mark - Private Methods
- (void)_initSubViewAndDataSources
{
    self.contentView.backgroundColor = [UIColor clearColor];

    TFY_DataImageView *imageView = [[TFY_DataImageView alloc] initWithFrame:self.contentView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    self.imageView.image = [TFY_ConfigTool shareInstance].normalImage;

    TFY_StickerProgressView *view1 = [[TFY_StickerProgressView alloc] init];
    [self.contentView addSubview:view1];
    [self.contentView bringSubviewToFront:view1];
    self.progressView = view1;
    
    /** 底部状态栏 */
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, self.contentView.frame.size.height - TFY_kVideoBoomHeight, self.contentView.frame.size.width, TFY_kVideoBoomHeight);
    [self.contentView addSubview:bottomView];
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = bottomView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0f alpha:.0f] CGColor], (id)[[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor], nil];
    [bottomView.layer insertSublayer:gradientLayer atIndex:0];
    self.bottomView = bottomView;
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectInset(bottomView.bounds, 2.5f, 5.f)];
    lab.textAlignment = NSTextAlignmentRight;
    lab.text = @"GIF";
    lab.textColor = [UIColor whiteColor];
    [self.bottomView addSubview:lab];
    self.bottomLab = lab;
    
    CGFloat markMargin = [TFY_ConfigTool shareInstance].itemMargin/2;
    CGRect markRect = CGRectInset(self.contentView.bounds, -markMargin, -markMargin);
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.bounds = markRect;
    maskLayer.hidden = YES;
    maskLayer.cornerRadius = CGRectGetWidth(markRect) * 0.05;
    maskLayer.backgroundColor = [UIColor colorWithWhite:.5f alpha:.7f].CGColor;
    [self.contentView.layer insertSublayer:maskLayer below:self.imageView.layer];
    self.maskLayer = maskLayer;
}

- (void)_download:(TFY_StickerContent *)content
{
    if (content.type != TFYStickerContentType_URLForHttp) {
        return;
    }
        
    content.state = TFYStickerContentState_Downloading;
    
    self.imageView.image = [TFY_ConfigTool shareInstance].normalImage;
    NSURL *httpURL = (NSURL *)content.content;
    self.progressView.hidden = NO;
    self.progressView.progress = content.progress;
    __weak typeof(self) weakSelf = self;
    [self picker_downloadImageWithURL:httpURL progress:^(CGFloat progress, NSURL * _Nonnull URL) {
        if ([URL.absoluteString isEqualToString:httpURL.absoluteString]) {
            weakSelf.progressView.progress = content.progress = progress;
        }
    } completed:^(NSData * _Nonnull downloadData, NSError * _Nonnull error, NSURL * _Nonnull URL) {
        if ([URL.absoluteString isEqualToString:httpURL.absoluteString]) {
            weakSelf.progressView.hidden = YES;
            if (error || downloadData == nil) {
                content.state = TFYStickerContentState_Fail;
                weakSelf.imageView.image = [TFY_ConfigTool shareInstance].failureImage;
            } else {
                if ([NSData picker_imageFormatForImageData:downloadData] == TFYImageFormatUndefined) {
                    content.state = TFYStickerContentState_Fail;
                    weakSelf.imageView.image = [TFY_ConfigTool shareInstance].failureImage;
                } else {
                    
                    content.state = TFYStickerContentState_Success;
                    [weakSelf.imageView picker_dataForImage:downloadData];
#ifdef picker_NotSupperGif
                    weakSelf.bottomView.hidden = YES;
#else
                    weakSelf.bottomView.hidden =  !weakSelf.imageView.isGif;
#endif
                }
            }
        }
        
    }];

}

@end
