//
//  TZPhotoPickerController.m
//  TZImagePickerController
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import "FJPhotoPickerController.h"
#import "FJImagePickerController.h"
#import "FJPhotoPreviewController.h"
#import "FJDefine.h"
#import "FJAssetCell.h"
#import "FJAssetModel.h"
#import "UIView+FJLayout.h"
#import "FJImageManager.h"
#import "FJVideoPlayerController.h"
#import "FJGifPhotoPreviewController.h"
#import "FJLocationManager.h"

@interface FJPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate> {
    NSMutableArray *_models;
    
    UIView *_bottomToolBar;
    UIButton *_previewButton;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    UIView *_divideLine;
    
    BOOL _shouldScrollToBottom;
    BOOL _showTakePhotoBtn;
    
    CGFloat _offsetItemCount;
}
@property CGRect previousPreheatRect;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) FJCollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (strong, nonatomic) CLLocation *location;
@end

static CGSize AssetGridThumbnailSize;
static CGFloat itemMargin = 5;

@implementation FJPhotoPickerController




#pragma mark --- life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    _isSelectOriginalPhoto = tzImagePickerVc.isSelectOriginalPhoto;
    _shouldScrollToBottom = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:tzImagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:tzImagePickerVc action:@selector(cancelButtonClick)];
    _showTakePhotoBtn = (([[FJImageManager manager] isCameraRollAlbum:_model.name]) && tzImagePickerVc.allowTakePicture);
    // [self resetCachedAssets];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    tzImagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600) {
        scale = 1.0;
    }
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    if (!_models) {
        [self fetchAssetModels];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (iOS8Later) {
        // [self updateCachedAssets];
    }
}

#pragma mark --- system method

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark --- private method

// 获取 asset model 数据
- (void)fetchAssetModels {
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    if (_isFirstAppear) {
        [tzImagePickerVc showProgressHUD];
    }
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        if (!tzImagePickerVc.sortAscendingByModificationDate && _isFirstAppear && iOS8Later) {
            [[FJImageManager manager] getCameraRollAlbum:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(FJAlbumModel *model) {
                _model = model;
                _models = [NSMutableArray arrayWithArray:_model.models];
                [self initSubviews];
            }];
        } else {
            if (_showTakePhotoBtn || !iOS8Later || _isFirstAppear) {
                [[FJImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(NSArray<FJAssetModel *> *models) {
                    _models = [NSMutableArray arrayWithArray:models];
                    [self initSubviews];
                }];
            } else {
                _models = [NSMutableArray arrayWithArray:_model.models];
                [self initSubviews];
            }
        }
    });
}

- (void)initSubviews {
    dispatch_async(dispatch_get_main_queue(), ^{
        FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
        [tzImagePickerVc hideProgressHUD];
        
        [self checkSelectedModels];
        [self configCollectionView];
        [self configBottomToolBar];
        
        [self scrollCollectionViewToBottom];
    });
}



- (void)configCollectionView {
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[FJCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceHorizontal = NO;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _collectionView.contentInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
    
    if (_showTakePhotoBtn && tzImagePickerVc.allowTakePicture ) {
        _collectionView.contentSize = CGSizeMake(self.view.fj_width, ((_model.count + self.columnNumber) / self.columnNumber) * self.view.fj_width);
    } else {
        _collectionView.contentSize = CGSizeMake(self.view.fj_width, ((_model.count + self.columnNumber - 1) / self.columnNumber) * self.view.fj_width);
    }
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[FJAssetCell class] forCellWithReuseIdentifier:@"FJAssetCell"];
    [_collectionView registerClass:[FJAssetCameraCell class] forCellWithReuseIdentifier:@"FJAssetCameraCell"];
}

