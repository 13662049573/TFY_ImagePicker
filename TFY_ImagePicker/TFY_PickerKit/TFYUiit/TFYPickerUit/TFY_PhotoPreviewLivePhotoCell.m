//
//  TFY_PhotoPreviewLivePhotoCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PhotoPreviewLivePhotoCell.h"
#import "TFY_PhotoPreviewCell+property.h"
#import "TFY_AssetManager.h"
#import <PhotosUI/PhotosUI.h>

@interface TFY_PhotoPreviewLivePhotoCell ()<PHLivePhotoViewDelegate>
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
@end

@implementation TFY_PhotoPreviewLivePhotoCell

#pragma mark - 重写父类方法
/** 创建显示视图 */
- (UIView *)subViewInitDisplayView
{
    if (_livePhotoView == nil) {
        _livePhotoView = [[PHLivePhotoView alloc] init];
        _livePhotoView.muted = YES;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _livePhotoView;
}
/** 重置视图 */
- (void)subViewReset
{
    [super subViewReset];
    _livePhotoView.delegate =  nil;
    [_livePhotoView stopPlayback];
    _livePhotoView.livePhoto = nil;
}

/** 图片大小 */
- (CGSize)subViewImageSize
{
    if (self.livePhotoView.livePhoto) {
        return self.livePhotoView.livePhoto.size;
    }
    return self.imageView.image.size;
}

/** 设置数据 */
- (void)subViewSetModel:(TFY_PickerAsset *)model completeHandler:(void (^)(id data,NSDictionary *info,BOOL isDegraded))completeHandler progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    if (model.subType == TFYAssetSubMediaTypeLivePhoto) { /** live photo */
        // 需要获取原图和缩略图
        [super subViewSetModel:model completeHandler:completeHandler progressHandler:progressHandler];
        // 获取livephoto
        [[TFY_AssetManager manager] getLivePhotoWithAsset:model.asset photoWidth:0 completion:^(PHLivePhoto *livePhoto, NSDictionary *info, BOOL isDegraded) {
            
            if ([model isEqual:self.model]) { /** live photo */
                self.livePhotoView.livePhoto = livePhoto;
                [self resizeSubviews]; // 刷新subview的位置。
            }
        } progressHandler:progressHandler networkAccessAllowed:YES];
    } else {
        [super subViewSetModel:model completeHandler:completeHandler progressHandler:progressHandler];
    }
}

- (void)didDisplayCell
{
    [super didDisplayCell];
    if (self.model.subType == TFYAssetSubMediaTypeLivePhoto && self.model.closeLivePhoto == NO) { /** live photo */
        [self didPlayCell];
    }
}

- (void)willEndDisplayCell
{
    [super willEndDisplayCell];
    if (self.model.subType == TFYAssetSubMediaTypeLivePhoto) { /** live photo */
        [self didStopCell];
    }
}

- (void)didPlayCell
{
    _livePhotoView.playbackGestureRecognizer.enabled = NO;
    _livePhotoView.delegate = self;
    [_livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
}

- (void)didStopCell
{
    _livePhotoView.playbackGestureRecognizer.enabled = YES;
    _livePhotoView.delegate = nil;
    [_livePhotoView stopPlayback];
}

#pragma mark - PHLivePhotoViewDelegate
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
    if (playbackStyle == PHLivePhotoViewPlaybackStyleFull) {
        [livePhotoView startPlaybackWithStyle:playbackStyle];
    }
}

@end
