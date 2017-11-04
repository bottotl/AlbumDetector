//
//  JFTPhotoCollectionViewCell.m
//  JFTFaceDetection
//
//  Created by syfll on 2017/10/27.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import "JFTPhotoCollectionViewCell.h"

@implementation JFTPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _photoPreviewImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_photoPreviewImageView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.photoPreviewImageView.image = nil;
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.photoPreviewImageView.frame = CGRectInset(self.contentView.bounds, 20, 20);
    
}

@end