- (void)configBottomToolBar {
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    if (!tzImagePickerVc.showSelectBtn) return;

    _bottomToolBar = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat rgb = 253 / 255.0;
    _bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];

    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitle:tzImagePickerVc.previewBtnTitleStr forState:UIControlStateNormal];
    [_previewButton setTitle:tzImagePickerVc.previewBtnTitleStr forState:UIControlStateDisabled];
    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.enabled = tzImagePickerVc.selectedModels.count;
    
    if (tzImagePickerVc.allowPickingOriginalPhoto) {
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originalPhotoButton setTitle:tzImagePickerVc.fullImageBtnTitleStr forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:tzImagePickerVc.fullImageBtnTitleStr forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:tzImagePickerVc.photoOriginDefImageName] forState:UIControlStateNormal];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:tzImagePickerVc.photoOriginSelImageName] forState:UIControlStateSelected];
        _originalPhotoButton.selected = _isSelectOriginalPhoto;
        _originalPhotoButton.enabled = tzImagePickerVc.selectedModels.count > 0;
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:16];
        _originalPhotoLabel.textColor = [UIColor blackColor];
        if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
    }
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:tzImagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
    [_doneButton setTitle:tzImagePickerVc.doneBtnTitleStr forState:UIControlStateDisabled];
    [_doneButton setTitleColor:tzImagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_doneButton setTitleColor:tzImagePickerVc.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
    _doneButton.enabled = tzImagePickerVc.selectedModels.count || tzImagePickerVc.alwaysEnableDoneBtn;
    
    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedFromMyBundle:tzImagePickerVc.photoNumberIconImageName]];
    _numberImageView.hidden = tzImagePickerVc.selectedModels.count <= 0;
    _numberImageView.backgroundColor = [UIColor clearColor];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",tzImagePickerVc.selectedModels.count];
    _numberLabel.hidden = tzImagePickerVc.selectedModels.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    
    _divideLine = [[UIView alloc] init];
    CGFloat rgb2 = 222 / 255.0;
    _divideLine.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    
    [_bottomToolBar addSubview:_divideLine];
    [_bottomToolBar addSubview:_previewButton];
    [_bottomToolBar addSubview:_doneButton];
    [_bottomToolBar addSubview:_numberImageView];
    [_bottomToolBar addSubview:_numberLabel];
    [self.view addSubview:_bottomToolBar];
    [self.view addSubview:_originalPhotoButton];
    [_originalPhotoButton addSubview:_originalPhotoLabel];
}

#pragma mark - Layout

- (CGFloat)bottomToolBarHeight {
    CGFloat bottomToolBarHeight = 50.0f;
    if (kFJPhotoIPhoneX) {
        bottomToolBarHeight += kFJPhotoTabbarBarHeightGap;
    }
    return bottomToolBarHeight;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    
    CGFloat top = 0;
    CGFloat collectionViewHeight = 0;
    CGFloat bottomToolBarHeight = [self bottomToolBarHeight];
    CGFloat naviBarHeight = kFJPhotoNavigationBarHeight;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (iOS7Later && isStatusBarHidden) top -= 20;
        collectionViewHeight = tzImagePickerVc.showSelectBtn ? self.view.fj_height - bottomToolBarHeight - top : self.view.fj_height - top;;
    } else {
        collectionViewHeight = tzImagePickerVc.showSelectBtn ? self.view.fj_height - bottomToolBarHeight : self.view.fj_height;
    }
    _collectionView.frame = CGRectMake(0, top, self.view.fj_width, collectionViewHeight);
    CGFloat itemWH = (self.view.fj_width - (self.columnNumber + 1) * itemMargin) / self.columnNumber;
    _layout.itemSize = CGSizeMake(itemWH, itemWH);
    _layout.minimumInteritemSpacing = itemMargin;
    _layout.minimumLineSpacing = itemMargin;
    [_collectionView setCollectionViewLayout:_layout];
    if (_offsetItemCount > 0) {
        CGFloat offsetY = _offsetItemCount * (_layout.itemSize.height + _layout.minimumLineSpacing);
        [_collectionView setContentOffset:CGPointMake(0, offsetY)];
    }
    
    CGFloat yOffset = 0;
    if (!self.navigationController.navigationBar.isHidden) {
        yOffset = self.view.fj_height - bottomToolBarHeight;
    } else {
        CGFloat navigationHeight = naviBarHeight;
        if (iOS7Later) navigationHeight += 20;
        yOffset = self.view.fj_height - bottomToolBarHeight - navigationHeight;
    }
    
   
    _bottomToolBar.frame = CGRectMake(0, yOffset, self.view.fj_width, bottomToolBarHeight);
    CGFloat previewWidth = [tzImagePickerVc.previewBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 2;
    if (!tzImagePickerVc.allowPreview) {
        previewWidth = 0.0;
    }
    _previewButton.frame = CGRectMake(10, 3, previewWidth, 44);
    _previewButton.fj_width = !tzImagePickerVc.showSelectBtn ? 0 : previewWidth;
    if (tzImagePickerVc.allowPickingOriginalPhoto) {
        CGFloat fullImageWidth = [tzImagePickerVc.fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
        _originalPhotoButton.frame = CGRectMake(CGRectGetMaxX(_previewButton.frame), self.view.fj_height - bottomToolBarHeight, fullImageWidth + 56, 50);
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 46, 0, 80, 50);
    }
    _doneButton.frame = CGRectMake(self.view.fj_width - 44 - 12, 3, 44, 44);
    _numberImageView.frame = CGRectMake(self.view.fj_width - 56 - 28, 10, 30, 30);
    _numberLabel.frame = _numberImageView.frame;
    _divideLine.frame = CGRectMake(0, 0, self.view.fj_width, 1);
    
    [FJImageManager manager].columnNumber = [FJImageManager manager].columnNumber;
    [self.collectionView reloadData];
}

