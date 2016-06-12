//
//  CHCameraPickerViewController.swift
//  ihappy
//
//  Created by Apple on 16/3/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

import UIKit
import ImageIO
import PhotosUI
import AVFoundation

class CHCameraPickerViewController: UIViewController,CHCameraViewDelegate,CHCameraImageViewDelegate {
    /**  照片类型 */
//    var imageType:CHImageType?
    /**  闭包 */
//    var result:((_:AnyObject)->Void)?
    /**  闪光灯 */
    var isOpen:Bool!
    /**  avfooundation */
    var session:AVCaptureSession!
    var captureOutput:AVCaptureStillImageOutput!
    var device:AVCaptureDevice!
    var input:AVCaptureDeviceInput!
    var output:AVCaptureMetadataOutput!
    var preview:AVCaptureVideoPreviewLayer!
    var cameraImage:UIImage?
    /**  完成后回调 */
    var callback:((_:UIImage) -> ())?
    
    let focuseView = CHCameraView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTopVoewUI()
        setBottomViewUi()
        initCameraMain()

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /**  创建顶部View */
    func setTopVoewUI(){
        let topView = UIView()
        topView.backgroundColor = CHColor(0x2c2c2c)
        topView.alpha = 0.8
        focuseView.addSubview(topView)
        topView.snp_makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(0)
            make.height.equalTo(44 * hScale)
        }
        
        let bottomView = UIView()
        bottomView.backgroundColor = CHColor(0x2c2c2c)
        bottomView.alpha = 0.8
        focuseView.addSubview(bottomView)
        bottomView.snp_makeConstraints { (make) -> Void in
            make.bottom.left.right.equalTo(0)
            make.height.equalTo(44 * hScale)
        }
        
        /**  画线 */
        let width = SCREEN_WIDTH
        let color = CHColor(0xeaeaea)
        self.view.drawLine(CGRectMake(width / 3, 44 * hScale, 0.5, width), color: color)
        self.view.drawLine(CGRectMake(width / 3 * 2, 44 * hScale, 0.5, width), color:color)
        self.view.drawLine(CGRectMake(0,width / 3 + 44 * hScale, width,0.5), color:color)
        self.view.drawLine(CGRectMake(0,width / 3 * 2 + 44 * hScale, width,0.5), color: color)

        
        
