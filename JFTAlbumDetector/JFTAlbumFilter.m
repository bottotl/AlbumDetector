//
//  JFTAlbumSearchEntity.m
//  JFTAlbumDetector
//
//  Created by syfll on 2017/10/31.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import "JFTAlbumFilter.h"

@implementation JFTAlbumFilter

- (id)copyWithZone:(NSZone *)zone {
    JFTAlbumFilter *newFilter = [[JFTAlbumFilter allocWithZone:zone] init];
    newFilter.location = self.location;
    newFilter.locationTolerance = self.locationTolerance;
    newFilter.startDate = self.startDate;
    newFilter.endDate = self.endDate;
    newFilter.maxCount = self.maxCount;
    return newFilter;
}

- (instancetype)init {
    if (self = [super init]) {
        _maxCount = 5;
    }
    return self;
}

- (NSUInteger)hash {
    /// 假设两个 filter 有同样的参数，但是可能在程序运行的不同时候创建的
    /// 这时候相册中的资源已经发生了变化
    /// 只根据参数相同就认为两个对象相同（从而直接从缓存中读取不太牢靠，干脆让再重新查一遍
    return [super hash];
}

@end
