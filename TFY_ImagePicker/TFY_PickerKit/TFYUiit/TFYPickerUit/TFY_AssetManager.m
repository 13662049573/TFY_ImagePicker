//
//  TFY_AssetManager.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_AssetManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "TFYCategory.h"
#import "TFY_VideoUtils.h"
#import "TFY_FileUtility.h"
#import "TFY_PickerToGIF.h"
#import "TFY_ResultObjectproperty.h"
#import "TFY_PickerAsset+property.h"

@interface TFY_AssetManager ()
/** 排序 YES */
@property (nonatomic, assign) BOOL sortAscendingByCreateDate;
/** 类型 TFYPickingMediaTypeALL */
@property (nonatomic, assign) TFYPickingMediaType allowPickingType;
@end

@implementation TFY_AssetManager
@synthesize assetLibrary = _assetLibrary;

static TFY_AssetManager *manager;
+ (instancetype)manager {

    if (manager == nil) {
        manager = [[self alloc] init];
    }
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shouldFixOrientation = YES;
        _shouldDecoded = YES;
        _autoPlayLivePhoto = YES;
    }
    return self;
}

+ (void)free
{
    manager = nil;
}


- (ALAssetsLibrary *)assetLibrary {
    if (_assetLibrary == nil) _assetLibrary = [[ALAssetsLibrary alloc] init];
    return _assetLibrary;
}


#pragma mark - Get Album

/// Get Album 获得相册/相册数组
- (void)getCameraRollAlbum:(TFYPickingMediaType)allowPickingType fetchLimit:(NSInteger)fetchLimit ascending:(BOOL)ascending completion:(void (^)(TFY_PickerAlbum *model))completion
{
    __block TFY_PickerAlbum *model;
    if (@available(iOS 8.0, *)){
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!(allowPickingType & TFYPickingMediaTypeVideo)) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        if (allowPickingType == TFYPickingMediaTypeVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
        if (@available(iOS 9.0, *)){
            option.fetchLimit = fetchLimit;
        }
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            model = [self modelWithResult:fetchResult album:collection];
            if (completion) completion(model);
            break;
        }
    } 
}

- (void)getAllAlbums:(TFYPickingMediaType)allowPickingType ascending:(BOOL)ascending completion:(void (^)(NSArray<TFY_PickerAlbum *> *))completion
{
    NSMutableArray *albumArr = [NSMutableArray array];
    if (@available(iOS 8.0, *)){
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!(allowPickingType & TFYPickingMediaTypeVideo)) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        if (allowPickingType == TFYPickingMediaTypeVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        PHAssetCollection *userCollection = nil;
        for (PHAssetCollection *collection in userAlbums) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            [albumArr addObject:[self modelWithResult:fetchResult album:collection]];
            userCollection = collection;
            break;
        }
    
        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        PHFetchResult *regularAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHFetchResult *customAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        NSArray *allAlbums = @[myPhotoStreamAlbum,syncedAlbums,sharedAlbums,regularAlbums,customAlbums];
        for (PHFetchResult *fetchResult in allAlbums) {
            for (PHAssetCollection *collection in fetchResult) {
                // 有可能是PHCollectionList类的的对象，过滤掉
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                if ([userCollection isEqual:collection]) {
                    continue;
                }
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                TFY_PickerAlbum *model = [self modelWithResult:fetchResult album:collection];
                if (![albumArr containsObject:model]) {
                    [albumArr addObject:model];
                }
            }
        }
        if (completion) completion(albumArr);
    }
}

#pragma mark - Get Assets

/// Get Assets 获得照片数组
- (void)getAssetsFromFetchResult:(id)result allowPickingType:(TFYPickingMediaType)allowPickingType fetchLimit:(NSInteger)fetchLimit ascending:(BOOL)ascending completion:(void (^)(NSArray<TFY_PickerAsset *> *models))completion
{
    __block NSMutableArray *photoArr = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        NSUInteger count = fetchResult.count;
        
        NSInteger start = 0;
        if (fetchLimit > 0 && ascending == NO) { /** 重置起始值 */
            start = count > fetchLimit ? count - fetchLimit : 0;
        }
        
        NSInteger end = count;
        if (fetchLimit > 0) { /** 重置结束值 */
            end = count > fetchLimit ? fetchLimit : count;
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(start, end)];
        
        NSArray *results = [fetchResult objectsAtIndexes:indexSet];
        
        for (PHAsset *asset in results) {
            TFY_PickerAsset *model = [self assetModelWithAsset:asset allowPickingType:allowPickingType];
            if (model) {
                if (ascending) {
                    [photoArr addObject:model];
                } else {
                    [photoArr insertObject:model atIndex:0];
                }
            }
        }
        if (completion) completion(photoArr);
    }
}

