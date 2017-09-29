//
//  UIView+Layout.h
//
//  Created by fjf on 2017/8/19.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TZOscillatoryAnimationToBigger,
    TZOscillatoryAnimationToSmaller,
} TZOscillatoryAnimationType;

@interface UIView (FJLayout)

@property (nonatomic) CGFloat fj_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat fj_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat fj_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat fj_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat fj_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat fj_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat fj_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat fj_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint fj_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  fj_size;        ///< Shortcut for frame.size.

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(TZOscillatoryAnimationType)type;

@end
