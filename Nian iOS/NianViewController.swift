//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol AddDreamDelegate {
    func addDreamCallback(_ id: String, img: String, title: String)
}

protocol DeleteDreamDelegate {
    func deleteDreamCallback(_ id: String)
}

class NianViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout, NIAlertDelegate, AddDreamDelegate, DeleteDreamDelegate, ShareDelegate {
    @IBOutlet var coinButton:UIButton!
    @IBOutlet var levelButton:UIButton!
    @IBOutlet var UserHead:UIImageView!
    @IBOutlet var UserName:UILabel!
    @IBOutlet var UserStep:UILabel!
    @IBOutlet var imageBG:UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var labelTableRight: UILabel!
    @IBOutlet var labelTableLeft: UILabel!
    @IBOutlet var viewMenu: UIView!
    @IBOutlet var imageBadge: SABadgeView!
    @IBOutlet var viewHolderHead: UIView!
    @IBOutlet var imageSettings: UIImageView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet weak var dynamicSummary: UIButton!
    
    var currentCell:Int = 0
    var lastPoint:CGPoint!
    var dataArray = NSMutableArray()
    var actionSheet:UIActionSheet!
    var imagePicker:UIImagePickerController!
    var uploadUrl:String = ""
    var navView: UIImageView!
    var viewHeader: UIView!
    var birthday: String = ""
    
