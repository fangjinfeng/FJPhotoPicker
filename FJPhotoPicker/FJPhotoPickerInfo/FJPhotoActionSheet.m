//
//  FJPhotoActionSheet
//  多选相册照片
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//


#import "FJDefine.h"
#import "FJToastUtils.h"
#import "FJPhotoTool.h"
#import "FJAssetModel.h"
#import "FJProgressHUD.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import "FJCollectionCell.h"
#import "FJPhotoActionSheet.h"
#import "FJImagePickerController.h"
#import "NSBundle+FJImagePicker.h"
#import "FJPhotoPreviewController.h"
#import "FJNoAuthorityViewController.h"


#define kBaseViewHeight (self.maxPreviewCount ? 300 : 142)

typedef NS_ENUM(NSInteger, FJPhotoType) {
    // 相机
    FJPhotoTypeCamara = 1,
    // 系统 相册
    FJPhotoTypeSystemAlbum = 2,
    // 自定义 相册
    FJPhotoTypeCustomAlbum = 3,
};


double const ScalePhotoWidth = 1000;

typedef void (^handler)(NSArray<UIImage *> *selectPhotos, NSArray<PHAsset *> *selectPhotoModels);

@interface FJPhotoActionSheet () <UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver, CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnAblum;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verColHeight;


@property (nonatomic, assign) BOOL animate;
@property (nonatomic, assign) BOOL preview;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *arrayDataSources;
@property (nonatomic, strong) NSMutableArray<FJAssetModel *> *arraySelectPhotos;
@property (nonatomic, strong) NSMutableArray<FJAssetModel *> *arrayDataSourcesPhotos;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, copy)   handler handler;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, assign) BOOL senderTabBarIsShow;

@end

@implementation FJPhotoActionSheet

#pragma mark --- init method

- (instancetype)init {
    self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"FJPhotoActionSheet" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        self.collectionView.collectionViewLayout = layout;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView registerNib:[UINib nibWithNibName:@"FJCollectionCell" bundle:[NSBundle bundleForClass:[self class]]] forCellWithReuseIdentifier:@"FJCollectionCell"];
        
        self.maxSelectCount = 10;
        self.maxPreviewCount = 20;
        self.isHideOriginal = NO;
        self.navigationBarBackgroundColor = kFJPhotoNavigationBarTintColor;
        self.arrayDataSources  = [NSMutableArray array];
        self.arraySelectPhotos = [NSMutableArray array];
        self.arrayDataSourcesPhotos = [NSMutableArray array];
        
        if (![self judgeIsHavePhotoAblumAuthority]) {
            //注册实施监听相册变化
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        }
    }
    return self;
}

#pragma mark --- layout method

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.btnCamera setTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCameraText"] forState:UIControlStateNormal];
    [self.btnAblum setTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserAblumText"] forState:UIControlStateNormal];
    [self.btnCancel setTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCancelText"] forState:UIControlStateNormal];
    [self resetSubViewState];
}

//相册变化回调
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (self.preview) {
            [self loadPhotoFromAlbum];
            [self show];
        } else {
            [self btnPhotoLibrary_Click:nil];
        }
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    });
}

#pragma mark --- public method
- (void)showWithSender:(UIViewController *)sender animate:(BOOL)animate lastSelectPhotoModels:(NSArray<PHAsset *> *)lastSelectPhotoModels completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<PHAsset *> * _Nonnull))completion
{
    [self showPreviewPhotoWithSender:sender animate:animate lastSelectPhotoModels:lastSelectPhotoModels completion:completion];
}

// 显示 预览 界面
- (void)showPreviewPhotoWithSender:(UIViewController *)sender animate:(BOOL)animate lastSelectPhotoModels:(NSArray<PHAsset *> *)lastSelectPhotoModels completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<PHAsset *> * _Nonnull))completion
{
    [self showPreview:YES sender:sender animate:animate photoType:FJPhotoTypeCamara lastSelectPhotoModels:lastSelectPhotoModels completion:completion];
}

// 自定义 相册
- (void)showPhotoLibraryWithSender:(UIViewController *)sender lastSelectPhotoModels:(NSArray<PHAsset *> *)lastSelectPhotoModels completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<PHAsset *> * _Nonnull))completion
{
    [self showPreview:NO sender:sender animate:NO photoType:FJPhotoTypeCustomAlbum lastSelectPhotoModels:lastSelectPhotoModels completion:completion];
}

