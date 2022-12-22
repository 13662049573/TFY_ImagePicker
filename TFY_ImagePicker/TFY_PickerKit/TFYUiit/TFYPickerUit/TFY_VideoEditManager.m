//
//  TFY_VideoEditManager.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_VideoEditManager.h"
#import "TFY_ImagePickerPublic.h"
#import "TFY_VideoEdit.h"
#import "TFY_PickerAsset.h"
#import "TFY_ResultObjectproperty.h"
#import "TFY_AssetManager.h"
#import "TFY_VideoUtils.h"

@interface TFY_VideoEditManager ()
@property (nonatomic, strong) NSMutableDictionary *videoEditDict;
@end

@implementation TFY_VideoEditManager
static TFY_VideoEditManager *manager;
+ (instancetype)manager {
    if (manager == nil) {
        manager = [[self alloc] init];
        manager.videoEditDict = [@{} mutableCopy];
    }
    return manager;
}

+ (void)free
{
    [manager.videoEditDict removeAllObjects];
    manager = nil;
}

/** 设置编辑对象 */
- (void)setVideoEdit:(TFY_VideoEdit *)obj forAsset:(TFY_PickerAsset *)asset
{
    __weak typeof(self) weakSelf = self;
    if (asset.asset) {
        if (asset.name.length) {
            if (obj) {
                [weakSelf.videoEditDict setObject:obj forKey:asset.name];
            } else {
                [weakSelf.videoEditDict removeObjectForKey:asset.name];
            }
        } else {
            [[TFY_AssetManager manager] requestForAsset:asset.asset complete:^(NSString *name) {
                if (name.length) {
                    if (obj) {
                        [weakSelf.videoEditDict setObject:obj forKey:name];
                    } else {
                        [weakSelf.videoEditDict removeObjectForKey:name];
                    }
                }
            }];
        }
    }
}
/** 获取编辑对象 */
- (TFY_VideoEdit *)videoEditForAsset:(TFY_PickerAsset *)asset
{
    __weak typeof(self) weakSelf = self;
    __block TFY_VideoEdit *videoEdit = nil;
    if (asset.asset) {
        if (asset.name.length) {
            videoEdit = [weakSelf.videoEditDict objectForKey:asset.name];
        } else {
            [[TFY_AssetManager manager] requestForAsset:asset.asset complete:^(NSString *name) {
                if (name.length) {
                    videoEdit = [weakSelf.videoEditDict objectForKey:name];
                }
            }];
        }
    }
    return videoEdit;
}

/**
 通过asset解析视频

  asset TFY_PickerAsset
  presetName 压缩预设名称 nil则默认为AVAssetExportPreset1280x720
  completion 回调
 */
- (void)getVideoWithAsset:(TFY_PickerAsset *)asset
               presetName:(NSString *)presetName
               completion:(void (^)(TFY_ResultVideo *resultVideo))completion
{
    if (presetName.length == 0) {
        presetName = AVAssetExportPreset1280x720;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        TFY_VideoEdit *videoEdit = [self videoEditForAsset:asset];
        /** 图片文件名 */
        NSString *videoName = asset.name;
        videoName = [videoName stringByDeletingPathExtension];
        videoName = [[videoName stringByAppendingString:@"_Edit"] stringByAppendingPathExtension:@"mp4"];
        
        void(^VideoResultComplete)(NSString *, NSString *) = ^(NSString *path, NSString *name) {
            
            TFY_ResultVideo *result = [TFY_ResultVideo new];
            result.asset = asset.asset;
            result.coverImage = videoEdit.editPreviewImage;
            if (path.length) {
                NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO)
                                                                 forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
                AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:opts];
                NSData *data = [NSData dataWithContentsOfFile:path];
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
                result.url = [NSURL fileURLWithPath:path];
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
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(result);
            });
        };
        
        
        NSString *videoPath = [[TFY_AssetManager CacheVideoPath] stringByAppendingPathComponent:videoName];
        AVAsset *av_asset = [AVURLAsset assetWithURL:videoEdit.editFinalURL];
        [TFY_VideoUtils encodeVideoWithAsset:av_asset outPath:videoPath presetName:presetName complete:^(BOOL isSuccess, NSError *error) {
            if (VideoResultComplete) VideoResultComplete(videoPath, videoName);
        }];
    });
}
@end
