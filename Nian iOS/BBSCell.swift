//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class BBSCell: UITableViewCell {
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var View:UIView?
    @IBOutlet var Line:UIView?
    var data :NSDictionary!
    var content:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        
        
        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        content = self.data.stringAttributeForKey("content")
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        self.View!.backgroundColor = BGColor
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!head"
        self.avatarView!.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        self.avatarView!.userInteractionEnabled = true
        self.avatarView!.tag = uid.toInt()!
        
        var height = content.stringHeightWith(17,width:225)
        
        
        
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        self.Line!.backgroundColor = LittleLineColor
        self.Line!.setY(self.contentLabel!.bottom()+16)
        
    }
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        var content = data.stringAttributeForKey("content")
        var height = content.stringHeightWith(17,width:225)
        return height + 80
    }
}