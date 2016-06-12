//
//  IHConfig.swift
//  IHShare
//
//  Created by 杨胜浩 on 16/6/7.
//  Copyright © 2016年 chuqingr. All rights reserved.
//

/**
 *一些config
 *@param nil
 *@return nil
 */

import UIKit
import Foundation


/**  适配 */
let hScale = SCREEN_HEIGHT / 667
let wScale = SCREEN_WIDTH / 375

let SCREEN_BOUNDS:CGRect = UIScreen.mainScreen().bounds
let SCREEN_SIZE:CGSize = UIScreen.mainScreen().bounds.size
let SCREEN_WIDTH:CGFloat = SCREEN_SIZE.width  //屏幕宽度
let SCREEN_HEIGHT:CGFloat = SCREEN_SIZE.height


func RGBA (r r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat)->UIColor { return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a) }
//** 十六进制转换颜色,需要写0x前缀 */
func CHColor(hex:Int) -> UIColor {
    let color = UIColor(colorLiteralRed: (Float)((hex & 0xFF0000) >> 16)/255.0, green: (Float)((hex & 0x00FF00) >> 8)/255.0, blue: (Float)(hex & 0x0000FF)/255.0, alpha: 1)
    return color
    
}


let labelColor = CHColor(0x2d2d35)
/**  照片最多张数 */
let MAX_IMAGENUMBER = 8
/**  图片 */
let Camera_focus_Pic = UIImage(named: "camera_focus_pic")
let Flash_close_btn_Pic = UIImage(named: "flash_close")
let Flash_open_btn_Pic = UIImage(named: "flash_open")
let TakePhoto_btn_Pic = UIImage(named: "take_photo")
let Camera_change_btn_Pic = UIImage(named: "camera_change")



/**
 *扩展
 *@param nil
 *@return nil
 */

extension UIButton {
    /**  图片文字上下 传入文字跟图片间距 */
    func setTitleAndImage(space:CGFloat){
        let iconSize = self.imageView?.size
        let textWidth = self.titleLabel?.width
        self.contentHorizontalAlignment = .Left
        self.contentVerticalAlignment = .Top
        /**  图片右移(总的宽度-图片宽度)/2-->居中 */
        self.imageEdgeInsets = UIEdgeInsetsMake(0, (self.width - (iconSize?.width)!) / 2, 0,  0)
        /**  文字下移 图片高度+图文间距 右移 (总的宽度-文字宽度)/2 - 图片宽度（图片在文字左边）-->居中 */
        self.titleEdgeInsets = UIEdgeInsetsMake((iconSize?.height)! + space,(self.width - textWidth!) / 2 - (iconSize?.width)!,0,0)
    }
}

var blockActionDict: [String : (() -> ())] = [:]

extension UIView {
    
