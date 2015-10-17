//
//  ExploreFollowCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/11.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class ExploreFollowProvider: ExploreProvider, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, delegateSAStepCell {
    
    class Data {
        var id: String!
        var sid: String!
        var uid: String!
        var user: String!
        var content: String!
        var lastdate: String!
        var title: String!
        var img: String!
        var img0: Float!
        var img1: Float!
        var like: Int!
        var liked: Int!
        var comment: Int!
    }
    
    weak var bindViewController: ExploreViewController?
    var page = 1
    var locked = false
    var dataArray = NSMutableArray()
    
    var targetRect: NSValue?
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.tableView.registerNib(UINib(nibName: "SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
//        viewController.tableView.estimatedRowHeight = 200
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        Api.getExploreFollow("\(page++)", callback: {
            json in
            if json != nil {
                if clear {
                    self.dataArray.removeAllObjects()
                }
                let data: AnyObject? = json!.objectForKey("data")
                let items = data!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    for item in items {
                        self.dataArray.addObject(item)
                    }
                    self.bindViewController?.tableView.tableHeaderView = nil
                } else if clear {
                    self.bindViewController?.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 49 - 64))
                    self.bindViewController?.tableView.tableHeaderView?.addGhost("这是关注页面！\n当你关注了一些人或记本时\n这里会发生微妙变化")
                }
                if self.bindViewController!.current == 0 {
                    self.bindViewController!.tableView.headerEndRefreshing()
                    self.bindViewController!.tableView.footerEndRefreshing()
                    self.bindViewController!.tableView.reloadData()
                }
            }
        })
    }
    
    override func onHide() {
        bindViewController!.tableView.headerEndRefreshing(false)
    }
    
    override func onShow(loading: Bool) {
//        bindViewController!.tableView.reloadData()
        if dataArray.count == 0 {
            bindViewController!.tableView.headerBeginRefreshing()
        } else {
            if loading {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.bindViewController!.tableView.setContentOffset(CGPointZero, animated: false)
                    }, completion: { (Bool) -> Void in
                        self.bindViewController!.tableView.headerBeginRefreshing()
                })
            }
        }
    }
    
    override func onRefresh() {
        load(true)
    }
    
    override func onLoad() {
        load(false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return getHeightCell(dataArray, index: indexPath.row)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
        c.delegate = self
//        if indexPath.row > self.dataArray.count {
//            return c
//        }
        c.data = self.dataArray[indexPath.row] as? NSDictionary
        c.index = indexPath.row
        if indexPath.row == self.dataArray.count - 1 {
            c.viewLine.hidden = true
        } else {
            c.viewLine.hidden = false
        }
        c.setupCell()
        return c
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let viewController = DreamViewController()
        let data = dataArray[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("dream")
        viewController.Id = id
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if dataArray.count > indexPath.row {
            let data = dataArray[indexPath.row] as! NSDictionary
            let type = data.stringAttributeForKey("type")
            
            switch type {
            case "0":
                break
            case "1":
                (cell as! SAStepCell).imageHolder.cancelImageRequestOperation()
                (cell as! SAStepCell).imageHolder.image = nil
            default:
                break
            }
        }
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: AnyObject) {
        SAUpdate(self.dataArray, index: index, key: key, value: value, tableView: bindViewController!.tableView!)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, section: 0, tableView: bindViewController!.tableView!)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(bindViewController!.tableView!)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, dataArray: self.dataArray, index: index, tableView: bindViewController!.tableView!, section: 0)
    }
    
}
















