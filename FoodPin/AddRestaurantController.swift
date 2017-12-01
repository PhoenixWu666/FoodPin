//
//  AddRestaurantController.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/10/06.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddRestaurantController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var photoImgView: UIImageView!
    
    @IBOutlet weak var restaurantNameField: UITextField!
    
    @IBOutlet weak var restaurantTypeField: UITextField!
    
    @IBOutlet weak var restaurantLocationField: UITextField!
    
    @IBOutlet weak var phoneNumField: UITextField!
    
    @IBOutlet weak var noBtn: UIButton!
    
    @IBOutlet weak var yesBtn: UIButton!
    
    private var isVisited = false
    
    var restaurant: RestaurantMO!
    
    func saveRecordToCloud(restaurant: RestaurantMO) {
        let record = CKRecord(recordType: "Restaurant")
        var tempFileUrl: URL?
        
        // 儲存文字內容
        record.setValue(restaurant.name, forKey: "name")
        record.setValue(restaurant.type, forKey: "type")
        record.setValue(restaurant.location, forKey: "location")
        record.setValue(restaurant.phoneNumber, forKey: "phone")
        
        if let imgData = restaurant.image {
            if let scaledImg = getScaledImg(img: imgData) {
                if let fileUrl = saveTempImgFile(img: scaledImg, restaurantName: restaurant.name!) {
                    // save image
                    record.setValue(CKAsset(fileURL: fileUrl), forKey: "image")
                    tempFileUrl = fileUrl
                }
            }
        }
        
        // save
        CKContainer.default().publicCloudDatabase.save(record, completionHandler: {
            record, error in
            
            if let url = tempFileUrl {
                // remove temp file after save successfully
                try? FileManager.default.removeItem(at: url)
            }
        })
    }
    
    func saveTempImgFile(img: UIImage, restaurantName: String) -> URL? {
        let url = URL(fileURLWithPath: NSTemporaryDirectory() + restaurantName)
        
        do {
            try UIImageJPEGRepresentation(img, 0.8)?.write(to: url)
            
            return url
        } catch {
            print(error)
            
            return nil
        }
    }
    
    func getScaledImg(img src: Data) -> UIImage? {
        let srcImg = UIImage(data: src)
        let srcImgWidth = srcImg!.size.width
        let scalingFactor = (srcImgWidth > 1024) ? 1024 / srcImgWidth : 1.0
        
        return UIImage(data: src, scale: scalingFactor)
    }
    
    func validateForm() -> Bool {
        let errMsg = "We can't proceed because one of the fields is blank. Please note that all fields are required."
        
        if isEmptyFieldValue(restaurantNameField) {
            displayMsg(errMsg)
            
            return false
        }
        
        if isEmptyFieldValue(restaurantTypeField) {
            displayMsg(errMsg)
            
            return false
        }
        
        if isEmptyFieldValue(restaurantLocationField) {
            displayMsg(errMsg)
            
            return false
        }
        
        if isEmptyFieldValue(phoneNumField) {
            displayMsg(errMsg)
            
            return false
        }
        
        return true
    }
    
    func isEmptyFieldValue(_ field: UITextField) -> Bool {
        let value = field.text
        
        return value == nil || value!.isEmpty
    }
    
    func displayMsg(_ msg: String) {
        let alertController = UIAlertController(title: "Oops", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if validateForm() {
            // save data
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                restaurant = RestaurantMO(context: appDelegate.container.viewContext)
                restaurant.name = restaurantNameField.text
                restaurant.type = restaurantTypeField.text
                restaurant.location = restaurantLocationField.text
                restaurant.isVisited = isVisited
                restaurant.phoneNumber = phoneNumField.text
                
                if let restaurantImg = photoImgView.image {
                    if let imgData = UIImagePNGRepresentation(restaurantImg) {
                        restaurant.image = imgData
                    }
                }
                
                // save
                appDelegate.saveContext()
//                saveRecordToCloud(restaurant: restaurant)
            }
            
            performSegue(withIdentifier: "unwindToHomeScreen", sender: self)
        }
    }
    
    @IBAction func toggleBeenHereBtn(_ sender: UIButton) {
        switch sender {
        case noBtn:
            isVisited = false
            noBtn.backgroundColor = UIColor.red
            yesBtn.backgroundColor = UIColor.lightGray
            
        case yesBtn:
            isVisited = true
            yesBtn.backgroundColor = UIColor.red
            noBtn.backgroundColor = UIColor.lightGray
            
        default:
            break
        }
    }
    
    /**
     configure layout constraint of photoImgView with programming
     */
    fileprivate func configurePhotoImgViewLayoutConstraints() {
        // leading
        NSLayoutConstraint(item: photoImgView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: photoImgView.superview, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        
        // trailing
        NSLayoutConstraint(item: photoImgView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: photoImgView.superview, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        // top
        NSLayoutConstraint(item: photoImgView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: photoImgView.superview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        
        // bottom
        NSLayoutConstraint(item: photoImgView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: photoImgView.superview, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // 在 photoImgView 顯示被選取的圖片
            photoImgView.image = selectImage
            
            // 設定以原圖寬高比例縮放，並填滿整個 view
            photoImgView.contentMode = .scaleAspectFill
            
            // 避免超出範圍，蓋到其它 view，設定限定在範圍內
            photoImgView.clipsToBounds = true
        }
        
        configurePhotoImgViewLayoutConstraints()
        
        // close image picker
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 相片在第一列
        if indexPath.row == 0 {
            
            /*
             先確認使用者是否允許程式存取相片
             .photoLibrary 是 user 的相片庫
             .camera 是 user 的裝置相機
             */
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                // create instance
                let imagePicker = UIImagePickerController()
                
                // set delegate
                imagePicker.delegate = self
                
                // disable editing
                imagePicker.allowsEditing = false
                
                // set source type to photo library
                imagePicker.sourceType = .photoLibrary
                
                // show
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
