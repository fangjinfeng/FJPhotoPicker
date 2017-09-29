//
//  TZGifPhotoPreviewController.m
//  TZImagePickerController
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import "FJGifPhotoPreviewController.h"
#import "FJImagePickerController.h"
#import "FJAssetModel.h"
#import "UIView+FJLayout.h"
#import "FJPhotoPreviewCell.h"
#import "FJImageManager.h"
#import "FJDefine.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface FJGifPhotoPreviewController () {
    UIView *_toolBar;
    UIButton *_doneButton;
    UIProgressView *_progress;
    
    FJPhotoPreviewView *_previewView;
    
    UIStatusBarStyle _originStatusBarStyle;
}
@end

@implementation FJGifPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    if (tzImagePickerVc) {
        self.navigationItem.title = [NSString stringWithFormat:@"GIF %@",tzImagePickerVc.previewBtnTitleStr];
    }
    [self configPreviewView];
    [self configBottomToolBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = iOS7Later ? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
}

- (void)configPreviewView {
    _previewView = [[FJPhotoPreviewView alloc] initWithFrame:CGRectZero];
    _previewView.model = self.model;
    __weak typeof(self) weakSelf = self;
    [_previewView setSingleTapGestureBlock:^{
        [weakSelf signleTapAction];
    }];
    [self.view addSubview:_previewView];
}

- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    FJImagePickerController *tzImagePickerVc = (FJImagePickerController *)self.navigationController;
    if (tzImagePickerVc) {
        [_doneButton setTitle:tzImagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
        [_doneButton setTitleColor:tzImagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
    } else {
        [_doneButton setTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserDoneText"] forState:UIControlStateNormal];
        [_doneButton setTitleColor:kFJPhotoButtonTitleNormalColor forState:UIControlStateNormal];
    }
    [_toolBar addSubview:_doneButton];
    
    UILabel *byteLabel = [[UILabel alloc] init];
    byteLabel.textColor = [UIColor whiteColor];
    byteLabel.font = [UIFont systemFontOfSize:13];
    byteLabel.frame = CGRectMake(10, 0, 100, 44);
    [[FJImageManager manager] getPhotosBytesWithArray:@[_model] completion:^(NSString *totalBytes) {
        byteLabel.text = totalBytes;
    }];
    [_toolBar addSubview:byteLabel];
    
    [self.view addSubview:_toolBar];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _previewView.frame = self.view.bounds;
    _previewView.scrollView.frame = self.view.bounds;
    _doneButton.frame = CGRectMake(self.view.fj_width - 44 - 12, 0, 44, 44);
    _toolBar.frame = CGRectMake(0, self.view.fj_height - 44, self.view.fj_width, 44);
}

#pragma mark - Click Event

- (void)signleTapAction {
    _toolBar.hidden = !_toolBar.isHidden;
    [self.navigationController setNavigationBarHidden:_toolBar.isHidden];
    
    if (!fj_isGlobalHideStatusBar) {
        if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = _toolBar.isHidden;
    }
}

- (void)doneButtonClick {
    FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
    if (self.navigationController) {
        if (imagePickerVc.autoDismiss) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [self callDelegateMethod];
            }];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    }
}

- (void)callDelegateMethod {
    FJImagePickerController *imagePickerVc = (FJImagePickerController *)self.navigationController;
    UIImage *animatedImage = _previewView.imageView.image;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingGifImage:sourceAssets:)]) {
        [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingGifImage:animatedImage sourceAssets:_model.asset];
    }
    if (imagePickerVc.didFinishPickingGifImageHandle) {
        imagePickerVc.didFinishPickingGifImageHandle(animatedImage,_model.asset);
    }
}

#pragma clang diagnostic pop

@end
