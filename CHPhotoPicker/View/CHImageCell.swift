//
//  ZuberImageCell.swift
//  swiftPickMore
//
//  Created by duzhe on 15/10/15.
//  Copyright © 2015年 duzhe. All rights reserved.
//



import UIKit
import Photos

class CHImageCell: UICollectionViewCell {
    
    var imageView:UIImageView!
    var selectBtn:UIButton!
    var selectImageView:UIImageView!
    var controller:UIViewController?
    var handleSelect:(()->())?
  
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame:CGRectZero)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(self.imageView)
        imageView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
        
        selectBtn = UIButton(type: UIButtonType.Custom)
        selectBtn.setImage(UIImage(named: "btn_choose_normal"), forState: UIControlState.Normal)
        selectBtn.setImage(UIImage(named: "btn_choose_selected"), forState: UIControlState.Selected)
        selectBtn.addTarget(self, action: #selector(CHImageCell.tap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        imageView.addSubview(self.selectBtn)
        selectBtn.snp_makeConstraints { (make) -> Void in
            make.top.right.equalTo(0)
            make.size.equalTo(CGSizeMake(30 * wScale, 30 * wScale))
        }
        imageView.userInteractionEnabled = true
        


    }

    

    
    func update(image:CHImage){
        CHPhotoDatas().photoThumbnails(image.asset, synchronous:false,resultHandler: { (image:UIImage?, info: [NSObject : AnyObject]?) -> Void in
            let downloadfinished = !(info![PHImageResultIsDegradedKey] as! Bool)
            if downloadfinished {
                self.imageView.image = image
            }
            
        })
    }
    

    func tap(btn:UIButton){
        handleSelect?()

    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
