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
#import "DateIdea.h"
#import "UserProfileDateIdeasCell.h"
#import "FirstDate-Swift.h"

@interface UserProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) User *currentUser;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (nonatomic) NSMutableArray *createdDateIdeas;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.createdDateIdeas = [NSMutableArray array];
    self.currentUser = [User currentUser];
    
    self.fullNameLabel.text = self.currentUser.username;
    self.ageLabel.text = [NSString stringWithFormat:@"Age: %lu",self.currentUser.age];
    
    self.userPhotoImageView.layer.cornerRadius = self.userPhotoImageView.frame.size.width/2;
    self.userPhotoImageView.layer.masksToBounds = true;
    
    PhotoHelper *photoHelper = [[PhotoHelper alloc]init];
    [photoHelper getPhotoInBackground:self.currentUser.userPhoto completionHandler:^(UIImage *userPhoto) {
        self.userPhotoImageView.image = userPhoto;
    }];
    [photoHelper getPhotoInBackground:self.currentUser.coverPhoto completionHandler:^(UIImage *coverPhoto) {
        self.photoImageView.image = coverPhoto;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchIdeas];
    [self.collectionView reloadData];
}

- (void)fetchIdeas {
    PFQuery *getLocalIdeas = [PFQuery queryWithClassName:@"DateIdea"];
    [getLocalIdeas whereKey:@"user" equalTo:[User currentUser]];
    [getLocalIdeas fromLocalDatastore];
    [getLocalIdeas findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (results.count) {
            self.createdDateIdeas = [results mutableCopy];
            [self.collectionView reloadData];
        } else {
            PFQuery *getNetworkIdeas = [PFQuery queryWithClassName:@"DateIdea"];
            [getNetworkIdeas whereKey:@"user" equalTo:[User currentUser]];
            [getNetworkIdeas findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (results.count) {
                    self.createdDateIdeas = [results mutableCopy];
                    [self.collectionView reloadData];
                }
            }];
        }
    }];
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
        self.currentUser.coverPhoto = [PFFile fileWithData:data];
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


#pragma mark - Collection View Delegate
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.createdDateIdeas.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserProfileDateIdeasCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"userIdeaCell" forIndexPath:indexPath];
    
    if (self.createdDateIdeas.count) {
        [cell setDateIdea:self.createdDateIdeas[indexPath.row]];
    }
    return cell;
}


@end
