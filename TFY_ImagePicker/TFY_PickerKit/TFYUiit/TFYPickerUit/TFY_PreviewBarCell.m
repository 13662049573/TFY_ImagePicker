//
//  TFY_PreviewBarCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PreviewBarCell.h"
#import "TFY_ImagePickerPublic.h"
#import "TFY_AssetManager.h"
#import "TFY_PhotoEditManager.h"
#import "TFY_PhotoEdit.h"
#import "TFY_VideoEditManager.h"
#import "TFY_VideoEdit.h"

@interface TFY_PreviewBarCell ()
/** 展示图片 */
@property (nonatomic, weak) UIImageView *imageView;
/** 编辑标记 */
@property (weak, nonatomic) UIImageView *editMaskImageView;
/** 视频标记 */
@property (weak, nonatomic) UIImageView *videoMaskImageView;
/** 遮罩 */
@property (nonatomic, weak) UIView *maskHitView;
@end

@implementation TFY_PreviewBarCell

+ (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (void)customInit
{
    self.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    UIImageView *editMaskImageView = [[UIImageView alloc] init];
    CGRect editFrame = CGRectMake(5, 5, 13.5, 11);
    editMaskImageView.frame = editFrame;
    [editMaskImageView setImage:bundleImageNamed(@"contacts_add_myablum")];
    editMaskImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:editMaskImageView];
    _editMaskImageView = editMaskImageView;
    
    UIImageView *videoMaskImageView = [[UIImageView alloc] init];
    CGRect videoFrame = CGRectMake(5, self.frame.size.height - 11 - 5, 18, 11);
    videoMaskImageView.frame = videoFrame;
    [videoMaskImageView setImage:bundleImageNamed(@"fileicon_video_wall")];
    videoMaskImageView.contentMode = UIViewContentModeScaleAspectFit;
    videoMaskImageView.hidden = YES;
    [self.contentView addSubview:videoMaskImageView];
    _videoMaskImageView = videoMaskImageView;
    
    
    UIView *maskHitView = [[UIView alloc] initWithFrame:self.bounds];
    maskHitView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    maskHitView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.5f];
    maskHitView.hidden = YES;
    [self.contentView addSubview:maskHitView];
    self.maskHitView = maskHitView;
}

- (void)setAsset:(TFY_PickerAsset *)asset
{
    _asset = asset;
    
    BOOL hiddenEditMask = YES;
    if (self.asset.type == TFYAssetMediaTypePhoto) {
        /** 优先显示编辑图片 */
        TFY_PhotoEdit *photoEdit = [[TFY_PhotoEditManager manager] photoEditForAsset:asset];
        if (photoEdit.editPosterImage) {
            self.imageView.image = photoEdit.editPosterImage;
            hiddenEditMask = NO;
        } else {
            [self getAssetImage:asset];
        }
        /** 显示编辑标记 */
        self.editMaskImageView.hidden = hiddenEditMask;
    } else if (self.asset.type == TFYAssetMediaTypeVideo) {
        /** 优先显示编辑图片 */
        TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:asset];
        if (videoEdit.editPosterImage) {
            self.imageView.image = videoEdit.editPosterImage;
            hiddenEditMask = NO;
        } else {
            [self getAssetImage:asset];
        }
        /** 显示编辑标记 */
        self.editMaskImageView.hidden = hiddenEditMask;
    }
    /** 显示视频标记 */
    if (_asset.type == TFYAssetMediaTypeVideo) {
        self.videoMaskImageView.hidden = NO;
    } else {
        self.videoMaskImageView.hidden = YES;
    }
}

- (void)setIsSelectedAsset:(BOOL)isSelectedAsset
{
    _isSelectedAsset = isSelectedAsset;
    /** 显示遮罩 */
    self.maskHitView.hidden = isSelectedAsset;
}


- (void)getAssetImage:(TFY_PickerAsset *)asset
{
    if (asset.thumbnailImage) { /** 显示自定义图片 */
        self.imageView.image = (asset.previewImage.images.count > 0 ? asset.previewImage.images.firstObject : asset.thumbnailImage);
    }  else {
        [[TFY_AssetManager manager] getPhotoWithAsset:asset.asset photoWidth:self.frame.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if ([asset.asset isEqual:self.asset.asset]) {
                self.imageView.image = photo;
            } else {
                self.imageView.image = nil;
            }
            
        } progressHandler:nil networkAccessAllowed:NO];
    }
}

@end
