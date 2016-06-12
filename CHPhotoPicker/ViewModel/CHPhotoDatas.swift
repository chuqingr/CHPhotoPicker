//
//  CHPhotoDatas.swift
//  ZuberPhotos
//
//  Created by Apple on 16/1/11.
//  Copyright © 2016年 duzhe. All rights reserved.
//

import UIKit
import PhotosUI


class CHPhotoDatas: NSObject {
    /**  获取指定相册的照片 */
    func getPhoto(album:PHAssetCollection) -> [CHImage]{
        let albumData = getFetchResult(album)
        let imageArr = getPhotoAssets(albumData)
        return imageArr
    }
    
    
    /**  获取全部相册 */
    func getPhotoListDatas() -> NSArray {
        var dataArr = [AnyObject]()
        // 列出所有相册智能相册
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype:.SmartAlbumUserLibrary, options: nil)
        dataArr.append(smartAlbums[0])
        // 列出所有用户创建的相册
        let topLevelUserCollections:PHFetchResult = PHAssetCollection.fetchTopLevelUserCollectionsWithOptions(nil)
        for i in 0  ..< topLevelUserCollections.count {
            let sub = topLevelUserCollections[i]
            dataArr.append(sub)
        }
        return dataArr
    }
    
    /**  获取一个相册的结果集合 */
    func getFetchResult(assetCollection:PHAssetCollection) -> PHFetchResult {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)
        return fetchResult
    }
    
    /**  获取图片实体并把图片结果存放到数组中，返回数组 */
    func getPhotoAssets(fetchResult:PHFetchResult) -> [CHImage]{
        var dataArr = [CHImage]()
        
        for i in 0  ..< fetchResult.count {
            
            let asset = fetchResult[i] as! PHAsset
            let image = CHImage()
            /**  过滤视频 */
            if asset.mediaType == .Image{
                image.asset = asset
                dataArr.append(image)
            }
        }
        return dataArr
    }
    
    
    /**  只获取相机胶卷结果集 */
    func getCameraRollFetchResul() -> PHFetchResult{
        let fetchOptions = PHFetchOptions()
        let smartAlbumsFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype:.SmartAlbumUserLibrary, options: fetchOptions)
        let fetch = PHAsset.fetchAssetsInAssetCollection(smartAlbumsFetchResult[0] as! PHAssetCollection, options: nil)
        return fetch
    }

    
    // 获取某个分组的第一张照片缩略图
    func firstPhotoThumbnails(assetCollection:PHAssetCollection,synchronous:Bool, resultHandler: (UIImage?, [NSObject : AnyObject]?) -> Void) {
        
        self.photoThumbnails(self.getFetchResult(assetCollection).firstObject as! PHAsset,synchronous:synchronous, resultHandler: resultHandler)
    }

    
    // 获取某一张照片缩略图
     func photoThumbnails(asset: PHAsset!,synchronous:Bool,resultHandler: (UIImage?, [NSObject : AnyObject]?) -> Void) {
        let superSize = CGSizeMake(186 , 186 )
        return self.photoImage(superSize,synchronous:synchronous ,asset: asset, resultHandler: resultHandler)
    }
    
    // 获取一张大图
    func photoDefault(asset: PHAsset!, synchronous:Bool, targetSize:CGSize,resultHandler: (UIImage?, [NSObject : AnyObject]?) -> Void) {
        return self.photoImage(targetSize, synchronous:synchronous, asset: asset, resultHandler: resultHandler)
      
    }
    

    /**  获取图片 */
    func photoImage(targetSize: CGSize, synchronous:Bool,asset: PHAsset!, resultHandler: (UIImage?, [NSObject : AnyObject]?) -> Void) {
        let options = PHImageRequestOptions()
        options.resizeMode = .Exact
        options.synchronous = synchronous
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize:targetSize, contentMode: .AspectFill, options: options, resultHandler: resultHandler)
    }
    
    
    func cutMapView(sourceView:UIScrollView) -> UIImage {
        let rect = sourceView.frame
        UIGraphicsBeginImageContext(rect.size)
        sourceView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    

}