///  Get asset at index 获得下标为index的单个照片
///  if index beyond bounds, return nil in callback 如果索引越界, 在回调中返回 nil
- (void)getAssetFromFetchResult:(id)result
                        atIndex:(NSInteger)index
               allowPickingType:(TFYPickingMediaType)allowPickingType
                      ascending:(BOOL)ascending
                     completion:(void (^)(TFY_PickerAsset *))completion
{
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        PHAsset *asset;
        @try {
            asset = fetchResult[index];
        }
        @catch (NSException* e) {
            if (completion) completion(nil);
            return;
        }
        TFY_PickerAsset *model = [self assetModelWithAsset:asset allowPickingType:allowPickingType];
        if (completion) completion(model);
    }
    else {
        if (completion) completion(nil);
    }
}

- (TFY_PickerAsset *)assetModelWithAsset:(id)asset allowPickingType:(TFYPickingMediaType)allowPickingType {
    TFY_PickerAsset *model = [[TFY_PickerAsset alloc] initWithAsset:asset];
    if (model.subType == TFYAssetSubMediaTypeLivePhoto) {
        model.closeLivePhoto = !self.autoPlayLivePhoto;
    }
    if (!(allowPickingType&TFYPickingMediaTypeVideo) && model.type == TFYAssetMediaTypeVideo) return nil;
    
    if (model.type == TFYAssetMediaTypePhoto) {
        /** 不是图片类型，判断是否可能存在gif或livePhoto */
        if (!(allowPickingType&TFYPickingMediaTypePhoto)) {
            
            if (allowPickingType&TFYPickingMediaTypeGif && model.subType == TFYAssetSubMediaTypeGIF) return model;
            if (allowPickingType&TFYPickingMediaTypeLivePhoto && model.subType == TFYAssetSubMediaTypeLivePhoto) return model;
            
            return nil;
        }
    }
    return model;
}

/// 检查照片的大小是否超过最大值
- (void)checkPhotosBytesMaxSize:(NSArray <TFY_PickerAsset *>*)photos maxBytes:(NSInteger)maxBytes completion:(void (^)(BOOL isPass))completion
{
    __block NSInteger assetCount = 0;
    __block BOOL isPass = YES;
    void (^completeBlock)(TFY_PickerAsset *) = ^(TFY_PickerAsset *asset){
        assetCount ++;
        if (isPass && asset.bytes > maxBytes) {
            isPass = NO;
        }
        if (assetCount >= photos.count) {
            if (completion) completion(isPass);
        }
    };
    
    for (NSInteger i = 0; i < photos.count; i++) {
        TFY_PickerAsset *model = photos[i];
        if (model.type == TFYAssetMediaTypePhoto) {
            if ([model.asset isKindOfClass:[PHAsset class]]) {
                if (model.bytes == 0) {
                    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                    option.resizeMode = PHImageRequestOptionsResizeModeFast;
                    option.version = PHImageRequestOptionsVersionOriginal;
                    if (@available(iOS 13, *)) {
                        [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:model.asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                            model.bytes = imageData.length;
                            completeBlock(model);
                        }];
                    } else {
                        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            model.bytes = imageData.length;
                            completeBlock(model);
                        }];
                    }
                } else {
                    completeBlock(model);
                }
            }
        } else {
            completeBlock(model);
        }
    }
}

/// Get photo bytes 获得一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray <TFY_PickerAsset *>*)photos completion:(void (^)(NSString *totalBytesStr, NSInteger totalBytes))completion {
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    void (^completeBlock)(NSInteger sizebytes) = ^(NSInteger sizebytes){
        dataLength += sizebytes;
        assetCount ++;
        if (assetCount >= photos.count) {
            NSString *bytesStr = [self getBytesFromDataLength:dataLength];
            if (completion) completion(bytesStr, dataLength);
        }
    };
    
    for (NSInteger i = 0; i < photos.count; i++) {
        TFY_PickerAsset *model = photos[i];
        if (model.type == TFYAssetMediaTypePhoto) {
            if ([model.asset isKindOfClass:[PHAsset class]]) {
                if (model.bytes == 0) {
                    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                    option.resizeMode = PHImageRequestOptionsResizeModeFast;
                    option.version = PHImageRequestOptionsVersionOriginal;
                    
                    if (@available(iOS 13, *)) {
                        [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:model.asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                            model.bytes = imageData.length;
                            completeBlock(model.bytes);
                        }];
                    } else {
                        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            model.bytes = imageData.length;
                            completeBlock(model.bytes);
                        }];
                    }
                    
                } else {
                    completeBlock(model.bytes);
                }
            }
        } else {
            completeBlock(model.bytes);
        }
    }
}

- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

#pragma mark - Get Photo

- (PHImageRequestID)getThumbnailWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth thumbnail:YES completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(photo, info, YES);
        }
    } progressHandler:nil networkAccessAllowed:YES];
}

