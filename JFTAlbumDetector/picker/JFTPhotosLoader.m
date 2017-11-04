//
//  JFTPhotosLoader.m
//  JFTFaceDetection
//
//  Created by syfll on 2017/10/27.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import "JFTPhotosLoader.h"
@interface JFTPhotosLoader ()
@end

@implementation JFTPhotosLoader

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSArray <JFTPhotoModel *> *)fetchModels {
    NSMutableArray <JFTPhotoModel *> *returnVideos = @[].mutableCopy;
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    NSLog(@"smartAlbums, count%lu", assetsFetchResults.count);
    [assetsFetchResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JFTPhotoModel *model = [JFTPhotoModel new];
        model.asset = obj;
        model.imageRequestID = nil;
        [returnVideos addObject:model];
    }];
    
    return returnVideos.copy;
}

- (NSValue *)requestImageForModel:(JFTPhotoModel *)model
                       targetSize:(CGSize)targetSize
                      contentMode:(PHImageContentMode)contentMode
                          options:(PHImageRequestOptions *)options
                    resultHandler:(void (^)(UIImage * _Nullable, NSDictionary * _Nullable))resultHandler {
    if (!resultHandler) return nil;
    if (!options) {
        options = [PHImageRequestOptions new];
        options.synchronous = YES;
        options.networkAccessAllowed = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
    }
    PHImageManager *manager = [PHImageManager defaultManager];
    PHImageRequestID imageRequesetID = [manager requestImageForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * __nullable result, NSDictionary * __nullable info) {
        resultHandler(result, info);
    }];
    model.imageRequestID = @(imageRequesetID);
    return model.imageRequestID;
}

- (void)cancelRequest:(JFTPhotoModel *)model {
    if (model.imageRequestID) {
        int32_t requestID;
        [model.imageRequestID getValue:&requestID];
        [[PHImageManager defaultManager] cancelImageRequest:requestID];
        model.imageRequestID = nil;
    }
}

@end


@implementation JFTPhotoModel
@end
