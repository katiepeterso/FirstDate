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
    
    var newUser = User()

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
    
    var textFields: [UITextField]!
    var activeTextField: UITextField!
    
    lazy var accessoryView: UIToolbar = {
        var av = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.width, 44.0))
        
        let previous = UIBarButtonItem(image: UIImage(named: "previous"), style: .Plain, target: self, action: "previousTextField")
        previous.tintColor = UIColor(red: 80.0/255.0, green: 210.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        
        let next = UIBarButtonItem(image: UIImage(named: "next"), style: .Plain, target: self, action: "nextTextField")
        next.tintColor = UIColor(red: 80.0/255.0, green: 210.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        
        let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneEditing")
        done.tintColor = UIColor(red: 80.0/255.0, green: 210.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        
        av.setItems([previous, next, UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), done], animated: true)
        av.userInteractionEnabled = true
        
        return av
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genderPickerView = UIPickerView()
        datingPreferencePickerView = UIPickerView()
        configurePickerView(genderPickerView)
        configurePickerView(datingPreferencePickerView)
        
        textFields = [nameField, ageField, genderField, datingPreferenceField]
        for textField in textFields {
            configureTextField(textField)
        }
        
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
    
    @IBAction func signUp(sender: UIButton?) {
        let nameString = nameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let ageString = ageField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let genderString = genderField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let datingPreferenceString = datingPreferenceField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if let name = nameString {
            newUser.name = name
        }
        
        if let age = ageString {
            newUser.age = UInt(age) ?? 0
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
    
    @IBAction func backButtonPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
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
    
    func configureTextField(textField: UITextField) {
        textField.delegate = self
        textField.inputAccessoryView = accessoryView
    }
    
    func previousTextField() {
        if activeTextField == nameField {
            textFields.last?.becomeFirstResponder()
        } else {
            if let currentIndex = textFields.indexOf(activeTextField) {
                textFields[currentIndex - 1].becomeFirstResponder()
            }
        }
    }
    
    func nextTextField() {
        if activeTextField == datingPreferenceField {
            textFields.first?.becomeFirstResponder()
        } else {
            if let currentIndex = textFields.indexOf(activeTextField) {
                textFields[currentIndex + 1].becomeFirstResponder()
            }
        }
    }
    
    func doneEditing() {
        view.endEditing(true)
        if nameField.text?.characters.count > 0 && ageField.text?.characters.count > 0 {
            signUp(nil)
        }
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
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
            
        } else {
            datingPreferenceField.text = datingPreferenceOptions[row]
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
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

}
