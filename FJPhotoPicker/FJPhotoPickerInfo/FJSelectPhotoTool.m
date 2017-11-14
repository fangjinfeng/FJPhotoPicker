//
//  FJSelectPhotoTool.m
//  FJPhotoBrowser
//
//  Created by fjf on 2017/8/19.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import "FJDefine.h"
#import "FJPhotoActionSheet.h"
#import "FJSelectPhotoTool.h"
#import "UIViewController+FJCurrentViewController.h"

@implementation FJSelectPhotoTool

// 根据 类型 选择 相册
+ (void)selectPhotoWithPhotoType:(FJSelectPhotoFromType)selectPhotoType photoSelectCompletion:(FJPhotoSelectCompletion)photoSelectCompletion {
    
     weakify(self);
    UIViewController *tmpCurrentViewController = [UIViewController fj_currentViewController];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *albumPicker = [UIAlertAction actionWithTitle:kFJLocalizaedStringForKey(@"FJPhotoBrowserSelectFromPhoneAlbumText") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        FJPhotoActionSheet *actionSheet = [[FJPhotoActionSheet alloc] init];
        //设置照片最大选择数
        actionSheet.maxSelectCount = 1;
        weakify(self);
        [actionSheet showSystemPhotoLibraryWithSender:tmpCurrentViewController lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<FJSelectPhotoModel *> * _Nonnull selectPhotoModels) {
            strongify(weakSelf);
            if (strongSelf) {
                photoSelectCompletion(selectPhotos, selectPhotoModels);
            }
        }];
    }];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:kFJLocalizaedStringForKey(@"FJPhotoBrowserCameraText") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        FJPhotoActionSheet *actionSheet = [[FJPhotoActionSheet alloc] init];
        [actionSheet showSystemCamaraWithSender:tmpCurrentViewController lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<FJSelectPhotoModel *> * _Nonnull selectPhotoModels) {
            strongify(weakSelf);
            if (strongSelf) {
               photoSelectCompletion(selectPhotos, selectPhotoModels);
            }
        }];
    }];
    
    UIAlertAction *takeCustomPhoto = [UIAlertAction actionWithTitle:kFJLocalizaedStringForKey(@"FJPhotoBrowserSelectFromPhoneAlbumText") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        FJPhotoActionSheet *actionSheet = [[FJPhotoActionSheet alloc] init];
        //设置照片最大选择数
        actionSheet.maxSelectCount = 1;
        weakify(self);
        [actionSheet showPhotoLibraryWithSender:tmpCurrentViewController lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<FJSelectPhotoModel *> * _Nonnull selectPhotoModels) {
            strongify(weakSelf);
            if (strongSelf) {
                photoSelectCompletion(selectPhotos, selectPhotoModels);
            }
        }];
    
    }];
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:kFJLocalizaedStringForKey(@"FJPhotoBrowserCancelText") style:UIAlertActionStyleCancel handler:nil];
    
     // 来自 手机 系统 相册 和 相机
    if (selectPhotoType == FJSelectPhotoFromTypeSystemAlbumAndCamera) {
        [alertController addAction:takePhoto];
        [alertController addAction:albumPicker];
        [alertController addAction:cancel];
        [tmpCurrentViewController.navigationController presentViewController:alertController animated:YES completion:nil];
    }
     // 来自 自定义 相册 和 相机
    else if(selectPhotoType == FJSelectPhotoFromTypeCustomAlbumAndCamera) {
        [alertController addAction:takePhoto];
        [alertController addAction:takeCustomPhoto];
        [alertController addAction:cancel];
        [tmpCurrentViewController.navigationController presentViewController:alertController animated:YES completion:nil];
    }
     // 来自 自定义 photo sheet
    else if(selectPhotoType == FJSelectPhotoFromTypeCustomPhotoSheet){
        FJPhotoActionSheet *actionSheet = [[FJPhotoActionSheet alloc] init];
        //设置照片最大选择数
        actionSheet.maxSelectCount = 9;
        //设置照片最大预览数
        actionSheet.maxPreviewCount = 30;
        weakify(self);
        [actionSheet showPreviewPhotoWithSender:tmpCurrentViewController animate:YES lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<FJSelectPhotoModel *> * _Nonnull selectPhotoModels) {
            strongify(weakSelf);
            if (strongSelf) {
                 photoSelectCompletion(selectPhotos, selectPhotoModels);
            }
        }];
    }
  
}



@end