// 手机 相册
- (void)showSystemPhotoLibraryWithSender:(UIViewController *)sender
                   lastSelectPhotoModels:(NSArray<PHAsset *> * _Nullable)lastSelectPhotoModels
                              completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<PHAsset *> *selectPhotoModels))completion {
     [self showPreview:NO sender:sender animate:NO photoType:FJPhotoTypeSystemAlbum lastSelectPhotoModels:lastSelectPhotoModels completion:completion];
}

// 手机 相机
- (void)showSystemCamaraWithSender:(UIViewController *)sender
                   lastSelectPhotoModels:(NSArray<PHAsset *> * _Nullable)lastSelectPhotoModels
                              completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<PHAsset *> *selectPhotoModels))completion {
    [self showPreview:NO sender:sender animate:NO photoType:FJPhotoTypeCamara lastSelectPhotoModels:lastSelectPhotoModels completion:completion];
}



- (void)showPreview:(BOOL)preview sender:(UIViewController *)sender animate:(BOOL)animate photoType:(FJPhotoType)photoType lastSelectPhotoModels:(NSArray<PHAsset *> *)lastSelectPhotoModels completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<PHAsset *> * _Nonnull))completion
{
    self.handler = completion;
    self.animate = animate;
    self.preview = preview;
    self.sender  = sender;
    
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [self.arraySelectPhotos removeAllObjects];
    
    [self.arraySelectPhotos addObjectsFromArray:[self generateAssetModelWithSelectedAsset:lastSelectPhotoModels]];
    
    if (!self.maxPreviewCount) {
        self.verColHeight.constant = .0;
    }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    [self addAssociatedOnSender];
    if (preview) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self loadPhotoFromAlbum];
            [self show];
        } else if (status == PHAuthorizationStatusRestricted ||
                   status == PHAuthorizationStatusDenied) {
            [self showNoAuthorityVC];
        }
    } else {
        if (status == PHAuthorizationStatusAuthorized) {
            if (photoType == FJPhotoTypeCustomAlbum) {
                [self btnPhotoLibrary_Click:nil];
            }
            else if(photoType == FJPhotoTypeSystemAlbum){
                [self btnSystemAlbum_Click:nil];
            }
            else if(photoType == FJPhotoTypeCamara){
                [self btnCamera_Click:nil];
            }
        } else if (status == PHAuthorizationStatusRestricted ||
                   status == PHAuthorizationStatusDenied) {
            [self showNoAuthorityVC];
        }
    }
}

// 生成 选择 模型 数组
- (NSArray <FJAssetModel *> *)generateAssetModelWithSelectedAsset:(NSArray *)assetArray {
    NSMutableArray *tmpModelArray = [NSMutableArray array];
    [assetArray enumerateObjectsUsingBlock:^(id  asset, NSUInteger idx, BOOL * _Nonnull stop) {
        FJAssetModel *assetModel = [[FJAssetModel alloc] init];
        assetModel.asset = asset;
        assetModel.isSelected = YES;
        assetModel.type = TZAssetModelMediaTypePhoto;
        [tmpModelArray addObject:assetModel];
    }];
    return tmpModelArray;
}

// 生成 选择 图片 Asset
- (NSMutableArray *)generateAssetModelWithSelectedAssetModelArray:(NSArray *)assetModelArray {
     NSMutableArray *tmpAssetArray = [NSMutableArray array];
    [assetModelArray enumerateObjectsUsingBlock:^(FJAssetModel *assetModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [tmpAssetArray addObject:assetModel.asset];
    }];
    return tmpAssetArray;
}

// 生成 数据源 模型 数组
- (void)genearateArrayDataSourcesPhotosWithArrayDataSources:(NSArray *)phassetArray {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (phassetArray.count > 0) {
            [self.arrayDataSourcesPhotos removeAllObjects];
            [phassetArray enumerateObjectsUsingBlock:^(id  asset, NSUInteger idx, BOOL * _Nonnull stop) {
                FJAssetModel *assetModel = [[FJAssetModel alloc] init];
                assetModel.asset = asset;
                assetModel.isSelected = NO;
                assetModel.type = TZAssetModelMediaTypePhoto;
                [self.arrayDataSourcesPhotos addObject:assetModel];
            }];
            
            
            if (self.arraySelectPhotos.count > 0) {
                [self.arraySelectPhotos enumerateObjectsUsingBlock:^(FJAssetModel * _Nonnull firstObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.arrayDataSourcesPhotos enumerateObjectsUsingBlock:^(FJAssetModel * _Nonnull secondObj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([((PHAsset *)firstObj.asset).localIdentifier isEqualToString:((PHAsset *)secondObj.asset).localIdentifier]) {
                            secondObj.isSelected = YES;
                            *stop = YES;
                        }
                    }];
                }];
            }
        }
    });
}