#pragma mark - Notification

- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = _collectionView.contentOffset.y / (_layout.itemSize.height + _layout.minimumLineSpacing);
}

#pragma mark - Click Event

- (void)previewButtonClick {
    FJPhotoPreviewController *photoPreviewVc = [[FJPhotoPreviewController alloc] init];
    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)originalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)doneButtonClick {
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    // 1.6.8 判断是否满足最小必选张数的限制
    if (tzImagePickerVc.minImagesCount && tzImagePickerVc.selectedModels.count < tzImagePickerVc.minImagesCount) {
        NSString *title = [NSString stringWithFormat:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserMinSelectCountText"], tzImagePickerVc.minImagesCount];
        [tzImagePickerVc showAlertWithTitle:title];
        return;
    }
    
    [tzImagePickerVc showProgressHUD];
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) { [photos addObject:@1];[assets addObject:@1];[infoArr addObject:@1]; }
    
    __block BOOL havenotShowAlert = YES;
    [FJImageManager manager].shouldFixOrientation = YES;
    __block id alertView;
    for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) {
        FJAssetModel *model = tzImagePickerVc.selectedModels[i];
        [[FJImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return;
            if (photo) {
                photo = [self scaleImage:photo toSize:CGSizeMake(tzImagePickerVc.photoWidth, (int)(tzImagePickerVc.photoWidth * photo.size.height / photo.size.width))];
                [photos replaceObjectAtIndex:i withObject:photo];
            }
            if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
            [assets replaceObjectAtIndex:i withObject:model.asset];
            
            for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
            
            if (havenotShowAlert) {
                [tzImagePickerVc hideAlertView:alertView];
                [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
            }
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            // 如果图片正在从iCloud同步中,提醒用户
            if (progress < 1 && havenotShowAlert && !alertView) {
                [tzImagePickerVc hideProgressHUD];
                alertView = [tzImagePickerVc showAlertWithTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserSynchronizingPhotosFromiCloudText"]];
                havenotShowAlert = NO;
                return;
            }
            if (progress >= 1) {
                havenotShowAlert = YES;
            }
        } networkAccessAllowed:YES];
    }
    if (tzImagePickerVc.selectedModels.count <= 0) {
        [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
    }
}

- (void)didGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    [tzImagePickerVc hideProgressHUD];
    
    if (tzImagePickerVc.autoDismiss) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
        }];
    } else {
        [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
    }
}

