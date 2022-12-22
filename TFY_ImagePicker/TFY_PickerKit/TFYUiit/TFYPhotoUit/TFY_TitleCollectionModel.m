//
//  TFY_TitleCollectionModel.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_TitleCollectionModel.h"

NSString * const TFYCollectionViewTitleModel_title = @"TFYCollectionViewTitleModel_title";
NSString * const TFYCollectionViewTitleModel_size = @"TFYCollectionViewTitleModel_size";

@implementation TFY_TitleCollectionModel

- (UIFont *)font
{
    return [UIFont systemFontOfSize:16.f];
}


- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        [self _picker_setTitle:title];
    } return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        _title = [dictionary objectForKey:TFYCollectionViewTitleModel_title];
        _size = CGSizeFromString([dictionary objectForKey:TFYCollectionViewTitleModel_size]);
    } return self;
}

- (NSDictionary *)dictionary
{
    if (_title == nil) {
        _title = @"";
    }
    return @{TFYCollectionViewTitleModel_title:_title, TFYCollectionViewTitleModel_size:NSStringFromCGSize(_size)};
}

#pragma mark - Private Methods
- (void)_picker_setTitle:(NSString *)title
{
    _title = title;
    if (_title == nil) {
        _size = CGSizeZero;
        return;
    }
    NSDictionary *btAtt = @{NSFontAttributeName:self.font};
    _size = [title sizeWithAttributes:btAtt];
}


@end
