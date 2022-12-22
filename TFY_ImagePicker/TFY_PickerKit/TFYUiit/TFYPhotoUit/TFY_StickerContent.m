//
//  TFY_StickerContent.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_StickerContent.h"
#import <Photos/Photos.h>

TFYStickerContentStringKey const TFYStickerContentDefaultSticker = @"TFYStickerContentDefaultSticker";
TFYStickerContentStringKey const TFYStickerContentAllAlbum = @"TFYStickerContentAllAlbum";
TFYStickerContentStringKey const TFYStickerContentCustomAlbum = @"TFYStickerContentCustomAlbum";

NSString * const TFYStickerContent_content = @"TFYStickerContent_content";
NSString * const TFYStickerContent_state = @"TFYStickerContent_state";

NSString *TFYStickerCustomAlbum(NSString *name)
{
    return [TFYStickerContentCustomAlbum stringByAppendingString:name];
}

@implementation TFY_StickerContent

+ (instancetype)stickerContentWithTitle:(NSString *)title contents:(NSArray *)contents
{
    return [[[self class] alloc] initWithTitle:title contents:contents];
}
- (instancetype)initWithTitle:(NSString *)title contents:(NSArray *)contents
{
    self = [super init];
    if (self) {
        _title = title;
        _contents = contents;
    }
    return self;
}

+ (instancetype)stickerContentWithContent:(id)content
{
    return [[self alloc] initWithContent:content];
}

- (instancetype)initWithContent:(id)content
{
    self = [super init];
    if (self) {
        _content = content;
        _state = TFYStickerContentState_None;
        _progress = 0.f;
    }
    return self;
}

- (TFYStickerContentType)type
{
    TFYStickerContentType _type = TFYStickerContentType_Unknow;
    if ([_content isKindOfClass:[NSURL class]]) {
        NSURL *dataURL = (NSURL *)_content;
        if ([[[dataURL scheme] lowercaseString] isEqualToString:@"file"]) {
            _type = TFYStickerContentType_URLForFile;
        } else {
            _type = TFYStickerContentType_URLForHttp;
        }
    } else if ([_content isKindOfClass:[PHAsset class]]) {
        _type = TFYStickerContentType_PHAsset;
    }
    return _type;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        _content = [dictionary objectForKey:TFYStickerContent_content];
        _progress = 0.f;
        _state = [[dictionary objectForKey:TFYStickerContent_state] integerValue];
    } return self;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *muDict = @{}.mutableCopy;
    if (self.content) {
        [muDict setObject:self.content forKey:TFYStickerContent_content];
    }
    if (self.state == TFYStickerContentState_Downloading) {
        self.state = TFYStickerContentState_None;
    }
    [muDict setObject:@(self.state) forKey:TFYStickerContent_state];
    return [muDict copy];

}

@end