/// Get photo 获得照片本身
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    CGFloat fullScreenWidth = [UIScreen mainScreen].bounds.size.width;
    return [self getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth thumbnail:NO completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth thumbnail:(BOOL)thumbnail completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    if ([asset isKindOfClass:[PHAsset class]]) {
        
        PHAsset *phAsset = (PHAsset *)asset;
        CGSize imageSize;
        if (photoWidth > 0) {
            CGFloat aspectRatio = 1.0;
            CGFloat pixelWidth = phAsset.pixelWidth;
            CGFloat pixelHeight = phAsset.pixelHeight;
            if (pixelWidth > pixelHeight) {
                aspectRatio = pixelHeight / (CGFloat)pixelWidth;
                pixelWidth = photoWidth / aspectRatio;
                pixelHeight = photoWidth;
            } else {
                aspectRatio = pixelWidth / (CGFloat)pixelHeight;
                pixelWidth = photoWidth;
                pixelHeight = pixelWidth / aspectRatio;
            }
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
        } else {
            imageSize = PHImageManagerMaximumSize;
        }
        // 修复获取图片时出现的瞬间内存过高问题
        // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        if (thumbnail) {
            option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        }
        PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
                if (self.shouldFixOrientation) {
                    result = [result picker_fixOrientation];
                }
                if (self.shouldDecoded) {
                    result = [result picker_decodedImage];
                }
                if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            } else
            // Download image from iCloud / 从iCloud下载图片
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !result && networkAccessAllowed) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    picker_dispatch_main_async_safe(^{
                        if (progressHandler) {
                            progressHandler(progress, error, stop, info);
                        }
                    });
                };
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                if (thumbnail) {
                    option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                }
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if (self.shouldFixOrientation) {
                        result = [result picker_fixOrientation];
                    }
                    if (self.shouldDecoded) {
                        result = [result picker_decodedImage];
                    }
                    if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }];
            } else {
                if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
        }];
        return imageRequestID;
    }
    else {
        if (completion) completion(nil,nil,NO);
    }
    return 0;
}

#pragma mark - Get photo data (gif)
- (PHImageRequestID)getPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion
{
    return [self getPhotoDataWithAsset:asset completion:completion progressHandler:nil networkAccessAllowed:YES];
}
- (PHImageRequestID)getPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    if ([asset isKindOfClass:[PHAsset class]]) {
        BOOL isGif = [[asset valueForKey:@"uniformTypeIdentifier"] isEqualToString:(__bridge NSString *)kUTTypeGIF];
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        if (isGif) {
            // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用默认的PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
            option.version = PHImageRequestOptionsVersionOriginal;
        }
        
        PHImageRequestID imageRequestID = PHInvalidImageRequestID;
        if (@available(iOS 13, *)) {
            imageRequestID = [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && imageData) {
                    BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (completion) completion(imageData,info,isDegraded);
                }
                else
                // Download image from iCloud / 从iCloud下载图片
                if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData && networkAccessAllowed) {
                    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                    if (progressHandler) {
                        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                            picker_dispatch_main_async_safe(^{
                                progressHandler(progress, error, stop, info);
                            });
                        };
                    }
                    options.networkAccessAllowed = YES;
                    options.resizeMode = PHImageRequestOptionsResizeModeFast;
                    if (isGif) {
                        // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用默认的PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
                        options.version = PHImageRequestOptionsVersionOriginal;
                    }
                    [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                        BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                        if (completion) completion(imageData,info,isDegraded);
                    }];
                } else {
                    if (completion) completion(imageData,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            }];
        } else {
            imageRequestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && imageData) {
                    BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (completion) completion(imageData,info,isDegraded);
                }
                else
                    // Download image from iCloud / 从iCloud下载图片
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData && networkAccessAllowed) {
                        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                        if (progressHandler) {
                            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                                picker_dispatch_main_async_safe(^{
                                    progressHandler(progress, error, stop, info);
                                });
                            };
                        }
                        options.networkAccessAllowed = YES;
                        options.resizeMode = PHImageRequestOptionsResizeModeFast;
                        if (isGif) {
                            // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用默认的PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
                            options.version = PHImageRequestOptionsVersionOriginal;
                        }
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                            if (completion) completion(imageData,info,isDegraded);
                        }];
                    } else {
                        if (completion) completion(imageData,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    }
            }];
        }
        
        return imageRequestID;
    }
    else {
        if (completion) completion(nil,nil,NO);
    }
    return 0;
}

#pragma mark - Get live photo

- (PHImageRequestID)getLivePhotoWithAsset:(id)asset completion:(void (^)(PHLivePhoto *livePhoto,NSDictionary *info,BOOL isDegraded))completion {
    CGFloat fullScreenWidth = [UIScreen mainScreen].bounds.size.width;
    return [self getLivePhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:nil networkAccessAllowed:NO];
}

- (PHImageRequestID)getLivePhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(PHLivePhoto *livePhoto,NSDictionary *info,BOOL isDegraded))completion {
    return [self getLivePhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:NO];
}

- (PHImageRequestID)getLivePhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(PHLivePhoto *livePhoto,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {

    if (@available(iOS 9.1, *)){
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
            CGFloat pixelWidth = photoWidth;
            CGFloat pixelHeight = pixelWidth / aspectRatio;
            CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
            
            PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc]init];
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestLivePhotoForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && livePhoto) {
                    BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (completion) completion(livePhoto,info,isDegraded);
                }
                else
                    // Download image from iCloud / 从iCloud下载图片
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !livePhoto && networkAccessAllowed) {
                        PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc]init];
                        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                            picker_dispatch_main_async_safe(^{
                                if (progressHandler) {
                                    progressHandler(progress, error, stop, info);
                                }
                            });
                        };
                        options.networkAccessAllowed = YES;
                        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                        [[PHImageManager defaultManager] requestLivePhotoForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                            
                            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                            if (completion) completion(livePhoto,info,isDegraded);
                        }];
                    } else {
                        if (completion) completion(livePhoto,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    }
            }];
            return imageRequestID;
        }
    } else {
        if (completion) completion(nil,nil,NO);
    }
    return 0;
}

