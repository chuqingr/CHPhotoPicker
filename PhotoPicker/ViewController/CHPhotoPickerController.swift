//
//  CHPhotoPickerController.swift
//  ihappy
//
//  Created by Apple on 16/2/25.
//  Copyright © 2016年 Apple. All rights reserved.
//


import UIKit
import PhotosUI


//protocol PassPhotosDelegate{
//    func passPhotos(selected:[CHImage])
//}

let AlbumsCell = "AlbumsCell"
let AlbumsImageCell = "AlbumsImageCell"

class CHPhotoPickerController: IHBaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource{
    
    /**  导航栏中间 */
    let titleView = UILabel()
    let titleBtn = UIButton(type: .Custom)
    
    
    var collectionView:UICollectionView!
//    var photoDelegate:PassPhotosDelegate?
    var tempZuber:CHImage!
    /**  选中的照片数组 */
    var selectedImageArr = [CHImage]()
    var headerView = CHSelectedImageCell()
    /**  指定相册 */
    var selectedAlbum:PHAssetCollection?
    /**  全部相册 */
    var allAlbums = NSArray()
    //当前选中图，防止重复点击
    var currentIndex:NSIndexPath?
    /**  相册名字数组 */
    var albumsNameArray = [String]()
    var tableView:UITableView!
    
    
    
    var photoDatas = CHPhotoDatas()
    
    /**  指定相册图片存放 */
    var imageArray = [CHImage]()
    
    /**  代码复用 要穿的参数 */
    /**    */
    /**  默认选中第一张图，参数 */
    var isFirstTime = true
    
    
    /**  来自上层的回调 */
    var callBack:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = whC
        initCollectionView()
        
