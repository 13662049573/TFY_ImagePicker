//
//  TFY_ConfigTool.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_ConfigTool.h"

@implementation TFY_ConfigTool
static TFY_ConfigTool *_tool = nil;

+ (instancetype)shareInstance
{
    if (!_tool) {
        _tool = [[TFY_ConfigTool alloc] init];
    }
    return _tool;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _normalInit];
    } return self;
}

+ (void)free
{
    _tool = nil;
}

- (UIColor *)selectTitleColor
{
    if (!_selectTitleColor) {
        _selectTitleColor = [UIColor redColor];
    }
    return _selectTitleColor;
}

- (UIColor *)normalTitleColor
{
    if (!_normalTitleColor) {
        _normalTitleColor = [UIColor whiteColor];
    }
    return _normalTitleColor;
}

#pragma mark - Private Methods
- (void)_normalInit
{
    _selectTitleColor = [UIColor redColor];
    _normalTitleColor = [UIColor whiteColor];
    _itemSize = CGSizeMake(80.f, 80.f);
    _itemMargin = 10.f;
    _normalImage = nil;
    _failureImage = nil;
    _concurrentQueue = dispatch_queue_create("djr.ConfigTool.queue", DISPATCH_QUEUE_CONCURRENT);
}
@end
