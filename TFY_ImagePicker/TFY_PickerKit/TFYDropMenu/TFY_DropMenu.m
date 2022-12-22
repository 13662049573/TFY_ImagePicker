//
//  TFY_DropMenu.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_DropMenu.h"
#import "TFY_DropMainMenu.h"

static TFY_DropMainMenu *_TFYDropMainMenu;

const NSString *TFYDropMainMenu_autoDismiss = @"TFYDropMainMenu_autoDismiss";
const NSString *TFYDropMainMenu_backgroundColor = @"TFYDropMainMenu_backgroundColor";
const NSString *TFYDropMainMenu_direction = @"TFYDropMainMenu_direction";

static NSMutableDictionary *_TFYDrapMainMenuPropertys;

@implementation TFY_DropMenu

#pragma mark - preporty
+ (void)setAutoDismiss:(BOOL)isAutoDismiss
{
    self.TFYDrapMainMenuPropertys[TFYDropMainMenu_autoDismiss] = @(isAutoDismiss);
    _TFYDropMainMenu.autoDismiss = isAutoDismiss;
}

+ (BOOL)isOnShow
{
    return (BOOL)_TFYDropMainMenu;
}

+ (void)setBackgroundColor:(UIColor *)color
{
    self.TFYDrapMainMenuPropertys[TFYDropMainMenu_backgroundColor] = color;
    _TFYDropMainMenu.containerViewbackgroundColor = color;
}
+ (void)setDirection:(TFYDropMainMenuDirection)direction
{
    self.TFYDrapMainMenuPropertys[TFYDropMainMenu_direction] = @(direction);
}

#pragma mark - function
+ (void)showInView:(UIView *)view items:(NSArray <id <TFY_DropItemProtocol>>*)items
{
    [self dismissWithAnimated:NO];
    _TFYDropMainMenu = [self TFYDropMainMenuWithItems:items];
    [_TFYDropMainMenu showInView:view];
}
+ (void)showFromPoint:(CGPoint)point items:(NSArray <id <TFY_DropItemProtocol>>*)items
{
    [self dismissWithAnimated:NO];
    _TFYDropMainMenu = [self TFYDropMainMenuWithItems:items];
    [_TFYDropMainMenu showFromPoint:point];
}

+ (void)dismiss
{
    [self dismissWithAnimated:YES];
}

+ (void)dismissWithAnimated:(BOOL)animated
{
    if (_TFYDropMainMenu) {
        [_TFYDropMainMenu dismissWithAnimated:animated];
        _TFYDropMainMenu = nil;
    }
}

#pragma mark - private
+ (NSMutableDictionary *)TFYDrapMainMenuPropertys
{
    if (_TFYDrapMainMenuPropertys == nil) {
        _TFYDrapMainMenuPropertys = [NSMutableDictionary dictionary];
    }
    return _TFYDrapMainMenuPropertys;
}

+ (TFY_DropMainMenu *)TFYDropMainMenuWithItems:(NSArray <id <TFY_DropItemProtocol>>*)items
{
    TFY_DropMainMenu *dropMainMenu = [[TFY_DropMainMenu alloc] init];
    dropMainMenu.displayMaxNum = 0;
    id value = self.TFYDrapMainMenuPropertys[TFYDropMainMenu_autoDismiss];
    if (value) {
        dropMainMenu.autoDismiss = [value boolValue];
    }
    value = self.TFYDrapMainMenuPropertys[TFYDropMainMenu_backgroundColor];
    if (value) {
        dropMainMenu.containerViewbackgroundColor = value;
    }
    value = self.TFYDrapMainMenuPropertys[TFYDropMainMenu_direction];
    if (value) {
        dropMainMenu.direction = [value integerValue];
    }
    for (id <TFY_DropItemProtocol> item in items) {
        [dropMainMenu addItem:item];
    }
    return dropMainMenu;
}


@end
