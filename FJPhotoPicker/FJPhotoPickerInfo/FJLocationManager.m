//
//  TZLocationManager.m
//  TZImagePickerController
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//  定位管理类

#import "FJLocationManager.h"
#import "FJImagePickerController.h"

@interface FJLocationManager ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
/// 定位成功的回调block
@property (nonatomic, copy) void (^successBlock)(CLLocation *location,CLLocation *oldLocation);
/// 编码成功的回调block
@property (nonatomic, copy) void (^geocodeBlock)(NSArray *geocodeArray);
/// 定位失败的回调block
@property (nonatomic, copy) void (^failureBlock)(NSError *error);
@end

@implementation FJLocationManager

+ (instancetype)manager {
    static FJLocationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.locationManager = [[CLLocationManager alloc] init];
        manager.locationManager.delegate = manager;
        if (iOS8Later) {
            [manager.locationManager requestWhenInUseAuthorization];
        }
    });
    return manager;
}

- (void)startLocation {
    [self startLocationWithSuccessBlock:nil failureBlock:nil geocoderBlock:nil];
}

- (void)startLocationWithSuccessBlock:(void (^)(CLLocation *location,CLLocation *oldLocation))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    [self startLocationWithSuccessBlock:successBlock failureBlock:failureBlock geocoderBlock:nil];
}

- (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock {
    [self startLocationWithSuccessBlock:nil failureBlock:nil geocoderBlock:geocoderBlock];
}

- (void)startLocationWithSuccessBlock:(void (^)(CLLocation *location,CLLocation *oldLocation))successBlock failureBlock:(void (^)(NSError *error))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock {
    [self.locationManager startUpdatingLocation];
    _successBlock = successBlock;
    _geocodeBlock = geocoderBlock;
    _failureBlock = failureBlock;
}

#pragma mark - CLLocationManagerDelegate

/// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    
    if (_successBlock) {
        _successBlock(newLocation,oldLocation);
    }
    
    if (_geocodeBlock) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error) {
            _geocodeBlock(array);
        }];
    }
}

/// 定位失败回调方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败, 错误: %@",error);
    switch([error code]) {
        case kCLErrorDenied: { // 用户禁止了定位权限
            
        } break;
        default: break;
    }
    if (_failureBlock) {
        _failureBlock(error);
    }
}

@end
