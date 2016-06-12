//
//  CHCameraImageView.swift
//  ihappy
//
//  Created by Apple on 16/3/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

import UIKit
enum CHImagewOrientation {



}

protocol CHCameraImageViewDelegate:NSObjectProtocol {
    func cameraImageViewSendBtnTouched()
    func cameraImageViewCancleBtnTouched()
}
let ZLCameraColletionViewW = 80
let ZLCameraColletionViewPadding = 20
let BOTTOM_HEIGHT = 120 * hScale

class CHCameraImageView: UIView {
    var delegate:CHCameraImageViewDelegate!
    var photoDisplayView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.blackColor()
        
        setupBottomView()
        
        
    }
    
    func setupBottomView(){
        let margin = 20
        
        /**  显示照片的view   在imagetodisplay的set方法中设置frame和image */
        self.addSubview(photoDisplayView)
        photoDisplayView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo((SCREEN_HEIGHT - BOTTOM_HEIGHT - SCREEN_WIDTH) / 2 * hScale)
            make.left.right.equalTo(0)
            make.height.equalTo(SCREEN_WIDTH)
        }
        
//        if let _ = imageToDisplay {
//            return
//        }
//        var size = CGSize()
//        size.width = SCREEN_WIDTH
//        size.height = imageToDisplay!.size.height * hScale
//        print("\(size)")
//        let x = (SCREEN_WIDTH - size.width) / 2
//        let y = (SCREEN_HEIGHT - size.height) / 2
//        photoDisplayView!.frame = CGRectMake(x, y, size.width, size.height)
//        photoDisplayView!.image = imageToDisplay
        
        /**  底部View */
        let controllerView = UIView()
        self.addSubview(controllerView)
        controllerView.snp_makeConstraints { (make) -> Void in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(BOTTOM_HEIGHT * hScale)
        }
        controllerView.backgroundColor = UIColor.clearColor()
        
        /**  重拍按钮 */
        let cancelBTN = UIButton(type: .Custom)
        controllerView.addSubview(cancelBTN)
        cancelBTN.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(margin)
            make.top.equalTo(0)
            make.size.equalTo(CGSizeMake(80, 40))
        }
        cancelBTN.setTitle("重拍", forState: .Normal)
        cancelBTN.titleLabel?.font = UIFont.systemFontOfSize(18)
        cancelBTN.setTitleColor(CHColor(0xeeeeee), forState: .Normal)
        cancelBTN.whenTapped { () -> Void in
            self.delegate.cameraImageViewCancleBtnTouched()
            self.removeFromSuperview()
        }
        
        /**  使用照片按钮 */
        let doneBtn = UIButton(type: .Custom)
        controllerView.addSubview(doneBtn)
        doneBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(-margin)
            make.top.equalTo(0)
            make.size.equalTo(CGSizeMake(80, 40))
        }
        doneBtn.setTitle("使用照片", forState: .Normal)
        doneBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        doneBtn.setTitleColor(CHColor(0xeeeeee), forState: .Normal)
        doneBtn.whenTapped { () -> Void in
            self.delegate.cameraImageViewSendBtnTouched()
        }
        
        
        
    }
    
    func imageToDisplay(imageToDisplay:UIImage?){
        

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
