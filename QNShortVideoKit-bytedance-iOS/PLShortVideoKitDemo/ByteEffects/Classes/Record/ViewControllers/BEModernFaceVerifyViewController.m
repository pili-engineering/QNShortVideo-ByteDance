// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
#import "BEModernFaceVerifyViewController.h"
#import "BEModernFaceVerifyView.h"
#import <Masonry/Masonry.h>
#import "BEEffectPickerDataStore.h"
#import "BEBeautyPickerCommonDefines.h"
#import "BEStudioConstants.h"
#import <Toast/UIView+Toast.h>
#import "UIResponder+BEAdd.h"


@interface BEModernFaceVerifyViewController () <UIImagePickerControllerDelegate, BEModernFaceVerifyViewDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) BEModernFaceVerifyView *faceVerifyView;
@property(nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation BEModernFaceVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.faceVerifyView];
    [self.faceVerifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.faceVerifyView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    BEEffectClearStatusDataStore *store = [BEEffectClearStatusDataStore sharedDataStore];
    
    if (store.shouldClearFaceVerify){
        [self.faceVerifyView setCellsUnSelected];
        store.shouldClearFaceVerify = NO;
    }
}
#pragma mark - getter
-(BEModernFaceVerifyView *) faceVerifyView{
    if (!_faceVerifyView){
        _faceVerifyView = [[BEModernFaceVerifyView alloc] init];
    }
    return _faceVerifyView;
}


#pragma  mark - delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self.faceVerifyView imageViewSetImage:image];
        
        //process image
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFaceVerifyImageNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: image}];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (UIImagePickerController*)imagePickerController{
    if (!_imagePickerController){
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePickerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
    
}

- (void) openSystemAlbumButtonClicked{
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}
@end
