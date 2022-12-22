//
//  TFY_PickerAsset.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PickerAsset.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "TFY_ImagePickerPublic.h"

@interface PHAsset (RealDuration)
- (NSTimeInterval)picker_getRealDuration;
@end

@implementation PHAsset (RealDuration)

- (NSTimeInterval)picker_getRealDuration
{
    __block double dur = 0;
    /** 为了更加快速的获取相册数据，非慢动作视频不使用requestAVAssetForVideo获取时长。直接获取duration属性即可 */
    if (self.mediaSubtypes == PHAssetMediaSubtypeVideoHighFrameRate) {
        /** 慢动作视频获取真实时长 */
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version =  PHVideoRequestOptionsVersionCurrent;
        [[PHImageManager defaultManager] requestAVAssetForVideo:self options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            dur = CMTimeGetSeconds(urlAsset.duration);
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    if (!isnan(dur) && dur>0) {
        return dur;
    }
    return self.duration;
}

@end

@interface TFY_PickerAsset ()
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) NSInteger bytes;
@end

@implementation TFY_PickerAsset
@synthesize bytes = _bytes;

- (instancetype)initWithAsset:(id)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        _type = TFYAssetMediaTypePhoto;
        _duration = 0;
        _name = nil;
        
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            _identifier = phAsset.localIdentifier;
            _name = [asset valueForKey:@"filename"];
            if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                _type = TFYAssetMediaTypeVideo;
                _duration = [phAsset picker_getRealDuration];
            } else if (phAsset.mediaType == PHAssetMediaTypeImage) {
#ifdef __IPHONE_9_1
                if (phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
                    _subType = TFYAssetSubMediaTypeLivePhoto;
                } else
#endif
                if (phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoPanorama) {
                    _subType = TFYAssetSubMediaTypePhotoPanorama;
                } else
            /** 判断gif图片，由于公开方法效率太低，改用私有API判断 */
                if ([[phAsset valueForKey:@"uniformTypeIdentifier"] isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    _subType = TFYAssetSubMediaTypeGIF;
                } else if (picker_isHor(CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight))){
                    _subType = TFYAssetSubMediaTypePhotoPanorama;
                } else if (picker_isPiiic(CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight))){
                    _subType = TFYAssetSubMediaTypePhotoPiiic;
                }
            }
        }
    }
    return self;
}

- (NSInteger)bytes
{
    return _bytes;
}

- (void)setBytes:(NSInteger)bytes
{
    _bytes = bytes;
}

#pragma mark - private
- (BOOL)isEqual:(id)object
{
    if([self class] == [object class])
    {
        if (self == object) {
            return YES;
        }
        TFY_PickerAsset *objAsset = (TFY_PickerAsset *)object;
        if ([self.asset isEqual: objAsset.asset]) {
            return YES;
        }
        if (!self.identifier && !objAsset.identifier && [self.identifier isEqualToString: objAsset.identifier]) {
            return YES;
        }
        return NO;
    }
    else
    {
        return [super isEqual:object];
    }
}

- (NSUInteger)hash
{
    NSUInteger assetHash = 0;
    if (self.asset) {
        assetHash ^= [self.asset hash];
    }
    if (self.identifier) {
        assetHash ^= [self.identifier hash];
    }
    return assetHash;
}

@end

@implementation TFY_PickerAsset (preview)

- (UIImage *)thumbnailImage
{
    if ([self.asset conformsToProtocol:@protocol(TFY_AssetImageProtocol)]) {
        id <TFY_AssetImageProtocol> imageAsset = self.asset;
        return imageAsset.assetImage;
    }
    else if ([self.asset conformsToProtocol:@protocol(TFY_AssetPhotoProtocol)]) {
        id <TFY_AssetPhotoProtocol> photoAsset = self.asset;
        return photoAsset.thumbnailImage;
    }
    else if ([self.asset conformsToProtocol:@protocol(TFY_AssetVideoProtocol)]) {
        id <TFY_AssetVideoProtocol> videoAsset = self.asset;
        return videoAsset.thumbnailImage;
    }
    return nil;
}

- (UIImage *)previewImage
{
    if ([self.asset conformsToProtocol:@protocol(TFY_AssetImageProtocol)]) {
        id <TFY_AssetImageProtocol> imageAsset = self.asset;
        return imageAsset.assetImage;
    }
    else if ([self.asset conformsToProtocol:@protocol(TFY_AssetPhotoProtocol)]) {
        id <TFY_AssetPhotoProtocol> photoAsset = self.asset;
        return photoAsset.originalImage;
    }
    else if ([self.asset conformsToProtocol:@protocol(TFY_AssetVideoProtocol)]) {
        id <TFY_AssetVideoProtocol> videoAsset = self.asset;
        return videoAsset.thumbnailImage;
    }
    return nil;
}

- (NSURL *)previewVideoUrl
{
    if ([self.asset conformsToProtocol:@protocol(TFY_AssetVideoProtocol)]) {
        id <TFY_AssetVideoProtocol> videoAsset = self.asset;
        return videoAsset.videoUrl;
    }
    return nil;
}

- (instancetype)initWithObject:(id/* <TFYAssetImageProtocol/TFYAssetPhotoProtocol/TFYAssetVideoProtocol> */)asset
{
    self = [self initWithAsset:asset];
    if (self) {
        if ([asset conformsToProtocol:@protocol(TFY_AssetImageProtocol)]) {
            id <TFY_AssetImageProtocol> imageAsset = asset;
            _subType = imageAsset.assetImage.images.count ? TFYAssetSubMediaTypeGIF : TFYAssetSubMediaTypeNone;
            _name = [NSString stringWithFormat:@"%zd", [imageAsset.assetImage hash]];
        }
        else if ([asset conformsToProtocol:@protocol(TFY_AssetPhotoProtocol)]) {
            id <TFY_AssetPhotoProtocol> photoAsset = asset;
            _subType = photoAsset.originalImage.images.count ? TFYAssetSubMediaTypeGIF : TFYAssetSubMediaTypeNone;
            _name = photoAsset.name.length ? photoAsset.name : [NSString stringWithFormat:@"%zd", [photoAsset.originalImage hash]];
        }
        else if ([asset conformsToProtocol:@protocol(TFY_AssetVideoProtocol)]) {
            id <TFY_AssetVideoProtocol> videoAsset = asset;
            _type = TFYAssetMediaTypeVideo;
            NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO)
                                                             forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoAsset.videoUrl options:opts];
            _duration = CMTimeGetSeconds(asset.duration);
            _name = videoAsset.name.length ? videoAsset.name : [NSString stringWithFormat:@"%zd", [videoAsset.videoUrl hash]];
        }
        
    }
    return self;
}


@end
