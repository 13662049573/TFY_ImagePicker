//
//  TFY_Text.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Text.h"

@implementation TFY_Text

- (instancetype)init
{
    self = [super init];
    if (self) {
        _usedRect = CGRectNull;
    }
    return self;
}

#pragma mark - NSSecureCoding
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _attributedText = [coder decodeObjectForKey:@"attributedText"];
        _layoutData = [coder decodeObjectForKey:@"layoutData"];
        _usedRect = [coder decodeCGRectForKey:@"usedRect"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.attributedText forKey:@"attributedText"];
    [coder encodeObject:self.layoutData forKey:@"layoutData"];
    [coder encodeCGRect:self.usedRect forKey:@"usedRect"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
