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

@objc class PhotoHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        return UIImageJPEGRepresentation(toImage, 0.95)!
    }
    
    
    class func makeCircleImageView(view: UIImageView) {
        view.layer.cornerRadius = view.frame.width/2
        view.clipsToBounds = true
    }
}

