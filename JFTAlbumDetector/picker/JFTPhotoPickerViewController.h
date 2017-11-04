//
//  JFTPhotoPickerViewController.h
//  JFTFaceDetection
//
//  Created by syfll on 2017/10/27.
//  Copyright © 2017年 syfll. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFTPhotosLoader.h"

@interface JFTPhotoPickerViewController : UIViewController
@property (nonatomic, strong) NSArray <JFTPhotoModel *> *models;
@end
