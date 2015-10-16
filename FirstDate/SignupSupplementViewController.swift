//
//  SignupSupplementViewController.swift
//  FirstDate
//
//  Created by Alp Eren Can on 15/10/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import Parse

class SignupSupplementViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var newUser: User!
    
    var username: String!
    var password: String!
    var email: String!

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var datingPreferenceField: UITextField!
    
    @IBOutlet weak var supplementFormBottom: NSLayoutConstraint!
    
    var genderPickerView: UIPickerView!
    var datingPreferencePickerView: UIPickerView!
    let genderOptions = ["Not Specified", "Male", "Female"]
    let datingPreferenceOptions = ["Both", "Men", "Women"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newUser = User(username: username, password: password, email: email)
        
        nameField.delegate = self
        ageField.delegate = self
        genderField.delegate = self
        datingPreferenceField.delegate = self
        
        genderPickerView = UIPickerView()
        datingPreferencePickerView = UIPickerView()
        configurePickerView(genderPickerView)
        configurePickerView(datingPreferencePickerView)
        
        let accessoryView = UIToolbar(frame: CGRectMake(0, 0, view.frame.width, 44.0))
        
        let previous = UIBarButtonItem(image: UIImage(named: "previous"), style: .Plain, target: self, action: "")// TODO: go to previous textField
        let next = UIBarButtonItem(image: UIImage(named: "next"), style: .Plain, target: self, action: "")// TODO: go to next textField
        let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "endEditing:")
        done.tintColor = UIColor(red: 80.0/255.0, green: 210.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        
        accessoryView.setItems([previous, next, UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), done], animated: true)
        
        ageField.inputAccessoryView = accessoryView

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        PhotoHelper.makeCircleImageView(self.photoImageView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Actions
    
    @IBAction func signUp(sender: UIButton) {
        let nameString = nameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let ageString = ageField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let genderString = genderField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let datingPreferenceString = datingPreferenceField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if let name = nameString {
            newUser.name = name
        }
        
        if let age = ageString {
            newUser.age = UInt(age)!
        }
        
        if genderString == "Male" {
            newUser.gender = .Male
        } else if genderString == "Female" {
            newUser.gender = .Female
        } else {
            newUser.gender = .NotSpecified
        }
        
        if datingPreferenceString == "Men" {
            newUser.datingPreference = .Men
        } else if datingPreferenceString == "Women" {
            newUser.datingPreference = .Women
        } else {
            newUser.datingPreference = .Both
        }
        
        newUser.signUpInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                let alertController = UIAlertController(title: "Oops! Something went wrong.", message: "\(error?.description)", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // MARK: - Gesture Recognizers
    
    @IBAction func setProfilePhotoTapRecognized(gesture: UITapGestureRecognizer) {
        PhotoHelper.displayImagePicker(self, delegate: self)
    }
    
    // MARK: = Helper Functions
    
    func configurePickerView(pickerView: UIPickerView) {
        pickerView.dataSource = self
        pickerView.delegate = self
        
        if pickerView == genderPickerView {
            genderField.inputView = pickerView
        } else {
            datingPreferenceField.inputView = pickerView
        }
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if newUser == nil {
            newUser == User(username: username, password: password, email: email)
        }
        
        let imageData = PhotoHelper.setView(photoImageView, toImage: info[UIImagePickerControllerOriginalImage] as! UIImage)
        
        newUser.userPhoto = PFFile(data: imageData)
        newUser.userPhoto.saveInBackground()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Picker View Data Source
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderPickerView {
            return genderOptions.count
        } else {
            return datingPreferenceOptions.count
        }
    }
    
    // MARK: - Picker View Delegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPickerView {
            return genderOptions[row]
        } else {
            return datingPreferenceOptions[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPickerView {
            genderField.text = genderOptions[row]
            genderField.resignFirstResponder()
            
        } else {
            datingPreferenceField.text = datingPreferenceOptions[row]
            datingPreferenceField.resignFirstResponder()
        }
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44.0;
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Handle System Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        UIView.animateWithDuration(0.25) { () -> Void in
            self.supplementFormBottom.constant = self.getKeyboardHeight(notification) + 16
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.25) { () -> Void in
            self.supplementFormBottom.constant = 16
            self.view.layoutIfNeeded()
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
