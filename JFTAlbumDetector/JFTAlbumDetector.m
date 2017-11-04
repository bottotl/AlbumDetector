//
//  JFTAlbumDetector.m
//  JFTAlbumDetector
//
//  Created by syfll on 2017/10/31.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import "JFTAlbumDetector.h"
#import "JFTPHAssetFaceDetecteOperation.h"
#import "JFTAlbumFilterMappingModel.h"
#import "JFTAlbumFilterHepler.h"
#import "JFTPHAssetDetectorCacheProtocol.h"

NSString * const JFTAlbumDetectorNeedNetworkKey = @"AlbumDetectorNeedNetwork";
NSString * const JFTAlbumDetectorNoFacePhotosNotification = @"JFTAlbumDetectorNoFacePhotosNotification";
//NSString const* JFTAlbumDetectorMaxMatchNumberKey = @"AlbumDetectorMaxMatchNumber";

static NSUInteger const maxTaskCount = 5;
static JFTAlbumDetector *_detector = nil;

@interface JFTAlbumDetector () <JFTPHAssetDetectorCacheProtocol>
@property (nonatomic, strong) CIContext *context;///< context for CIFilter
@property (nonatomic, strong) PHFetchResult<PHAsset *> *allAssets;/// 暂时不考虑相册资源会变动的情况
@property (nonatomic, strong) NSOperationQueue *taskQueue;
@property (nonatomic, strong) NSMutableArray<JFTAlbumFilterMappingModel *> *filters;///<
@property (nonatomic, strong) NSMutableArray<JFTAlbumFilterMappingModel *> *detectingFilters;
@property (nonatomic, strong) NSMutableArray<JFTAlbumFilterMappingModel *> *finishedFilters;
@property (nonatomic, strong) NSMutableArray<NSString *> *detectingAssets;
@end

@implementation JFTAlbumDetector
@synthesize assetCache = _assetCache;

+ (instancetype)sharedDetector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _detector = [[JFTAlbumDetector alloc] init];
    });
    return _detector;
}

- (instancetype)init {
    if (self = [super init]) {
        _assetCache = @{}.mutableCopy;/// 后期添加从本地持久化数据恢复的能力
        _filters = @[].mutableCopy;
        _detectingFilters = @[].mutableCopy;
        _finishedFilters = @[].mutableCopy;
        _detectingAssets = @[].mutableCopy;
        _context = [CIContext contextWithOptions:nil];
        _taskQueue = [[NSOperationQueue alloc] init];
        _taskQueue.maxConcurrentOperationCount = maxTaskCount;
    }
    return self;
}

- (PHFetchResult<PHAsset *> *)allAssets {
    if (!_allAssets) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        _allAssets = [PHAsset fetchAssetsWithOptions:options];
        NSLog(@"smartAlbums, count%lu", _allAssets.count);
    }
    return _allAssets;
}

- (void)detecteImagesAsynchronouslyForFilter:(NSArray<JFTAlbumFilter *> *)filters options:(NSDictionary *)options {
    NSArray *models = [JFTAlbumFilterHepler mappingFilters:filters allAssets:self.allAssets];
    if (!models.count) return;
    [self.filters addObjectsFromArray:models];
    [self startTask];
}

- (void)startTask {
    /// 提交 task to operation
    for (int i = 0; i < maxTaskCount; i++) {
        [self submitNextTask];
    }
}

/// 串行队列进行
- (void)submitNextTask {
    /// 更新 filters 的状态
    BOOL allFinish = [self checkFilters];
    [self popFinishedFilters];
    if (allFinish) {
        [self.taskQueue cancelAllOperations];
        NSLog(@"all decete Finished");
        return;
    }
    
    /// 获取需要被识别的 asset
    PHAsset *asset = [self findNextAsset];
    if (!asset) return;
    
    __weak typeof(self) weakSelf = self;
    JFTPHAssetFaceDetecteOperation *task = [JFTPHAssetFaceDetecteOperation taskWithPHAsset:asset
                                                                               needNetwork:YES
                                                                                   context:weakSelf.context];
    task.startDetecting = ^(PHAsset *asset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.detectingAssets addObject:asset.localIdentifier];
        });
    };
    task.finishDetecting = ^(PHAsset *asset, BOOL faceInside, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.detectingAssets removeObject:asset.localIdentifier];
            weakSelf.assetCache[asset.localIdentifier] = @(faceInside);
            [weakSelf submitNextTask];
        });
    };
    [self.taskQueue addOperation:task];
}

/**
 检查人脸检测状态

 @return 是否完成所有检测 yes means all detection finished
 */
