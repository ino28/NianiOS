//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//  change the world

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WeiboSDKDelegate{
    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = BGColor
        var navigationViewController = UINavigationController(rootViewController: WelcomeViewController())
        navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
        navigationViewController.navigationBar.clipsToBounds = true
        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.window!.rootViewController = navigationViewController
        self.window!.makeKeyAndVisible()
        
//        if application.respondsToSelector("isRegisteredForRemoteNotifications") {
//            var settings = UIUserNotificationSettings(forTypes: (UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge), categories: nil)
//            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
//        } else {
//            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge)
//        }
        WeiboSDK.enableDebugMode(false)
        WeiboSDK.registerApp("4189056912")
        WXApi.registerApp("wx08fea299d0177c01")
        MobClick.startWithAppkey("54b48fa8fd98c59154000ff2")
        
        /* 极光推送 */
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            var catagories = NSMutableSet()
            var catagory = UIMutableUserNotificationCategory()
            catagory.identifier = "identifier"
            var action = UIMutableUserNotificationAction()
            action.identifier = "test2"
            action.title = "test"
            action.activationMode = UIUserNotificationActivationMode.Background
            action.authenticationRequired = true
            //YES显示为红色，NO显示为蓝色
            action.destructive = false

            var actions = [action]
            catagory.setActions(actions, forContext: UIUserNotificationActionContext.Minimal)
            catagories.addObject(catagory)
            
            // UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge
            APService.registerForRemoteNotificationTypes( 1 << 0 | 1 << 1 | 1 << 2, categories: catagories as Set<NSObject>)
        } else {
            // UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge
            APService.registerForRemoteNotificationTypes( 1 << 0 | 1 << 1 | 1 << 2, categories: nil)
        }
        APService.setupWithOption(launchOptions)
        
        var notiCenter = NSNotificationCenter.defaultCenter()
        notiCenter.addObserver(self, selector: "handleNetworkReceiveMsg:", name: kJPFNetworkDidReceiveMessageNotification, object: nil)
        
        /* DDLog */
        let formatter = Formatter()
        DDTTYLogger.sharedInstance().logFormatter = formatter
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDLog.logLevel = .Verbose
        DDTTYLogger.sharedInstance().colorsEnabled = true
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.magentaColor(), backgroundColor: nil, forFlag: .Info)
        
        application.cancelAllLocalNotifications()
        
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
//        NSNotificationCenter.defaultCenter().postNotificationName("CircleLeave", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("AppDeactive", object: nil)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("CircleLeave", object: nil)
        
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("AppActive", object: nil)
        vc5._addObserver()
        
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
//        NSNotificationCenter.defaultCenter().postNotificationName("AppActive", object: nil)
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        go {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var newDeviceToken = SAReplace("\(deviceToken)", "<", "")
            newDeviceToken = SAReplace("\(newDeviceToken)", ">", "")
            newDeviceToken = SAReplace("\(newDeviceToken)", " ", "")
            Sa.setObject(newDeviceToken, forKey:"DeviceToken")
            Sa.synchronize()
        }
        
        /* 设置极光推送 */
        
        APService.registerDeviceToken(deviceToken)
        var cc = APService.registrationID()
        logInfo("\(cc)")
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        logError("\(error)")
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        var aps = userInfo["aps"] as! NSDictionary

        
        // TODO: - 处理
        
        handleReceiveRemoteNotification(aps)
        
        APService.handleRemoteNotification(userInfo)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if let s = url.scheme {
            if s == "nian" {
                delay(1, { () -> () in
                    NSNotificationCenter.defaultCenter().postNotificationName("AppURL", object: "\(url)")
                })
                return true
            }else if s == "wb4189056912" {
                return WeiboSDK.handleOpenURL(url, delegate: self)
            }
        }
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                    fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        var aps = userInfo["aps"] as! NSDictionary
                        
        handleReceiveRemoteNotification(aps)
        /*    */
        APService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)

    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        if let s = url.scheme {
            if s == "wb4189056912" {
                return WeiboSDK.handleOpenURL(url, delegate: self)
            }
        }
        return true
    }
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        var json = response.userInfo as NSDictionary
        var uidWeibo = json.stringAttributeForKey("uid")
        var token = json.stringAttributeForKey("access_token")
        if let uid = uidWeibo.toInt() {
            NSNotificationCenter.defaultCenter().postNotificationName("weibo", object:[uid, token])
        }
    }
    
    func handleNetworkReceiveMsg(noti: NSNotification) {
    
    
    }
    
    // 收到消息通知，
    func handleReceiveRemoteNotification(aps: NSDictionary) {
        var content = aps["alert"] as! NSString
        var badge = aps["badge"] as! NSInteger
        var sound = aps["sound"] as! NSString
    }
}

