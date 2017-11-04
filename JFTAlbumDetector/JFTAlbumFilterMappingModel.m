//
//  JFTAlbumFilterMappingModel.m
//  JFTAlbumDetector
//
//  Created by syfll on 2017/11/1.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import "JFTAlbumFilterMappingModel.h"

@implementation JFTAlbumFilterMappingModel
- (instancetype)init {
    if (self = [super init]) {
        _assets = @[].mutableCopy;
        _filterAssets = @[].mutableCopy;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    JFTAlbumFilterMappingModel *model = [[JFTAlbumFilterMappingModel alloc] copyWithZone:zone];
    model.filter = self.filter;
    model.filterAssets = self.filterAssets.mutableCopy;
    model.assets = self.assets.mutableCopy;
    return model;
}

@end
