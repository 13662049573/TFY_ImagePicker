//
//  TFY_PickerAlbum.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PickerAlbum.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TFY_PickerAsset.h"

@implementation TFY_PickerAlbum
@synthesize count = _count;

- (instancetype)initWithAlbum:(id)album result:(id)result
{
    self = [super init];
    if (self) {
        [self changedAlbum:album];
        [self changedResult:result];
    }
    return self;
}

- (void)changedResult:(id)result
{
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        _result = result;
        _count = fetchResult.count;
    } 
}

- (void)changedAlbum:(id)album
{
    if ([album isKindOfClass:[PHAssetCollection class]]) {
        PHAssetCollection *collection = (PHAssetCollection *)album;
        _album = album;
        _name = collection.localizedTitle;
    }
}

- (NSInteger)count
{
    if (_models.count) {
        // 实际显示数据为准
        return _models.count;
    }
    return _count;
}

- (BOOL)isEqual:(id)object
{
    if([self class] == [object class])
    {
        if (self == object) {
            return YES;
        }
        TFY_PickerAlbum *objAlbum = (TFY_PickerAlbum *)object;
        if ([self.album isEqual: objAlbum.album] && [self.name isEqual: objAlbum.name]) {
            return YES;
        }
        return NO;
    }
    else
    {
        return [super isEqual:object];
    }
}


@end
