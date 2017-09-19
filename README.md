# FJPhotoPicker

图片选择器:一句话集成系统相册、拍照、手机相册等选取图片。

# 使用方法
**CustomPhotoSheet:**

        weakify(self);
       [FJSelectPhotoTool selectPhotoWithPhotoType:FJSelectPhotoFromTypeCustomPhotoSheet photoSelectCompletion:^(NSArray * _Nullable photoArray, NSArray * _Nullable photoModelArray) {
           strongify(weakSelf);
            strongSelf.arrDataSources = photoArray;
           strongSelf.lastSelectMoldels = [NSMutableArray arrayWithArray:photoModelArray];
            [strongSelf.collectionView reloadData];
       }];
       
效果图:

FJPhotoPicker-Preview:

![FJPhotoPicker-Preview](https://github.com/fangjinfeng/FJPhotoPicker/blob/master/FJPhotoPickerDemo/Snapshots/FJPhotoPicker-Preview.gif)
     
     
 **CustomAlbumAndCamera:**
 
     weakify(self);
        [FJSelectPhotoTool selectPhotoWithPhotoType:FJSelectPhotoFromTypeCustomAlbumAndCamera photoSelectCompletion:^(NSArray * _Nullable photoArray, NSArray * _Nullable photoModelArray) {
           strongify(weakSelf);
            strongSelf.arrDataSources = photoArray;
           strongSelf.lastSelectMoldels = [NSMutableArray arrayWithArray:photoModelArray];
            [strongSelf.collectionView reloadData];
       }];
     
     
 FJPhotoPicker-Album:

![FJPhotoPicker-Album](https://github.com/fangjinfeng/FJPhotoPicker/blob/master/FJPhotoPickerDemo/Snapshots/FJPhotoPicker-Album.gif)

 **SystemAlbumAndCamera:**
 
     weakify(self);
      [FJSelectPhotoTool selectPhotoWithPhotoType:FJSelectPhotoFromTypeSystemAlbumAndCamera photoSelectCompletion:^(NSArray * _Nullable photoArray, NSArray * _Nullable photoModelArray) {
          strongify(weakSelf);
          strongSelf.arrDataSources = photoArray;
          strongSelf.lastSelectMoldels = [NSMutableArray arrayWithArray:photoModelArray];
          [strongSelf.collectionView reloadData];
      }];


FJPhotoPicker-SystemAlbum:

![FJPhotoPicker-SystemAlbum](https://github.com/fangjinfeng/FJPhotoPicker/blob/master/FJPhotoPickerDemo/Snapshots/FJPhotoPicker-SystemAlbum.gif)


FJPhotoPicker-Camera:

![FJPhotoPicker-Camera](https://github.com/fangjinfeng/FJPhotoPicker/blob/master/FJPhotoPickerDemo/Snapshots/FJPhotoPicker-Camera.gif)


FJPhotoPicker-NoAuthorization:

![FJPhotoPicker-NoAuthorization](https://github.com/fangjinfeng/FJPhotoPicker/blob/master/FJPhotoPickerDemo/Snapshots/FJPhotoPicker-NoAuthorization.gif)
