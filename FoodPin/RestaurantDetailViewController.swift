//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/09/25.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RestaurantDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var restaurant: RestaurantMO!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showReview":
                let reviewController = segue.destination as! ReviewViewController
                reviewController.restaurant = restaurant!
                
            case "showMap":
                let mapViewController = segue.destination as! MapViewController
                mapViewController.restaurant = restaurant!
                
            default:
                break
            }
        }
    }
    
    @IBAction func ratingButtonTapped(segue: UIStoryboardSegue) {
        if let rating = segue.identifier {
            restaurant!.isVisited = true
            
            switch rating {
            case "great":
                restaurant!.rating = "Absolutely love it! Must try."
                
            case "good":
                restaurant!.rating = "Pretty good."
                
            case "dislike":
                restaurant!.rating = "I don't like it."
                
            default:
                break
            }
        }
        
        // save updating
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            appDelegate.saveContext()
        }
        
        tableView.reloadData()
    }
    
    @IBAction func close(segue: UIStoryboardSegue) {
        // TODO
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ここはただプロパティの変更だけだ
        navigationController?.hidesBarsOnSwipe = false
        
        // ここは隠されたナビゲーションバーを示す
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RestaurantDetailTableViewCell
        
        // cell 的背景色設成透明
        cell.backgroundColor = UIColor.clear
        
        if let restaurant = self.restaurant {
            switch indexPath.row {
            case 0:
                cell.fieldLabel.text = NSLocalizedString("Name", comment: "name field label")
                cell.valueLabel.text = restaurant.name
                
            case 1:
                cell.fieldLabel.text = NSLocalizedString("Type", comment: "type field label")
                cell.valueLabel.text = restaurant.type
                
            case 2:
                cell.fieldLabel.text = NSLocalizedString("Location", comment: "location field label")
                cell.valueLabel.text = restaurant.location
                
            case 3:
                cell.fieldLabel.text = NSLocalizedString("TEL", comment: "tel field label")
                
                if let phoneNum = restaurant.phoneNumber {
                    cell.valueLabel.text = phoneNum
                } else {
                    cell.valueLabel.text = ""
                }
                
            case 4:
                cell.fieldLabel.text = NSLocalizedString("Been Here", comment: "Been here field label")
                cell.valueLabel.text = restaurant.isVisited ? restaurant.rating : "No"
                
            default:
                setEmptyValueToCell(cell: cell)
            }
        } else {
            setEmptyValueToCell(cell: cell)
        }
        
        return cell
    }
    
    func setEmptyValueToCell(cell: RestaurantDetailTableViewCell) {
        cell.fieldLabel.text = ""
        cell.valueLabel.text = ""
    }
    
    @objc func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         在 mapView 上加入地址標註
         */
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location!, completionHandler: {
            placemarks, error in
            
            if error != nil {
                print(error!)
            } else if let placeMarks = placemarks {
                // 直接取第一個地標
                let placemark = placeMarks[0]
                
                // 建立標註物件
                let annotation = MKPointAnnotation()
                
                // 從地標取得位置
                if let location = placemark.location {
                    // 設定標註的位置
                    annotation.coordinate = location.coordinate
                    
                    // 在 map view 加入標註
                    self.mapView.addAnnotation(annotation)
                    
                    // 設定縮放範圍
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                    self.mapView.setRegion(region, animated: false)
                }
            }
        })
        
        /*
         mapView 的 tap event 處理
         */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.2)
        
        /*
         移除空白列的分隔線
         這行的實質意義是移除掉 table view 的 footer
         */
//        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //設定內容列的分隔線
        tableView.separatorColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.8)

        if let bean = self.restaurant {
            // title of navigation bar
            title = bean.name
            
            // image
            if let imgData = restaurant.image {
                restaurantImageView.image = UIImage(data: imgData)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
