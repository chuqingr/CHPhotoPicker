//
//  CHSelectedImageCell.swift
//  ZuberPhotos
//
//  Created by Apple on 16/1/11.
//  Copyright © 2016年 duzhe. All rights reserved.
//

import UIKit
import Photos

class CHSelectedImageCell: UICollectionReusableView,UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    var imageView = UIImageView()

    var leftBtn = UIButton(type: UIButtonType.Custom)
    var rightBtn = UIButton(type: UIButtonType.Custom)
    var selectedImageArr = NSArray()
    var count:Int = -1
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        
        /**  初始化content */
 
        self.imageView.contentMode = .Center
        
        
        
        scrollView.delegate = self
    
        self.addSubview(scrollView)
        
        scrollView.snp_makeConstraints { (make) -> Void in
            make.top.left.equalTo(0)
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH))
        }
        scrollView.addSubview(imageView)
        /**  画线 */
        let width = SCREEN_WIDTH
        let color = CHColor(0xeaeaea)
        self.drawLine(CGRectMake(width / 3, 0, 0.5, width), color: color)
        self.drawLine(CGRectMake(width / 3 * 2, 0, 0.5, width), color:color)
        self.drawLine(CGRectMake(0,width / 3, width,0.5), color:color)
        self.drawLine(CGRectMake(0,width / 3 * 2, width,0.5), color: color)
        
        self.addSubview(leftBtn)
        leftBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(0)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSizeMake(40 * wScale, 40 * wScale))
        }
        leftBtn.setImage(UIImage(named: "up"), forState: .Normal)
//        左按钮  ->方法
        leftBtn.whenTapped { () -> Void in
            self.count -= 1
            if self.count >= 0{
                self.updatePhotos(self.selectedImageArr[self.count] as! CHImage)
                if self.count == 0 {
                    self.leftBtn.hidden = true
                }
            }
        }
        
        self.addSubview(rightBtn)
        rightBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(0)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSizeMake(40 * wScale, 40 * wScale))
        }
        rightBtn.setImage(UIImage(named: "next"), forState: .Normal)
//        右按钮 -> 方法
        rightBtn.whenTapped { () -> Void in
            self.count += 1
            if self.count <= self.selectedImageArr.count - 1 {
                self.updatePhotos(self.selectedImageArr[self.count] as! CHImage)
                if self.count == self.selectedImageArr.count - 1 {
                    self.rightBtn.hidden = true
                }
            }
        }
        
        rightBtn.hidden = true
        leftBtn.hidden = true

    
}
    
    
    
    func showPhotos(image: CHImage,currentIndex:Int) {
        count = currentIndex
        updatePhotos(image)
    }
    
    func updatePhotos(superImage:CHImage){
        if count > 0 {
            leftBtn.hidden = false
        }else {
            leftBtn.hidden = true
        }
        if count < selectedImageArr.count - 1 && count >= 0{
            rightBtn.hidden = false
        }else {
            rightBtn.hidden = true
        }
        
        //        /**  如果是选中数组中的，获取下标 */
        //        if let currentSelected = (selectedImageArr as! [ZuberImage]).indexOf(superImage) {
        //            currentIndex = currentSelected
        //
        //        }
        let animation = CATransition()
        animation.duration = 2
        animation.type = "rippleEffect"
        animation.subtype = kCATransitionFromRight
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.scrollView.layer.addAnimation(animation, forKey: "scrollView")
        
        CHPhotoDatas().photoDefault(superImage.asset, synchronous: false, targetSize: PHImageManagerMaximumSize,resultHandler:{ (image, info:[NSObject : AnyObject]?) -> Void in
            let widthRatio = SCREEN_WIDTH / image!.size.width
            let heightRatio = SCREEN_WIDTH / image!.size.height
            let initialZoom = (widthRatio < heightRatio) ? heightRatio : widthRatio
            /**  压缩图 */
            let scaleImage = UIImage.scaleToSize(image!, width: image!.size.width * initialZoom * 2, height: image!.size.height * initialZoom * 2)
            let maxSize = self.scrollView.frame.size
            let widthRatio2 = maxSize.width / scaleImage.size.width
            let heightRatio2 = maxSize.height / scaleImage.size.height
            let initialZoom2 = (widthRatio2 < heightRatio2) ? heightRatio2 : widthRatio2
            /**  最大最小比例 */
            self.scrollView.minimumZoomScale = initialZoom2
            self.scrollView.maximumZoomScale = 3
            self.imageView.image = scaleImage
            self.scrollView.zoomScale = initialZoom2
            self.imageView.frame = CGRectMake(0, 0,scaleImage.size.width / 2,scaleImage.size.height / 2)
            self.scrollView.contentSize = self.imageView.size
            if widthRatio2 < heightRatio2 {
                self.scrollView.contentOffset = CGPointMake((self.imageView.size.width - SCREEN_WIDTH) / 2, 0)
            }else {
                self.scrollView.contentOffset = CGPointMake(0, (self.imageView.size.height - SCREEN_WIDTH) / 2)
            }
            

        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -- scrollviewdelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        scrollView.contentSize = self.imageView.frame.size
        return self.imageView
    }
//    func scrollViewDidZoom(scrollView: UIScrollView) {
//        print("image:\(self.imageView.image!.size)")
//        print("contentSize:\(self.scrollView.contentSize)")
//    }
//    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
////        let image = CHPhotoDatas().cutMapView(scrollView)
////        self.imageView.image = image
////        print("image:\(image)")
//        //获取选中数组
//        if count != -1{
//            self.scrollViewOffset![count] = scrollView.contentOffset
//            self.scrollViewScale![count] = scrollView.zoomScale
//            print("scrollViewOffset2,scrollViewScale2:\(scrollViewOffset![count],scrollViewScale![count])")
//        }
//        print("imageView.center1:\(self.imageView.center)")
//        print("scrollView.center1:\(self.scrollView.center)")
////        print("Offset:\(scrollView.contentOffset)")
////        print("zoomScale:\(scale)")
//
//    }
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        if count != -1{
//            self.scrollViewOffset![count] = scrollView.contentOffset
//            self.scrollViewScale![count] = scrollView.zoomScale
//            print("scrollViewOffset2,scrollViewScale2:\(scrollViewOffset![count],scrollViewScale![count])")
//        }
//        print("imageView.center2:\(self.imageView.center)")
//        print("scrollView.center2:\(self.scrollView.center)")
//    }
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate && count != -1 {
//            self.scrollViewOffset![count] = scrollView.contentOffset
//            self.scrollViewScale![count] = scrollView.zoomScale
//            print("scrollViewOffset2,scrollViewScale2:\(scrollViewOffset![count],scrollViewScale![count])")
//        }
//        print("imageView.center3:\(self.imageView.center)")
//        print("scrollView.center3:\(self.scrollView.center)")
//    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        if count != -1{
//            scrollViewOffset![count] = scrollView.contentOffset
//            scrollViewScale![count] = scale
//            
//        }
//    }
//    func drawLine(startPoint:CGPoint,desPoint:CGPoint) {
//        var path = CGPathCreateMutable()
//        CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y)
//        CGPathAddLineToPoint(path, nil, desPoint.x, desPoint.y)
//
//    }
}
