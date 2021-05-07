//
//  UtilityClass.swift
//  Twak-iOS-Test
//
//  Created by Dinesh Chavda on 05/05/21.
//

import Foundation


let appDelegate = UIApplication.shared.delegate as! AppDelegate

extension UIImageView {
    
    func downloaded(from url: URL, isInvert : Bool,withUser username : String) {
        
        let fileManager = FileManager.default
        let diskPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let cacheDirectory = diskPaths[0] as NSString
        let diskPath = cacheDirectory.appendingPathComponent("\(username).jpg")
        
        if let data = ImageCacheHelper.getObjectForKey(imageKey: url.absoluteString as AnyObject){
            if let userImage =  UIImage(data: data as Data) {
                if isInvert {
                    self.image = self.InvertImage(withImage: userImage)
                } else {
                    self.image = userImage
                }
            }
            
        }else if fileManager.fileExists(atPath: diskPath){
            
            if let image =  UIImage(contentsOfFile: diskPath) {
                if isInvert {
                    self.image = self.InvertImage(withImage: image)
                } else {
                    self.image = image
                }
                let imageData = image.jpegData(compressionQuality: 1.0)
                ImageCacheHelper.setObjectForKey(imageData: imageData! as NSData , imageKey: url.absoluteString as AnyObject)
            }
            
        } else {
            ImageCacheHelper.getImage(imageUrl: url.absoluteString) { (imageData) in
                
                imageData.write(toFile: diskPath, atomically: true)
                DispatchQueue.main.async {
                    if let userImage = UIImage(data: imageData as Data) {
                        
                        if isInvert {
                            self.image = self.InvertImage(withImage: userImage)
                        } else {
                            self.image = userImage
                        }
                    }
                }
            }
        }
    }
    
    func InvertImage(withImage image : UIImage) -> UIImage {
        if let beginImage = CIImage(image: image) {
            if let filter = CIFilter(name: "CIColorInvert") {
                filter.setValue(beginImage, forKey: kCIInputImageKey)
                let invertImg = UIImage(ciImage: filter.outputImage!)
                return invertImg
            }
        }
        return image
    }
}

extension UIViewController {
    func showError(_ title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}




class ImageCacheHelper:NSObject{
    
    static var cache = NSCache<AnyObject, AnyObject>()
    static var isNotRunningDispatch:Bool = true
    
    class func setObjectForKey(imageData:NSData,imageKey:AnyObject){
        
        ImageCacheHelper.cache.setObject(imageData, forKey: imageKey)
    }
    
    class func getObjectForKey(imageKey:AnyObject)->NSData?{
        
        return ImageCacheHelper.cache.object(forKey: imageKey) as? NSData
        
    }
    
    class func getImage(imageUrl:String,completionHandler: @escaping (NSData)->()){
        if ImageCacheHelper.isNotRunningDispatch{
            
            ImageCacheHelper.isNotRunningDispatch = false
            
            DispatchQueue.global(qos: .userInitiated).async {
                if let imgUrl = NSURL(string:imageUrl) as URL? {
                    if let imageData = NSData(contentsOf: imgUrl) {
                        ImageCacheHelper.setObjectForKey(imageData: imageData, imageKey: imgUrl.absoluteString as AnyObject)
                        ImageCacheHelper.isNotRunningDispatch = true
                        completionHandler(imageData)
                    }
                }
            }
            
        }else{
            print("alerady started loading image")
        }
    }
}




