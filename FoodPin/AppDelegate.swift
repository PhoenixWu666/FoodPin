//
//  AppDelegate.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/09/11.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    enum QuickAction: String {
        case OpenFavorites = "OpenFavorites"
        case OpenDiscover = "OpenDiscover"
        case NewRestaurant = "NewRestaurant"
        
        init?(fullID: String){
            guard let shortcutID = fullID.components(separatedBy: ".").last else {
                return nil
            }
            
            self.init(rawValue: shortcutID)
        }
    }

    var window: UIWindow?

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FoodPin")
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            
            if let nserror = error as NSError? {
                fatalError("Unresolved error: \(nserror), \(nserror.userInfo)")
            }
        })
        
        return container
    }()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "foodpin.makeReservation" {
            let fetchReq: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchReq.sortDescriptors = [sortDescriptor]
            
            let context = container.viewContext
            let fetchResultController = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            do {
                try fetchResultController.performFetch()
                
                if let result = fetchResultController.fetchedObjects {
                    if result.count > 0 {
                        print("result: \(result.count)")
                        // TODO move to restaurant detail
                    }
                }
            } catch {
                print(error)
            }
        }
        
        completionHandler()
    }
    
    /**
     Function from UIApplicationDelegate.
     實作 quick action item 執行動作
     */
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    private func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        if let tabBarController = window?.rootViewController as? UITabBarController {
            if let shortcutID = QuickAction(fullID: shortcutItem.type) {
                switch shortcutID {
                case .OpenFavorites:
                    tabBarController.selectedIndex = 0
                    
                case .OpenDiscover:
                    tabBarController.selectedIndex = 1
                    
                case .NewRestaurant:
                    return performAddRestaurantCtrl(tabBarCtrl: tabBarController)
                }
                
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func performAddRestaurantCtrl(tabBarCtrl: UITabBarController) -> Bool {
        if let navCtrl = tabBarCtrl.viewControllers?[0] {
            let restaurantTableViewCtrl = navCtrl.childViewControllers[0]
            restaurantTableViewCtrl.performSegue(withIdentifier: "addRestaurant", sender: restaurantTableViewCtrl)
            
            return true
        } else {
            return false
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("Cord Data Saving OK")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Tab bar setting
//        let tabBar = UITabBar.appearance()
//        tabBar.tintColor = UIColor.white
//        tabBar.barTintColor = UIColor(red: 236 / 255, green: 236 / 255, blue: 236 / 255, alpha: 1.0)
//        tabBar.selectionIndicatorImage = UIImage(named: "tabitem-selected")
        
        // 通知許可を求める
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: {
            granted, error in
            
            if granted {
                print("OK")
            } else {
                print("no permission")
            }
        })
        
        // notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // アプリでステータスバーのスタイル設定
        UIApplication.shared.statusBarStyle = .lightContent
        
        let navigationBar = UINavigationBar.appearance()
        
        // navigation bar 背景色
        navigationBar.barTintColor = UIColor(red: 216/255, green: 74/255, blue: 32/255, alpha: 1)
        
        // tintColor 控制導覽項目與導覽列按鈕項目的顏色
        navigationBar.tintColor = UIColor.white
        
        // 導覽標題的字型
        if let barFont = UIFont(name: "AvenirNextCondensed-DemiBold", size: 24) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedStringKey.foregroundColor : UIColor.white,
                NSAttributedStringKey.font : barFont
            ]
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

