//
//  JFTPHAssetDetectorCacheProtocol.h
//  JFTAlbumDetector
//
//  Created by syfll on 2017/11/1.
//  Copyright © 2017年 syfll. All rights reserved.
//

#ifndef JFTPHAssetDetectorCacheProtocol_h
#define JFTPHAssetDetectorCacheProtocol_h

#import <Photos/Photos.h>
@protocol JFTPHAssetDetectorCacheProtocol <NSObject>

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *assetCache;///< if true means face inside

@end
#endif /* JFTPHAssetDetectorCacheProtocol_h */
