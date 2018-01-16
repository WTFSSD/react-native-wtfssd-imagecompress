//
//  RCTImageCompress.m
//  RCTImageCompress
//
//  Created by WTFSSD on 2018/1/15.
//  Copyright © 2018年 wtfssd. All rights reserved.
//

#import "RCTImageCompress.h"
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <React/RCTUtils.h>
@interface RCTImageCompress()

@property(nonatomic)RCTPromiseResolveBlock resolve;
@property(nonatomic)RCTPromiseRejectBlock reject;
@property(nonatomic,strong)NSDictionary * params;
@end
@implementation RCTImageCompress


RCT_EXPORT_MODULE();

//RCT_EXTERN_METHOD(doSomething:(NSString *)string withFoo:(NSInteger)a bar:(NSInteger)b)
RCT_EXPORT_METHOD(compress:(NSString*)url
                      size:(id)size
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    self.resolve = resolve;
    self.reject = reject;
    UIImage * originImage = nil;

        if([self checkPremission]){
//            dispatch_async(dispatch_get_global_queue(0,0), ^{
////                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//                UIImage * image = [UIImage imageWithContentsOfFile:url];
//                dispatch_async(dispatch_get_main_queue(), ^{
////                    NSLog(@"图片数据:\n%@",data);
//                     NSLog(@"图片数据:\n%@",image);
//                });
//            });
            
            __weak typeof(self) ws = self;
            NSString * fileName = @"";
            PHAsset *pickedAsset = [PHAsset fetchAssetsWithALAssetURLs:@[[NSURL URLWithString:url]] options:nil].lastObject;
            if(pickedAsset){
                PHImageRequestOptions * op1 = [[PHImageRequestOptions alloc] init];
                PHImageManager * manager = [PHImageManager defaultManager];
                fileName = [self originalFilenameForAsset:pickedAsset assetType:PHAssetResourceTypePhoto];
                [manager requestImageDataForAsset:pickedAsset options:op1 resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_global_queue(0,0), ^{
                        NSData * d = [self compressWithImageData:imageData lastData:nil to:[size floatValue]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *base64 = [d base64EncodedStringWithOptions:0];
                            base64 = [NSString stringWithFormat:@"data:image/png;base64,%@",base64];
                            ws.resolve(@{
                                         @"data":base64,
                                         @"fileName":fileName,
                                         @"size":@(d.length),
                                         @"origin":url,
                                         @"originSize":@(imageData.length)
                                         });
                        });
                    });
                }];
            }else{
                NSData * imageData =[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                NSArray * arr =[url componentsSeparatedByString:@"/"];
                fileName = arr.lastObject;
                dispatch_async(dispatch_get_global_queue(0,0), ^{
                    NSData * d = [self compressWithImageData:imageData lastData:nil to:[size floatValue]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                         NSString *base64 = [d base64EncodedStringWithOptions:0];
                        
                        ws.resolve(@{
                                         @"data":base64,
                                         @"fileName":fileName,
                                         @"size":@(d.length),
                                         @"origin":url,
                                         @"originSize":@(imageData.length)
                                         });
                    });
                });
            }
    
//            PHAssetResource *resource = [self originalFilenameForAsset:pickedAsset assetType:PHAssetResourceTypePhoto];
//            PHFetchOptions * options = [[PHFetchOptions alloc] init];
//            NSArray  *res =  [PHAsset fetchAssetsWithLocalIdentifiers:@[resource.assetLocalIdentifier] options:options];
//
//
//            NSLog(@"相册:%@\n原图:%@\n结果:%@",pickedAsset,resource,res);
        }
    NSLog(@"========压缩=======\nurl=%@\nsize:%@\n原始图片:%@",url,size,originImage);
}



- (NSString * _Nullable)originalFilenameForAsset:(PHAsset * _Nullable)asset assetType:(PHAssetResourceType)type {
    if (!asset) { return nil; }
    
    PHAssetResource *originalResource;
    // Get the underlying resources for the PHAsset (PhotoKit)
    NSArray<PHAssetResource *> *pickedAssetResources = [PHAssetResource assetResourcesForAsset:asset];
    
    // Find the original resource (underlying image) for the asset, which has the desired filename
    for (PHAssetResource *resource in pickedAssetResources) {
        if (resource.type == type) {
            originalResource = resource;
        }
    }
    
    return originalResource.originalFilename;
}

-(BOOL)checkPremission{
    BOOL t = !([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied||[PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted);
    if(!t){
        _reject(@"403",@"暂无相册使用权限",nil);
    }
    
    return t;
}




-(NSData *)compressWithImageData:(NSData*)originData lastData:(NSData*)lastData to:(CGFloat)maxLength {
     NSData * data = [[NSData alloc] initWithData:originData];
    if (data.length/1024 < maxLength) return data;
    if(lastData&&lastData.length == data.length) return data;
    else{
            NSData *_data = UIImageJPEGRepresentation([UIImage imageWithData:data], 0.5);
        return [self compressWithImageData:_data lastData:data to:maxLength];
    }
}

@end
