//
//  PhotoHelper.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-05.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import ParseUI
import Parse
import JSQMessagesViewController

class PhotoHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    class func getPhotoInBackground(file: PFFile?, completionHandler:(resultImage:UIImage?) -> Void) {
        if file != nil {
            file!.getDataInBackgroundWithBlock{
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil && imageData != nil) {
                    completionHandler(resultImage: UIImage(data:imageData!))
                } else {
                    completionHandler(resultImage: UIImage(named: "add photo")!)
                }
            }

        } else {
            completionHandler(resultImage: UIImage(named: "add photo")!)
        }
    }
    
    
    class func displayImagePicker(controller: UIViewController, delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = delegate
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            controller.presentViewController(pickerController, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
            
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let cameraAction = UIAlertAction(title: "Take Photo or Video", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                pickerController.sourceType = UIImagePickerControllerSourceType.Camera
                controller.presentViewController(pickerController, animated: true, completion: nil)
            })
            alertController.addAction(cameraAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    class func setView(view: UIImageView, toImage: UIImage) -> NSData {
        view.image = toImage
        
        var actualHeight : CGFloat = toImage.size.height
        var actualWidth : CGFloat = toImage.size.width
        let maxHeight : CGFloat = 600.0
        let maxWidth : CGFloat = 800.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        let compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        toImage.drawInRect(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();
        
        return imageData!;
    }
    
    class func makeCircleImageView(view: UIImageView) {
        view.layer.cornerRadius = view.frame.width/2
        view.clipsToBounds = true
    }
}

//MARK: NSOperations image downloader -
enum PhotoRecordState {
    case New, Downloaded, Failed
}

class PhotoRecord {
    let name:String
    let url:NSURL
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")
    
    init(name:String, url:NSURL) {
        self.name = name
        self.url = url
    }
}

class PendingOperations {
    lazy var downloadsInProgress = [NSIndexPath:NSOperation]()
    lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
}

class ImageDownloader: NSOperation {
    //1
    let photoRecord: PhotoRecord
    
    //2
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    //3
    override func main() {
        //4
        if self.cancelled {
            return
        }
        //5
        let imageData = NSData(contentsOfURL:self.photoRecord.url)
        
        //6
        if self.cancelled {
            return
        }
        
        //7
        if imageData?.length > 0 {
            self.photoRecord.image = UIImage(data:imageData!)
            self.photoRecord.state = .Downloaded
        }
        else
        {
            self.photoRecord.state = .Failed
            self.photoRecord.image = UIImage(named: "Failed")
        }
    }
}


