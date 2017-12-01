//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by Phoenix Wu on 2017/10/24.
//  Copyright © 2017年 Phoenix Wu. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {
    
    var imgCache = NSCache<CKRecordID, NSURL>()
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var restaurants: [CKRecord] = []
    
    // create query with predicate
    var query: CKQuery {
        let query: CKQuery = CKQuery(recordType: "Restaurant", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return query
    }
    
    var queryOperation: CKQueryOperation {
        // create query operation with CKQuery object
        let operation = CKQueryOperation(query: query)
        
        // 想取得的欄位資訊
        operation.desiredKeys = ["name"]
        
        // thread priority
        operation.queuePriority = .veryHigh
        
        // record size limit
        operation.resultsLimit = 50
        
        // 將取得的資料 append 到 controller 的資料儲存區
        operation.recordFetchedBlock = {
            record in
            
            self.restaurants.append(record)
        }
        
        // 完成載入後更新 table view
        operation.queryCompletionBlock = {
            cursor, error in
            
            if let err = error {
                print(err)
            } else {
                // refresh screen when query completed
                OperationQueue.main.addOperation {
                    // close refresh controller
                    if let refreshCtrl = self.refreshControl {
                        if refreshCtrl.isRefreshing {
                            refreshCtrl.endRefreshing()
                        }
                    }
                    
                    // 載入結束後關掉 spinner
                    self.spinner.stopAnimating()
                    
                    // refresh table view
                    self.tableView.reloadData()
                }
            }
        }
        
        return operation
    }
    
    func getRecordImgFetchOperation(record: CKRecord, cellImgUpdAction: @escaping (Data) -> Void) -> CKFetchRecordsOperation {
        // 傳入主鍵值取得特定 record
        let fetchOperation = CKFetchRecordsOperation(recordIDs: [record.recordID])
        
        fetchOperation.desiredKeys = ["image"]
        fetchOperation.queuePriority = .veryHigh
        
        fetchOperation.perRecordCompletionBlock = {
            rec, recID, error in
            
            if let err = error {
                print(err.localizedDescription)
            } else if let rec = rec {
                OperationQueue.main.addOperation {
                    if let imgAsset = rec.object(forKey: "image") as? CKAsset {
                        if let imgData = try? Data.init(contentsOf: imgAsset.fileURL) {
                            // save img cache
                            self.imgCache.setObject(imgAsset.fileURL as NSURL, forKey: rec.recordID)
                            
                            // update cell
                            cellImgUpdAction(imgData)
                        }
                    }
                }
            }
        }
        
        return fetchOperation
    }
    
    @objc func fetchRecordsFromCloud() {
        if restaurants.count > 0 {
            // remove all old records before fetching
            restaurants.removeAll()
            tableView.reloadData()
        }
        
        // Get container
        let cloudContainer = CKContainer.default()
        
        // load data from public DB
        cloudContainer.publicCloudDatabase.add(queryOperation)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        /*
         CKRecord.object(forKey:) 回傳的是 CKRecordValue 型態的物件
         在取用各欄位的值時，必須 cast 相應的 type
         */
        let restaurant = restaurants[indexPath.row]
        cell.textLabel?.text = restaurant.object(forKey: "name") as? String
        
        // 設為預設圖片
        cell.imageView?.image = UIImage(named: "photoalbum")
        
        if let imgFileUrl = imgCache.object(forKey: restaurant.recordID) as URL? {
            print("get img from cache...")
            
            // use img cache if exist
            if let imgData = try? Data.init(contentsOf: imgFileUrl) {
                cell.imageView?.image = UIImage(data: imgData)
            }
        } else {
            // 透過 CKFetchRecordsOperation 取得圖片資訊
            CKContainer.default().publicCloudDatabase.add(getRecordImgFetchOperation(record: restaurant, cellImgUpdAction: {
                imgData in
                
                cell.imageView?.image = UIImage(data: imgData)
            }))
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func initRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControlEvents.valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pull to refresh
        initRefreshControl()
        
        spinner.hidesWhenStopped = true
        
        // 預設位置是在螢幕原點 (0, 0)，所以這裡將它設成 controller default view 的中心
        spinner.center = view.center
        
        // table view 將 spinner 加入 subview
        tableView.addSubview(spinner)
        
        // 開始顯示動畫
        spinner.startAnimating()

        // download data
        fetchRecordsFromCloud()
    }
    
}