- (void)cancelImageRequest:(PHImageRequestID)requestID
{
    [[PHImageManager defaultManager] cancelImageRequest:requestID];
}

/**
 *  通过asset解析缩略图、标清图/原图、图片数据字典
 *
 *   asset      PHAsset／ALAsset
 *   isOriginal 是否原图
 *   completion 返回block 顺序：缩略图、原图、图片数据字典
 */
- (void)getPhotoWithAsset:(id)asset
               isOriginal:(BOOL)isOriginal
               completion:(void (^)(TFY_ResultImage *resultImage))completion
{
    [self getPhotoWithAsset:asset isOriginal:isOriginal pickingGif:NO completion:completion];
}

/**
 *  通过asset解析缩略图、标清图/原图、图片数据字典
 *
 *   asset      PHAsset／ALAsset
 *   isOriginal 是否原图
 *   pickingGif 是否需要处理GIF图片
 *   completion 返回block 顺序：缩略图、原图、图片数据字典
 */
- (void)getPhotoWithAsset:(id)asset
               isOriginal:(BOOL)isOriginal
               pickingGif:(BOOL)pickingGif
               completion:(void (^)(TFY_ResultImage *resultImage))completion
{
    [self getPhotoWithAsset:asset isOriginal:isOriginal pickingGif:pickingGif compressSize:kCompressSize thumbnailCompressSize:kThumbnailCompressSize completion:completion];
}


/**
 通过asset解析缩略图、标清图/原图、图片数据字典

  asset PHAsset／ALAsset
  isOriginal 是否原图
  pickingGif 是否需要处理GIF图片
  compressSize 非原图的压缩大小
  thumbnailCompressSize 缩略图压缩大小
  completion 返回block 顺序：缩略图、标清图、图片数据字典
 */
