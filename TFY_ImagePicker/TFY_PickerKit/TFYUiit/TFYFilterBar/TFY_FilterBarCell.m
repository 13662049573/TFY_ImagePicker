//
//  TFY_FilterBarCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_FilterBarCell.h"

CGFloat const TFY_LABEL_HEIGHT = 25.f;

@interface TFY_FilterBarCell ()
@property (nonatomic, weak) UIImageView *showImgView;
@property (nonatomic, weak) UILabel *bottomLab;
@end

@implementation TFY_FilterBarCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _createShowImageView_jr];
    } return self;
}

+ (NSString *)identifier {
    return NSStringFromClass([TFY_FilterBarCell class]);
}

- (void)setCellData:(TFY_FilterModel *)cellData{
    self.showImgView.image = cellData.image;
    self.bottomLab.text = cellData.name;
}

- (void)setIsSelectedModel:(BOOL)isSelectedModel
{
    UIColor *color;
    if (isSelectedModel) {
        color = self.selectColor;
    } else {
        color = self.defaultColor;
    }
    self.showImgView.layer.borderWidth = 2.5f;
    self.showImgView.layer.borderColor = color.CGColor;
    self.bottomLab.textColor = color;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect viewR = self.contentView.bounds;
    viewR.size.height -= TFY_LABEL_HEIGHT;

    self.showImgView.frame = viewR;

    CGRect labViewR = CGRectMake(2.5f, CGRectGetMaxY(viewR), CGRectGetWidth(viewR)-5.f, TFY_LABEL_HEIGHT);
    self.bottomLab.frame = labViewR;
}

- (void)_createShowImageView_jr {
    if (!self.showImgView) {
        UIImageView *aImgView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
        aImgView.contentMode = UIViewContentModeScaleAspectFill;
        aImgView.clipsToBounds = YES;
        [self.contentView addSubview:aImgView];
        self.showImgView = aImgView;
    }
    if (!self.bottomLab) {
        UILabel *aLab = [[UILabel alloc] initWithFrame:self.contentView.frame];
        aLab.font = [UIFont systemFontOfSize:15.f];
        aLab.textAlignment = NSTextAlignmentCenter;
        aLab.lineBreakMode = NSLineBreakByTruncatingHead;
        [self.contentView addSubview:aLab];
        self.bottomLab = aLab;
    }
}


@end
