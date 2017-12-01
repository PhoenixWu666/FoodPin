//
//  AboutTableViewController.swift
//  FoodPin
//
//  Created by Phoenix Wu on 2017/10/23.
//  Copyright © 2017年 Phoenix Wu. All rights reserved.
//

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {
    
    var sectionTitles = ["Leave Feedback", "Follow Us"]
    var sectionContent = [["Rate us on App Store", "Tell us your feedback"],
                          ["Twitter", "Facebook", "Pinterest"]]
    var links = ["https://twitter.com/appcodamobile", "https://facebook.com/appcodamobile", "https://www.pinterest.com/appcoda/"]
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                if let url = URL(string: "http://www.apple.com/itunes/charts/paidapps/") {
                    // open url with safari
                    UIApplication.shared.open(url)
                }
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "showWebView", sender: self)
            }
            
        case 1:
            if let url = URL(string: links[indexPath.row]) {
                let safariController = SFSafariViewController(url: url)
                present(safariController, animated: true, completion: nil)
            }
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // 取得目前區塊中，當下要顯示的資料
        cell.textLabel?.text = sectionContent[indexPath.section][indexPath.row]
        
        return cell
    }
    
    // 回傳區塊 header 的標題
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    // 回傳區塊數量
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // 回傳區塊裡有多少列
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionContent[section].count
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // hide footer view
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let testStr = NSLocalizedString("testStr", comment: "")
        print(testStr)
    }

}
