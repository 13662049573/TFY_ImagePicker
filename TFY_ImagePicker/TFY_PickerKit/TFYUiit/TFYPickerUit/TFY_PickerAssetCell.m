//
//  TFY_PickerAssetCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PickerAssetCell.h"
#import "TFY_ImagePickerPublic.h"
#import "TFY_PickerAsset.h"
#import "TFY_AssetManager.h"
#import "TFY_PhotoEdit.h"
#import "TFY_PhotoEditManager.h"
#import "TFY_VideoEdit.h"
#import "TFY_VideoEditManager.h"
#import "TFYItools.h"

#pragma mark - /// 宫格图片视图

#define kAdditionalSize (isiPad ? 15 : 0)
#define kVideoBoomHeight (20.f + kAdditionalSize)

#define TFYAssetCell_markNoSelColor [UIColor colorWithWhite:1.f alpha:0.5f]
#define TFYAssetCell_markSelColor [UIColor colorWithWhite:0.f alpha:0.5f]

@interface TFY_PickerAssetCell ()
@property (weak, nonatomic) UIImageView *imageView;       // The photo / 照片
@property (weak, nonatomic) UIImageView *selectImageView;
@property (weak, nonatomic) UIImageView *editMaskImageView;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *selectPhotoButton;

@property (nonatomic, weak) UIImageView *styleImgView;
@property (weak, nonatomic) UILabel *timeLength;

@property (weak, nonatomic) UIView *maskSelectView;
@property (weak, nonatomic) UIView *maskHitView;

@property (assign, nonatomic) CGRect selectPhotoButtonRect;
@end

@implementation TFY_PickerAssetCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    /** 背景图片 */
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    _imageView = imageView;
    
    /** 选中蒙蔽层 */
    UIView *maskSelectView = [[UIView alloc] init];
    maskSelectView.backgroundColor = TFYAssetCell_markSelColor;
    maskSelectView.frame = self.bounds;
    maskSelectView.hidden = YES;
    [self.contentView addSubview:maskSelectView];
    _maskSelectView = maskSelectView;
    
    /** 底部状态栏 */
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, self.frame.size.height - kVideoBoomHeight, self.frame.size.width, kVideoBoomHeight);
    [self.contentView addSubview:bottomView];
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = bottomView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0f alpha:.0f] CGColor], (id)[[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor], nil];
    [bottomView.layer insertSublayer:gradientLayer atIndex:0];
    bottomView.hidden = YES;
    _bottomView = bottomView;
    
    /** 状态栏 子控件 懒加载 */
    
    /** 编辑标记 */
    UIImageView *editMaskImageView = [[UIImageView alloc] init];
    CGRect frame = CGRectMake(8, 8, 27*0.7 + kAdditionalSize, 22*0.7 + kAdditionalSize);
    editMaskImageView.frame = frame;
    [editMaskImageView setImage:bundleImageNamed(@"contacts_add_myablum")];
    editMaskImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:editMaskImageView];
    _editMaskImageView = editMaskImageView;
    
    CGFloat offset = 0;
    CGFloat selectButtonWidth = self.frame.size.width/2*0.9;
    /** 选择按钮 */
    UIButton *selectPhotoButton = [[UIButton alloc] init];
    selectPhotoButton.frame = CGRectMake(self.frame.size.width - selectButtonWidth - offset, 0, selectButtonWidth + offset, selectButtonWidth + offset);
    [selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:selectPhotoButton];
    _selectPhotoButton = selectPhotoButton;
    _selectPhotoButtonRect = selectPhotoButton.frame;
    
    CGFloat selectImageScale = 0.6;
    CGFloat selectImageWidth = selectButtonWidth * selectImageScale;
    
    UIImageView *selectImageView = [[UIImageView alloc] init];
    selectImageView.frame = CGRectMake(0, 0, selectImageWidth, selectImageWidth);
    selectImageView.center = selectPhotoButton.center;
    selectImageView.contentMode = UIViewContentModeScaleAspectFit;
    selectImageView.layer.shadowOpacity = .8;
    selectImageView.layer.shadowRadius = 1.0;
    selectImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    selectImageView.layer.shadowOffset = CGSizeMake(1, 1);
    selectImageView.layer.shouldRasterize = true;
    selectImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.contentView addSubview:selectImageView];
    _selectImageView = selectImageView;
    
    /** 蒙蔽层 */
    UIView *view = [[UIButton alloc] init];
    view.backgroundColor = TFYAssetCell_markNoSelColor;
    view.frame = self.bounds;
    view.hidden = YES;
    [self.contentView addSubview:view];
    _maskHitView = view;
    
}