static char RelatedKey;
- (void)addAssociatedOnSender
{
    BOOL selfInstanceIsClassVar = NO;
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList(self.sender.class, &count);
    for (int i = 0; i < count; i++) {
        Ivar var = vars[i];
        const char * type = ivar_getTypeEncoding(var);
        NSString *className = [NSString stringWithUTF8String:type];
        if ([className isEqualToString:[NSString stringWithFormat:@"@\"%@\"", NSStringFromClass(self.class)]]) {
            selfInstanceIsClassVar = YES;
        }
    }
    if (!selfInstanceIsClassVar) {
        objc_setAssociatedObject(self.sender, &RelatedKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - 判断软件是否有相册、相机访问权限
- (BOOL)judgeIsHavePhotoAblumAuthority
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

- (BOOL)judgeIsHaveCameraAuthority
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserOKText"] style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self.sender presentViewController:alert animated:YES completion:nil];
}

- (void)loadPhotoFromAlbum
{
    [self.arrayDataSources removeAllObjects];
    [self.arrayDataSources addObjectsFromArray:[[FJPhotoTool sharePhotoTool] getAllAssetInPhotoAblumWithAscending:NO]];
    [self genearateArrayDataSourcesPhotosWithArrayDataSources:self.arrayDataSources];
    [self.collectionView reloadData];
}



#pragma mark - 显示隐藏视图及相关动画
- (void)resetSubViewState
{
    self.hidden = NO;
    self.baseView.hidden = NO;
    [self changeBtnCameraTitle];
    [self.collectionView setContentOffset:CGPointZero];
}

- (void)show
{
    [self.sender.view addSubview:self];
    if (self.sender.tabBarController.tabBar.hidden == NO) {
        self.senderTabBarIsShow = YES;
        self.sender.tabBarController.tabBar.hidden = YES;
    }
    
    if (self.animate) {
        CGPoint fromPoint = CGPointMake(kScreenWidth/2, kScreenHeight+kBaseViewHeight/2);
        CGPoint toPoint   = CGPointMake(kScreenWidth/2, kScreenHeight-kBaseViewHeight/2);
        CABasicAnimation *animation = GetPositionAnimation([NSValue valueWithCGPoint:fromPoint], [NSValue valueWithCGPoint:toPoint], 0.2, @"position");
        [self.baseView.layer addAnimation:animation forKey:nil];
    }
}

- (void)hide
{
    if (self.animate) {
        CGPoint fromPoint = self.baseView.layer.position;
        CGPoint toPoint   = CGPointMake(fromPoint.x, fromPoint.y+kBaseViewHeight);
        CABasicAnimation *animation = GetPositionAnimation([NSValue valueWithCGPoint:fromPoint], [NSValue valueWithCGPoint:toPoint], 0.1, @"position");
        animation.delegate = self;
        
        [self.baseView.layer addAnimation:animation forKey:nil];
    } else {
        self.hidden = YES;
        [self removeFromSuperview];
    }
    if (self.senderTabBarIsShow) {
        self.sender.tabBarController.tabBar.hidden = NO;
    }
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hide];
}

#pragma mark --- response event

- (IBAction)btnCamera_Click:(id)sender
{
    if (self.arraySelectPhotos.count > 0) {
        [self requestSelPhotos:nil];
    } else {
        if (![self judgeIsHaveCameraAuthority] || ![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            NSString *message = [NSString stringWithFormat:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserNoCameraAuthorityText"], [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];
            if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                message = [NSString stringWithFormat:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCannotUseCameraInSimulatorText"], [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];

            }
            [self showAlertWithTitle:nil message:message];
            [self hide];
            return;
        }
        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.videoQuality = UIImagePickerControllerQualityTypeLow;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.sender presentViewController:picker animated:YES completion:nil];
        }
    }
}

// 系统 相册
- (void)btnSystemAlbum_Click:(id)sender {
    
    if (![self judgeIsHavePhotoAblumAuthority]) {
        [self showNoAuthorityVC];
    } else {
        self.animate = NO;
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.sender presentViewController:picker animated:YES completion:nil];
    }
}

