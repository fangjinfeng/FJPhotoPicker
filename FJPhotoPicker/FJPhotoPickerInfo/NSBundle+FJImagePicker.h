//
//  NSBundle+TZImagePicker.h
//  TZImagePickerController
//
//  Created by fjf on 2017/8/19.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (FJImagePicker)

+ (NSBundle *)fj_imagePickerBundle;

+ (NSString *)fj_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)fj_localizedStringForKey:(NSString *)key;

@end

