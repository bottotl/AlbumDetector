//
//  JFTAlbumSearchEntity.h
//  JFTAlbumDetector
//
//  Created by syfll on 2017/10/31.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface JFTAlbumFilter : NSObject<NSCopying>

@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) double locationTolerance;// 单位 km

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;//

@property (nonatomic, assign) NSUInteger maxCount;

@end