    // uploadWay，当上传封面时为 0，上传头像时为 1
    var uploadWay:Int = 0
    var heightScroll:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        load()
    }
    
    func setupViews(){
        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 49)
        self.scrollView.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 49)
        self.scrollView.contentSize.height = globalHeight - 49 > 640 ? globalHeight - 49 : 640
        self.scrollView.alwaysBounceVertical = true
        self.extendedLayoutIncludesOpaqueBars = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.scrollView.contentOffset.y = -64
        
        self.viewHolder.frame = CGRect(x: 0, y: 0, width: globalWidth, height: 320)
        self.imageBG.frame = CGRect(x: 0, y: 0, width: globalWidth, height: 320 - 64)
        self.viewMenu.setWidth(globalWidth)
        self.labelTableLeft.setX(globalWidth/2 - 160 + 20)
        self.labelTableRight.setX(globalWidth/2 + 160 - 20 - 80)
        self.viewHolderHead.frame.origin.x = globalWidth/2-32
        self.UserName.frame.origin.x = globalWidth/2-120
        self.UserStep.frame.origin.x = globalWidth/2-65
        self.coinButton.frame.origin.x = globalWidth/2-104
        self.levelButton.frame.origin.x = globalWidth/2-104+108
        
        self.activity.setX(globalWidth - 24 - 40)
        self.activity.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.activity.isHidden = true
        self.dynamicSummary.setX(globalWidth - 44)
        self.dynamicSummary.addTarget(self, action: #selector(NianViewController.toActivitiesSummary(_:)), for: .touchUpInside)
        
        self.UserHead.layer.cornerRadius = 30
        self.UserHead.layer.masksToBounds = true
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.labelTableRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NianViewController.addDreamButton)))
        
        self.navView = UIImageView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        self.navView.backgroundColor = UIColor.NavColor()
        self.navView.isHidden = true
        self.navView.clipsToBounds = true
        self.navView.isUserInteractionEnabled = true
        self.view.addSubview(self.navView)
        
        viewHeader = UIView(frame: CGRect(x: 0, y: 375, width: globalWidth, height: 200))
        let viewQuestionHeader = viewEmpty(globalWidth, content: "先随便写个记本吧\n比如日记、英语、画画...")
        viewQuestionHeader.setY(0)
        let btnGoHeader = UIButton()
        btnGoHeader.setButtonNice("  嗯！")
        btnGoHeader.setX(globalWidth/2-50)
        btnGoHeader.setY(viewQuestionHeader.bottom())
        btnGoHeader.addTarget(self, action: #selector(NianViewController.addDreamButton), for: UIControlEvents.touchUpInside)
        viewHeader.addSubview(viewQuestionHeader)
        viewHeader.addSubview(btnGoHeader)
        viewHeader.isHidden = true
        self.scrollView.addSubview(viewHeader)
        
        let nib = UINib(nibName: "NianCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "NianCell")
        
        let safename = Cookies.get("user") as? String
        let cacheCoverUrl = Cookies.get("coverUrl") as? String
        
        if safename != nil {
            self.UserName.text = "\(safename!)"
        }
        self.UserHead.setHead(SAUid())
        
        if cacheCoverUrl != nil && cacheCoverUrl != "http://img.nian.so/cover/!cover" && cacheCoverUrl != "http://img.nian.so/cover/background.png!cover" {
            self.imageBG.setCover(cacheCoverUrl!)
        } else {
            self.imageBG.image = UIImage(named: "bg")
            self.imageBG.contentMode = UIViewContentMode.scaleAspectFill
        }
        
        self.setupUserTop()
        self.coinButton.addTarget(self, action: #selector(NianViewController.coinClick), for: UIControlEvents.touchUpInside)
        self.levelButton.addTarget(self, action: #selector(NianViewController.levelClick), for: UIControlEvents.touchUpInside)
        self.UserStep.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NianViewController.stepClick)))
        self.UserName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NianViewController.stepClick)))
        self.UserHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NianViewController.headClick)))
        imageSettings.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NianViewController.headClick)))
        imageSettings.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(NianViewController.EggShell(_:))))
        
        self.viewHolderHead.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.imageBadge.setX(globalWidth/2 + 60/2 - 14)
        NotificationCenter.default.addObserver(self, selector: #selector(NianViewController.QuickActionsEgg), name: NSNotification.Name(rawValue: "QuickActionsEgg"), object: nil)
    }
    
    @objc func EggShell(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            showEgg()
        }
    }
    
    var i = 0
    // 3D Touch 下的调用彩蛋
    @objc func QuickActionsEgg() {
        showEgg()
    }
    
    func showEgg() {
        let eggShell = NIAlert()
        eggShell.delegate = self
        eggShell.dict = NSMutableDictionary(objects: [UserHead, " 彩蛋！", "你在念的第一瞬间\n\(self.birthday)", ["太开心"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
        eggShell.showWithAnimation(.flip)
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            let skView = SKView(frame: CGRect(x: 0, y: 0, width: 272, height: 108))
            if #available(iOS 8.0, *) {
                skView.allowsTransparency = true
            }
            eggShell._containerView!.addSubview(skView)
            scene.scaleMode = SKSceneScaleMode.aspectFit
            skView.presentScene(scene)
            scene.setupViews()
            eggShell._containerView?.sendSubview(toBack: skView)
        }
    }
    
    func niAlert(_ niAlert: NIAlert, didselectAtIndex: Int) {
        niAlert.dismissWithAnimation(.normal)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let height = scrollView.contentOffset.y
            self.heightScroll = height
            if self.viewHolder != nil {
                if height > -64 {
                    if height > globalWidth {
                        self.imageBG.isHidden = true
                    }else{
                        self.imageBG.frame = CGRect(x: 0, y: height, width: globalWidth, height: 320 - height - 64 - 64)
                        self.imageBG.isHidden = false
                    }
                }else{
                    self.viewHolder!.setY(height)
                    self.viewMenu.setY(height + 320)
                    self.imageBG.frame = CGRect(x: height/10, y: height, width: globalWidth-height/5, height: 320 - 64)
                }
                scrollHidden(self.viewHolderHead, scrollY: 68 - 64)
                scrollHidden(self.imageBadge, scrollY: 68 - 64)
                scrollHidden(self.UserName, scrollY: 138 - 64)
                scrollHidden(self.UserStep, scrollY: 161 - 64)
                scrollHidden(self.coinButton, scrollY: 214 - 64)
                scrollHidden(self.levelButton, scrollY: 214 - 64)
                scrollHidden(self.imageSettings, scrollY: 50 - 64)
                scrollHidden(self.dynamicSummary, scrollY: 50 - 64)
                scrollHidden(self.activity, scrollY: 50 - 64)
                if height >= 320 - 64 - 64 {
                    self.navView.isHidden = false
                }else{
                    if self.navView != nil {
                        self.navView.isHidden = true
                    }
                }
            }
            let a = scrollView.contentOffset
            print(a)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visiblePaths = self.collectionView!.indexPathsForVisibleItems as Array
        
        for item in visiblePaths {
            let indexPath = item 
            let cell = self.collectionView!.cellForItem(at: indexPath) as! NianCell
            if cell.imageCover.image == nil {
            
            }
        }
    }
    
    func scrollHidden(_ theView:UIView, scrollY:CGFloat){
        if ( self.heightScroll > scrollY - 50 && self.heightScroll <= scrollY ) {
            theView.alpha = ( scrollY - self.heightScroll ) / 50
        }else if self.heightScroll > scrollY {
            theView.alpha = 0
        }else{
            theView.alpha = 1
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setupUserTop(_ willRefreshCover: Bool = true){
        let safeuid = SAUid()
        if let uid = Int(safeuid) {
            Api.getUserTop(uid){ json in
                if json != nil {
                    if let j = json as? NSDictionary {
                        let error = j.stringAttributeForKey("error")
                        if error == "0" {
                            let _data = json!.object(forKey: "data") as! NSDictionary
                            let data = _data.object(forKey: "user") as! NSDictionary
                            let name = data.stringAttributeForKey("name")
                            let coin = data.stringAttributeForKey("coin")
                            let dream = data.stringAttributeForKey("dream")
                            let step = data.stringAttributeForKey("step")
                            let coverURL = data.stringAttributeForKey("cover")
                            self.birthday = V.relativeTime(data.stringAttributeForKey("lastdate"))
                            let petCount = data.stringAttributeForKey("pet_count")
                            let AllCoverURL = "http://img.nian.so/cover/\(coverURL)!cover"
                            let vip = data.stringAttributeForKey("vip")
                            let member = data.stringAttributeForKey("member")
                            Cookies.set(member as AnyObject?, forKey: "member")
                            let deadLine = data.stringAttributeForKey("deadline")
                            self.coinButton.setTitle("念币 \(coin)", for: UIControlState())
                            self.levelButton.setTitle("宠物 \(petCount)", for: UIControlState())
                            self.UserName.text = "\(name)"
                            self.UserHead.setHead(safeuid)
                            self.imageBadge.setType(vip)
                            if deadLine == "0" {
                                self.UserStep.text = "\(dream) 记本，\(step) 进展"
                            } else {
                                self.UserStep.text = "倒计时 \(deadLine)"
                            }
                            if willRefreshCover {
                                if coverURL == "" {
                                    self.imageBG.image = UIImage(named: "bg")
//                                    self.navView.image = UIImage(named: "bg")
                                    self.navView.contentMode = UIViewContentMode.scaleAspectFill
                                } else {
//                                    self.navView.setCover(AllCoverURL)
                                    self.imageBG.setCover(AllCoverURL)
                                }
                            }
                            Cookies.set(name as AnyObject?, forKey: "user")
                            Cookies.set(AllCoverURL as AnyObject?, forKey: "coverUrl")
                            Cookies.set(coin as AnyObject?, forKey: "coin")
                        } else {
                            self.SAlogout()
                        }
                    }
                }
            }
        }
    }
    
    /* 添加记本后，首页上相应地产生变化
    */
    func addDreamCallback(_ id: String, img: String, title: String) {
        let data = NSDictionary(objects: [id, img, title], forKeys: ["id" as NSCopying, "image" as NSCopying, "title" as NSCopying])
        for _d in dataArray {
            if let d = _d as? NSDictionary {
                let _id = d.stringAttributeForKey("id")
                if _id == id {
                    return
                }
            }
        }
        dataArray.insert(data, at: dataArray.count)
        Cookies.set(dataArray, forKey: "NianDreams")
        reloadFromDataArray()
    }
    
    /* 删除记本后，首页上相应地产生变化
    */
    func deleteDreamCallback(_ id: String) {
        if dataArray.count > 0 {
            for i in 0...(dataArray.count - 1) {
                let data = dataArray[i] as! NSDictionary
                let _id = data.stringAttributeForKey("id")
                if _id == id {
                    dataArray.removeObject(at: i)
                    reloadFromDataArray()
                    Cookies.set(dataArray, forKey: "NianDreams")
                    break
                }
            }
        }
    }
    
    @objc func addDreamButton(){
        let vc = AddDreamController(nibName: "AddDreamController", bundle: nil)
        vc.delegateAddDream = self
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func onDreamLabelClick(_ sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        self.onDreamClick("\(tag)")
    }
    
    @objc func stepClick(){
        let safeuid = SAUid()
        let userVC = PlayerViewController()
        userVC.Id = "\(safeuid)"
        self.navigationController!.pushViewController(userVC, animated: true)
    }
    
    @objc func levelClick(){
        let vc = PetViewController()
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func coinClick(){
//        let storyboard = UIStoryboard(name: "Coin", bundle: nil)
//        let viewController = storyboard.instantiateViewControllerWithIdentifier("CoinViewController") 
//        self.navigationController!.pushViewController(viewController, animated: true)
        let vc = Coin()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navShow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
        if let coin = Cookies.get("coin") as? String {
            coinButton.setTitle("念币 \(coin)", for: UIControlState())
        }
        self.scrollView.contentOffset.y = -64
    }
    
    /**
     进入新的设置页面
     */
    @objc func headClick(){
        let vc = NewSettingViewController(nibName: "NewSettingView", bundle: nil)
        vc.coverImage = self.imageBG.image
        vc.avatarImage = self.UserHead.image
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     进入汇总页
     */
    @objc func toActivitiesSummary(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "ActivitiesSummary", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ActivitiesViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onDreamClick(_ ID:String){
        if ID != "0" && ID != "" {
            let vc = DreamViewController()
            vc.Id = ID
            vc.delegateDelete = self
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func onDreamLikeClick(_ sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        let LikeVC = LikeViewController()
        LikeVC.Id = "\(tag)"
        LikeVC.urlIdentify = 3
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    /* 从本地数据中加载 */
    func loadFromLocal() {
        let NianDreams = Cookies.get("NianDreams") as? NSMutableArray
        if NianDreams != nil {
            let mutableArrayLocal = NSMutableArray()
            for data in NianDreams! {
                mutableArrayLocal.add(data)
            }
            self.dataArray = mutableArrayLocal
            reloadFromDataArray()
        }
    }
    
    func load(){
        loadFromLocal()
        
        activity.isHidden = false
        activity.startAnimating()
        
        // 从服务器加载记本数据
        Api.getNian() { json in
            if json != nil {
                self.activity.isHidden = true
                if let j = json as? NSDictionary {
                    let error = j.stringAttributeForKey("error")
                    if error == "0" {
                        let d = j.object(forKey: "data") as! NSDictionary
                        let arr = d.object(forKey: "dreams") as! NSArray
                        
                        let mutableArray = NSMutableArray()
                        
                        var idArrayLocal: [Int] = []
                        var idArrayRemote: [Int] = []
                        
                        // 创建远程记本数组，以及记本的编号数组
                        for data  in arr {
                            mutableArray.add(data)
                            let d = data as! NSDictionary
                            if let id = Int(d.stringAttributeForKey("id")) {
                                idArrayRemote.append(id)
                            }
                        }
                        
                        // 创建本地记本数组，以及记本的编号数组
                        for data in self.dataArray {
                            let d = data as! NSDictionary
                            if let id = Int(d.stringAttributeForKey("id")) {
                                idArrayLocal.append(id)
                            }
                        }
                        
                        /* 当记本在本地和服务器两边数据不相同时
                         ** 以服务器的数据为准
                         ** 同时服务器的数据会覆盖本地的数据
                         */
                        if bubble(idArrayRemote) != bubble(idArrayLocal) {
                            // 启动后不延时
                            self.dataArray = mutableArray
                            Cookies.set(self.dataArray, forKey: "NianDreams")
                            self.reloadFromDataArray()
                        } else {
                            /* 本地与服务器的记本完全相同
                             ** 在完成卡片动画后关闭动画选项
                             */
                            let newArr = NSMutableArray()
                            for id in idArrayLocal {
                                for _data in mutableArray {
                                    if let data = _data as? NSDictionary {
                                        let newId = data.stringAttributeForKey("id")
                                        if newId == "\(id)" {
                                            newArr.add(data)
                                            break
                                        }
                                    }
                                }
                            }
                            self.dataArray = newArr
                            Cookies.set(self.dataArray, forKey: "NianDreams")
                            self.reloadFromDataArray()
                        }
                    }
                }
            }
        }
    }
    
    func reloadFromDataArray() {
        self.collectionView.reloadData()
        let height = ceil(CGFloat(self.dataArray.count) / 3) * 125
        self.collectionView.frame = CGRect(x: globalWidth/2 - 140, y: 320 + 55 - 64, width: 280, height: height)
        let heightContentSize = globalHeight - 49 > 640 ? globalHeight - 49 : 640
        self.scrollView.contentSize.height = heightContentSize > height + 375 + 45 ? heightContentSize : height + 375 + 45
        self.collectionView.contentSize.height = height
        if self.dataArray.count == 0 {
            self.viewHeader.isHidden = false
        }else{
            self.viewHeader.isHidden = true
        }
    }
    
    func onShare(_ avc: UIActivityViewController) {
        self.present(avc, animated: true, completion: nil)
    }
    
    func saegg(_ coin: String, totalCoin: String) {
        /* 如果念币小于 3 */
        if Int(totalCoin) <  3 {
            let ni = NIAlert()
            ni.delegate = self
            ni.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "你获得了念币奖励", ["好"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
            ni.showWithAnimation(.flip)
        } else {
            /* 如果念币多于 3，就出现宠物 */
            let v = SAEgg()
            v.delegateShare = self
            v.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "要以 3 念币抽一次\n宠物吗？", ["嗯！", "不要"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
            v.showWithAnimation(.flip)
        }
        
    }
}


extension NianViewController: NewSettingDelegate {
    func setting(name: String?, cover: UIImage?, avatar: UIImage?) {
        if let _name = name {
            self.UserName.text = _name
        }
        
        if let _cover = cover {
            self.imageBG.image = _cover
        }
        
        if let _avatar = avatar {
            self.UserHead.image = _avatar
        }
        
    }
    
}







