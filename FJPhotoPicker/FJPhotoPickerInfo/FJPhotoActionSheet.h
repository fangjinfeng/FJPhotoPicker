//
//  FJPhotoActionSheet.h
//  多选相册照片
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PHAsset;

@interface FJPhotoActionSheet : UIView

@property (nonatomic, weak) UIViewController *sender;

/** 最大选择数 default is 10 */
@property (nonatomic, assign) NSInteger maxSelectCount;
/** 是否 隐藏 原图 default is NO */
@property (nonatomic, assign) BOOL      isHideOriginal;
/** 导航栏 背景颜色 default kRGB(19, 153, 231)*/
@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;

/** 预览图最大显示数 default is 20 */
@property (nonatomic, assign) NSInteger maxPreviewCount;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (void)showWithSender:(UIViewController *)sender
               animate:(BOOL)animate
        lastSelectPhotoModels:(NSArray<PHAsset *> * _Nullable)lastSelectPhotoModels
            completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<PHAsset *> *selectPhotoModels))completion NS_DEPRECATED(2.0, 2.0, 2.0, 8.0, "Use - showPreviewPhotoWithSender:animate:lastSelectPhotoModels:completion:");

/**
 * @brief 显示多选照片视图，带预览效果
 * @param sender
 *              调用该控件的视图控制器
 * @param animate
 *              是否显示动画效果
 * @param lastSelectPhotoModels
 *              已选择的PHAsset，再次调用"showWithSender:animate:lastSelectPhotoModels:completion:"方法之前，可以把上次回调中selectPhotoModels赋值给该属性，便可实现记录上次选择照片的功能，若不需要记录上次选择照片的功能，则该值传nil即可
 * @param completion
 *              完成回调
 */
- (void)showPreviewPhotoWithSender:(UIViewController *)sender
                 animate:(BOOL)animate
   lastSelectPhotoModels:(NSArray<PHAsset *> * _Nullable)lastSelectPhotoModels
              completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<PHAsset *> *selectPhotoModels))completion;

/**
 * @brief 显示多选照片视图，直接进入相册选择界面
 * @param sender
 *              调用该控件的视图控制器
 * @param lastSelectPhotoModels
 *              已选择的PHAsset，再次调用"showWithSender:animate:lastSelectPhotoModels:completion:"方法之前，可以把上次回调中selectPhotoModels赋值给该属性，便可实现记录上次选择照片的功能，若不需要记录上次选择照片的功能，则该值传nil即可
 * @param completion
 *              完成回调
 */
- (void)showPhotoLibraryWithSender:(UIViewController *)sender
             lastSelectPhotoModels:(NSArray<PHAsset *> * _Nullable)lastSelectPhotoModels
                        completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<PHAsset *> *selectPhotoModels))completion;

/**
 * @brief 显示单张照片视图，直接进入系统相册选择界面
 * @param sender
 *              调用该控件的视图控制器
 * @param lastSelectPhotoModels
 *              已选择的PHAsset，再次调用"showWithSender:animate:lastSelectPhotoModels:completion:"方法之前，可以把上次回调中selectPhotoModels赋值给该属性，便可实现记录上次选择照片的功能，若不需要记录上次选择照片的功能，则该值传nil即可
 * @param completion
 *              完成回调
 */
- (void)showSystemPhotoLibraryWithSender:(UIViewController *)sender
             lastSelectPhotoModels:(NSArray<PHAsset *> * _Nullable)lastSelectPhotoModels
                        completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<PHAsset *> *selectPhotoModels))completion;

// 手机 相机
- (void)showSystemCamaraWithSender:(UIViewController *)sender
             lastSelectPhotoModels:(NSArray<PHAsset *> * _Nullable)lastSelectPhotoModels
                        completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<PHAsset *> *selectPhotoModels))completion;

NS_ASSUME_NONNULL_END

@end



@interface CustomerNavgationController : UINavigationController

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

@end
