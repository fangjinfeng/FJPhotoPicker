//
//  ZLNoAuthorityViewController.m
//  多选相册照片
//
//  Created by fjf on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import "FJNoAuthorityViewController.h"
#import "NSBundle+FJImagePicker.h"
#import "FJDefine.h"

@interface FJNoAuthorityViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labPrompt;

@end

@implementation FJNoAuthorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title =  [NSBundle fj_localizedStringForKey:@"FJPhotoBrowserPhotoText"];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue([NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCancelText"], 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCancelText"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    NSString *message = [NSString stringWithFormat:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserNoAblumAuthorityText"], [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];

    
    self.labPrompt.text = message;
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)navRightBtn_Click
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnSetting_Click:(id)sender {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
        if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
            [[UIApplication sharedApplication] openURL:privacyUrl];
        } else {
            NSString *message = [NSBundle fj_localizedStringForKey:@"FJPhotoBrowserCanNotJumpToPrivacySettingPage"];
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserSorryText"] message:message delegate:nil cancelButtonTitle:[NSBundle fj_localizedStringForKey:@"FJPhotoBrowserOKText"] otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