- (void)callDelegateMethodWithPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:)]) {
        [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto];
    }
    if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos:)]) {
        [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto infos:infoArr];
    }
    if (tzImagePickerVc.didFinishPickingPhotosHandle) {
        tzImagePickerVc.didFinishPickingPhotosHandle(photos,assets,_isSelectOriginalPhoto);
    }
    if (tzImagePickerVc.didFinishPickingPhotosWithInfosHandle) {
        tzImagePickerVc.didFinishPickingPhotosWithInfosHandle(photos,assets,_isSelectOriginalPhoto,infoArr);
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_showTakePhotoBtn) {
        FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
        if (tzImagePickerVc.allowPickingImage && tzImagePickerVc.allowTakePicture) {
            return _models.count + 1;
        }
    }
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // the cell lead to take a picture / 去拍照的cell
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    if (((tzImagePickerVc.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!tzImagePickerVc.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoBtn) {
        FJAssetCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FJAssetCameraCell" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamedFromMyBundle:tzImagePickerVc.takePictureImageName];
        return cell;
    }
    // the cell dipaly photo or video / 展示照片或视频的cell
    FJAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FJAssetCell" forIndexPath:indexPath];
    cell.allowPickingMultipleVideo = tzImagePickerVc.allowPickingMultipleVideo;
    cell.photoDefImageName = tzImagePickerVc.photoDefImageName;
    cell.photoSelImageName = tzImagePickerVc.photoSelImageName;
    FJAssetModel *model;
    if (tzImagePickerVc.sortAscendingByModificationDate || !_showTakePhotoBtn) {
        model = _models[indexPath.row];
    } else {
        model = _models[indexPath.row - 1];
    }
    cell.allowPickingGif = tzImagePickerVc.allowPickingGif;
    cell.model = model;
    cell.showSelectBtn = tzImagePickerVc.showSelectBtn;
    if (!tzImagePickerVc.allowPreview) {
        cell.selectPhotoButton.frame = cell.bounds;
    }
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_numberImageView.layer) weakLayer = _numberImageView.layer;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)weakSelf.navigationController;
        // 1. cancel select / 取消选择
        if (isSelected) {
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:tzImagePickerVc.selectedModels];
            for (FJAssetModel *model_item in selectedModels) {
                if ([[[FJImageManager manager] getAssetIdentifier:model.asset] isEqualToString:[[FJImageManager manager] getAssetIdentifier:model_item.asset]]) {
                    [tzImagePickerVc.selectedModels removeObject:model_item];
                    break;
                }
            }
            [weakSelf refreshBottomToolBarStatus];
        } else {
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            if (tzImagePickerVc.selectedModels.count < tzImagePickerVc.maxImagesCount) {
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [tzImagePickerVc.selectedModels addObject:model];
                [weakSelf refreshBottomToolBarStatus];
            } else {
                NSString *title = [NSString stringWithFormat:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserMaxSelectCountText"], tzImagePickerVc.maxImagesCount];
                [tzImagePickerVc showAlertWithTitle:title];
            }
        }
        [UIView showOscillatoryAnimationWithLayer:weakLayer type:TZOscillatoryAnimationToSmaller];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // take a photo / 去拍照
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    if (((tzImagePickerVc.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!tzImagePickerVc.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoBtn)  {
        [self takePhoto]; return;
    }
    // preview phote or video / 预览照片或视频
    NSInteger index = indexPath.row;
    if (!tzImagePickerVc.sortAscendingByModificationDate && _showTakePhotoBtn) {
        index = indexPath.row - 1;
    }
    FJAssetModel *model = _models[index];
    if (model.type == TZAssetModelMediaTypeVideo && !tzImagePickerVc.allowPickingMultipleVideo) {
        if (tzImagePickerVc.selectedModels.count > 0) {
            FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCanNotChosseVideoWhenPhotoTypeText"]];
        } else {
            FJVideoPlayerController *videoPlayerVc = [[FJVideoPlayerController alloc] init];
            videoPlayerVc.model = model;
            [self.navigationController pushViewController:videoPlayerVc animated:YES];
        }
    } else if (model.type == TZAssetModelMediaTypePhotoGif && tzImagePickerVc.allowPickingGif && !tzImagePickerVc.allowPickingMultipleVideo) {
        if (tzImagePickerVc.selectedModels.count > 0) {
            FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCanNotChosseGifWhenPhotoTypeText"]];
        } else {
            FJGifPhotoPreviewController *gifPreviewVc = [[FJGifPhotoPreviewController alloc] init];
            gifPreviewVc.model = model;
            [self.navigationController pushViewController:gifPreviewVc animated:YES];
        }
    } else {
        FJPhotoPreviewController *photoPreviewVc = [[FJPhotoPreviewController alloc] init];
        photoPreviewVc.currentIndex = index;
        photoPreviewVc.models = _models;
        [self pushPhotoPrevireViewController:photoPreviewVc];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (iOS8Later) {
        // [self updateCachedAssets];
    }
}

#pragma mark - Private Method

/// 拍照按钮点击事件
- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) && iOS7Later) {
        // 无权限 做一个友好的提示
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        NSString *message = [NSString stringWithFormat:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserNoCameraAuthorityText"],appName];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCannotUseCameraText"] message:message delegate:self cancelButtonTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCancelText"] otherButtonTitles:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserSettingText"], nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self pushImagePickerController];
                    });
                }
            }];
        } else {
            [self pushImagePickerController];
        }
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    __weak typeof(self) weakSelf = self;
    [[FJLocationManager manager] startLocationWithSuccessBlock:^(CLLocation *location, CLLocation *oldLocation) {
        weakSelf.location = location;
    } failureBlock:^(NSError *error) {
        weakSelf.location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if(iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)refreshBottomToolBarStatus {
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    
    _previewButton.enabled = tzImagePickerVc.selectedModels.count > 0;
    _doneButton.enabled = tzImagePickerVc.selectedModels.count > 0 || tzImagePickerVc.alwaysEnableDoneBtn;
    
    _numberImageView.hidden = tzImagePickerVc.selectedModels.count <= 0;
    _numberLabel.hidden = tzImagePickerVc.selectedModels.count <= 0;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",tzImagePickerVc.selectedModels.count];
    
    _originalPhotoButton.enabled = tzImagePickerVc.selectedModels.count > 0;
    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
    _originalPhotoLabel.hidden = (!_originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)pushPhotoPrevireViewController:(FJPhotoPreviewController *)photoPreviewVc {
    __weak typeof(self) weakSelf = self;
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    [photoPreviewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf.collectionView reloadData];
        [weakSelf refreshBottomToolBarStatus];
    }];
    [photoPreviewVc setDoneButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf doneButtonClick];
    }];
    [photoPreviewVc setDoneButtonClickBlockCropMode:^(UIImage *cropedImage, id asset) {
        [weakSelf didGetAllPhotos:@[cropedImage] assets:@[asset] infoArr:nil];
    }];
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)getSelectedPhotoBytes {
    FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
    [[FJImageManager manager] getPhotosBytesWithArray:imagePickerVc.selectedModels completion:^(NSString *totalBytes) {
        _originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

/// Scale image / 缩放图片
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width < size.width) {
        return image;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)scrollCollectionViewToBottom {
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    if (_shouldScrollToBottom && _models.count > 0) {
        NSInteger item = 0;
        if (tzImagePickerVc.sortAscendingByModificationDate) {
            item = _models.count - 1;
            if (_showTakePhotoBtn) {
                FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
                if (tzImagePickerVc.allowPickingImage && tzImagePickerVc.allowTakePicture) {
                    item += 1;
                }
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            _shouldScrollToBottom = NO;
        });
    }
}

- (void)checkSelectedModels {
    for (FJAssetModel *model in _models) {
        model.isSelected = NO;
        NSMutableArray *selectedAssets = [NSMutableArray array];
        FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
        for (FJAssetModel *model in tzImagePickerVc.selectedModels) {
            [selectedAssets addObject:model.asset];
        }
        if ([[FJImageManager manager] isAssetsArray:selectedAssets containAsset:model.asset]) {
            model.isSelected = YES;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                NSString *message = [NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCanNotJumpToPrivacySettingPage"];
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserSorryText"] message:message delegate:nil cancelButtonTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserOKText"] otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
        [imagePickerVc showProgressHUD];
        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (photo) {
            [[FJImageManager manager] savePhotoWithImage:photo location:self.location completion:^(NSError *error){
                if (!error) {
                    [self reloadPhotoArray];
                }
            }];
            self.location = nil;
        }
    }
}

- (void)reloadPhotoArray {
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    [[FJImageManager manager] getCameraRollAlbum:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(FJAlbumModel *model) {
        _model = model;
        [[FJImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(NSArray<FJAssetModel *> *models) {
            [tzImagePickerVc hideProgressHUD];
            
            FJAssetModel *assetModel;
            if (tzImagePickerVc.sortAscendingByModificationDate) {
                assetModel = [models lastObject];
                [_models addObject:assetModel];
            } else {
                assetModel = [models firstObject];
                [_models insertObject:assetModel atIndex:0];
            }
            
            if (tzImagePickerVc.maxImagesCount <= 1) {
                if (tzImagePickerVc.allowCrop) {
                    FJPhotoPreviewController *photoPreviewVc = [[FJPhotoPreviewController alloc] init];
                    if (tzImagePickerVc.sortAscendingByModificationDate) {
                        photoPreviewVc.currentIndex = _models.count - 1;
                    } else {
                        photoPreviewVc.currentIndex = 0;
                    }
                    photoPreviewVc.models = _models;
                    [self pushPhotoPrevireViewController:photoPreviewVc];
                } else {
                    [tzImagePickerVc.selectedModels addObject:assetModel];
                    [self doneButtonClick];
                }
                return;
            }
            
            if (tzImagePickerVc.selectedModels.count < tzImagePickerVc.maxImagesCount) {
                assetModel.isSelected = YES;
                [tzImagePickerVc.selectedModels addObject:assetModel];
                [self refreshBottomToolBarStatus];
            }
            [_collectionView reloadData];
            
            _shouldScrollToBottom = YES;
            [self scrollCollectionViewToBottom];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [[FJImageManager manager].cachingImageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = _collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [[FJImageManager manager].cachingImageManager startCachingImagesForAssets:assetsToStartCaching
                                                                       targetSize:AssetGridThumbnailSize
                                                                      contentMode:PHImageContentModeAspectFill
                                                                          options:nil];
        [[FJImageManager manager].cachingImageManager stopCachingImagesForAssets:assetsToStopCaching
                                                                      targetSize:AssetGridThumbnailSize
                                                                     contentMode:PHImageContentModeAspectFill
                                                                         options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item < _models.count) {
            FJAssetModel *model = _models[indexPath.item];
            [assets addObject:model.asset];
        }
    }
    
    return assets;
}

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}


#pragma mark --- getter method

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[FJImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[FJImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

@end



@implementation FJCollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