        self.edgesForExtendedLayout = .None
        getFirstAlbums()
        /**  获取照片 */
        imageArray = photoDatas.getPhoto(selectedAlbum!)
//        imageArray[0].isSelected = true
        
//        (self.navigationController! as! IHBaseNavigationController).leftBtn.hidden = true
        /**  配置navgationbar */
        setRightItem()
        setTitleView()
        setTableView()
        
       
    
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showHeaderImage(0)
    }
    
    func setTableView(){
        tableView = UITableView(frame:CGRectMake(0, -80 * hScale * 3, SCREEN_WIDTH, 80 * hScale * 3), style: .Plain)
        self.view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(CHAlubmsCell.self, forCellReuseIdentifier: AlbumsCell)
        
    }
    //MARK: -- uitableviewdelegate && uitableviewdatasoure
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAlbums.count - 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AlbumsCell, forIndexPath: indexPath) as! CHAlubmsCell
        cell.loadPhotoListData(allAlbums[indexPath.row] as! PHAssetCollection)
        albumsNameArray.append(cell.alubmName.text!)
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80 * hScale
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let title = (tableView.cellForRowAtIndexPath(indexPath) as! CHAlubmsCell).alubmName.text!
        titleView.text = "\(title)"
        putTableView()
        selectedAlbum = allAlbums[indexPath.row] as? PHAssetCollection
        /**  换相册之前 先获取当前相册的选中照片 */
        selectedImageArr = self.getSelectedImageArray()
        /**  首张照片默认选中重置 */
        isFirstTime = true
        imageArray = selectedImageArr  + photoDatas.getPhoto(selectedAlbum!)
        titleBtn.selected = false
        collectionView.reloadData()
        
        
    }
    
    
    
    func setTitleView(){
        let bgView = UIView()
        bgView.frame = CGRectMake(0, 0, 90 * wScale, 30)
        
        
        
        bgView.addSubview(titleBtn)
        titleBtn.snp_makeConstraints { (make) in
            make.right.bottom.equalTo(0)
            make.size.equalTo(CGSizeMake(20, 30))
        }
        titleBtn.setImage(UIImage(named: "showAlbum_normal"), forState: .Normal)
        titleBtn.setImage(UIImage(named: "showAlbum_selected"), forState: .Selected)
//        titleView.setTitle("相机胶卷", forState: .Normal)
//        titleView.frame = CGRectMake(0, 0, 90 * wScale, 30)
        bgView.addSubview(titleView)
        titleView.snp_makeConstraints { (make) in
            make.right.equalTo(titleBtn.snp_left)
            make.centerY.equalTo(titleBtn)
        }
        titleView.textColor = labelColor
        titleView.font = UIFont.systemFontOfSize(17)
        titleView.text = "相机胶卷"
//        titleView.setTitleColor(CHColor(0x2d2d35), forState: .Normal)
//        titleView.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10)
//        titleView.imageEdgeInsets = UIEdgeInsetsMake(0, (titleView.titleLabel?.width)!, 0, -(titleView.titleLabel?.width)!)
        bgView.whenTapped { () -> Void in
            self.titleBtn.selected = !self.titleBtn.selected
            if self.titleBtn.selected {
                self.showTableView()
            }else {
                self.putTableView()
            }
            
        }
        self.navigationItem.titleView = bgView
        
    }
    
    func showTableView(){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80 * hScale * 3)
        })
    }
    func putTableView(){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.tableView.frame = CGRectMake(0, -80 * hScale * 3, SCREEN_WIDTH, 80 * hScale * 3)
        })
    }
    func setRightItem(){
        let rightBtn = UIButton(type: .Custom)
        rightBtn.setTitle("继续", forState: .Normal)
        rightBtn.frame = CGRectMake(0, 0, 40 * wScale, 40 * wScale)
        rightBtn.setTitleColor(CHColor(0xff6d59), forState: .Normal)
        rightBtn.setTitleColor(CHColor(0x929292), forState: .Highlighted)
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        rightBtn.whenTapped { () -> Void in
            let VC = IHPublishViewController()
            self.selectedImageArr = self.getSelectedImageArray()
            for i in 0 ..< self.selectedImageArr.count {
                let asset = self.selectedImageArr[i].asset
                    CHPhotoDatas().photoDefault(asset,synchronous:true, targetSize: PHImageManagerMaximumSize, resultHandler: { (image, info:[NSObject : AnyObject]?) -> Void in
                            let downloadfinished = !(info![PHImageResultIsDegradedKey] as! Bool)
                            if downloadfinished {
                                VC.imageArray.append(image!)
                            }
                    })
                
            }
//            var leftBtn = UIButton(type: .Custom)
//            leftBtn = (self.navigationController! as! IHBaseNavigationController).leftBtn
//            leftBtn.setImage(UIImage(named: "pop"), forState: .Normal)
//            leftBtn.frame = CGRectMake(0, 0, 20, 40)
//            (self.navigationController! as! IHBaseNavigationController).leftBtn.hidden = false
            VC.callBack = self.callBack
            self.navigationController!.pushViewController(VC, animated: true)
            
        }
        let rightItem = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightItem
        
    }

    
    /**  初始化collectionview*/
    func initCollectionView(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection =  UICollectionViewScrollDirection.Vertical
        let itemWidth = (SCREEN_WIDTH - 3)/4
        let itemHeight:CGFloat = itemWidth
        flowLayout.itemSize = CGSize(width: itemWidth , height: itemHeight)
        flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH)
        flowLayout.minimumLineSpacing = 1 //上下间隔
        flowLayout.minimumInteritemSpacing = 1  //左右间隔
        flowLayout.sectionInset = UIEdgeInsetsMake(10 * hScale, 0, 10 * hScale, 0)
        
        collectionView = UICollectionView(frame: CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT - 64), collectionViewLayout: flowLayout)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.backgroundColor = UIColor.clearColor()
        //注册
        self.collectionView.registerClass(CHImageCell.self,forCellWithReuseIdentifier:AlbumsImageCell)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AlbumsImageCell, forIndexPath: indexPath) as! CHImageCell;
        if indexPath.item == 0 {
            cell.selectBtn.hidden = true
            cell.imageView.image = UIImage(named: "camera")
        }else {
            cell.selectBtn.hidden = false
            /**  默认选中第一张 */
            if indexPath.item == 1 && isFirstTime{
                (self.imageArray)[0].isSelected = true
                isFirstTime = false
            }
            let selectedImage = (imageArray)[indexPath.item - 1]
            cell.update(selectedImage)
            selectedImage.cellIndex = indexPath.item
            cell.selectBtn.selected = selectedImage.isSelected
            cell.handleSelect = {
                self.currentIndex = NSIndexPath(forItem: -1, inSection: 0)
                //找出当前点击的item在图片数组中的位置
                var currentItem:Int = 0
                //真机照片数据量大，--->使用谓词筛选数组
                let predicate = NSPredicate(format: "cellIndex == %@", NSNumber(integer: indexPath.item))
                //是个数组
                let selectedImageA = (self.imageArray as NSArray).filteredArrayUsingPredicate(predicate)
                currentItem = (self.imageArray as NSArray).indexOfObject(selectedImageA.first!)
                //判断按钮状态
                if cell.selectBtn.selected{
                    self.setImageArrayData(currentItem, cell: cell)
                }else{
                    //获取选中数组
                    self.selectedImageArr = self.getSelectedImageArray()
                    if self.selectedImageArr.count < MAX_IMAGENUMBER {
                        self.setImageArrayData(currentItem, cell: cell)
                    }else {
                        self.showAlertView()
                        
                    }
                }
                
            }
        }
        return cell
    }
    /**  设置图片数组交换 */
    func setImageArrayData(currentItem:Int,cell:CHImageCell){
        //改变按钮状态
//        cell.isSelect = !cell.isSelect
        
        
        let bool = cell.selectBtn.selected
        cell.selectBtn.selected = !bool
        (self.imageArray )[currentItem].isSelected = !bool
        
        
        
        //获取选中数组
        self.selectedImageArr = self.getSelectedImageArray()
        //下面方法顺序不能改变
        /**  显示头部图片 */
        self.showHeaderImage(currentItem)
        //传递数组给头部视图
        self.headerView.selectedImageArr = self.selectedImageArr
        //交换数据源
        self.imageArray = self.exchange(currentItem, toData: self.selectedImageArr.count - (bool ? 0 : 1), fromArr: self.imageArray)
        //交换视图 UI
        self.collectionView.moveItemAtIndexPath(NSIndexPath(forItem:currentItem+1, inSection: 0) , toIndexPath: NSIndexPath(forItem: self.selectedImageArr.count + (bool ? 1 : 0), inSection: 0))
        
    }
    /**  获取选中数组 */
    func getSelectedImageArray() -> [CHImage] {
        let predicate1 = NSPredicate(format: "isSelected == true")
        return (self.imageArray as NSArray).filteredArrayUsingPredicate(predicate1) as! [CHImage]
    }
    //MARK: -- 头部视图
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "headView", forIndexPath: indexPath) as! CHSelectedImageCell
        return headerView
        
    }
    
    //MARK: -- delegate  选中方法
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item == 0 {
            //获取选中数组
            self.selectedImageArr = self.getSelectedImageArray()
            if self.selectedImageArr.count < MAX_IMAGENUMBER{
                let cameraController = CHCameraPickerViewController()
                /**  回调 */
                cameraController.callback = { (array) -> () in
                    self.getFirstAlbums()
                    /**  获取图片 */
                    self.imageArray = [self.photoDatas.getPhoto(self.selectedAlbum!).first!] + self.imageArray
                    self.collectionView.reloadData()
                }
                /**  首张照片默认选中开启 */
                self.isFirstTime = true
                self.presentViewController(cameraController, animated: true, completion: nil)
            }else {
                self.showAlertView()
            }
    
        }else {
            /**  防止重复点击 */
            if self.currentIndex != indexPath{
                showHeaderImage(indexPath.item - 1)
                self.currentIndex = indexPath
            }
        }
    }
    
    
    //MARK: -- 显示头部图片  方法封装
    func showHeaderImage(indexItem:Int){
        if let count = selectedImageArr.indexOf(self.imageArray[indexItem]) {
            self.headerView.showPhotos(self.imageArray[indexItem], currentIndex: count)
        }else {
            self.headerView.showPhotos(self.imageArray[indexItem], currentIndex: -1)
        }
    }
    
    //MARK: --  交换数组指定位置的元素
    func exchange(scoreData:Int,toData:Int,fromArr:[CHImage]) -> [CHImage] {
        if scoreData < 0 || toData < 0 {
            return fromArr
        }
        var array = fromArr
        if toData < scoreData {
            let change:CHImage = fromArr[scoreData]
            for i in toData..<scoreData {
                let j = toData + scoreData - i
                array[j] = array[j-1]
            }
            array[toData] = change
        }else {
            let change:CHImage = fromArr[scoreData]
            for i in scoreData..<toData {
                array[i] = array[i+1]
            }
            array[toData] = change
        }
        
        return array
    }
    
    

    //MARK: -- 获取相机胶卷
    func getFirstAlbums(){
        allAlbums = photoDatas.getPhotoListDatas()
        selectedAlbum = allAlbums.firstObject as? PHAssetCollection
        
    }
    
    //MARK: -- 显示提示框
    func showAlertView(){
        let alertView = UIAlertView(title: "你最多只能选择\(MAX_IMAGENUMBER)张照片", message: nil, delegate: self, cancelButtonTitle: "我知道了~")
        alertView.show()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}






