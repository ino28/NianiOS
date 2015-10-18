//
//  VVeboViewController.swift
//  Nian iOS
//
//  Created by Sa on 15/10/17.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

class VVeboViewController: UIViewController, delegateSAStepCell, UIScrollViewDelegate {
    var currenTableView: VVeboTableView?
    var currentDataArray: NSMutableArray?
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == currenTableView {
            currenTableView!.needLoadArrRemoveAll()
        }
    }
    
    // 正在滚动到顶部
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        if scrollView == currenTableView {
            currenTableView!.setscrollToToping(true)
        }
        return true
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollView == currenTableView {
            currenTableView!.setFalseAndLoadContent()
        }
    }
    
    // 已经滚动到顶部
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        if scrollView == currenTableView {
            currenTableView!.setFalseAndLoadContent()
        }
    }
    
    // 按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == currenTableView {
            currenTableView!.loadIfNeed(velocity, targetContentOffset: targetContentOffset)
        }
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: AnyObject) {
        SAUpdate(self.currentDataArray!, index: index, key: key, value: value, tableView: self.currenTableView!)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        let numSection = max(currenTableView!.numberOfSections - 1, 0)
        SAUpdate(index, section: numSection, tableView: self.currenTableView!)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.currenTableView!)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        let numSection = max(currenTableView!.numberOfSections - 1, 0)
        SAUpdate(delete, dataArray: self.currentDataArray!, index: index, tableView: self.currenTableView!, section: numSection)
    }
    
    // 获得高度
    func getHeight(indexPath: NSIndexPath, dataArray: NSMutableArray) -> CGFloat {
        return currenTableView!.getHeight(indexPath, dataArray: dataArray)
    }
    
    // 获得 cell
    func getCell(indexPath: NSIndexPath, dataArray: NSMutableArray, type: Int = 0) -> UITableViewCell {
        let c = currenTableView!.getCell(indexPath, dataArray: dataArray, type: type)
        c.delegate = self
        return c
    }
}