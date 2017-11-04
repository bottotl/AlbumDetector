//
//  JFTPhotoPickerViewController.m
//  JFTFaceDetection
//
//  Created by syfll on 2017/10/27.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import "JFTPhotoPickerViewController.h"
#import "JFTPhotoCollectionViewCell.h"
#import "JFTPhotosLoader.h"

@interface JFTPhotoPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
/// UI

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign)   CGFloat           cellWidth;

@property (nonatomic, strong) JFTPhotosLoader *loader;


@property (nonatomic, strong) CIContext *context;

@end

@implementation JFTPhotoPickerViewController

- (instancetype)init {
    if (self = [super init]) {
        _context = [CIContext context];
        
        CGFloat balanceValue = 100;
        NSInteger viewCount = [UIScreen mainScreen].bounds.size.width / balanceValue;
        CGFloat width = [UIScreen mainScreen].bounds.size.width -( viewCount - 1 ) * 10 - 30;
        width = width / viewCount;
        _cellWidth = width;
        _loader = [JFTPhotosLoader new];
    }
    return self;
}

- (void)showNoAuthorizationAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"我要访问你的手机相册" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
#pragma clang diagnostic pop
            
        } else {
            /// 防止警告
            [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    [alert addAction:setting];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    _collectionView.backgroundColor = [UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:1];
    [self.view addSubview:_collectionView];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerClass:[JFTPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    // Do any additional setup after loading the view.
    [self.collectionView reloadData];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    CGFloat margin = 15;
    layout.itemSize = CGSizeMake(self.cellWidth, self.cellWidth);
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    [layout invalidateLayout];
    
}


+ (void)requestAuthorizationWithCompletionBlock:(void(^)(BOOL))completion{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(status == PHAuthorizationStatusAuthorized);
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized);
        });
    }
}


////

#pragma mark - Collection View DataSource & Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//// http://www.jianshu.com/p/8cf7593cc44d 滚动性能：缓存。这个点也可以提升性能。（暂时不考虑添加这个 feature，标记一下）
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JFTPhotoModel *model = self.models[indexPath.row];
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = NO;
    option.networkAccessAllowed = YES;
    option.version = PHImageRequestOptionsVersionCurrent;
    
    CGSize size = CGSizeMake(self.cellWidth * [UIScreen mainScreen].scale, self.cellWidth * [UIScreen mainScreen].scale);
    JFTPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    /// load image
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        model.imageRequestID = [weakSelf.loader requestImageForModel:model targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [weakSelf configCell:cell  indexPath:indexPath image:result info:info];
        }];
    });
    
    return cell;
}

- (void)configCell:(JFTPhotoCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath image:(UIImage *)image info:(NSDictionary *)info {
    JFTPhotoModel *model = self.models[indexPath.row];
    model.image = image;
    model.info = info;
    if (!image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.backgroundColor = [UIColor greenColor];
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.photoPreviewImageView.image = image;
        [cell setNeedsLayout];
    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        NSNumber *fileOrientation = info[@"PHImageFileOrientationKey"];
//        long imageFileOrientation = fileOrientation.longValue;
//        if (model.image.imageOrientation != imageFileOrientation) {
//            NSLog(@"有问题");
//        }
//        if ([self faceInside:[CIImage imageWithCGImage:model.image.CGImage] imageOrientation:model.image.imageOrientation]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                cell.contentView.backgroundColor = [UIColor redColor];
//            });
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                cell.contentView.backgroundColor = [UIColor whiteColor];
//            });
//        }
//    });
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.clickAssetBlock) {
//        self.clickAssetBlock(self.models[indexPath.row].asset);
//    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    JFTPhotoModel *model = self.models[indexPath.row];
    [self.loader cancelRequest:model];
}

- (BOOL)faceInside:(CIImage *)image imageOrientation:(UIImageOrientation)imageOrientation {
    
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:self.context
                                              options:opts];
    
    opts = @{ CIDetectorImageOrientation : [self UIOrientationToCIOrientation:imageOrientation] };
    
    NSArray *features = [detector featuresInImage:image options:opts];
    if (features.count > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - face detection

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