- (void)getPhotoWithAsset:(id)asset
               isOriginal:(BOOL)isOriginal
               pickingGif:(BOOL)pickingGif
             compressSize:(CGFloat)compressSize
    thumbnailCompressSize:(CGFloat)thumbnailCompressSize
               completion:(void (^)(TFY_ResultImage *resultImage))completion
{
    [self getBasePhotoWithAsset:asset completion:^(NSData *imageData, NSString *imageName, TFYImagePickerSubMediaType subMediaType, NSError *error) {
        
        dispatch_globalQueue_async_safe(^{
            CGFloat thumbnailCompress = (thumbnailCompressSize <=0 ? kThumbnailCompressSize : thumbnailCompressSize);
            CGFloat sourceCompress = (compressSize <=0 ? kCompressSize : compressSize);
            BOOL isGif = (subMediaType == TFYImagePickerSubMediaTypeGIF);
            NSData *sourceData = nil; NSData *thumbnailData = nil;
            UIImage *thumbnail = nil; UIImage *source = nil;
        
            // gif的数据源比较特别，不取动图时，仅取第一帧图片，数据源需要重设。（如果选取多张过千帧的动图，这里的优化相当明显。）
            NSData *originalData = imageData;
            
            TFYImagePickerSubMediaType mediaType = subMediaType;
            
            if (imageData && !error) {
                
                TFY_ResultImage *result = [TFY_ResultImage new];
                
                @autoreleasepool {
                    
                    if (isGif && pickingGif) { /** GIF图片处理方式 */
                        /** 原图 */
                        source = [UIImage picker_imageWithImageData:imageData];
                        
                        CGFloat minWidth = MIN(source.size.width, source.size.height);
                        CGFloat imageRatio = 0.7f;
                        
                        if (!isOriginal) {
                            /** 标清图 */
                            sourceData = [source picker_fastestCompressAnimatedImageDataWithScaleRatio:imageRatio];
                        }
                        if (thumbnailCompressSize > 0) {
                            /** 缩略图 */
                            imageRatio = 0.5f;
                            if (minWidth > 100.f) {
                                imageRatio = 50.f/minWidth;
                            }
                            /** 缩略图 */
                            thumbnailData = [source picker_fastestCompressAnimatedImageDataWithScaleRatio:imageRatio];
                        }
                        
                    } else {
                        
                        if (isGif) {
                            /** gif时只取第一帧图片 */
                            CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
                            size_t count = CGImageSourceGetCount(sourceRef);
                            
                            if (count <= 1) {
                                source = [UIImage imageWithData:imageData];
                            } else {
                                CGImageRef image = CGImageSourceCreateImageAtIndex(sourceRef, 0, NULL);
                                
                                source = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                                if (image) {
                                    CGImageRelease(image);
                                }
                                originalData = picker_UIImageRepresentation(source, 1, kUTTypeGIF, nil);
                            }
                            if (sourceRef) {
                                CFRelease(sourceRef);
                            }
                        } else {
                            /** 原图 */
                            source = [UIImage picker_imageWithImageData:imageData];
                        }
                        
                        /** 原图方向更正 */
                        BOOL isFixOrientation = NO;
                        if (self.shouldFixOrientation && source.imageOrientation != UIImageOrientationUp) {
                            source = [source picker_fixOrientation];
                            isFixOrientation = YES;
                        }
                        
                        /** 重写标记 */
                        mediaType = TFYImagePickerSubMediaTypeNone;
                        
                        /** 标清图 */
                        if (!isOriginal) {
                            sourceData = [source picker_fastestCompressImageDataWithSize:sourceCompress imageSize:imageData.length];
                        } else {
                            if (isFixOrientation) { /** 更正方向，原图data需要更新 */
                                sourceData = picker_UIImageJPEGRepresentation(source, 1.f);
                            }
                        }
                        if (thumbnailCompressSize > 0) {
                            /** 缩略图 */
                            thumbnailData = [source picker_fastestCompressImageDataWithSize:thumbnailCompress imageSize:imageData.length];
                        }
                    }
                    
                    /** 创建展示图片 */
                    if (thumbnailData) {
                        /** 缩略图数据 */
                        thumbnail = [UIImage picker_imageWithImageData:thumbnailData];
                    }
                    if (sourceData) {
                        source = [UIImage picker_imageWithImageData:sourceData];
                    } else {
                        /** 不需要压缩的情况 */
                        sourceData = [NSData dataWithData:originalData];
                    }
                    
                    if (self.shouldDecoded && thumbnail.images.count <= 1) {
                        thumbnail = [thumbnail picker_decodedImage];
                    }
                    if (self.shouldDecoded && source.images.count <= 1) {
                        source = [source picker_decodedImage];
                    }
                    /** 图片宽高 */
                    CGSize imageSize = source.size;
                    
                    
                    result.asset = asset;
                    result.thumbnailImage = thumbnail;
                    result.thumbnailData = thumbnailData;
                    result.originalImage = source;
                    result.originalData = sourceData;
                    result.subMediaType = mediaType;
                    
                    TFY_PickerResultInfo *info = [TFY_PickerResultInfo new];
                    result.info = info;
                    
                    /** 图片文件名 */
                    info.name = imageName;
                    /** 图片大小 */
                    info.byte = sourceData.length;
                    /** 图片宽高 */
                    info.size = imageSize;
                }
                
                picker_dispatch_main_async_safe(^{
                    if (completion) {
                        completion(result);
                    }
                });
            } else {
                picker_dispatch_main_async_safe(^{
                    if (completion) {
                        completion(nil);
                    }
                });
            }
        });
    }];
}


/**
 基础方法
 
  asset PHAsset／ALAsset
  completion 返回block 顺序：缩略图、原图、图片数据字典
 */
