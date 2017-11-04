//
//  JFTAlbumDetector.h
//  JFTAlbumDetector
//
//  Created by syfll on 2017/10/31.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "JFTAlbumFilter.h"
#import "JFTAlbumFilterMappingModel.h"

extern NSString * const JFTAlbumDetectorNeedNetworkKey; ///< 照片可能在 iCloud 上，是否需要网络加载逻辑
extern NSString * const JFTAlbumDetectorNoFacePhotosNotification;
typedef void(^JFTAlbumDetectorGenerateCompletionHandler)(JFTAlbumFilter *filter, NSArray<NSString *> *localIdentifiers);

@interface JFTAlbumDetector : NSObject
+ (instancetype)sharedDetector;
//- (void)generateImagesAsynchronouslyForTimes:(NSArray<JFTAlbumFilter *> *)requestedFilters
//                           completionHandler:(JFTAlbumDetectorGenerateCompletionHandler)handler;

- (void)detecteImagesAsynchronouslyForFilter:(NSArray<JFTAlbumFilter *> *)filters options:(NSDictionary *)options;

//completionHandler:(JFTAlbumDetectorGenerateCompletionHandler)handler;

//- (void)generateImagesAsynchronouslyForFilter:(JFTAlbumFilter *)requestedFilter options:(NSDictionary *)options completionHandler:(JFTAlbumDetectorGenerateCompletionHandler)handler;

@end
