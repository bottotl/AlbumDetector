//
//  JFTAlbumFilterHepler.h
//  JFTAlbumDetector
//
//  Created by syfll on 2017/11/1.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFTAlbumFilter.h"
#import <Photos/Photos.h>
#import "JFTAlbumFilterMappingModel.h"

@interface JFTAlbumFilterHepler : NSObject
+ (NSMutableArray<JFTAlbumFilterMappingModel *> *)mappingFilters:(NSArray<JFTAlbumFilter *> *)filters allAssets:(PHFetchResult<PHAsset *> *)assets;
@end
