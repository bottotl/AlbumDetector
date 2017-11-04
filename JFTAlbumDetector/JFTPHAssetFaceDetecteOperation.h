//
//  JFTPHAssetFaceDetecteTask.h
//  JFTAlbumDetector
//
//  Created by syfll on 2017/11/1.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset, CIContext;
@interface JFTPHAssetFaceDetecteOperation : NSOperation

+ (instancetype)taskWithPHAsset:(PHAsset *)asset needNetwork:(BOOL)networkNeed context:(CIContext *)context;
@property (nonatomic, copy) void(^startDetecting)(PHAsset *);
@property (nonatomic, copy) void(^finishDetecting)(PHAsset *asset, BOOL faceInside, NSError *error);
@end
