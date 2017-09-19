//
//  FJSelectPhotoTool.h
//  FJPhotoBrowser
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//


#import <UIKit/UIKit.h>

@class FJSelectPhotoModel;
typedef void(^FJPhotoSelectCompletion)(NSArray * _Nullable photoArray, NSArray * _Nullable photoModelArray);



@interface FJSelectPhotoTool : UIView
typedef NS_ENUM(NSInteger, FJSelectPhotoFromType) {
    // 来自 手机 系统 相册 和 相机
    FJSelectPhotoFromTypeSystemAlbumAndCamera = 1,
    // 来自 自定义 相册 和 相机
    FJSelectPhotoFromTypeCustomAlbumAndCamera = 2,
    // 来自 自定义 photo sheet
    FJSelectPhotoFromTypeCustomPhotoSheet = 3,
};

// 根据 类型 选择 相册
+ (void)selectPhotoWithPhotoType:(FJSelectPhotoFromType)selectPhotoType photoSelectCompletion:(FJPhotoSelectCompletion _Nullable )photoSelectCompletion;
@end