- (void)getBasePhotoWithAsset:(id)asset completion:(void (^)(NSData *imageData, NSString *imageName, TFYImagePickerSubMediaType subMediaType, NSError *error))completion
{
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        
        // 修复获取图片时出现的瞬间内存过高问题
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        BOOL isGif = [[phAsset valueForKey:@"uniformTypeIdentifier"] isEqualToString:(__bridge NSString *)kUTTypeGIF];
        if (isGif) {
            // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用默认的PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
            option.version = PHImageRequestOptionsVersionOriginal;
        }
        /** 图片文件名+图片大小 */
        
        if (@available(iOS 13, *)) {
            [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:phAsset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && imageData) {
                    NSString *fileName = [phAsset valueForKey:@"filename"];
                    
                    TFYImagePickerSubMediaType mediaType = TFYImagePickerSubMediaTypeNone;
#ifdef __IPHONE_9_1
                    if (phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
                        mediaType = TFYImagePickerSubMediaTypeLivePhoto;
                    } else
#endif
                        if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                            mediaType = TFYImagePickerSubMediaTypeGIF;
                        }
                    NSError *error = [info objectForKey:PHImageErrorKey];
                    if (completion) completion(imageData, fileName, mediaType, error);
                } else
                    // Download image from iCloud / 从iCloud下载图片
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData) {
                        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                        options.networkAccessAllowed = YES;
                        options.resizeMode = PHImageRequestOptionsResizeModeFast;
                        if (isGif) {
                            // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用默认的PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
                            options.version = PHImageRequestOptionsVersionOriginal;
                        }
                        [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                            
                            NSString *fileName = [phAsset valueForKey:@"filename"];
                            
                            TFYImagePickerSubMediaType mediaType = TFYImagePickerSubMediaTypeNone;
#ifdef __IPHONE_9_1
                            if (phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
                                mediaType = TFYImagePickerSubMediaTypeLivePhoto;
                            } else
#endif
                                if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                                    mediaType = TFYImagePickerSubMediaTypeGIF;
                                }
                            NSError *error = [info objectForKey:PHImageErrorKey];
                            if (completion) completion(imageData, fileName, mediaType, error);
                            
                        }];
                    } else {
                        NSError *error = [info objectForKey:PHImageErrorKey];
                        if (completion) completion(nil, nil, TFYImagePickerSubMediaTypeNone, error);
                    }
            }];
        } else {
            [[PHImageManager defaultManager] requestImageDataForAsset:phAsset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && imageData) {
                    NSString *fileName = [phAsset valueForKey:@"filename"];
                    
                    TFYImagePickerSubMediaType mediaType = TFYImagePickerSubMediaTypeNone;
#ifdef __IPHONE_9_1
                    if (phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
                        mediaType = TFYImagePickerSubMediaTypeLivePhoto;
                    } else
#endif
                        if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                            mediaType = TFYImagePickerSubMediaTypeGIF;
                        }
                    NSError *error = [info objectForKey:PHImageErrorKey];
                    if (completion) completion(imageData, fileName, mediaType, error);
                } else
                    // Download image from iCloud / 从iCloud下载图片
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData) {
                        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                        options.networkAccessAllowed = YES;
                        options.resizeMode = PHImageRequestOptionsResizeModeFast;
                        if (isGif) {
                            // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用默认的PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
                            options.version = PHImageRequestOptionsVersionOriginal;
                        }
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            
                            NSString *fileName = [phAsset valueForKey:@"filename"];
                            
                            TFYImagePickerSubMediaType mediaType = TFYImagePickerSubMediaTypeNone;
#ifdef __IPHONE_9_1
                            if (phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
                                mediaType = TFYImagePickerSubMediaTypeLivePhoto;
                            } else
#endif
                                if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                                    mediaType = TFYImagePickerSubMediaTypeGIF;
                                }
                            NSError *error = [info objectForKey:PHImageErrorKey];
                            if (completion) completion(imageData, fileName, mediaType, error);
                            
                        }];
                    } else {
                        NSError *error = [info objectForKey:PHImageErrorKey];
                        if (completion) completion(nil, nil, TFYImagePickerSubMediaTypeNone, error);
                    }
            }];
        }
    }
    else {
        if (completion) completion(nil, nil, TFYImagePickerSubMediaTypeNone, nil);
    }
}

- (void)getLivePhotoWithAsset:(id)asset
                   isOriginal:(BOOL)isOriginal
                needThumbnail:(BOOL)needThumbnail
                   completion:(void (^)(TFY_ResultImage *resultImage))completion
{
    if (@available(iOS 9.1, *)){
        if ([asset isKindOfClass:[PHAsset class]]) {
            
            PHAsset *phAsset = (PHAsset *)asset;
            
            PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc]init];
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            
            [[PHImageManager defaultManager] requestLivePhotoForAsset:phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                
                void (^livePhotoFinish)(PHLivePhoto *) = ^(PHLivePhoto *livePhoto){
                    NSString *fileName = [phAsset valueForKey:@"filename"];
                    
                    NSString *fileFirstName = [fileName stringByDeletingPathExtension];
                    
                    NSArray *resourceArray = [PHAssetResource assetResourcesForLivePhoto:livePhoto];
                    PHAssetResourceManager *arm = [PHAssetResourceManager defaultManager];
                    PHAssetResource *assetResource = resourceArray.lastObject;
                    NSString *cache = [TFY_AssetManager CacheVideoPath];
                    NSString *filePath = [cache stringByAppendingPathComponent:[fileFirstName stringByAppendingPathExtension:@"mov"]];
                    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                    
                    NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:filePath];
                    
                    void (^livePhotoToGif)(NSURL *) = ^(NSURL *videoURL){
                        [TFY_PickerToGIF optimalGIFfromURL:videoURL loopCount:0 completion:^(NSURL *GifURL) {
                            
                            if (GifURL) {
                                TFY_ResultImage *result = [TFY_ResultImage new];
                                
                                @autoreleasepool {
                                    
                                    /** 图片数据 */
                                    NSData *sourceData = [NSData dataWithContentsOfURL:GifURL];
                                    /** 图片名称 */
                                    NSString *imageName = [fileFirstName stringByAppendingPathExtension:@"gif"];
                                    
                                    /** 原图 */
                                    UIImage *source = [UIImage picker_imageWithImageData:sourceData];
                                    
                                    CGFloat minWidth = MIN(source.size.width, source.size.height);
                                    CGFloat imageRatio = 0.7f;
                                    if (!isOriginal) {
                                        /** 标清图 */
                                        sourceData = [source picker_fastestCompressAnimatedImageDataWithScaleRatio:imageRatio];
                                    }
                                    NSData *thumbnailData = nil;
                                    UIImage *thumbnail = nil;
                                    if (needThumbnail) {
                                        /** 缩略图 */
                                        imageRatio = 0.5f;
                                        if (minWidth > 100.f) {
                                            imageRatio = 50.f/minWidth;
                                        }
                                        /** 缩略图 */
                                        thumbnailData = [source picker_fastestCompressAnimatedImageDataWithScaleRatio:imageRatio];
                                        thumbnail = [UIImage picker_imageWithImageData:thumbnailData];
                                    }
                                    
                                    /** 图片宽高 */
                                    CGSize imageSize = source.size;
                                    
                                    if (self.shouldDecoded && thumbnail.images.count <= 1) {
                                        thumbnail = [thumbnail picker_decodedImage];
                                    }
                                    if (self.shouldDecoded && source.images.count <= 1) {
                                        source = [source picker_decodedImage];
                                    }
                                    result.asset = asset;
                                    result.thumbnailImage = thumbnail;
                                    result.thumbnailData = thumbnailData;
                                    result.originalImage = source;
                                    result.originalData = sourceData;
                                    result.subMediaType = TFYImagePickerSubMediaTypeGIF;
                                    
                                    TFY_PickerResultInfo *info = [TFY_PickerResultInfo new];
                                    result.info = info;
                                    
                                    /** 图片文件名 */
                                    info.name = imageName;
                                    /** 图片大小 */
                                    info.byte = sourceData.length;
                                    /** 图片宽高 */
                                    info.size = imageSize;
                                }
                                
                                if (completion) completion(result);
                            } else {
                                if (completion) completion(nil);
                            }
                        }];
                    };
                    
                    
                    if (isExists) {
                        livePhotoToGif(videoURL);
                    } else {
                        [arm writeDataForAssetResource:assetResource toFile:videoURL options:nil completionHandler:^(NSError * _Nullable error)
                         {
                            if (error) {
                                [self getPhotoWithAsset:phAsset isOriginal:isOriginal completion:completion];
                            } else {
                                livePhotoToGif(videoURL);
                            }
                        }];
                    }
                };
                
                /** 方法处理 */
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && livePhoto) {
                    livePhotoFinish(livePhoto);
                } else if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !livePhoto) { // Download image from iCloud / 从iCloud下载图片
                    PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc]init];
                    options.networkAccessAllowed = YES;
                    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    
                    [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                        
                        if (![info objectForKey:PHImageErrorKey]) {
                            livePhotoFinish(livePhoto);
                        } else {
                            if (completion) completion(nil);
                        }
                    }];
                } else {
                    if (completion) completion(nil);
                }
            }];
        }
    } else {
        if (completion) completion(nil);
    }
}