    private func whenTouch(NumberOfTouche touchNumbers: Int,NumberOfTaps tapNumbers: Int) -> Void {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTouchesRequired = touchNumbers
        tapGesture.numberOfTapsRequired = tapNumbers
        tapGesture.addTarget(self, action: #selector(UIView.tapActions))
        self.addGestureRecognizer(tapGesture)
    }
    
    func whenTapped(action :(() -> Void)) {
        // 手势-一次点击
        _addBlock(NewAction: action)
        whenTouch(NumberOfTouche: 1, NumberOfTaps: 1)
    }
    
    
    func tapActions() {
        // 执行action
        _excuteCurrentBlock()
    }
    
    
    private func _addBlock(NewAction newAction:()->()) {
        let key = String(NSValue(nonretainedObject: self))
        blockActionDict[key] = newAction
    }
    
    private func _excuteCurrentBlock(){
        let key = String(NSValue(nonretainedObject: self))
        let block = blockActionDict[key]
        block!()
    }
    
    
    
    
    /**  淡入 */
    func fadeInWithTime(time:NSTimeInterval){
        fadeInWithTime(time, alpha: 1)
    }
    
    /**  淡入到制定alpha */
    func fadeInWithTime(time:NSTimeInterval,alpha:CGFloat){
        self.alpha = 0
        UIView.animateWithDuration(time, animations: { () -> Void in
            self.alpha = alpha
        }) { (bool:Bool) -> Void in
            
        }
        
    }
    
    /**  淡出 */
    //MARK: -- 淡出
    func fadeOutWithTime(time:NSTimeInterval){
        self.alpha = 1
        UIView.animateWithDuration(time, animations: { () -> Void in
            self.alpha = 0
        }) { (bool:Bool) -> Void in
            //            self.removeFromSuperview()
        }
    }
    /**  缩放 */
    //MARK: -- 缩放
    func scalingWithTime(time:NSTimeInterval,scale:CGFloat){
        //        self.transform = CGAffineTransformIdentity
        UIView.animateWithDuration(time) { () -> Void in
            //            self.transform = CGAffineTransformScale(current, scal, scal)
            self.transform = CGAffineTransformMakeScale(scale,scale)
        }
    }
    /**  旋转 */
    //MARK: -- 旋转
    func RevolvingWithTime(time:NSTimeInterval,delta:CGFloat){
        UIView.animateWithDuration(time) { () -> Void in
            self.transform = CGAffineTransformMakeRotation(delta)
        }
    }
    
    /**  画线 */
    func drawLine(frame:CGRect,color:UIColor){
        let bottomBorder = CALayer()
        bottomBorder.frame = frame
        bottomBorder.backgroundColor = color.CGColor
        self.layer.addSublayer(bottomBorder)
    }
    
    func setVipImage(size:CGFloat,isAdd:Bool){
        let vipImageView = UIImageView()
        vipImageView.tag = 100
        if isAdd{
            self.addSubview(vipImageView)
            vipImageView.snp_makeConstraints { (make) -> Void in
                make.right.bottom.equalTo(1)
                make.size.equalTo(CGSizeMake(size * wScale, size * wScale))
            }
            vipImageView.layer.cornerRadius = size / 2 * wScale
            vipImageView.layer.borderWidth = 1
            vipImageView.layer.borderColor = UIColor.whiteColor().CGColor
            vipImageView.image = UIImage(named: "king")
        }else {
            for view in self.subviews {
                if view.tag == 100 {
                    view.removeFromSuperview()
                }
            }
        }
        
    }
}

extension UIView {
    public var origin: CGPoint{
        get{
            return self.frame.origin
        }
        set{
            self.frame.origin = origin
        }
    }
    public var size: CGSize{
        get{
            return self.frame.size
        }
        set{
            self.frame.size = size
        }
    }
    
    public var bottomLeft: CGPoint {
        get{
            return CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height)
        }
        
    }
    public var bottomRight: CGPoint {
        get{
            return CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height)
        }
    }
    public var topRight: CGPoint {
        get{
            return CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y)
        }
    }
    
    public var height: CGFloat{
        get{
            return self.frame.size.height
        }
        set{
            self.frame.size.height = height
        }
    }
    public var width: CGFloat{
        get{
            return self.frame.size.width
        }
        set{
            self.frame.size.width = width
        }
    }
    
    public var top: CGFloat{
        get {
            return self.frame.origin.y
        }
        set{
            self.frame.origin.y = top
        }
    }
    public var left: CGFloat{
        get {
            return self.frame.origin.x
        }
        set{
            self.frame.origin.x = left
        }
    }
    
    public var bottom: CGFloat{
        get {
            return top + self.frame.size.height
        }
        set{
            self.frame.size.height = bottom - top
        }
    }
    public var right: CGFloat{
        get {
            return left + self.frame.size.width
        }
        set{
            self.frame.size.height = right - left
        }
    }
    
    //    public func moveBy(delta: CGPoint)
    //    public func scaleBy(scaleFactor: CGFloat)
    //    public func fitInSize(aSize: CGSize)
    //
    //    public func convertViewToImage() -> UIImage!
}


extension UIImage {
    /**  修改图片尺寸 */
    static func scaleToSize(image:UIImage?,width:CGFloat,height:CGFloat) -> UIImage {
        //        let scale = image!.size.height/image!.size.width
        let size = CGSizeMake(width, height)
        UIGraphicsBeginImageContext(size)
        image!.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

class IHConfig: NSObject {

}