// 手机 相册
- (IBAction)btnPhotoLibrary_Click:(id)sender
{
    if (![self judgeIsHavePhotoAblumAuthority]) {
        [self showNoAuthorityVC];
    } else {
        self.animate = NO;

        FJImagePickerController *imagePickerVc = [[FJImagePickerController alloc] initWithMaxImagesCount:kMaxLimitSelectPhotoNum columnNumber:kCollectionViewColumnNumber delegate:nil pushPhotoPickerVc:YES];
        imagePickerVc.allowTakePicture = NO;
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.selectedModels = self.arraySelectPhotos;
        // imagePickerVc.navigationBar.translucent = NO;
                
        // You can get the photos by block, the same as by delegate.
        // 你可以通过block或者代理，来得到用户选择的照片.
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
              [self done:photos];
             [self hide];
        }];
        
        [self.sender presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

// 取消 按键
- (IBAction)btnCancel_Click:(id)sender
{
    [self.arraySelectPhotos removeAllObjects];
    [self hide];
}

// 预览 取消 按键
- (void)cell_btn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        ShowToastLong([NSBundle fj_localizedStringForKey:@"FJPhotoBrowserMaxSelectCountText"], self.maxSelectCount);
        return;
    }
    
    PHAsset *asset = self.arrayDataSources[btn.tag];
    FJAssetModel *assetModle = self.arrayDataSourcesPhotos[btn.tag];
    assetModle.isSelected = !btn.selected;
    if (!btn.selected) {
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        if (![[FJPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"%@", [NSBundle fj_localizedStringForKey:@"FJPhotoBrowseriCloudPhotoText"]);
            return;
        }
        FJAssetModel *model = [[FJAssetModel alloc] init];
        model.asset = asset;
        [self.arraySelectPhotos addObject:model];
    } else {
        for (FJAssetModel *model in self.arraySelectPhotos) {
            if ([((PHAsset *)model.asset).localIdentifier isEqualToString:asset.localIdentifier]) {
                [self.arraySelectPhotos removeObject:model];
                break;
            }
        }
    }
    
    btn.selected = !btn.selected;
    [self changeBtnCameraTitle];
}

