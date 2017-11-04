//
//  JFTAlbumFilterMappingModel.h
//  JFTAlbumDetector
//
//  Created by syfll on 2017/11/1.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset, JFTAlbumFilter;
@interface JFTAlbumFilterMappingModel : NSObject <NSCopying>
@property (nonatomic, strong) JFTAlbumFilter *filter;
@property (nonatomic, strong) NSMutableArray<NSString *> *filterAssets;///< assets matched with filter
@property (nonatomic, strong) NSMutableArray<NSString *> *assets;///< assets with no face
@end
