//
//  ViewController.swift
//  swiftPickMore
//
//  Created by duzhe on 15/10/15.
//  Copyright © 2015年 duzhe. All rights reserved.
//

import UIKit
import AssetsLibrary
import PhotosUI

protocol PassPhotosDelegate{
    func passPhotos(selected:[CHImage])
}

let AlbumsCell = "AlbumsCell"

class CHPhotoPickerController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource{

    
    var collectionView:UICollectionView!
    var photoDelegate:PassPhotosDelegate?
//    var showPhotoDelegate:ShowPhotosDelegate?
    var assetsLibrary:ALAssetsLibrary!
    var currentAlbum:ALAssetsGroup?
    var tempZuber:CHImage!
    /**  选中的照片数组 */
    var selectedImageArr = NSArray()
    var headerView = CHSelectedImageCell()
    /**  指定相册 */
    var selectedAlbum:PHAssetCollection?
    /**  全部相册 */
    var allAlbums = NSArray()
    //当前选中图，防止重复点击
    var currentIndex:NSIndexPath?
    
    var tableView:UITableView!
    
    
    var photoDatas = CHPhotoDatas()
    
    /**  指定相册图片存放 */
    var imageArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        initCollectionView()
        
        self.edgesForExtendedLayout = .None
        allAlbums = photoDatas.getPhotoListDatas()
        
        selectedAlbum = allAlbums.firstObject as? PHAssetCollection
        /**  获取图片 */
        imageArray = photoDatas.getPhoto(selectedAlbum!)
        
