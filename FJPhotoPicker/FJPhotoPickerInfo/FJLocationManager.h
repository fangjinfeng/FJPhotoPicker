//
//  FJLocationManager.h
//  FJImagePickerController
//
//  Created by fjf on 2017/8/19.
//  Copyright © 2017年 fjf. All rights reserved.
//  定位管理类


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FJLocationManager : NSObject

+ (instancetype)manager;

/// 开始定位
- (void)startLocation;
- (void)startLocationWithSuccessBlock:(void (^)(CLLocation *location,CLLocation *oldLocation))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock;
- (void)startLocationWithSuccessBlock:(void (^)(CLLocation *location,CLLocation *oldLocation))successBlock failureBlock:(void (^)(NSError *error))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock;

@end

