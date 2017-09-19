//
//  TestViewController.m
//  TZImagePickerController
//
//  Created by fjf on 2017/9/15.
//  Copyright © 2017年 谭真. All rights reserved.
//

#import "FJDefine.h"
#import "FJAssetModel.h"
#import "FJCollectionCell.h"
#import "TestViewController.h"
#import "FJSelectPhotoTool.h"


@interface TestViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *arrDataSources;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<FJSelectPhotoModel *> *lastSelectMoldels;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCollectionView];
}



- (void)initCollectionView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((width-9)/4, (width-9)/4);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FJCollectionCell" bundle:[NSBundle bundleForClass:[self class]]] forCellWithReuseIdentifier:@"FJCollectionCell"];
}

- (IBAction)btnSelectPhotoPreview:(id)sender
{
    weakify(self);
    [FJSelectPhotoTool selectPhotoWithPhotoType:FJSelectPhotoFromTypeCustomPhotoSheet photoSelectCompletion:^(NSArray * _Nullable photoArray, NSArray * _Nullable photoModelArray) {
        strongify(weakSelf);
        strongSelf.arrDataSources = photoArray;
        strongSelf.lastSelectMoldels = [NSMutableArray arrayWithArray:photoModelArray];
        [strongSelf.collectionView reloadData];
    }];
    
}

- (IBAction)btnSelectPhotoLibrary:(id)sender {
    
    weakify(self);
    [FJSelectPhotoTool selectPhotoWithPhotoType:FJSelectPhotoFromTypeCustomAlbumAndCamera photoSelectCompletion:^(NSArray * _Nullable photoArray, NSArray * _Nullable photoModelArray) {
        strongify(weakSelf);
        strongSelf.arrDataSources = photoArray;
        strongSelf.lastSelectMoldels = [NSMutableArray arrayWithArray:photoModelArray];
        [strongSelf.collectionView reloadData];
    }];
}

- (IBAction)btnSelectSystemPhotoLibrary:(id)sender {
    weakify(self);
    [FJSelectPhotoTool selectPhotoWithPhotoType:FJSelectPhotoFromTypeSystemAlbumAndCamera photoSelectCompletion:^(NSArray * _Nullable photoArray, NSArray * _Nullable photoModelArray) {
        strongify(weakSelf);
        strongSelf.arrDataSources = photoArray;
        strongSelf.lastSelectMoldels = [NSMutableArray arrayWithArray:photoModelArray];
        [strongSelf.collectionView reloadData];
    }];
}


#pragma mark --- delegate method
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FJCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FJCollectionCell" forIndexPath:indexPath];
    cell.btnSelect.hidden = YES;
    cell.imageView.image = _arrDataSources[indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    FJCollectionCell *cell = (FJCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    [ZLShowBigImage showBigImage:cell.imageView];
}



@end
