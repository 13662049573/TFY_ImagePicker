//
//  TFY_PickerCollectionViewCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_PickerCollectionViewCell.h"
#import "TFY_ImageCollectionViewCell.h"
#import "TFY_EditCollectionView.h"
#import "TFY_StickerContent.h"
#import "TFY_ConfigTool.h"
#import "TFY_ImageCoder.h"
#import "TFY_StickerContent+getData.h"
#import "TFY_PHAssetManager.h"
#import "NSObject+picker.h"
#import "NSBundle+picker.h"

@interface TFY_PickerCollectionViewCell ()<TFYEditCollectionViewDelegate>

@property (strong, nonatomic) TFY_EditCollectionView *collectionView;

@property (strong, nonatomic) NSIndexPath *longPressIndexPath;

@end

@implementation TFY_PickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self _initSubView];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.collectionView.dataSources = @[];
    [self.collectionView reloadData];
}

- (void)dealloc
{
    [self.collectionView removeFromSuperview];
    [self _removeDisplayView];
}

#pragma mark - Public Methods
- (void)setCellData:(id)data
{
    [super setCellData:data];
    self.collectionView.dataSources = @[];
    if ([data isKindOfClass:[NSArray class]]) {
        self.collectionView.dataSources = @[data];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        [weakSelf.collectionView reloadData];
    } completion:^(BOOL finished) {
        UICollectionViewCell *cell = [weakSelf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (cell) {
            [self picker_showInView:[UIApplication sharedApplication].keyWindow maskRects:@[[NSValue valueWithCGRect:[cell.superview convertRect:cell.frame toView:nil]]] withTips:@[[NSBundle picker_localizedStringForKey:@"_LFME_UserGuide_StickerView_DisplayView_LongPress"]]];
        }
    }];
}

#pragma mark - Private Methods
- (void)_initSubView
{
    __weak typeof(self) weakSelf = self;
    TFY_EditCollectionView *col = [[TFY_EditCollectionView alloc] initWithFrame:self.contentView.bounds];
    col.itemSize = [TFY_ConfigTool shareInstance].itemSize;
    col.delegate = self;
    col.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:col];
    self.collectionView = col;
    [self.collectionView registerClass:[TFY_ImageCollectionViewCell class] forCellWithReuseIdentifier:[TFY_ImageCollectionViewCell identifier]];
    [self.collectionView callbackCellIdentifier:^NSString * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [TFY_ImageCollectionViewCell identifier];
    } configureCell:^(NSIndexPath * _Nonnull indexPath, TFY_StickerContent * _Nonnull item, UICollectionViewCell * _Nonnull cell) {
        TFY_ImageCollectionViewCell *imageCell = (TFY_ImageCollectionViewCell *)cell;
        [imageCell setCellData:item];
    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, TFY_StickerContent * _Nonnull item) {
        TFY_ImageCollectionViewCell *imageCell = (TFY_ImageCollectionViewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
        TFY_StickerContent *obj = (TFY_StickerContent *)imageCell.cellData;
        if (item.state == TFYStickerContentState_Success) {
            if ([weakSelf.delegate respondsToSelector:@selector(picker_didSelectData:thumbnailImage:index:)]) {
                [obj picker_getImageAndData:^(NSData * _Nullable data, UIImage * _Nullable image) {
                    [weakSelf.delegate picker_didSelectData:data thumbnailImage:image index:indexPath.row];
                }];
            }
        } else if (item.state == TFYStickerContentState_Fail) {
            if (obj.type == TFYStickerContentType_URLForHttp) {
                [imageCell resetForDownloadFail];
            }
        }
    }];
    
    UILongPressGestureRecognizer *ge = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longpress:)];
    self.backgroundColor = [UIColor blackColor];
    [self addGestureRecognizer:ge];

}

static TFY_MEGifView *_picker_showView = nil;
static UIView *_picker_contenView = nil;
static TFY_StickerContent *_showStickerContent = nil;

- (void)_removeDisplayView
{
    if (_picker_contenView) {
        [_picker_contenView removeFromSuperview];
        [_picker_showView removeFromSuperview];
        _picker_showView = nil;
        _picker_contenView = nil;
        _showStickerContent = nil;
    }
}

