//
//  ToastUtils.h
//  vsfa
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ShowToastAtTop(format, ...) \
[FJToastUtils showAtTop:[NSString stringWithFormat:format, ## __VA_ARGS__]]

#define ShowToast(format, ...) \
[FJToastUtils show:[NSString stringWithFormat:format, ## __VA_ARGS__]]

#define ShowToastLongAtTop(format, ...) \
[FJToastUtils showLongAtTop:[NSString stringWithFormat:format, ## __VA_ARGS__]]

#define ShowToastLong(format, ...) \
[FJToastUtils showLong:[NSString stringWithFormat:format, ## __VA_ARGS__]]

@interface FJToastUtils : NSObject

//显示提示视图, 默认显示在屏幕上方，防止被软键盘覆盖，1.5s后自动消失
+ (void)showAtTop:(NSString *)message;

//显示提示视图, 默认显示在屏幕下方，1.5s后自动消失
+ (void)show:(NSString *)message;

//显示提示视图, 默认显示在屏幕上方，防止被软键盘覆盖,3s后自动消失
+ (void)showLongAtTop:(NSString *)message;

//显示提示视图, 默认显示在屏幕下方,3s后自动消失
+ (void)showLong:(NSString *)message;

@end
