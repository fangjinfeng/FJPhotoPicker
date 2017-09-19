//
//  FJPhotoPickerController.h
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FJAlbumModel;
@interface FJPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) FJAlbumModel *model;

@end


@interface FJCollectionView : UICollectionView

@end
