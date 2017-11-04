//
//  JFTPhotosLoader.h
//  JFTFaceDetection
//
//  Created by syfll on 2017/10/27.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFTPhotoModel : NSObject
@property (nonatomic, strong) PHAsset  *asset;
@property (nonatomic, weak) UIImage  *image;
@property (nonatomic, strong, nullable) NSValue *imageRequestID;///< int32_t
@property (nonatomic, strong) NSDictionary *info;
@end

@interface JFTPhotosLoader : NSObject

- (NSArray <JFTPhotoModel *> *)fetchModels;
- (NSValue *)requestImageForModel:(JFTPhotoModel *)model
                       targetSize:(CGSize)targetSize
                      contentMode:(PHImageContentMode)contentMode
                          options:(PHImageRequestOptions *)options
                    resultHandler:(void (^)(UIImage * _Nullable, NSDictionary * _Nullable))resultHandler;

- (void)cancelRequest:(JFTPhotoModel *)model;

@end
NS_ASSUME_NONNULL_END
