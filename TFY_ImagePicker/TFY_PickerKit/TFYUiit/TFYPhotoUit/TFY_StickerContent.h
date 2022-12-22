//
//  TFY_StickerContent.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TFYStickerContentState) {
    TFYStickerContentState_None = 0,
    TFYStickerContentState_Downloading,
    TFYStickerContentState_Success,
    TFYStickerContentState_Fail,
};

typedef NS_ENUM(NSInteger, TFYStickerContentType) {
    TFYStickerContentType_Unknow = 0,
    TFYStickerContentType_URLForHttp,
    TFYStickerContentType_URLForFile,
    TFYStickerContentType_PHAsset,
};


typedef NSString * TFYStickerContentStringKey NS_EXTENSIBLE_STRING_ENUM;
/**
 默认贴图
 defalut sticker
 */
extern TFYStickerContentStringKey const TFYStickerContentDefaultSticker;
/**
 默认全部相册图片
 all album photo
 */
extern TFYStickerContentStringKey const TFYStickerContentAllAlbum;

extern NSString *TFYStickerCustomAlbum(NSString *name);

@interface TFY_StickerContent : NSObject

/** 标题 */
@property (nonatomic, readonly) NSString *title;

@property (nonatomic, readonly) NSArray <id /* TFYStickerContentStringKey / NSString * / NSURL * / PHAsset * */> *contents;

+ (instancetype)stickerContentWithTitle:(NSString *)title contents:(NSArray *)contents;
- (instancetype)initWithTitle:(NSString *)title contents:(NSArray *)contents;

/** 内容 */
@property (nonatomic, strong) id content;

/** 进度 */
@property (nonatomic, assign) float progress;

/** 状态 */
@property (nonatomic, assign) TFYStickerContentState state;

@property (nonatomic, assign, readonly) TFYStickerContentType type;

+ (instancetype)stickerContentWithContent:(id)content;
- (instancetype)initWithContent:(id)content;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
