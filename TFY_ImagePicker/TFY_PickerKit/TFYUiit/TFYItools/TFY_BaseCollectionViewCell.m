//
//  TFY_BaseCollectionViewCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_BaseCollectionViewCell.h"

@interface TFY_BaseCollectionViewCell ()
@property (strong, nonatomic) id cellData;
@end

@implementation TFY_BaseCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

- (void)setCellData:(nullable id)data
{
    _cellData = data;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _cellData = nil;
}
@end
