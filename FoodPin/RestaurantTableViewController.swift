//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/09/11.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class RestaurantTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {
    
    var searchResults: [RestaurantMO] = []
    
    var searchController: UISearchController!
    
    var restaurants: [RestaurantMO] = []
    
    let checkInActionTitle = "Check in"
    
    let undoCheckInActionTitle = "Undo check in"
    
    var fetchResultController: NSFetchedResultsController<RestaurantMO>!
    
    /*
     ローカル通知示す
     */
    func prepareNotification() {
        print("restaurant count: \(restaurants.count)")
        guard restaurants.count > 0 else { return }
        
        let suggestedRestaurant = restaurants[0]
        
        // 通知作る
        let content = UNMutableNotificationContent()
        content.title = "Hello from FoodPin"
        content.subtitle = "お客様に勧めのレストラン"
        content.body = "こんにちは。今日 FoodPin で新しいレストラン見つけましたか？今日のおすすめのレストランは一件あります。\(suggestedRestaurant.name!) をぜひ試していただきましょう！"
        content.sound = UNNotificationSound.default()
        
        // time trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        // notification request
        let request = UNNotificationRequest(identifier: "foodpin.10secTestNotification", content: content, trigger: trigger)
        
        // 通知センターに追加する
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let cellAndIdxTuple = getPreviewCellAndIndex(location: location) {
            if let detailViewController = getRestaurantDetailViewController(idxPath: cellAndIdxTuple.idxPath) {
                previewingContext.sourceRect = cellAndIdxTuple.cell.frame
                
                return detailViewController
            }
        }
        
        return nil
    }
    
    func getRestaurantDetailViewController(idxPath: IndexPath) -> RestaurantDetailViewController? {
        if let viewController =
            storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController {
            
            viewController.restaurant = restaurants[idxPath.row]
            viewController.preferredContentSize = CGSize(width: 0.0, height: 450.0)
            
            return viewController
        } else {
            return nil
        }
    }
    
    func getPreviewCellAndIndex(location: CGPoint) -> (cell: UITableViewCell, idxPath: IndexPath)? {
        guard let idxPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        guard let cell = tableView.cellForRow(at: idxPath) else {
            return nil
        }
        
        return (cell: cell, idxPath: idxPath)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchController.isActive = false
    }
    
    /*
     追加 override 這個 function 是為了防止 user 在搜尋結果的 cell 上進行其它動作。
     */
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !searchController.isActive
    }
    
    /*
     採用 UISearchResultsUpdating 時所需要實作的 function
     搜尋結果有變時會被呼叫
     */
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
    
    func filterContent(for searchText: String) {
        searchResults = restaurants.filter({
            restaurant -> Bool in
            
            if let name = restaurant.name, let location = restaurant.location {
                return name.localizedCaseInsensitiveContains(searchText) || location.localizedCaseInsensitiveContains(searchText)
            } else {
                return false
            }
        })
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // iOS 11 導入新的作法，table view 的變動只需要呼叫 performBatchUpdates(_:completion:) 即可
        tableView.performBatchUpdates({
            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    tableView.insertRows(at: [newIndexPath], with: .fade)
                }
                
            case .delete:
                if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
            case .update:
                if let indexPath = indexPath {
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }
                
            default:
                tableView.reloadData()
            }
            
            if let result = controller.fetchedObjects {
                restaurants = result as! [RestaurantMO]
            }
        }, completion: nil)
    }
    
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        // TODO
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            if let walkthroughPageController = loadViewControllerWithID("WalkthroughController") as? WalkthroughPageViewController {
                present(walkthroughPageController, animated: true, completion: nil)
            }
        }
        
        // 用來測試導覽頁面，想測的時候就將註解拿掉
//        UserDefaults.standard.set(false, forKey: "hasViewedWalkthrough")
        
        // hide navigation bar on swipe
        navigationController?.hidesBarsOnSwipe = true
    }
    
    func loadViewControllerWithID(_ id: String) -> UIViewController? {
        return storyboard?.instantiateViewController(withIdentifier: id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! RestaurantDetailViewController
                let idx = indexPath.row
                
                destinationController.restaurant = searchController.isActive ? searchResults[idx] : restaurants[idx]
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // row index
        let rowIdx = indexPath.row
        
        // share action
        let shareAction = UITableViewRowAction(style: .destructive, title: "⏎\nshare", handler: {
            (action, indexPath) -> Void in
            
            // text that you want to share
            let defaultText = "Just checking at \(self.restaurants[rowIdx].name!)"
            
            // image that you want to share
            if let imgToShare = UIImage(data: self.restaurants[rowIdx].image!) {
                let activityController = UIActivityViewController(activityItems: [defaultText, imgToShare], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
            }
        })
        
        shareAction.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
        
        // delete action
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: {
            (action, indexPath) -> Void in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.container.viewContext
                let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(restaurantToDelete)
                
                // 儲存這次的更動
                appDelegate.saveContext()
            }
        })
        
        return [deleteAction, shareAction]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? searchResults.count : restaurants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let index = indexPath.row
        let restaurant = searchController.isActive ? searchResults[index] : restaurants[index]
        
        if let myCell = cell as? RestaurantTableViewCell {
            myCell.nameLabel.text = restaurant.name
            myCell.locationCell.text = restaurant.location
            myCell.typeLabel.text = restaurant.type
            myCell.thumbnailImageView.image = UIImage(data: restaurant.image!)
            myCell.accessoryType = restaurant.isVisited ? .checkmark : .none
            
            return myCell
        } else {
            cell.textLabel?.text = restaurant.name
            cell.imageView?.image = UIImage(data: restaurant.image!)
            cell.accessoryType = restaurant.isVisited ? .checkmark : .none
            
            return cell
        }
    }

    fileprivate func initSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        initSearchBar(searchController.searchBar)
        
        // 將顯示搜尋結果時，背景變暗的特效關掉
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchResultsUpdater = self
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func initSearchBar(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search restaurants..."
        searchBar.tintColor = UIColor.white
        searchBar.barTintColor = UIColor(red: 218/255, green: 100/255, blue: 78/255, alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 如果裝置有支援 3D Touch 的話，就註冊 peek & pop 事件
        if traitCollection.forceTouchCapability == .available {
//            registerForPreviewing(with: self, sourceView: view)
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        initSearchController()
        
        // Load data
        let fetchReq: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchReq.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.container.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                
                if let result = fetchResultController.fetchedObjects {
                    restaurants = result
                }
            } catch {
                print(error)
            }
        }

        // remove back button's title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 90.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // 通知サンプル
        prepareNotification()
    }
    
}
