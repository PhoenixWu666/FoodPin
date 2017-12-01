//
//  WalkthroughContentViewController.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/10/17.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var contentImgView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var forwardBtn: UIButton!
    
    var index = 0
    
    var heading = ""
    
    var imgFile = ""
    
    var content = ""
    
    var pageCount = 0
    
    var finalPageIndex: Int {
        return pageCount > 0 ? pageCount - 1 : 0
    }
    
    var isFinalPage: Bool {
        return index == finalPageIndex
    }
    
    @IBAction func tappedForwardBtn(_ sender: UIButton) {
        if !isFinalPage {
            if let parentController = parent as? WalkthroughPageViewController {
                parentController.forward(index: index + 1)
            }
        } else {
            dismiss(animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
            
            if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                let bundleID = Bundle.main.bundleIdentifier
                var shortItemArray: [UIApplicationShortcutItem] = []
                
                shortItemArray.append(getShortItem(type: "\(bundleID!).OpenFavorites", title: "Show Favorites", icon: createShortIconByFileName(name: "favorite-shortcut")))
                shortItemArray.append(getShortItem(type: "\(bundleID!).OpenDiscover", title: "Discover restaurants", icon: createShortIconByFileName(name: "discover-shortcut")))
                shortItemArray.append(getShortItem(type: "\(bundleID!).NewRestaurant", title: "New Restaurant", icon: UIApplicationShortcutIcon(type: .add)))
                
                UIApplication.shared.shortcutItems = shortItemArray
            }
        }
    }
    
    private func createShortIconByFileName(name: String) -> UIApplicationShortcutIcon {
        return UIApplicationShortcutIcon(templateImageName: name)
    }
    
    private func getShortItem(type: String, title: String, icon: UIApplicationShortcutIcon) -> UIApplicationShortcutItem {
        return UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: icon, userInfo: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headingLabel.text = heading
        contentLabel.text = content
        contentImgView.image = UIImage(named: imgFile)
        pageControl.currentPage = index
        pageControl.numberOfPages = pageCount
        forwardBtn.setTitle(isFinalPage ? "Done" : "Next", for: .normal)
    }

}
