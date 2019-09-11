//  Copyright © 2019 ailab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "BENetworking.h"
#import <SSZipArchive.h>
#import "BEStudioConstants.h"

@interface BENetworking ()
@end

const NSString *PREFIX = @"https://cv-tob.bytedance.com/download_effect?deviceId=";
static AFNetworkReachabilityStatus networkingStatus;

@implementation BENetworking

+ (BOOL) downLoadStickerWithUrl:(NSString* )stickerID{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", PREFIX, stickerID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.message = @"正在下载中";
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress){ //下载过程设置参数
        alertView.message = [@"正在下载中，已完成" stringByAppendingString:downloadProgress.localizedDescription];
    }
    destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        //定义下载位置
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error != nil){
            NSLog(@"BytedEffect download network stickers failed:%@", error);
            return ;
        }
            
        //下载完成后的callback
        NSLog(@"File downloaded to: %@", filePath.absoluteString);
        
        NSString *sourceZip = filePath.path;
        
        NSString *stickersDir = [BENetworking createStickersPathIfNeeded];
        NSString *stickerID = [filePath.lastPathComponent stringByDeletingPathExtension];
        NSString *sticker = [stickersDir stringByAppendingPathComponent: stickerID];
        
        //如果有的话，删除上一次的贴纸文件
        if ([[NSFileManager defaultManager] fileExistsAtPath:sticker]){
            [[NSFileManager defaultManager] removeItemAtPath:sticker error:nil];
        }
        
        //创建贴纸文件夹
        if (![[NSFileManager defaultManager] fileExistsAtPath:sticker]){
            [[NSFileManager defaultManager] createDirectoryAtPath:sticker withIntermediateDirectories:YES attributes:nil error:nil];
        }

        [SSZipArchive unzipFileAtPath:sourceZip toDestination:sticker progressHandler: ^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
            //NSLog(@"%zd---%zd",entryNumber,total);
        } completionHandler:^(NSString *path, BOOL succeeded, NSError *error){
            if (!succeeded && error == nil){
                NSLog(@"Decompress network sticker error: %@", error);
                return ;
            }
            NSLog(@"Finish decompress network sticker");
            
            // 删除原始的zip文件
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            
            NSString* stickerZip = [path lastPathComponent];
            NSString* sticker = [stickerZip stringByDeletingPathExtension];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectNetworkStickerReadyNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey:sticker}];
            
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }];
    }];
    
    [downloadTask resume];
    [alertView show];
    return true;
}

+ (NSString*) createStickersPathIfNeeded{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [paths objectAtIndex:0];
    NSString* stickersDir = [cachePath stringByAppendingPathComponent:@"stickers"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:stickersDir]){
        [fileManager createDirectoryAtPath:stickersDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return stickersDir;
}

+ (void) startNetworkMonintoring{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        networkingStatus = status;
    }];
}

+ (AFNetworkReachabilityStatus) getCurrentNetworkingStatus{
    return networkingStatus;
}
@end