#pragma mark - Get Video

/// Get Video / 获取视频
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * _Nullable, NSDictionary * _Nullable))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc]init];
        option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            /** 方法处理 */
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && playerItem) {
                picker_dispatch_main_async_safe(^{
                    if (completion) completion(playerItem,info);
                });
            } else if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !playerItem) { // Download image from iCloud / 从iCloud下载图片
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
                options.networkAccessAllowed = YES;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                
                [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                    
                    picker_dispatch_main_async_safe(^{
                        if (completion) completion(playerItem,info);
                    });
                    
                }];
            } else {
                picker_dispatch_main_async_safe(^{
                    if (completion) completion(playerItem ,info);
                });
            }
            
        }];
    }
    else {
        if (completion) completion(nil ,nil);
    }
}

- (void)getVideoResultWithAsset:(id)asset
                     presetName:(NSString *)presetName
                          cache:(BOOL)cache
                     completion:(void (^)(TFY_ResultVideo *resultVideo))completion
{
    NSString *name = @"default.mp4";
    if ([asset isKindOfClass:[PHAsset class]]) {
        name = [asset valueForKey:@"filename"];
    }
    if (![name hasSuffix:@".mp4"]) {
        name = [name stringByDeletingPathExtension];
        name = [name stringByAppendingPathExtension:@"mp4"];
    }
    
    void(^VideoResultComplete)(NSString *videoPath) = ^(NSString *videoPath) {
        
        TFY_ResultVideo *result = nil;
        if (videoPath.length) {
            result = [TFY_ResultVideo new];
            result.asset = asset;
            result.coverImage = [TFY_VideoUtils thumbnailImageForVideo:[NSURL fileURLWithPath:videoPath] atTime:1.f];
            NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO)
                                                             forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:opts];
            NSData *data = [NSData dataWithContentsOfFile:videoPath];
            NSTimeInterval duration = CMTimeGetSeconds(urlAsset.duration);
            
            NSArray *assetVideoTracks = [urlAsset tracksWithMediaType:AVMediaTypeVideo];
            CGSize size = CGSizeZero;
            if (assetVideoTracks.count > 0)
            {
                // Insert the tracks in the composition's tracks
                AVAssetTrack *track = [assetVideoTracks firstObject];
                
                CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
                size = CGSizeMake(fabs(dimensions.width), fabs(dimensions.height));
            }
            
            
            result.data = data;
            result.url = [NSURL fileURLWithPath:videoPath];
            result.duration = duration;
            
            TFY_PickerResultInfo *info = [TFY_PickerResultInfo new];
            result.info = info;
            
            /** 文件名 */
            info.name = name;
            /** 大小 */
            info.byte = data.length;
            /** 宽高 */
            info.size = size;
        }
        if (completion) {
            completion(result);
        }
    };
    
    NSString *videoPath = [[TFY_AssetManager CacheVideoPath] stringByAppendingPathComponent:name];
    /** 判断视频是否存在 */
    if (cache && [[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        if (VideoResultComplete) VideoResultComplete(videoPath);
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
        [self compressAndCacheVideoWithAsset:asset presetName:presetName completion:^(NSString *path) {
            if (VideoResultComplete) VideoResultComplete(path);
        }];
    }
    
}

/**
 *   lincf, 16-06-15 13:06:26
 *
 *  视频压缩并缓存压缩后视频 (将视频格式变为mp4)
 *
 *   asset      PHAsset／ALAsset
 *   presetName 压缩预设名称 nil则默认为AVAssetExportPreset1280x720
 *   completion 回调压缩后视频路径，可以复制或剪切
 */
- (void)compressAndCacheVideoWithAsset:(id)asset
                            presetName:(NSString *)presetName
                            completion:(void (^)(NSString *path))completion
{
    if (completion == nil) return;
    
    if (presetName.length == 0) {
        presetName = AVAssetExportPreset1280x720;
    }
    
    NSString *cache = [TFY_AssetManager CacheVideoPath];
    NSString *name = @"default.mp4";
    if ([asset isKindOfClass:[PHAsset class]]) {
        name = [asset valueForKey:@"filename"];
    }
    if (![name hasSuffix:@".mp4"]) {
        name = [name stringByDeletingPathExtension];
        name = [name stringByAppendingPathExtension:@"mp4"];
    }
    NSString *path = [cache stringByAppendingPathComponent:name];
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc]init];
        option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * _Nullable av_asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            
            void (^compressAndCacheVideoFinish)(AVAsset *) = ^(AVAsset *av_asset){
                [TFY_VideoUtils encodeVideoWithAsset:av_asset outPath:path presetName:presetName complete:^(BOOL isSuccess, NSError *error) {
                    if (error) {
                        picker_dispatch_main_async_safe(^{
                            completion(nil);
                        });
                    }else{
                        picker_dispatch_main_async_safe(^{
                            completion(path);
                        });
                    }
                }];
            };
            
            /** 方法处理 */
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && av_asset) {
                compressAndCacheVideoFinish(av_asset);
            } else if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !av_asset) { // Download image from iCloud / 从iCloud下载图片
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
                options.networkAccessAllowed = YES;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable av_asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    
                    if (![info objectForKey:PHImageErrorKey]) {
                        compressAndCacheVideoFinish(av_asset);
                    } else {
                        picker_dispatch_main_async_safe(^{
                            completion(nil);
                        });
                    }
                    
                }];
            } else {
                picker_dispatch_main_async_safe(^{
                    completion(nil);
                });
            }
        }];
    }
    else{
        picker_dispatch_main_async_safe(^{
            completion(nil);
        });
    }
}

