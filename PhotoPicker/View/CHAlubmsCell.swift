//
//  CHAlubmsCell.swift
//  ihappy
//
//  Created by Apple on 16/2/25.
//  Copyright © 2016年 Apple. All rights reserved.
//

import UIKit
import Photos

class CHAlubmsCell: UITableViewCell {
    
    /**  左侧图片 */
    let alubmImageView = UIImageView()
    /**  相册名字 */
    let alubmName = UILabel()
    /**  照片数量 */
    let alubmNum = UILabel()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(alubmImageView)
        alubmImageView.snp_makeConstraints { (make) -> Void in
            make.top.left.equalTo(10 * wScale)
            make.size.equalTo(CGSizeMake(58 * wScale, 58 * wScale))
        }
        
        self.addSubview(alubmName)
        alubmName.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.left.equalTo(alubmImageView.snp_right).offset(10 * wScale)
            make.height.equalTo(15)
        }
        alubmName.font = UIFont.systemFontOfSize(15)
        
        self.addSubview(alubmNum)
        alubmNum.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.left.equalTo(alubmName.snp_right).offset(8 * wScale)
            make.height.equalTo(15)
        }
        alubmNum.font = UIFont.systemFontOfSize(15)
        alubmNum.textColor = RGBA(r: 174, g: 175, b: 176, a: 1)

        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func loadPhotoListData(collectionItem:PHAssetCollection){
        if collectionItem.isKindOfClass(PHAssetCollection.self) {
            let group = PHAsset.fetchAssetsInAssetCollection(collectionItem, options: nil)
            PHImageManager.defaultManager().requestImageForAsset(group.lastObject as! PHAsset, targetSize: CGSizeMake(200,200), contentMode: .Default, options: nil, resultHandler: { (image:UIImage?, _:[NSObject : AnyObject]?) -> Void in
                if image == nil {
                    self.alubmImageView.image = UIImage(named: "c_image")
                }else {
                    self.alubmImageView.image = image
                }

            })

            self.alubmName.text = collectionItem.localizedTitle
            
        }
    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