        /**  配置navgationbar */
        setLeftItem()
        setRightItem()
        setTitleView()
        setTableView()

        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showHeaderImage(0)
    }
    
    func setTableView(){
        tableView = UITableView(frame:CGRectZero, style: .Plain)
        self.view.addSubview(tableView)
        tableView.snp_remakeConstraints { (make) -> Void in
            make.right.left.top.equalTo(0)
//            make.top.equalTo(-80 * hScale * CGFloat(allAlbums.count))
            make.height.equalTo(80 * hScale * CGFloat(allAlbums.count))
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: AlbumsCell)
        tableView.separatorStyle = .None
        
    }
    //MARK: -- uitableviewdelegate && uitableviewdatasoure
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAlbums.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AlbumsCell, forIndexPath: indexPath) as UITableViewCell
        photoDatas.firstPhotoThumbnails(allAlbums[indexPath.row] as! PHAssetCollection, resultHandler: { (image, _: [NSObject : AnyObject]?) -> Void in
            cell.imageView?.image = image
        })
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80 * hScale
    }
    
    
    
    func setTitleView(){
        let titleView = UIButton(type: .Custom)
        titleView.setImage(UIImage(named: "showAlbum_normal"), forState: .Normal)
        titleView.setImage(UIImage(named: "showAlbum_selected"), forState: .Selected)
        titleView.setTitle("相机胶卷", forState: .Normal)
        titleView.frame = CGRectMake(0, 0, 90 * wScale, 30)
        titleView.setTitleColor(CHColor(0x2d2d35), forState: .Normal)
        titleView.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10)
        titleView.imageEdgeInsets = UIEdgeInsetsMake(0, 75, 0, -75)
        self.navigationItem.titleView = titleView

    }
    func setRightItem(){
        let rightBtn = UIButton(type: .Custom)
        rightBtn.setTitle("继续", forState: .Normal)
        rightBtn.frame = CGRectMake(0, 0, 40 * wScale, 40 * wScale)
        rightBtn.setTitleColor(CHColor(0xff6d59), forState: .Normal)
        rightBtn.setTitleColor(CHColor(0x929292), forState: .Highlighted)
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        let rightItem = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightItem

    }
    func setLeftItem(){
        let leftBtn = UIButton(type: .Custom)
        leftBtn.setTitle("取消", forState: .Normal)
        leftBtn.frame = CGRectMake(0, 0, 40 * wScale, 40 * wScale)
        leftBtn.whenTapped { () -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
        leftBtn.setTitleColor(CHColor(0x929292), forState: .Normal)
        leftBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        leftBtn.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        let leftItem = UIBarButtonItem(customView: leftBtn)
        self.navigationItem.leftBarButtonItem = leftItem
        
    }
    
    /**  初始化collectionview*/
    func initCollectionView(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection =  UICollectionViewScrollDirection.Vertical
        let itemWidth = (SCREEN_WIDTH - 3)/4
        print("SCREEN_WIDTH:\(SCREEN_WIDTH)")
        print("\(itemWidth)")
        let itemHeight:CGFloat = itemWidth
        flowLayout.itemSize = CGSize(width: itemWidth , height: itemHeight)
        flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH + 10)
        flowLayout.minimumLineSpacing = 1 //上下间隔
        flowLayout.minimumInteritemSpacing = 1  //左右间隔
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 10 * hScale, 0)

        collectionView = UICollectionView(frame: CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT), collectionViewLayout: flowLayout)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.backgroundColor = UIColor.clearColor()
        //注册
        self.collectionView.registerClass(CHImageCell.self,forCellWithReuseIdentifier:"cell")
        self.collectionView.registerClass(CHSelectedImageCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headView")
        //设置代理
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(collectionView)
    }
    //MARK: -- uicollectionviewdelegate
    /**  uicollectionviewdelegate */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return imageArray.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CHImageCell;
        if indexPath.item == 0 {
            cell.isSelect = false
            cell.selectBtn.hidden = true
            cell.imageView.image = UIImage(named: "Camera")
        }else {
            /**  默认选中第一张 */
            if indexPath.item == 1 {
                cell.isSelect = true
                (self.imageArray as! [CHImage])[0].isSelected = true
                cell.selectBtn.selected = true
                
            }
            let selectedImage = (imageArray as! [CHImage])[indexPath.item - 1]
            cell.update(selectedImage)
            (imageArray as! [CHImage])[indexPath.item - 1].cellIndex = indexPath.item
            cell.selectBtn.selected = selectedImage.isSelected
            
            cell.handleSelect = {
                self.currentIndex = NSIndexPath(forItem: -1, inSection: 0)
                //找出当前点击的item在图片数组中的位置
                var currentItem:Int = 0
                //真机照片数据量大，--->使用谓词筛选数组
                let predicate = NSPredicate(format: "cellIndex == %@", NSNumber(integer: indexPath.item))
                //是个数组
                let selectedImageA = self.imageArray.filteredArrayUsingPredicate(predicate)
                currentItem = self.imageArray.indexOfObject(selectedImageA.first!)
                //判断按钮状态
                if cell.isSelect{
                    self.setImageArrayData(false, currentItem: currentItem, cell: cell)
                }else{
                    //获取选中数组
                    self.selectedImageArr = self.getSelectedImageArray()
                    if self.selectedImageArr.count < 9 {
                        self.setImageArrayData(true, currentItem: currentItem, cell: cell)
                    }else {
                        let alertView = UIAlertView(title: "你最多只能选择9张照片", message: nil, delegate: self, cancelButtonTitle: "我知道了")
                        alertView.show()
                    }
                }

            }
        }
        return cell
        
    }
    /**  设置图片数组交换 */
    func setImageArrayData(bool:Bool,currentItem:Int,cell:CHImageCell){
        //改变按钮状态
        cell.isSelect = !cell.isSelect
        (self.imageArray as! [CHImage])[currentItem].isSelected = bool
        cell.selectBtn.selected = bool
        
        //获取选中数组
        self.selectedImageArr = self.getSelectedImageArray()
        //下面方法顺序不能改变
        /**  显示头部图片 */
        self.showHeaderImage(currentItem)
        //传递数组给头部视图
        self.headerView.selectedImageArr = self.selectedImageArr
        //交换数据源
        self.imageArray = self.exchange(currentItem, toData: self.selectedImageArr.count - (bool ? 1 : 0), fromArr: self.imageArray as! [CHImage])
        //交换视图 UI
        print("\(self.selectedImageArr.count + (bool ? 0 : 1)),\(currentItem+1)")
        self.collectionView.moveItemAtIndexPath(NSIndexPath(forItem:currentItem+1, inSection: 0) , toIndexPath: NSIndexPath(forItem: self.selectedImageArr.count + (bool ? 0 : 1), inSection: 0))
        
    }
    /**  获取选中数组 */
    func getSelectedImageArray() -> NSArray {
        let predicate1 = NSPredicate(format: "isSelected == true")
        return self.imageArray.filteredArrayUsingPredicate(predicate1)
    }
    //MARK: -- 头部视图
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "headView", forIndexPath: indexPath) as! CHSelectedImageCell
        return headerView
    
    }

    //MARK: -- delegate  选中方法
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        /**  防止重复点击 */
        if indexPath.item == 0 {
            //跳转到相机
            
        }else {
            if self.currentIndex != indexPath{
                print("\(indexPath.item)")
                showHeaderImage(indexPath.item - 1)
                self.currentIndex = indexPath
            }
        }
    }
    
    
    //MARK: -- 显示头部图片  方法封装
    func showHeaderImage(indexItem:Int){
        let headerImageArr:NSArray = self.selectedImageArr
        if let count = (headerImageArr as! [CHImage]).indexOf(self.imageArray[indexItem] as! CHImage) {
            self.headerView.showPhotos(self.imageArray[indexItem] as! CHImage, currentIndex: count)
        }else {
            self.headerView.showPhotos(self.imageArray[indexItem] as! CHImage, currentIndex: -1)
        }
    }
    
    //MARK: --  交换数组指定位置的元素
    func exchange(scoreData:Int,toData:Int,var fromArr:[CHImage]) -> NSArray {
        if scoreData < 0 || toData < 0 {
            return fromArr
        }
        if toData < scoreData {
            let change:CHImage = fromArr[scoreData]
            for var i = scoreData;i>toData;--i {
                fromArr[i] = fromArr[i-1]
            }
            fromArr[toData] = change
        }else {
            let change:CHImage = fromArr[scoreData]
            for var i = scoreData;i<toData;++i {
                fromArr[i] = fromArr[i+1]
            }
            fromArr[toData] = change
        }

        return fromArr as NSArray
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}