- (void)setModel:(TFY_PickerAsset *)model {
    _model = model;

    BOOL hiddenEditMask = YES;
    if (self.model.type == TFYAssetMediaTypePhoto) {
        /** 优先显示编辑图片 */
        TFY_PhotoEdit *photoEdit = [[TFY_PhotoEditManager manager] photoEditForAsset:model];
        if (photoEdit.editPosterImage) {
            self.imageView.image = photoEdit.editPosterImage;
            hiddenEditMask = NO;
        } else {
            [self getAssetImage:model];
        }
        /** 显示编辑标记 */
        self.editMaskImageView.hidden = hiddenEditMask;
    } else if (self.model.type == TFYAssetMediaTypeVideo) {
        /** 优先显示编辑图片 */
        TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:model];
        if (videoEdit.editPosterImage) {
            self.imageView.image = videoEdit.editPosterImage;
            hiddenEditMask = NO;
        } else {
            [self getAssetImage:model];
        }
        /** 显示编辑标记 */
        self.editMaskImageView.hidden = hiddenEditMask;
    }
    
    
    [self setTypeToSubView];
}

- (void)getAssetImage:(TFY_PickerAsset *)model
{
    if (model.thumbnailImage) { /** 显示自定义图片 */
        self.imageView.image = model.thumbnailImage;
    } else {
        CGFloat photoWidth = self.frame.size.width * [UIScreen mainScreen].scale;
        [[TFY_AssetManager manager] getPhotoWithAsset:model.asset photoWidth:photoWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if ([model.asset isEqual:self.model.asset]) {
                self.imageView.image = photo;
                [self setTypeToSubView];
            }
        } progressHandler:nil networkAccessAllowed:YES];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (void)setTypeToSubView {
    
    if (self.model.type == TFYAssetMediaTypePhoto) {
        _bottomView.hidden = YES;
        if (self.displayPhotoName) {
            _styleImgView.hidden = YES;
            self.timeLength.text = [self.model.name stringByDeletingPathExtension];
            self.timeLength.textAlignment = NSTextAlignmentCenter;
            _bottomView.hidden = NO;
        } else if (self.displayGif && self.model.subType == TFYAssetSubMediaTypeGIF) {
            _styleImgView.hidden = NO;
            self.styleImgView.image = bundleImageNamed(@"fileicon_gif_wall");
            _bottomView.hidden = NO;
        } else if (self.displayLivePhoto && self.model.subType == TFYAssetSubMediaTypeLivePhoto) {
            _styleImgView.hidden = NO;
            self.styleImgView.image = bundleImageNamed(@"fileicon_live_wall");
            _bottomView.hidden = NO;
        } else if (self.model.subType == TFYAssetSubMediaTypePhotoPiiic) {
            _styleImgView.hidden = NO;
            self.styleImgView.image = bundleImageNamed(@"fileicon_piiic_wall");
            _bottomView.hidden = NO;
        } else if (self.model.subType == TFYAssetSubMediaTypePhotoPanorama) {
            _styleImgView.hidden = NO;
            self.styleImgView.image = bundleImageNamed(@"fileicon_hor_wall");
            _bottomView.hidden = NO;
        } else {
            _styleImgView.hidden = YES;
        }
    } else if (self.model.type == TFYAssetMediaTypeVideo) {
        if (self.displayPhotoName) {
            _styleImgView.hidden = YES;
            self.timeLength.text = [self.model.name stringByDeletingPathExtension];
            self.timeLength.textAlignment = NSTextAlignmentCenter;
            _bottomView.hidden = NO;
        } else {
            _styleImgView.hidden = NO;
            self.styleImgView.image = bundleImageNamed(@"fileicon_video_wall");
            TFY_VideoEdit *videoEdit = [[TFY_VideoEditManager manager] videoEditForAsset:self.model];
            if (videoEdit.editPosterImage) {
                self.timeLength.text = [self getNewTimeFromDurationSecond:picker_videoDuration(videoEdit.duration)];
            } else {
                self.timeLength.text = [self getNewTimeFromDurationSecond:picker_videoDuration(self.model.duration)];
            }
            self.timeLength.textAlignment = NSTextAlignmentRight;
            _bottomView.hidden = NO;
        }
    }
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

- (void)setOnlySelected:(BOOL)onlySelected
{
    _onlySelected = onlySelected;
    if (onlySelected) {
        _onlyClick = NO;
        _selectPhotoButton.hidden = NO;
        _selectImageView.hidden = NO;
        _selectPhotoButton.frame = self.bounds;
    } else {
        _selectPhotoButton.frame = self.selectPhotoButtonRect;
    }
}

- (void)setOnlyClick:(BOOL)onlyClick
{
    if (!self.onlySelected) {
        _onlyClick = onlyClick;
        _selectPhotoButton.hidden = onlyClick;
        _selectImageView.hidden = onlyClick;
    }
}

- (void)setNoSelected:(BOOL)noSelected
{
    _noSelected = noSelected;
    self.maskHitView.hidden = !noSelected;
    self.maskHitView.backgroundColor = TFYAssetCell_markNoSelColor;
}

- (void)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        __weak typeof(self) weakSelf = self;
        self.didSelectPhotoBlock(!sender.selected, self.model, weakSelf);
    }
}

