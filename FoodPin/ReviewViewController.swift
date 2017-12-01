//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/10/02.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit
import CoreData

class ReviewViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var greatBtn: UIButton!
    
    @IBOutlet weak var goodBtn: UIButton!
    
    @IBOutlet weak var dislikeBtn: UIButton!
    
    var restaurant: RestaurantMO!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         播放一個 0.3 秒的動畫，container view 的 size 會從 0 放大至原尺寸
         搭配滑下動畫的起始狀態的話，會成為滑下動畫
         */
        UIView.animate(withDuration: 0.9, animations: {
            // 在動畫結束後，container view 回到原尺寸
            self.containerView.transform = CGAffineTransform.identity
            
            /*
             homework
             close button, great button, good button, dislike button 均需進行位移動畫
             */
            self.closeBtn.transform = CGAffineTransform.identity
            self.greatBtn.transform = CGAffineTransform.identity
            self.goodBtn.transform = CGAffineTransform.identity
            self.dislikeBtn.transform = CGAffineTransform.identity
        })
        
        // 彈跳動畫
        UIView.animate(
            withDuration: 0.4,
            delay: 0.0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 0.2,
            options: .curveEaseInOut,
            animations: {
                self.containerView.transform = CGAffineTransform.identity
            },
            completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         homework
         close button, great button, good button, dislike button 均需進行位移動畫
         */
        closeBtn.transform = CGAffineTransform(translationX: 2000, y: 0)
        greatBtn.transform = CGAffineTransform(translationX: 2000, y: 0)
        goodBtn.transform = CGAffineTransform(translationX: 2000, y: 0)
        dislikeBtn.transform = CGAffineTransform(translationX: 2000, y: 0)
        
        /*
         container view 起始狀態
         尺寸放大或是彈跳動畫時使用
         */
//        containerView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        /*
         container view 起始狀態
         滑下動畫時使用
         */
//        containerView.transform = CGAffineTransform(translationX: 0, y: -1000)
        
        /*
         container view 起始狀態
         結合放大與滑下動畫時使用
         */
        // 縮放起始狀態
        let scaleTransform = CGAffineTransform(scaleX: 0, y: 0)

        // 滑下起始狀態
        let translateTransform = CGAffineTransform(translationX: 0, y: -1000)

        // 將兩者結合的起始狀態
        let combineTransform = scaleTransform.concatenating(translateTransform)

        // 設定 container view 的起始狀態為結合狀態
        containerView.transform = combineTransform

        // 建立 UIBlurEffect 物件，這是指定特效風格的物件
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        
        /*
         以剛才建立的 UIBlurEffect 物件，建立 UIVisualEffectView 物件
         這個是特效物件
         */
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // 設定特效物件的範圍，這裡設成和畫面一致
        blurEffectView.frame = view.bounds
        
        /*
         backgroundImageView 是背景圖的物件
         在背景圖加入剛才建立的特效
         */
        backgroundImageView.addSubview(blurEffectView)
        
        if let restaurant = self.restaurant {
            if let imgData = restaurant.image {
                backgroundImageView.image = UIImage(data: imgData)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
