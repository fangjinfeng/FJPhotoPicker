//
//  ZLDefine.h
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#ifndef FJDefine_h
#define FJDefine_h


#import <UIKit/UIKit.h>
#import "NSBundle+FJImagePicker.h"

// 最大 选择 图片 数
#define kMaxLimitSelectPhotoNum 9
// 每一行 显示 图片 数量
#define kCollectionViewColumnNumber 4

// iPhoneX 状态栏 高度差
#define kTabbarBarHeightGap 34

// iPhoneX 导航栏 高度差
#define kNavigationBarHeightGap 22

// iPhoneX
#define kIPhoneX ([[UIScreen mainScreen] bounds].size.height >= 812.0)

// 状态栏 高度
#define kTabbarHeight  ([[UIScreen mainScreen] bounds].size.height >= 812.0  ?83 : 49)

// 导航栏 高度
#define kNavigationBarHeight     ([[UIScreen mainScreen] bounds].size.height >= 812.0 ? 88 : 64)



// 弱引用
#define weakify(var)   __weak typeof(var) weakSelf = var
// 强引用
#define strongify(var) __strong typeof(var) strongSelf = var

// 屏幕 宽度
#define kScreenWidth      [[UIScreen mainScreen] bounds].size.width
// 屏幕 高度
#define kScreenHeight     [[UIScreen mainScreen] bounds].size.height

#define kRGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define kRGBA(r, g, b, a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

// 按钮 字体 正常 颜色
#define kFJPhotoButtonTitleNormalColor kRGB(31, 185, 34)

// 按钮 字体 不可选中 颜色
#define kFJPhotoButtonTitleDisabledColor kRGBA(31, 185, 34, 0.5)

// 按钮 字体 不可选中 颜色
#define kFJPhotoNavigationBarTintColor kRGB(34, 34, 34)

// 国际化
#define kFJLocalizaedStringForKey(a) [NSBundle fj_localizedStringForKey:a]

///////ZLBigImageCell 不建议设置太大，太大的话会导致图片加载过慢
#define kMaxImageWidth 500

static inline void SetViewWidth (UIView *view, CGFloat width) {
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

static inline CGFloat GetViewWidth (UIView *view) {
    return view.frame.size.width;
}

static inline void SetViewHeight (UIView *view, CGFloat height) {
    CGRect frame = view.frame;
    frame.size.height = height;
    view.frame = frame;
}

static inline CGFloat GetViewHeight (UIView *view) {
    return view.frame.size.height;
}


static inline CGFloat GetMatchValue (NSString *text, CGFloat fontSize, BOOL isHeightFixed, CGFloat fixedValue) {
    CGSize size;
    if (isHeightFixed) {
        size = CGSizeMake(MAXFLOAT, fixedValue);
    } else {
        size = CGSizeMake(fixedValue, MAXFLOAT);
    }
    
    CGSize resultSize;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        //返回计算出的size
        resultSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
    }
    if (isHeightFixed) {
        return resultSize.width;
    } else {
        return resultSize.height;
    }
}

static inline CABasicAnimation * GetPositionAnimation (id fromValue, id toValue, CFTimeInterval duration, NSString *keyPath) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue   = toValue;
    animation.duration = duration;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    //以下两个设置，保证了动画结束后，layer不会回到初始位置
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

static inline CAKeyframeAnimation * GetBtnStatusChangedAnimation() {
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    return animate;
}

#endif /* ZLDefine_h */
