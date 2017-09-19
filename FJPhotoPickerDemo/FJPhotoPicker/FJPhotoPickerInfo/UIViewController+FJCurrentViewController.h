//
//  UIViewController+FJCurrentViewController.h
//  FJPhotoBrowser
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FJCurrentViewController)
// 查找 当前 控制器
+ (UIViewController *)fj_currentViewController;
@end
