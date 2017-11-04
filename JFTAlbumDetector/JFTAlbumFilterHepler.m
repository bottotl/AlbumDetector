//
//  JFTAlbumFilterHepler.m
//  JFTAlbumDetector
//
//  Created by syfll on 2017/11/1.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import "JFTAlbumFilterHepler.h"

@implementation JFTAlbumFilterHepler

+ (NSMutableArray<JFTAlbumFilterMappingModel *> *)mappingFilters:(NSArray<JFTAlbumFilter *> *)filters allAssets:(PHFetchResult<PHAsset *> *)assets {
    NSMutableArray *filterMappings = @[].mutableCopy;
    [filters enumerateObjectsUsingBlock:^(JFTAlbumFilter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JFTAlbumFilterMappingModel *model = [[JFTAlbumFilterMappingModel alloc] init];
        model.filter = obj;
        model.filterAssets = [self assetsMatchFilter:obj allAssets:assets];
        [filterMappings addObject:model];
    }];
    return filterMappings;
}

+ (NSMutableArray<NSString *> *)assetsMatchFilter:(JFTAlbumFilter *)filter allAssets:(PHFetchResult<PHAsset *> *)assets {
    NSMutableArray *returnModels = @[].mutableCopy;
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isPHAsset:asset matchFilter:filter]) {
            [returnModels addObject:asset.localIdentifier];
        }
    }];
    NSLog(@"match photo count:%lu", returnModels.count);
    return returnModels;
}

+ (BOOL)isPHAsset:(PHAsset *)asset matchFilter:(JFTAlbumFilter *)filter {
    if (!asset.creationDate || !asset.location) return NO;
    if ([self isCreateTime:asset.creationDate matchFilter:filter] && [self isLocation:asset.location matchFilter:filter]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isLocation:(CLLocation *)location matchFilter:(JFTAlbumFilter *)filter {
    CLLocation *filterLocation = [[CLLocation alloc] initWithLatitude:filter.location.latitude longitude:filter.location.longitude];
    CLLocationDistance distance = [filterLocation distanceFromLocation:location];
    return (distance < filter.locationTolerance )? YES : NO;
}

+ (BOOL)isCreateTime:(NSDate *)creationDate matchFilter:(JFTAlbumFilter *)filter {
    if (([filter.startDate compare:creationDate] != NSOrderedDescending) &&
        ([filter.endDate compare:creationDate] != NSOrderedAscending)) {
        return YES;
    }
    return NO;
}

@end