- (void)selectPhoto:(BOOL)isSelected index:(NSUInteger)index animated:(BOOL)animated
{
    self.selectPhotoButton.selected = isSelected;
    UIImage *image = nil;
    if (_selectPhotoButton.selected) {
        NSString *text = [NSString stringWithFormat:@"%zd", index];
        image = [UIImage picker_mergeImage:bundleImageNamed(self.photoSelImageName) text:text];
    } else {
        image = bundleImageNamed(self.photoDefImageName);
    }
    self.maskSelectView.hidden = !isSelected;
    self.selectImageView.image = image;
    if (animated) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:OscillatoryAnimationToBigger];
    }
}

#pragma mark - Lazy load
- (UIImageView *)styleImgView
{
    if (_styleImgView == nil) {
        UIImageView *styleImgView = [[UIImageView alloc] init];
        if (self.model.type == TFYAssetMediaTypeVideo) {
            styleImgView.frame = CGRectMake(8, 0, 37*0.7, 22*0.7);
        } else {
            styleImgView.frame = CGRectMake(self.frame.size.width - 37*0.7 - 8, 1, 37*0.7, 22*0.7);
        }
        styleImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bottomView addSubview:styleImgView];
        _styleImgView = styleImgView;
    }
    return _styleImgView;
}

- (UILabel *)timeLength {
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:isiPad ? 19 : 15];
        CGFloat height = [@"A" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, kVideoBoomHeight) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:timeLength.font} context:nil].size.height;
        
        CGFloat videoImageMaxX = MAX(CGRectGetMaxX(_styleImgView.frame), 8);
        CGFloat y = (22*0.7-height)/2;
        
        if (self.displayPhotoName && _styleImgView) {
            y = (_styleImgView.frame.size.height-height)/2;
        }
        
        timeLength.frame = CGRectMake(videoImageMaxX, y, self.frame.size.width - videoImageMaxX - 8, height);
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        timeLength.lineBreakMode = NSLineBreakByTruncatingHead;
        [self.bottomView addSubview:timeLength];
        _timeLength = timeLength;
    }
    return _timeLength;
}

@end

#pragma mark - /// 拍照视图
@interface TFY_PickerAssetCameraCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation TFY_PickerAssetCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setPosterImage:(UIImage *)posterImage
{
    _posterImage = posterImage;
    [self.imageView setImage:posterImage];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}


@end
