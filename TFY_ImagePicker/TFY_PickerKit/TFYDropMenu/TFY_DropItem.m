//
//  TFY_DropItem.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_DropItem.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface TFY_DropItem ()
{
    BOOL _selected;
    UIView *_displayView;
}
@property (nonatomic, strong) NSMutableDictionary *titleColorDict;
@property (nonatomic, strong) NSMutableDictionary *imageDict;

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *textLabel;
@end

@implementation TFY_DropItem
@synthesize tapHandler, doubleTapHandler, longPressHandler;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _titleColorDict = [NSMutableDictionary dictionaryWithCapacity:1];
        _imageDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

- (void)setTitleColor:(nullable UIColor *)color forState:(TFYDropItemState)state
{
    if (color) {
        [_titleColorDict setObject:color forKey:@(state)];
    } else {
        [_titleColorDict removeObjectForKey:@(state)];
    }
}
- (void)setImage:(nullable UIImage *)image forState:(TFYDropItemState)state
{
    if (image) {
        [_imageDict setObject:image forKey:@(state)];
    } else {
        [_imageDict removeObjectForKey:@(state)];
    }
}

- (nullable UIColor *)colorForState:(TFYDropItemState)state
{
    return [_titleColorDict objectForKey:@(state)];
}
- (nullable UIImage *)imageForState:(TFYDropItemState)state
{
    return [_imageDict objectForKey:@(state)];
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        TFYDropItemState state = TFYDropItemStateNormal;
        if (selected) {
            state = TFYDropItemStateSelected;
        }
        UIColor *color = _titleColorDict[@(state)];
        if (color) {
            self.textLabel.textColor = color;
        }
        
        UIImage *image = _imageDict[@(state)];
        if (image) {
            self.imageView.image = image;
        }
    }
}

- (BOOL)isSelected
{
    return _selected;
}

- (UIView *)displayView
{
    if (_displayView == nil) {
        
        CGFloat margin = 8.f;
        /**
         最大宽度
         */
        CGFloat maxWidth = 100.f;

        CGSize iconSize = CGSizeZero;
        CGFloat maxTextWidth = 0;
        
        BOOL hasIcon = (_imageDict[@(TFYDropItemStateNormal)] || _imageDict[@(TFYDropItemStateSelected)]);
        
        if (hasIcon) {
            UIImage *image = _imageDict[@(TFYDropItemStateNormal)];
            if (image == nil) {
                image = _imageDict[@(TFYDropItemStateSelected)];
            }
            iconSize = image.size;
            maxTextWidth = maxWidth - iconSize.width - margin*3;
        } else {
            maxTextWidth = maxWidth - margin*2;
        }
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor colorWithRed:39/255.0 green:35/255.0 blue:35/255.0 alpha:0.8f];
        /**
         计算文字高度
         */
        UIFont *font = [UIFont systemFontOfSize:17.f];
        NSAttributedString *attribString = [[NSAttributedString alloc] initWithString:self.title attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor whiteColor]}];
        CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)attribString;
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attribString length]), NULL, CGSizeMake(maxTextWidth, CGFLOAT_MAX), NULL);
        textSize.height += 1.0;
        CFRelease(framesetter);
        
        CGFloat cellHeight = MAX(iconSize.height, textSize.height) + 2*margin;
        CGFloat x = 0;
        // icon
        if (hasIcon) {
            TFYDropItemState state = self.isSelected ? TFYDropItemStateSelected : TFYDropItemStateNormal;
            UIImage *image = _imageDict[@(state)];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(x+margin, (cellHeight-iconSize.height)/2, iconSize.width, iconSize.height);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [view addSubview:imageView];
            x = CGRectGetMaxX(imageView.frame);
            _imageView = imageView;
        }
        // title
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x+margin, (cellHeight-textSize.height)/2, textSize.width, textSize.height)];
            label.attributedText = attribString;
            
            TFYDropItemState state = self.isSelected ? TFYDropItemStateSelected : TFYDropItemStateNormal;
            UIColor *textColor = _titleColorDict[@(state)];
            if (textColor) {
                label.textColor = textColor;
            }
            [view addSubview:label];
            x = CGRectGetMaxX(label.frame);
            _textLabel = label;
        }
        view.frame = CGRectMake(0, 0, maxWidth, cellHeight);
        _displayView = view;
    }
    return _displayView;
}


@end
