//
//  TFY_AssetManager+SaveAlbum.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_AssetManager+SaveAlbum.h"
#import "TFY_ImagePickerPublic.h"
#import "TFYItools.h"
#import "TFY_AssetManager+Authorization.h"

@implementation TFY_AssetManager (SaveAlbum)

#pragma mark - 创建相册
- (void)createCustomAlbumWithTitle:(NSString *)title complete:(void (^)(PHAssetCollection *result))complete faile:(void (^)(NSError *error))faile{
    
    TFYPhotoAuthorizationStatus status = [self picker_authorizationStatus];
    BOOL isAuthorized = (status == TFYPhotoAuthorizationStatusLimited || status == TFYPhotoAuthorizationStatusAuthorized);
    if (isAuthorized) {
        if (title.length == 0) {
            if (complete) complete(nil);
        }else{
            dispatch_globalQueue_async_safe(^{
                // 是否存在相册 如果已经有了 就不再创建
                PHFetchResult <PHAssetCollection *> *results = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                BOOL haveHDRGroup = NO;
                NSError *error = nil;
                PHAssetCollection *createCollection = nil;
                for (PHAssetCollection *collection in results) {
                    if ([collection.localizedTitle isEqualToString:title]) {
                        /** 已经存在了，不需要创建了 */
                        haveHDRGroup = YES;
                        createCollection = collection;
                        break;
                    }
                }
                if (haveHDRGroup) {
                    NSLog(@"Already exists");
                    picker_dispatch_main_async_safe(^{
                        if (complete) complete(createCollection);
                    });
                }else{
                    __block NSString *createdCustomAssetCollectionIdentifier = nil;
                    /**
                     * 注意：这个方法只是告诉 photos 我要创建一个相册，并没有真的创建
                     *      必须等到 performChangesAndWait block 执行完毕后才会
                     *      真的创建相册。
                     */
                    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
                        /**
                         * collectionChangeRequest 即使我们告诉 photos 要创建相册，但是此时还没有
                         * 创建相册，因此现在我们并不能拿到所创建的相册，我们的需求是：将图片保存到
                         * 自定义的相册中，因此我们需要拿到自己创建的相册，从头文件可以看出，collectionChangeRequest
                         * 中有一个占位相册，placeholderForCreatedAssetCollection ，这个占位相册
                         * 虽然不是我们所创建的，但是其 identifier 和我们所创建的自定义相册的 identifier
                         * 是相同的。所以想要拿到我们自定义的相册，必须保存这个 identifier，等 photos app
                         * 创建完成后通过 identifier 来拿到我们自定义的相册
                         */
                        createdCustomAssetCollectionIdentifier = collectionChangeRequest.placeholderForCreatedAssetCollection.localIdentifier;
                    } error:&error];
                    if (error) {
                        NSLog(@"Album Failed: %@",title);
                        picker_dispatch_main_async_safe(^{
                            if (faile) faile(error);
                        });
                    }else{
                        if (createdCustomAssetCollectionIdentifier) {
                            /** 获取创建成功的相册 */
                            createCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCustomAssetCollectionIdentifier] options:nil].firstObject;
                            NSLog(@"Album Created: %@",title);
                            picker_dispatch_main_async_safe(^{
                                if (complete) complete(createCollection);
                            });
                        } else {
                            NSLog(@"Album Failed: %@",title);
                            picker_dispatch_main_async_safe(^{
                                if (faile) faile(error);
                            });
                        }
                    }
                }
            });
        }
    }
}


#pragma mark - 保存图片到自定义相册
- (void)saveImageToCustomPhotosAlbumWithTitle:(NSString *)title images:(NSArray <UIImage *>*)images complete:(void (^)(NSArray <id /* PHAsset/ALAsset */>*assets,NSError *error))complete
{
    [self baseSaveImageToCustomPhotosAlbumWithTitle:title datas:images complete:complete];
}
- (void)saveImageToCustomPhotosAlbumWithTitle:(NSString *)title imageDatas:(NSArray <NSData *>*)imageDatas complete:(void (^)(NSArray <id /* PHAsset/ALAsset */>*assets ,NSError *error))complete
{
    [self baseSaveImageToCustomPhotosAlbumWithTitle:title datas:imageDatas complete:complete];
}
- (void)baseSaveImageToCustomPhotosAlbumWithTitle:(NSString *)title datas:(NSArray <id /* NSData/UIImage */>*)datas complete:(void (^)(NSArray <id /* PHAsset/ALAsset */>*assets ,NSError *error))complete
{
    
    TFYPhotoAuthorizationStatus status = [self picker_authorizationStatus];
    BOOL isAuthorized = (status == TFYPhotoAuthorizationStatusLimited || status == TFYPhotoAuthorizationStatusAuthorized);
    if (isAuthorized) {
        if (@available(iOS 8.0, *)){
            [self createCustomAlbumWithTitle:title complete:^(PHAssetCollection *result) {
                [self saveToAlbumIOS8LaterWithImages:datas customAlbum:result completionBlock:^(NSArray<PHAsset *> *assets) {
                    if (complete) complete(assets, nil);
                } failureBlock:^(NSError *error) {
                    if (complete) complete(nil, error);
                }];
            } faile:^(NSError *error) {
                if (complete) complete(nil, error);
            }];
        }
    } else {
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSBundle picker_localizedStringForKey:@"_LFAssetManager_SaveAlbum_notpermissionError"]}];
        if (complete) complete(nil, error);
    }
    
}