/// Get postImage / 获取封面图
- (void)getPostImageWithAlbumModel:(TFY_PickerAlbum *)model ascending:(BOOL)ascending completion:(void (^)(UIImage *))completion {
    if (@available(iOS 8.0, *)){
        id asset = [model.result lastObject];
        if (!ascending) {
            asset = [model.result firstObject];
        }
        [self getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (completion) completion(photo);
        }];
    }
}

/// Judge is a assets array contain the asset 判断一个assets数组是否包含这个asset
- (NSInteger)isAssetsArray:(NSArray *)assets containAsset:(id)asset {
    if (@available(iOS 8.0, *)){
        return [assets indexOfObject:asset];
    }
    return NSNotFound;
}

- (NSString *)getAssetIdentifier:(id)asset {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        return phAsset.localIdentifier;
    }
    return nil;
}

- (CGSize)photoSizeWithAsset:(id)asset {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        return CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    }
    return CGSizeZero;
}

- (void)requestForAsset:(id)asset complete:(void (^)(NSString *name))complete
{
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        NSString *fileName = [phAsset valueForKey:@"filename"];
        if (complete) complete(fileName);
    }
}

#pragma mark - Private Method

- (TFY_PickerAlbum *)modelWithResult:(id)result album:(id)album{
    TFY_PickerAlbum *model = [[TFY_PickerAlbum alloc] initWithAlbum:album result:result];
    return model;
}

/// Return Cache Path
+ (NSString *)CacheVideoPath
{
    NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:(id)kCFBundleIdentifierKey];
    NSString *fullNamespace = [bundleId stringByAppendingPathComponent:@"videoCache"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths.firstObject stringByAppendingPathComponent:fullNamespace];
    
    [TFY_FileUtility createFolder:cachePath errStr:nil];
    
    return cachePath;
}

+ (BOOL)cleanCacheVideoPath
{
    NSString *path = [self CacheVideoPath];
    return [TFY_FileUtility removeFile:path];
}

- (NSURL *)getURLInPlayer:(AVPlayer *)player
{
    // get current asset
    AVAsset *currentPlayerAsset = player.currentItem.asset;
    // make sure the current asset is an AVURLAsset
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) return nil;
    // return the NSURL
    return [(AVURLAsset *)currentPlayerAsset URL];
}

@end
