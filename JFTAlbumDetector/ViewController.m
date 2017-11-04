//
//  ViewController.m
//  JFTAlbumDetector
//
//  Created by syfll on 2017/10/31.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import "ViewController.h"
#import "JFTAlbumDetector.h"
#import "JFTPhotoPickerViewController.h"

@interface ViewController ()
@property (nonatomic, strong) JFTAlbumDetector *detector;
@property (nonatomic, strong) NSArray<JFTPhotoModel *> *models;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.detector = [[JFTAlbumDetector alloc] init];
    
}

- (IBAction)detectPhoto:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectPhotos:) name:JFTAlbumDetectorNoFacePhotosNotification object:nil];
    JFTAlbumFilter *filter = [self createFilter];
    self.startTime = [NSDate dateWithTimeIntervalSinceNow:0];
    [self.detector detecteImagesAsynchronouslyForFilter:@[filter] options:nil];
    
}

- (IBAction)showPhotos:(id)sender {
    JFTPhotoPickerViewController *vc = [[JFTPhotoPickerViewController alloc] init];
    vc.models = self.models;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)detectPhotos:(NSNotification *)notificaiton {
    self.endTime = [NSDate dateWithTimeIntervalSinceNow:0];
    NSLog(@"detect cost time:%@", @([self.endTime timeIntervalSinceDate:self.startTime]));
    JFTAlbumFilterMappingModel *model = notificaiton.object;
    if (model) {
        NSLog(@"%@", model);
    } else {
        NSLog(@"model nil?");
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:model.assets options:nil];
    NSMutableArray *models = @[].mutableCopy;
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JFTPhotoModel *model = [JFTPhotoModel new];
        model.asset = obj;
        [models addObject:model];
    }];
    self.models = models;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (JFTAlbumFilter *)createFilter {
    JFTAlbumFilter *filter = [[JFTAlbumFilter alloc] init];
    filter.startDate = [NSDate dateWithTimeIntervalSince1970:0];
    filter.endDate = [NSDate dateWithTimeIntervalSinceNow:0];
    filter.locationTolerance = 10000000000;
    filter.location = (CLLocationCoordinate2D){31.221412, 121.426711};
    filter.maxCount = 5;
    return filter;
}

@end
