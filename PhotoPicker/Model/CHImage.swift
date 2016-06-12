//
//  ZuberImage.swift
//  swiftPickMore
//
//  Created by duzhe on 15/10/15.
//  Copyright © 2015年 duzhe. All rights reserved.
//


import UIKit
import AssetsLibrary
import Photos

class CHImage: NSObject {
   
    var asset:PHAsset!
    var isSelected:Bool = false
    /**  谓词使用，获取 */
    var cellIndex = Int()
    override init() {
        super.init()
    }
    
}
