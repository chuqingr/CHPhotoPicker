//
//  ViewController.swift
//  CHPhotoPicker
//
//  Created by 杨胜浩 on 16/6/8.
//  Copyright © 2016年 chuqingr. All rights reserved.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        showIn()
    }
    
    func showIn(){
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .Denied || status == .Restricted {
            self.showAlertViewToController()
        }else if status == .NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (statu) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if statu == .Authorized {
                        self.showController()
                    }
                })
                
            })
        }else if status == .Authorized {
            self.showController()
        }
    }
    /**  推出下一个页面 */
    func showController(){
        let VC = CHPhotoPickerController()
        VC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(VC, animated: true)
    }
    /**  显示提醒并跳转 */
    func showAlertViewToController(){
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        let appName = infoDictionary["CFBundleDisplayName"]
        print("\(appName)")
        let alert = UIAlertController(title: "提醒", message: "请在iPhone的“设置->隐私->照片”开启\(appName)访问你的手机相册", preferredStyle: .Alert)
        let action = UIAlertAction(title: "确定", style: .Cancel) { (action) -> Void in
            let url = NSURL(string: "prefs:root=Privacy&path=PHOTOS")!
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