- (BOOL)checkFilters {
    NSMutableArray *finished = @[].mutableCopy;
    /// update asset state in mapping model
    [self.detectingFilters enumerateObjectsUsingBlock:^(JFTAlbumFilterMappingModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray<NSString *> *checkedAssets = @[].mutableCopy;
        [obj.filterAssets enumerateObjectsUsingBlock:^(NSString * _Nonnull localIdentifier, NSUInteger idx, BOOL * _Nonnull stop) {
            NSNumber *checkNum = self.assetCache[localIdentifier];
            if (checkNum) {
                [checkedAssets addObject:localIdentifier];
                if (!checkNum.boolValue) {
                    [obj.assets addObject:localIdentifier];
                }
            }
        }];
        [obj.filterAssets removeObjectsInArray:checkedAssets];/// 移除已经检查过的
    }];
    /// check if filter is finished
    [self.detectingFilters enumerateObjectsUsingBlock:^(JFTAlbumFilterMappingModel * _Nonnull filterModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (filterModel.filterAssets.count == 0 || (filterModel.assets.count >= filterModel.filter.maxCount)) {// Filter 对应的 asset 都已经被检查完毕
            [finished addObject:filterModel];
            return;
        }
    }];
    /// remove finished filter
    [self.detectingFilters removeObjectsInArray:finished];
    [self.finishedFilters addObjectsFromArray:finished];
    /// check if all filter finished
    if (self.filters.count == 0 && self.detectingFilters.count == 0) {
        return YES;
    }
    return NO;
}

- (void)popFinishedFilters {
    [self.finishedFilters enumerateObjectsUsingBlock:^(JFTAlbumFilterMappingModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] postNotificationName:JFTAlbumDetectorNoFacePhotosNotification object:obj];
    }];
    [self.finishedFilters removeAllObjects];
}

- (PHAsset *)findNextAsset {
    /// 调整待检测的 filter 队列
    while (self.detectingFilters.count < maxTaskCount) {
        /// remove filter form filters
        /// until detectingFilters full
        if (self.filters.count) {
            JFTAlbumFilterMappingModel *filter = self.filters.firstObject;
            [self.filters removeObject:filter];
            [self.detectingFilters addObject:filter];
        } else {
            break;
        }
    }
    if (!self.detectingFilters.count) return nil;
    /// 随机从待检测队列中拿一个 asset 出来
    NSUInteger index = rand() % self.detectingFilters.count;
    __block NSString *assetIdentifier = nil;
    [self.detectingFilters[index].filterAssets enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self.detectingAssets containsObject:obj] && !self.assetCache[obj]) {
            assetIdentifier = obj;
            *stop = YES;
        }
    }];
    if (assetIdentifier.length) {
        return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil].firstObject;
    }
    return nil;
}

- (void)finishFaceDetect:(BOOL)faceInside asset:(PHAsset *)asset {
    // 记录识别结果
    self.assetCache[asset.localIdentifier] = @(faceInside);
    // 开启下一个任务
    [self submitNextTask];
}


- (void)generateImagesAsynchronouslyForFilter:(JFTAlbumFilter *)requestedFilter options:(NSDictionary *)options completionHandler:(JFTAlbumDetectorGenerateCompletionHandler)handler {
//    BOOL needNetwork =  options[JFTAlbumDetectorNeedNetworkKey] ? ((NSNumber *)options[JFTAlbumDetectorNeedNetworkKey]).boolValue : YES;
////    NSUInteger maxMatchCount = options[JFTAlbumDetectorMaxMatchNumberKey] ? ((NSNumber *)options[JFTAlbumDetectorMaxMatchNumberKey]).unsignedIntegerValue : 5;
//    NSArray<PHAsset *> *assets = [self assetsMatchFilter:requestedFilter];
//    if (!assets.count) {
//        handler(requestedFilter, nil);
//    }
//
//    JFTPHAssetFaceDetecteTask *task = [JFTPHAssetFaceDetecteTask taskWithPHAsset:assets needNetwork:needNetwork maxMatchCount:maxMatchCount context:self.context];
//    task.cache = self;
//    [task getAssetAsynchronously:^(NSArray<PHAsset *> *assets) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            handler(requestedFilter, assets);
//        });
//    }];
}



//- (void)generateImagesAsynchronouslyForTimes:(NSArray<JFTAlbumFilter *> *)requestedFilters completionHandler:(JFTAlbumDetectorGenerateCompletionHandler)handler {
//    // find all PHAsset first
//    NSLog(@"start photo filter");
//    NSArray <PHAsset *> *assets = [self assetsMatchFilter:requestedFilters];
//    [self deletePhotoWithPeopleInside:assets completionHandler:^(NSArray<PHAsset *> * assetsNoFace) {
//        NSLog(@"assetsNoFace %lu", assetsNoFace.count);
//    }];
//    NSLog(@"end photo filter");
//}


@end