#pragma mark - iOS8之后保存相片到自定义相册
- (void)saveToAlbumIOS8LaterWithImages:(NSArray <id /* NSData/UIImage */>*)datas
                           customAlbum:(PHAssetCollection *)customAlbum
                       completionBlock:(void(^)(NSArray <PHAsset *>*assets))completionBlock
                          failureBlock:(void (^)(NSError *error))failureBlock
{
    NSError *error = nil;
    __block NSMutableArray <NSString *>*createdAssetIds = [@[] mutableCopy];
    PHAssetCollection *assetCollection = (PHAssetCollection *)customAlbum;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        
        for (id data in datas) {
            PHAssetChangeRequest *req = nil;
            if ([data isKindOfClass:[NSData class]]) {
                if (@available(iOS 9.0, *)){
                    PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                    req = [PHAssetCreationRequest creationRequestForAsset];
                    [(PHAssetCreationRequest *)req addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
                } else {
                    UIImage *image = [UIImage picker_imageWithImageData:data];
                    req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                }
            } else if ([data isKindOfClass:[UIImage class]]) {
                req = [PHAssetChangeRequest creationRequestForAssetFromImage:data];
            }
            PHObjectPlaceholder *placeholder = req.placeholderForCreatedAsset;
            //记录本地标识，等待完成后取到相册中的图片对象
            NSString *createdAssetId = placeholder.localIdentifier;
            if (createdAssetId) {
                [createdAssetIds addObject:createdAssetId];
            }
        }
    } error:&error];
    
    if (error) {
        NSLog(@"Save failed");
        picker_dispatch_main_async_safe(^{
            if (failureBlock) failureBlock(error);
        });
    } else {
        NSError *nextError = nil;
        PHFetchResult <PHAsset *>*result = nil;
        if (createdAssetIds.count) {
            //成功后取相册中的图片对象
            result = [PHAsset fetchAssetsWithLocalIdentifiers:createdAssetIds options:nil];
            
            /** 保存到指定相册 */
            if (assetCollection) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                    //            [request addAssets:@[placeholder]];
                    //将最新保存的图片设置为封面
                    [request insertAssets:result atIndexes:[NSIndexSet indexSetWithIndex:0]];
                } error:&nextError];
            }
        }
        if (result == nil) {
            nextError = [NSError errorWithDomain:@"SaveToAlbumError" code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSBundle picker_localizedStringForKey:@"_LFAssetManager_SaveAlbum_saveVideoError"]}];
        }
        
        if (nextError) {
            NSLog(@"Save failed");
            picker_dispatch_main_async_safe(^{
                if (failureBlock) failureBlock(nextError);
            });
        } else {
            NSLog(@"Saved successfully");
            NSMutableArray <PHAsset *>*assets = [@[] mutableCopy];
            [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [assets addObject:obj];
            }];
            picker_dispatch_main_async_safe(^{
                if (completionBlock) completionBlock([assets copy]);
            });
        }
    }
}

#pragma mark - Save the video to a custom album
- (void)saveVideoToCustomPhotosAlbumWithTitle:(NSString *)title videoURLs:(NSArray <NSURL *>*)videoURLs complete:(void(^)(NSArray <id /* PHAsset/ALAsset */>*assets, NSError *error))complete
{
    TFYPhotoAuthorizationStatus status = [self picker_authorizationStatus];
    BOOL isAuthorized = (status == TFYPhotoAuthorizationStatusLimited || status == TFYPhotoAuthorizationStatusAuthorized);
    if (isAuthorized) {
        if (@available(iOS 8.0, *)){
            [self createCustomAlbumWithTitle:title complete:^(PHAssetCollection *result) {
                [self saveToAlbumIOS8LaterWithVideoURLs:videoURLs customAlbum:result completionBlock:^(NSArray<PHAsset *> *assets) {
                    if (complete) complete(assets, nil);
                } failureBlock:^(NSError *error) {
                    if (complete) complete(nil, error);
                }];
            } faile:^(NSError *error) {
                if (complete) complete(nil, error);
            }];
        }
    } else {
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSBundle picker_localizedStringForKey:@"_LFAssetManager_SaveAlbum_notpermissionError"]}];
        if (complete) complete(nil, error);
    }
}