- (void)_showDisplayView:(TFY_ImageCollectionViewCell *)cell
{
    if (!cell) {
        _picker_contenView.hidden = YES;
        return;
    }
    
    _showStickerContent = (TFY_StickerContent *)cell.cellData;
    if (_showStickerContent.state == TFYStickerContentState_Fail) {
        _picker_contenView.hidden = YES;
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect covertRect = [cell.superview convertRect:cell.frame toView:keyWindow];
    /** 主容器和cell的间距 */
    CGFloat topMargin = [TFY_ConfigTool shareInstance].itemMargin;
    /** 长按cell的选择模式大小 */
    covertRect = CGRectInset(covertRect, -topMargin/2, -topMargin/2);
    
    if (!_picker_contenView) {
        
        {
            UIView *contenView = [[UIView alloc] initWithFrame:CGRectZero];
            contenView.backgroundColor = [UIColor whiteColor];
            contenView.hidden = YES;
            [keyWindow addSubview:contenView];
            [keyWindow bringSubviewToFront:contenView];
            _picker_contenView = contenView;
        }
        
        {
            TFY_MEGifView *gifView = [[TFY_MEGifView alloc] initWithFrame:CGRectZero];
            [_picker_contenView addSubview:gifView];
            _picker_showView = gifView;
        }
        
    }
    
    /** 展示图片与主容器的间隔 */
    CGFloat margin = 8.f;
    
    CGRect contentViewF = _picker_contenView.frame;
    
    contentViewF.size = CGSizeMake(CGRectGetWidth(covertRect)*2, CGRectGetHeight(covertRect)*2);
    /** 图片实际大小 */
    CGSize imageSize = cell.image.size;
    /** 转换容器大小 */
    CGRect convertF = CGRectInset(contentViewF, margin, margin);
    /** 实际比例  */
    CGFloat radio = CGRectGetWidth(convertF)/imageSize.width;
    if (imageSize.width > imageSize.height) {
        radio = CGRectGetHeight(convertF)/imageSize.height;
    }
    /** 展示图片大小 */
    imageSize = CGSizeMake(roundf(imageSize.width * radio), roundf(imageSize.height * radio));
    if (imageSize.width > (CGRectGetWidth(keyWindow.bounds) - margin*2)) {
        radio = (CGRectGetWidth(keyWindow.bounds) - margin*2)/imageSize.width;
        imageSize = CGSizeMake(roundf(imageSize.width * radio), roundf(imageSize.height * radio));
    } else if (imageSize.height > (CGRectGetMinY(covertRect) - margin*2 - topMargin*2)) {
        radio = ((CGRectGetMinY(covertRect) - margin*2 - topMargin*2) - margin*2)/imageSize.height;
        imageSize = CGSizeMake(roundf(imageSize.width * radio), roundf(imageSize.height * radio));
    }
    
    /** 根据展示大小确定主容器大小 */
    contentViewF.size = CGSizeMake(imageSize.width + margin*2, imageSize.height + margin*2);
    contentViewF.origin = CGPointMake(CGRectGetMidX(covertRect) - CGRectGetWidth(contentViewF)/2, CGRectGetMinY(covertRect) - topMargin - CGRectGetHeight(contentViewF));

    /** 如果主容器x坐标超过当前屏幕 */
    if (CGRectGetMaxX(contentViewF) > CGRectGetWidth(keyWindow.bounds)) {
        CGFloat margin = CGRectGetMaxX(contentViewF) - CGRectGetWidth(keyWindow.bounds);
        contentViewF.origin.x -= margin;
    }
    
    /** 主容器y坐标超过当前屏幕 */
    if (CGRectGetMinY(contentViewF) < 0) {
        contentViewF.origin.y = topMargin + CGRectGetMaxY(covertRect);
        if (CGRectGetMaxY(contentViewF) > CGRectGetHeight(keyWindow.bounds)) {
            contentViewF.origin.y = CGRectGetMinY(covertRect) - topMargin - CGRectGetHeight(contentViewF);
        }
    }
    
    if (CGRectGetMinX(contentViewF) < 0) {
        contentViewF.origin.x = 0.f;
    }

    
    _picker_contenView.frame = contentViewF;
    _picker_contenView.layer.cornerRadius = MIN(CGRectGetWidth(contentViewF), CGRectGetHeight(contentViewF)) * 0.05;
    
    _picker_showView.frame = CGRectMake(margin, margin, imageSize.width, imageSize.height);
    
    
#ifdef picker_NotSupperGif
    [_showStickerContent picker_getImage:^(UIImage * _Nullable image, BOOL isDegraded) {
        if (_showStickerContent == cell.cellData) {
            _picker_showView.image = image;
            _picker_contenView.hidden = NO;
        }
    }];
    
#else
    if (_showStickerContent.type == TFYStickerContentType_PHAsset) {
        if ([TFY_PHAssetManager picker_IsGif:_showStickerContent.content]) {
            [_showStickerContent picker_getImage:^(UIImage * _Nullable image, BOOL isDegraded) {
                if (_showStickerContent == cell.cellData) {
                    _picker_showView.image = image;
                    _picker_contenView.hidden = NO;
                }
            }];
        } else {
            [_showStickerContent picker_getData:^(NSData * _Nullable data) {
                if (_showStickerContent == cell.cellData) {
                    _picker_showView.data = data;
                    _picker_contenView.hidden = NO;
                }
            }];
        }
    } else {
        [_showStickerContent picker_getData:^(NSData * _Nullable data) {
            if (_showStickerContent == cell.cellData) {
                _picker_showView.data = data;
                _picker_contenView.hidden = NO;
            }
        }];
    }
#endif
}

- (void)_longpress:(UILongPressGestureRecognizer *)longpress
{
    CGPoint location = [longpress locationInView:self];
    location = [self convertPoint:location toView:self.collectionView];
    location.x += self.collectionView.contentOffset.x;
    location.y += self.collectionView.contentOffset.y;
    
    switch (longpress.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.longPressIndexPath = [self.collectionView indexPathForItemAtPoint:location];
            TFY_ImageCollectionViewCell *cell = (TFY_ImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
            [cell showMaskLayer:YES];
            [self _showDisplayView:cell];
        }
            break;
        case UIGestureRecognizerStateChanged:
        { // 手势位置改变
            NSIndexPath *changeIndexPath = [self.collectionView indexPathForItemAtPoint:location];
            if ((changeIndexPath && changeIndexPath.row != self.longPressIndexPath.row) || !self.longPressIndexPath) {
                NSIndexPath *oldIndexPath = self.longPressIndexPath;
                TFY_ImageCollectionViewCell *oldCell = (TFY_ImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:oldIndexPath];
                [oldCell showMaskLayer:NO];
                self.longPressIndexPath = changeIndexPath;
                TFY_ImageCollectionViewCell *cell = (TFY_ImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
                [cell showMaskLayer:YES];
                [self _showDisplayView:cell];
            } else if (changeIndexPath == nil) {
                [self _removeDisplayView];
                if (self.longPressIndexPath) {
                    TFY_ImageCollectionViewCell *cell = (TFY_ImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
                    [cell showMaskLayer:NO];
                    self.longPressIndexPath = nil;
                }
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
        {
            [self _removeDisplayView];
            if (self.longPressIndexPath) {
                TFY_ImageCollectionViewCell *cell = (TFY_ImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
                [cell showMaskLayer:NO];
                self.longPressIndexPath = nil;
            }
        }
            break;
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    int count = collectionView.frame.size.width / ([TFY_ConfigTool shareInstance].itemSize.width + [TFY_ConfigTool shareInstance].itemMargin);
    CGFloat margin = (collectionView.frame.size.width - [TFY_ConfigTool shareInstance].itemSize.width * count) / (count + 1);
    return UIEdgeInsetsMake(margin, margin, margin, margin);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    int count = collectionView.frame.size.width / ([TFY_ConfigTool shareInstance].itemSize.width + [TFY_ConfigTool shareInstance].itemMargin);
    CGFloat margin = (collectionView.frame.size.width - [TFY_ConfigTool shareInstance].itemSize.width * count) / (count + 1);
    return margin;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    int count = collectionView.frame.size.width / ([TFY_ConfigTool shareInstance].itemSize.width + [TFY_ConfigTool shareInstance].itemMargin);
    CGFloat margin = (collectionView.frame.size.width - [TFY_ConfigTool shareInstance].itemSize.width * count) / (count + 1);
    return margin;
}


@end
