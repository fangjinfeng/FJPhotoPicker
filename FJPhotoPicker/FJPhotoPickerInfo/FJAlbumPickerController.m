//
//  FJAlbumPickerController.m
//  TZImagePickerController
//
//  Created by fjf on 2017/9/18.
//  Copyright © 2017年 谭真. All rights reserved.
//

#import "FJAssetCell.h"
#import "UIView+FJLayout.h"
#import "FJImageManager.h"
#import "FJPhotoPickerController.h"
#import "FJImagePickerController.h"
#import "FJAlbumPickerController.h"

@interface FJAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;
}
@property (nonatomic, strong) NSMutableArray *albumArr;
@property (assign, nonatomic) BOOL isFirstAppear;
@end

@implementation FJAlbumPickerController

#pragma mark --- life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstAppear = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:imagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
    [imagePickerVc hideProgressHUD];
    if (imagePickerVc.allowTakePicture) {
        self.navigationItem.title = [NSBundle fj_localizedStringForKey:@"FJPhotoBrowserPhotoText"];
    } else if (imagePickerVc.allowPickingVideo) {
        self.navigationItem.title = [NSBundle fj_localizedStringForKey:@"FJPhotoBrowserVideoText"];
    }
    
    // 1.6.10 采用微信的方式，只在相册列表页定义backBarButtonItem为返回，其余的顺系统的做法
    if (self.isFirstAppear) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserBackText"] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.isFirstAppear = NO;
    }
    
    [self configTableView];
}


#pragma mark --- private method

- (void)configTableView {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
        [[FJImageManager manager] getAllAlbums:imagePickerVc.allowPickingVideo allowPickingImage:imagePickerVc.allowPickingImage completion:^(NSArray<FJAlbumModel *> *models) {
            _albumArr = [NSMutableArray arrayWithArray:models];
            for (FJAlbumModel *albumModel in _albumArr) {
                albumModel.selectedModels = imagePickerVc.selectedModels;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_tableView) {
                    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                    _tableView.rowHeight = 70;
                    _tableView.tableFooterView = [[UIView alloc] init];
                    _tableView.dataSource = self;
                    _tableView.delegate = self;
                    [_tableView registerClass:[FJAlbumCell class] forCellReuseIdentifier:@"FJAlbumCell"];
                    [self.view addSubview:_tableView];
                } else {
                    [_tableView reloadData];
                }
            });
        }];
    });
}

- (void)dealloc {
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat top = 0;
    CGFloat tableViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.fj_height;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (iOS7Later && !isStatusBarHidden) top += 20;
        tableViewHeight = self.view.fj_height - top;
    } else {
        tableViewHeight = self.view.fj_height;
    }
    _tableView.frame = CGRectMake(0, top, self.view.fj_width, tableViewHeight);
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FJAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FJAlbumCell"];
    FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
    cell.selectedCountButton.backgroundColor = imagePickerVc.oKButtonTitleColorNormal;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FJPhotoPickerController *photoPickerVc = [[FJPhotoPickerController alloc] init];
    photoPickerVc.columnNumber = self.columnNumber;
    FJAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.model = model;
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma clang diagnostic pop

@end