- (void)changeBtnCameraTitle
{
    if (self.arraySelectPhotos.count > 0) {
        [self.btnCamera setTitle:[NSString stringWithFormat:@"%@(%ld)", [NSBundle fj_localizedStringForKey:@"FJPhotoBrowserDoneText"], self.arraySelectPhotos.count] forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:kFJPhotoButtonTitleNormalColor forState:UIControlStateNormal];
    } else {
        [self.btnCamera setTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCameraText"] forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 请求所选择图片、回调
- (void)requestSelPhotos:(UIViewController *)vc
{

    weakify(self);
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:self.arraySelectPhotos.count];
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        [photos addObject:@""];
    }
    
    CGFloat scale = self.isSelectOriginalPhoto?1:[UIScreen mainScreen].scale;
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        FJAssetModel *model = self.arraySelectPhotos[i];
        [[FJPhotoTool sharePhotoTool] requestImageForAsset:model.asset scale:scale resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            strongify(weakSelf);
            if (image) [photos replaceObjectAtIndex:i withObject:[self scaleImage:image]];
            
            for (id obj in photos) {
                if ([obj isKindOfClass:[NSString class]]) return;
            }
            [strongSelf done:photos];
            [strongSelf hide];
            [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

/**
 * @brief 这里对拿到的图片进行缩放，不然原图直接返回的话会造成内存暴涨
 */
- (UIImage *)scaleImage:(UIImage *)image
{
    CGSize size = CGSizeMake(ScalePhotoWidth, ScalePhotoWidth * image.size.height / image.size.width);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)done:(NSArray<UIImage *> *)photos
{
    if (self.handler) {
        self.handler(photos, self.arraySelectPhotos.copy);
        self.handler = nil;
    }
}

#pragma mark --- system delegate

/********************** UICollectionDataSource ***************************/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.maxPreviewCount>_arrayDataSources.count?_arrayDataSources.count:self.maxPreviewCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FJCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FJCollectionCell" forIndexPath:indexPath];
    
    cell.btnSelect.selected = NO;
    PHAsset *asset = _arrayDataSources[indexPath.row];
    weakify(self);
    [self getImageWithAsset:asset completion:^(UIImage *image, NSDictionary *info) {
        strongify(weakSelf);
        cell.imageView.image = image;
        for (FJAssetModel *model in strongSelf.arraySelectPhotos) {
            if ([((PHAsset *)model.asset).localIdentifier isEqualToString:asset.localIdentifier]) {
                cell.btnSelect.selected = YES;
                break;
            }
        }
    }];
    
    cell.btnSelect.tag = indexPath.row;
    [cell.btnSelect addTarget:self action:@selector(cell_btn_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

/**************************** UICollectionViewDelegate *****************************/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.arrayDataSources[indexPath.row];
    return [self getSizeWithAsset:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    FJImagePickerController *imagePickerVc = [[FJImagePickerController alloc] initWithSelectedAssets:[self generateAssetModelWithSelectedAssetModelArray:_arraySelectPhotos] selectedPhotos:_arraySelectPhotos originalPhotos:self.arrayDataSourcesPhotos  index:indexPath.row];
    imagePickerVc.maxImagesCount = kMaxLimitSelectPhotoNum;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        _arraySelectPhotos = [NSMutableArray arrayWithArray:photos];
        _arrayDataSources = [NSMutableArray arrayWithArray:assets];
        _isSelectOriginalPhoto = isSelectOriginalPhoto;
        [_collectionView reloadData];
    }];
    
     [self.sender presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - 显示无权限视图
- (void)showNoAuthorityVC
{
    //无相册访问权限
    FJNoAuthorityViewController *nvc = [[FJNoAuthorityViewController alloc] initWithNibName:@"FJNoAuthorityViewController" bundle:[NSBundle bundleForClass:[self class]]];
    [self presentVC:nvc];
}


- (void)presentVC:(UIViewController *)vc
{
    CustomerNavgationController *nav = [[CustomerNavgationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = YES;
    nav.previousStatusBarStyle = self.previousStatusBarStyle;
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [nav.navigationBar setBackgroundImage:[self imageWithColor:self.navigationBarBackgroundColor] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.sender presentViewController:nav animated:YES completion:nil];
}


- (UIImage *)imageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        strongify(weakSelf);
        if (strongSelf.handler) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [[FJPhotoTool sharePhotoTool] saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (suc) {
                        strongSelf.handler(@[[strongSelf scaleImage:image]], @[asset]);
                    } else {
                        ShowToastLong(@"%@", [NSBundle fj_localizedStringForKey:@"FJPhotoBrowserSaveImageErrorText"]);
                    }
                    [strongSelf hide];
                });
            }];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
    weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        strongify(weakSelf);
        if (strongSelf.handler) {
            UIImage *image = [editingInfo objectForKey:UIImagePickerControllerOriginalImage];
            
            [[FJPhotoTool sharePhotoTool] saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (suc) {
                        strongSelf.handler(@[[strongSelf scaleImage:image]], @[asset]);
                    } else {
                        ShowToastLong(@"%@", [NSBundle fj_localizedStringForKey:@"FJPhotoBrowserSaveImageErrorText"]);
                    }
                    [strongSelf hide];
                });
            }];
        }
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        strongify(weakSelf);
        [strongSelf hide];
    }];
}

#pragma mark - 获取图片及图片尺寸的相关方法
- (CGSize)getSizeWithAsset:(PHAsset *)asset
{
    CGFloat width  = (CGFloat)asset.pixelWidth;
    CGFloat height = (CGFloat)asset.pixelHeight;
    CGFloat scale = width/height;
    
    return CGSizeMake(self.collectionView.frame.size.height*scale, self.collectionView.frame.size.height);
}

- (void)getImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    CGSize size = [self getSizeWithAsset:asset];
    size.width  *= 1.5;
    size.height *= 1.5;
    [[FJPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
}

#pragma mark --- dealloc method

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

@end


#pragma mark - 自定义导航控制器
@implementation CustomerNavgationController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.previousStatusBarStyle;
}


@end
