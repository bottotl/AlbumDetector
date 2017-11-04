//
//  JFTPHAssetFaceDetecteTask.m
//  JFTAlbumDetector
//
//  Created by syfll on 2017/11/1.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import "JFTPHAssetFaceDetecteOperation.h"
#import <Photos/Photos.h>

static CGSize const faceDetectImageSize = {200, 200};

@interface JFTPHAssetFaceDetecteOperation ()
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL networkNeed;
@property (nonatomic, strong) CIContext *context;
@end

@implementation JFTPHAssetFaceDetecteOperation

+ (instancetype)taskWithPHAsset:(PHAsset *)asset needNetwork:(BOOL)networkNeed context:(CIContext *)context {
    JFTPHAssetFaceDetecteOperation *task = [[JFTPHAssetFaceDetecteOperation alloc] init];
    task.asset = asset;
    task.networkNeed = networkNeed;
    task.context = context;
    return task;
}

- (void)main {
    if (![self isCancelled]) {
        if (!self.finishDetecting) {
            [self finish:NO error:nil];
            return;
        }
        if (self.startDetecting) {
            self.startDetecting(self.asset);
        }
        [self detectFaceWithAsset:self.asset];
    }
}

- (void)detectFaceWithAsset:(PHAsset *)asset {
    __weak typeof(self) weakSelf = self;
    [self fetchImage:asset resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        if (![weakSelf isCancelled]) {
            [weakSelf detectFaceWithAsset:asset andImage:image];
        }
    }];
}

- (void)finishWithError:(NSError *)error {
//    [self setValue:@(YES) forKey:@"will"];
    NSLog(@"error happen%@", error ?: @"");
    [self finish:NO error:error];
}

- (void)finish:(BOOL)faceInside error:(NSError *)error {
    if ([self isCancelled]) {
        self.finishDetecting = nil;
        return;
    }
    if (self.finishDetecting) {
        self.finishDetecting(self.asset, faceInside, error);
    }
    self.finishDetecting = nil;
}

- (void)detectFaceWithAsset:(PHAsset *)asset andImage:(UIImage *)image {
    if (!asset || !image || !image.CGImage) {
        NSString *description = [NSString stringWithFormat:@"asset:%@\n image:%@\n CGImage:%@\n", (asset ?: @"null"), (image ?: @"null"), ((__bridge id)image.CGImage ?: @"null")];
        NSDictionary *info = @{NSLocalizedDescriptionKey : description};
        [self finishWithError:[NSError errorWithDomain:@"face detect error" code:404 userInfo:info]];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self faceInside:[CIImage imageWithCGImage:image.CGImage] imageOrientation:image.imageOrientation handler:^(BOOL haveFace) {
        [weakSelf finish:haveFace error:nil];
    }];
}

#pragma mark - PHAsset

- (void)fetchImage:(PHAsset *)asset resultHandler:(void (^)(UIImage * _Nullable, NSDictionary * _Nullable))resultHandler  {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    options.networkAccessAllowed = NO;
    options.version = PHImageRequestOptionsVersionCurrent;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset targetSize:faceDetectImageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * __nullable result, NSDictionary * __nullable info) {
        resultHandler(result, info);
    }];
}

#pragma mark - face detection

- (void)faceInside:(CIImage *)image imageOrientation:(UIImageOrientation)imageOrientation handler:(void(^)(BOOL haveFace))handler {
    if (!handler) return;
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:self.context
                                              options:opts];
    
    opts = @{ CIDetectorImageOrientation : [self UIOrientationToCIOrientation:imageOrientation] };
    
    NSArray *features = [detector featuresInImage:image options:opts];
    if (features.count > 0) {
        NSLog(@"find face");
        handler(YES);
    }
    NSLog(@"no face");
    handler(NO);
}

/// see http://www.tanhao.me/pieces/1019.html/
- (NSNumber *)UIOrientationToCIOrientation:(UIImageOrientation)imageOrientation {
    switch (imageOrientation) {
        case UIImageOrientationUp:
            return @(1);
            break;
        case UIImageOrientationDown:
            return @(3);
            break;
        case UIImageOrientationLeft:
            return @(8);
            break;
        case UIImageOrientationRight:
            return @(6);
            break;
        case UIImageOrientationUpMirrored:
            return @(2);
            break;
        case UIImageOrientationDownMirrored:
            return @(4);
            break;
        case UIImageOrientationLeftMirrored:
            return @(5);
            break;
        case UIImageOrientationRightMirrored:
            return @(7);
            break;
    }
}


@end
