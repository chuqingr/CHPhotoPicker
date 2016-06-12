//
//  CHCameraView.swift
//  ihappy
//
//  Created by Apple on 16/3/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

import UIKit
protocol CHCameraViewDelegate:NSObjectProtocol {
  func cameraDidSelected(camera:CHCameraView)

}


class CHCameraView: UIView {
    
    var delegate:CHCameraViewDelegate!
    var focus = UIImageView()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        focus.image = Camera_focus_Pic
    }
    
   
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = (touches as NSSet).anyObject()
        let point = touch!.locationInView(touch!.view)
        focus.frame = CGRectMake(0, 0, 60, 60)
        focus.center = point
        self.addSubview(focus)
        self.shakeToShow(focus)
        self.delegate.cameraDidSelected(self)
        
    }
    
    func shakeToShow(aview:UIView){
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.duration = 0.5
        
        let values = NSMutableArray()
        values.addObject(NSValue(CATransform3D: CATransform3DMakeScale(0.1, 0.1, 1)))
        values.addObject(NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1)))
        values.addObject(NSValue(CATransform3D: CATransform3DMakeScale(0.9, 0.9, 1)))
        values.addObject(NSValue(CATransform3D: CATransform3DMakeScale(1, 1, 1)))
        animation.values = values as [AnyObject]
        aview.layer.addAnimation(animation, forKey: nil)
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
