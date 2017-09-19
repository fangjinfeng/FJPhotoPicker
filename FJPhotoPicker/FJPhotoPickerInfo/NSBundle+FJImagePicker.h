//
//  NSBundle+TZImagePicker.h
//  TZImagePickerController
//
//  Created by fjf on 2017/8/19.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (FJImagePicker)

+ (NSBundle *)tz_imagePickerBundle;

+ (NSString *)tz_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)tz_localizedStringForKey:(NSString *)key;

@end