#pragma mark iOS8 After saving the video to a custom album
- (void)saveToAlbumIOS8LaterWithVideoURLs:(NSArray <NSURL *>*)videoURLs
                              customAlbum:(PHAssetCollection *)customAlbum
                          completionBlock:(void(^)(NSArray <PHAsset *>*assets))completionBlock
                             failureBlock:(void (^)(NSError *error))failureBlock
{
    dispatch_globalQueue_async_safe(^{
        NSError *error = nil;
        __block NSMutableArray <NSString *>*createdAssetIds = [@[] mutableCopy];
        PHAssetCollection *assetCollection = (PHAssetCollection *)customAlbum;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            for (NSURL *videoURL in videoURLs) {
                PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
                PHObjectPlaceholder *placeholder = req.placeholderForCreatedAsset;
                //记录本地标识，等待完成后取到相册中的图片对象
                NSString *createdAssetId = placeholder.localIdentifier;
                if (createdAssetId) {
                    [createdAssetIds addObject:createdAssetId];
                }
            }
            
        } error:&error];
        
        if (error) {
            NSLog(@"Save failed:%@", error.localizedDescription);
            picker_dispatch_main_async_safe(^{
                if (failureBlock) failureBlock(error);
            });
        } else {
            NSError *nextError = nil;
            PHFetchResult <PHAsset *>*result = nil;
            if (createdAssetIds.count) {
                //成功后取相册中的图片对象
                result = [PHAsset fetchAssetsWithLocalIdentifiers:createdAssetIds options:nil];
                
                if (result && assetCollection) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                        //            [request addAssets:@[placeholder]];
                        //将最新保存的图片设置为封面
                        [request insertAssets:result atIndexes:[NSIndexSet indexSetWithIndex:0]];
                    } error:&nextError];
                }
            }
            if (result == nil) {
                nextError = [NSError errorWithDomain:@"SaveToAlbumError" code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSBundle picker_localizedStringForKey:@"_LFAssetManager_SaveAlbum_saveVideoError"]}];
            }
            if (nextError) {
                NSLog(@"Save failed");
                picker_dispatch_main_async_safe(^{
                    if (failureBlock) failureBlock(nextError);
                });
            } else {
                NSLog(@"Saved successfully");
                NSMutableArray <PHAsset *>*assets = [@[] mutableCopy];
                [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [assets addObject:obj];
                }];
                picker_dispatch_main_async_safe(^{
                    if (completionBlock) completionBlock([assets copy]);
                });
            }
        }
    });
}

- (void)deleteAssets:(NSArray <id /* PHAsset/ALAsset */ > *)assets complete:(void (^)(NSError *error))complete
{
    if (@available(iOS 8.0, *)){
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:assets];
        } completionHandler:^(BOOL success, NSError *error) {
            picker_dispatch_main_async_safe(^{
                NSLog(@"deleteAssets Error: %@", error);
                if (complete) {
                    complete(error);
                }
            });
        }];
    }
}

- (void)deleteAssetCollections:(NSArray <PHAssetCollection *> *)collections complete:(void (^)(NSError *error))complete
{
    [self deleteAssetCollections:collections deleteAssets:NO complete:complete];
}

- (void)deleteAssetCollections:(NSArray <PHAssetCollection *> *)collections deleteAssets:(BOOL)deleteAssets complete:(void (^)(NSError *error))complete
{
    if (@available(iOS 8.0, *)){
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            if (deleteAssets) {
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                for (PHAssetCollection *collection in collections) {
                    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, fetchResult.count)];
                    NSArray *results = [fetchResult objectsAtIndexes:indexSet];
                    [PHAssetChangeRequest deleteAssets:results];
                }
            }
            [PHAssetCollectionChangeRequest deleteAssetCollections:collections];
        } completionHandler:^(BOOL success, NSError *error) {
            picker_dispatch_main_async_safe(^{
                NSLog(@"deleteAssetCollections Error: %@", error);
                if (complete) {
                    complete(error);
                }
            });
        }];
    }
}


@end
