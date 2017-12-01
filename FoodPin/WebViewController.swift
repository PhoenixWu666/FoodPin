//
//  WebViewController.swift
//  FoodPin
//
//  Created by Phoenix Wu on 2017/10/23.
//  Copyright © 2017年 Phoenix Wu. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webView: WKWebView!
    
    // 在載入前進行處理
    override func loadView() {
        // 建立 web view，並且取代 controller 預設的 view
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 載入 web
        if let url = URL(string: "http://www.appcoda.com/contact") {
            webView.load(URLRequest(url: url))
        }
    }

}
