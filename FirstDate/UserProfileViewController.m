//
//  UserProfileViewController.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-24.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "UserProfileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "User.h"

@interface UserProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) User *currentUser;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = [User currentUser];
    // Do any additional setup after loading the view.
    self.fullNameLabel.text = self.currentUser.name;
    self.ageLabel.text = [NSString stringWithFormat:@"%lu",self.currentUser.age];
    if ([self.currentUser.photo isDataAvailable]) {
        [self.currentUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.photoImageView.image = [UIImage imageWithData:data];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Image Picker and display
- (IBAction)profilePhotoTapped:(UITapGestureRecognizer *)sender {
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.mediaTypes = @[(__bridge NSString *)kUTTypeImage];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerController animated:YES completion:nil];
        
    }]];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Take Photo or Video" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerController animated:YES completion:nil];
            
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.photoImageView.image = info[UIImagePickerControllerOriginalImage];
    if (self.photoImageView.image) {
        NSData* data = UIImageJPEGRepresentation(self.photoImageView.image, 0.25);
        self.currentUser.photo = [PFFile fileWithData:data];
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
        } else {
            // There was a problem, check error.description
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
