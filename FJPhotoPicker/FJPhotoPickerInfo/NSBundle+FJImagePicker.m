//
//  NSBundle+TZImagePicker.m
//  TZImagePickerController
//
//  Created by fjf on 2017/8/19.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import "NSBundle+FJImagePicker.h"
#import "FJImagePickerController.h"

@implementation NSBundle (FJImagePicker)

+ (NSBundle *)fj_imagePickerBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[FJImagePickerController class]];
    NSURL *url = [bundle URLForResource:@"FJPhotoPicker" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

+ (NSString *)fj_localizedStringForKey:(NSString *)key {
    return [self fj_localizedStringForKey:key value:@""];
}

+ (NSString *)fj_localizedStringForKey:(NSString *)key value:(NSString *)value {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language rangeOfString:@"zh-Hans"].location != NSNotFound) {
            language = @"zh-Hans";
        } else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle fj_imagePickerBundle] pathForResource:language ofType:@"lproj"]];
    }
    NSString *value1 = [bundle localizedStringForKey:key value:value table:nil];
    return value1;
}
@end