        /**  设置闪光灯默认状态为关闭 */
        isOpen = false
        let flashBtn = UIButton(type: .Custom)
        topView.addSubview(flashBtn)
        flashBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(16 * wScale)
            make.top.bottom.equalTo(0)
            make.width.equalTo(40 * wScale)
        }
        flashBtn.tag = 30
        flashBtn.setImage(Flash_close_btn_Pic, forState: .Normal)
        flashBtn.setImage(Flash_open_btn_Pic, forState: .Selected)
        flashBtn.addTarget(self, action: #selector(CHCameraPickerViewController.flashOfCamera(_:)), forControlEvents: .TouchUpInside)
        
        
        let changeBtn = UIButton(type: .Custom)
        topView.addSubview(changeBtn)
        changeBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(-16 * wScale)
            make.top.bottom.equalTo(0)
            make.width.equalTo(40 * wScale)
        }
        changeBtn.setImage(Camera_change_btn_Pic, forState: .Normal)
        changeBtn.addTarget(self, action: #selector(CHCameraPickerViewController.changeCameraDevice(_:)), forControlEvents: .TouchUpInside)
    }
    
    /**  创建底部View */
    func setBottomViewUi(){
        let bottomView = UIView()
        self.view.addSubview(bottomView)
        bottomView.snp_makeConstraints { (make) -> Void in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH - 88 * hScale)
        }
        bottomView.backgroundColor = CHColor(0x232323)
        
        let cancelBtn = UIButton(type: .Custom)
        bottomView.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(30 * wScale)
            make.top.equalTo(85 * hScale)
            make.height.equalTo(18)
        }
        cancelBtn.setTitle("取消", forState: .Normal)
        cancelBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        cancelBtn.setTitleColor(CHColor(0xeeeeee), forState: .Normal)
        cancelBtn.addTarget(self, action: #selector(CHCameraPickerViewController.cancel), forControlEvents: .TouchUpInside)
        
        let takePhotoBtn = UIButton(type: .Custom)
        bottomView.addSubview(takePhotoBtn)
        takePhotoBtn.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(75 * hScale)
            make.centerX.equalTo(bottomView)
            make.size.equalTo(CGSizeMake(81 * wScale, 81 * wScale))
        }
        takePhotoBtn.setImage(TakePhoto_btn_Pic, forState: .Normal)
        takePhotoBtn.whenTapped { () -> Void in
            self.captureImage()
        }
        
        
        
    }
    
    /**  111 */
    func initCameraMain(){
        /**  创建会话层 */
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        /**  input */
        do {
            try input = AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        /**  output */
        captureOutput = AVCaptureStillImageOutput()
        let outputSettings = NSDictionary(object: AVVideoCodecJPEG, forKey: AVVideoCodecKey)
        captureOutput.outputSettings = outputSettings as! [NSObject : AnyObject]
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        if session.canAddInput(self.input){
            self.session.addInput(self.input)
        }
        if session.canAddOutput(captureOutput){
            self.session.addOutput(captureOutput)
        }
        
        preview = AVCaptureVideoPreviewLayer(session: self.session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH + 88 * hScale)
        
        
        if (session != nil) {
            self.session.startRunning()
        }
        
//        self.prefersStatusBarHidden()
        
        
        focuseView.delegate = self
        self.view.addSubview(focuseView)
        self.view.layer.insertSublayer(preview, atIndex: 0)
        focuseView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(SCREEN_WIDTH + 88 * hScale)
        }
        
    }
    func cameraDidSelected(camera:CHCameraView){
        do {
            try self.device.lockForConfiguration()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        self.device.focusMode = .AutoFocus
        self.device.focusPointOfInterest = CGPointMake(50, 50)
        /**  操作完成后unlock */
        self.device.unlockForConfiguration()
        
        
    }
    
    //MARK: -- delegate
    func cameraImageViewSendBtnTouched(){
        self.doneAction()
    }
    func cameraImageViewCancleBtnTouched(){
        cameraImage = nil
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "adjustingFocus" {
            print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQ")
        }
    }
    /**  完成拍照 */
    func doneAction(){
        UIImageWriteToSavedPhotosAlbum(cameraImage!, self, #selector(CHCameraPickerViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        /**  关闭相册界面 */
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error != nil {
            print("错误")
            return
        }
        if let _ = self.callback {
            self.callback!(cameraImage!)
        }
        self.cancel()
    }
    
    /**  底层拍照控制 */
    func captureImage(){
//        var videoConnection:AVCaptureConnection?
//        for connection in self.captureOutput.connections {
//            for port in (connection as! AVCaptureConnection).inputPorts{
//                if ((port as! AVCaptureInputPort).mediaType == AVMediaTypeAudio) {
//                    videoConnection = connection as? AVCaptureConnection
//                    break
//                }
//                print("\(videoConnection)")
//            }
//            if let _ = videoConnection {
//                break
//            }
//        }
        let connection = self.captureOutput.connectionWithMediaType(AVMediaTypeVideo)
        if connection.enabled {
        
            /**  get uiimage */
            self.captureOutput.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (imageSampleBuffer, error) -> Void in
                let exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, nil)
                if let _ = exifAttachments {
                    // Do something with the attachments.
                }
                
                // Continue as appropriate.
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                var image = UIImage(data: imageData)
                
                image = self.cutImage(image!)
                self.cameraImage = image
                self.displayImage(image!)
            })
        }
    
        
    }
    
    func fixOrientation(srcImage:UIImage) -> UIImage{
        if srcImage.imageOrientation == .Up {
            return srcImage
        }
        var transform = CGAffineTransformIdentity
        switch srcImage.imageOrientation {
        case .Down:fallthrough
        case .DownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImage.size.width, srcImage.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            
        case .Left:fallthrough
        case .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImage.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            
        case .Right:fallthrough
        case .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImage.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            
        case .Up: fallthrough
        case .UpMirrored:
            break
        }
        
        switch srcImage.imageOrientation {
        case .UpMirrored:fallthrough
        case .DownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImage.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored:fallthrough
        case .RightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImage.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .Up:fallthrough
        case .Down:fallthrough
        case .Left:fallthrough
        case .Right:
            break
        }
        let ctx = CGBitmapContextCreate(nil, Int(srcImage.size.width), Int(srcImage.size.height),CGImageGetBitsPerComponent(srcImage.CGImage), 0,
            CGImageGetColorSpace(srcImage.CGImage),
            CGImageGetBitmapInfo(srcImage.CGImage).rawValue)
        CGContextConcatCTM(ctx, transform)
        switch srcImage.imageOrientation {
        case .Left:fallthrough
        case .LeftMirrored:fallthrough
        case .Right:fallthrough
        case .RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImage.size.height,srcImage.size.width), srcImage.CGImage)
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImage.size.width,srcImage.size.height), srcImage.CGImage)
        }
        let cgimage = CGBitmapContextCreateImage(ctx)
        let image = UIImage(CGImage: cgimage!)
        return image
    }
    
    func cutImage(srcImage:UIImage) -> UIImage{
        /**  rect 的坐标是横屏，home在右  */
        let rect = CGRectMake((srcImage.size.height / CGRectGetHeight(self.view.frame)) * 124, 0,  srcImage.size.width,  srcImage.size.width)
        let subImageRef = CGImageCreateWithImageInRect(srcImage.CGImage, rect)
        let subWidth = CGFloat(CGImageGetWidth(subImageRef))
        let subHeight = CGFloat(CGImageGetHeight(subImageRef))
        let smallBounds = CGRectMake(0, 0, subWidth, subHeight)
        /**  旋转后，画出来 */
        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformTranslate(transform, 0, subWidth)
        transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        let ctx = CGBitmapContextCreate(nil, Int(subHeight), Int(subWidth), CGImageGetBitsPerComponent(subImageRef), 0, CGImageGetColorSpace(subImageRef), CGImageGetBitmapInfo(subImageRef).rawValue)
        CGContextConcatCTM(ctx, transform)
        CGContextDrawImage(ctx, smallBounds, subImageRef)
        let cgImage = CGBitmapContextCreateImage(ctx)
        let image = UIImage(CGImage: cgImage!)
        return image
    
    }
    
    func displayImage(image:UIImage){
        let view = CHCameraImageView(frame: self.view.frame)
        view.delegate = self
//        view.imageToDisplay = image
        view.photoDisplayView.image = image

        self.view.addSubview(view)
    }
    
    func CaptureStillImage(){
        self.captureImage()
    }
    
    //MARK: -- 按钮响应方法
    func cancel(){
        self.flashLightModel({ () -> Void in
            self.device.flashMode = .Off
        })
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changeCameraDevice(btn:UIButton){
        UIView.beginAnimations("animation", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationCurve(.EaseInOut)
        UIView.setAnimationTransition(.FlipFromRight, forView: self.view, cache: true)
        UIView.commitAnimations()
        let inputs = self.session.inputs
        for  input in inputs {
            let device = (input as! AVCaptureDeviceInput).device
            if device.hasMediaType(AVMediaTypeVideo) {
                let position = device.position
                var newCamera:AVCaptureDevice?
                var newInput:AVCaptureDeviceInput?
                
                if position == .Front {
                    newCamera = self.cameraWithPosition(.Back)
                }else {
                    newCamera = self.cameraWithPosition(.Front)
                }
                do {
                    try newInput = AVCaptureDeviceInput(device: newCamera)
                }catch  let error as NSError {
                    print(error.localizedDescription)
                }
                self.session.beginConfiguration()
                self.session.removeInput(input as! AVCaptureInput)
                self.session.addInput(newInput)
                self.session.commitConfiguration()
                break
            }
        }
        
    }
    func cameraWithPosition(position:AVCaptureDevicePosition) -> AVCaptureDevice?{
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            if device.position == position {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    func flashOfCamera(btn:UIButton){
        btn.selected = !btn.selected
        var mode:AVCaptureFlashMode!
        if btn.selected {
            mode = .On
        }else {
            mode = .Off
        }
        if self.device.isFlashModeSupported(mode) {
            self.flashLightModel({ () -> Void in
                self.device.flashMode = mode
            })
        }
       
    }
    
    func flashLightModel(codeBlock:(()->Void)?){
        if codeBlock == nil {
            return
        }
        self.session.beginConfiguration()
        do {
            try self.device.lockForConfiguration()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        codeBlock!()
        self.device.unlockForConfiguration()
        self.session.commitConfiguration()
        self.session.startRunning()
        
    }
    
//    func saveImageToAlbum(){
//        let status = PHPhotoLibrary.authorizationStatus()
//        if status == .Denied{
//            print("当前用户不允许访问相册")
//        }else if status == .NotDetermined {
//            print("用户还没有做出选择")
//        }else if status == .Authorized {
//            print("用户允许访问相册")
//            self.saveImage()
//        }
//    }
    func collection() -> PHAssetCollection {
        let topLevelUserCollections:PHFetchResult = PHAssetCollection.fetchTopLevelUserCollectionsWithOptions(nil)
        for i in 0  ..< topLevelUserCollections.count {
            let sub = topLevelUserCollections[i]
            if sub.localizedTitle == "ihappy"{
                return sub as! PHAssetCollection
            }
        }
        
        var collectionID:AnyObject!
        do {
        try PHPhotoLibrary.sharedPhotoLibrary().performChangesAndWait { () -> Void in
            collectionID = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle("ihappy")
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        return PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([collectionID as! String], options: nil).firstObject as! PHAssetCollection
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
//    //MARK: -- 屏幕
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return .All
//    }   
//    /**  旋转屏幕 */
//    override func shouldAutorotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) -> Bool {
//        return true
//    }
    /**  一开始是横还是竖 */
//    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
//        return .Portrait
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
