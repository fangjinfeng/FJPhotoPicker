//
//  ZLCollectionCell.h
//  多选相册照片
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
// 相册 小图 浏览 cell
@interface FJCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;

@end
