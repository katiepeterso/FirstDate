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

const CGFloat coverPhotoOffset = 50;

@interface UserProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (nonatomic) NSMutableArray *createdDateIdeas;
@property (strong, nonatomic) NSMutableArray *heartedDateIdeas;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic) BOOL userPhotoSelected;
@property (weak, nonatomic) IBOutlet UISegmentedControl *userIdeasControl;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.createdDateIdeas = [NSMutableArray array];
    self.heartedDateIdeas = [NSMutableArray array];
    
    self.fullNameLabel.text = User.currentUser.username;
    self.ageLabel.text = [NSString stringWithFormat:@"Age: %lu",User.currentUser.age];
    
    self.userPhotoImageView.layer.cornerRadius = self.userPhotoImageView.frame.size.width/2;
    self.userPhotoImageView.layer.masksToBounds = YES;
    
    [PhotoHelper getPhotoInBackground:User.currentUser.userPhoto completionHandler:^(UIImage *userPhoto) {
        self.userPhotoImageView.image = userPhoto;
    }];
    [PhotoHelper getPhotoInBackground:User.currentUser.coverPhoto completionHandler:^(UIImage *coverPhoto) {
        self.photoImageView.image = coverPhoto;
    }];
    
    [self addDiagonalMaskToImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchIdeas];
    [self fetchHearts];
    self.navigationController.navigationBarHidden = NO;
}

- (void)fetchIdeas {
    PFQuery *getCreatedIdeas = [PFQuery queryWithClassName:@"DateIdea"];
    [getCreatedIdeas whereKey:@"user" equalTo:[User currentUser]];
    [getCreatedIdeas findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            self.createdDateIdeas = [objects mutableCopy];
            [self.collectionView reloadData];
        }
    }];
}

- (void)fetchHearts {
    PFQuery *getHearts = [PFQuery queryWithClassName:@"DateIdea"];
    [getHearts whereKey:@"heartedBy" equalTo:[User currentUser]];
    [getHearts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            self.heartedDateIdeas = [objects mutableCopy];
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark - Image Picker and Display
- (IBAction)profilePhotoTapped:(UITapGestureRecognizer *)sender {
    [PhotoHelper displayImagePicker:self delegate:self];
    self.userPhotoSelected = NO;
}

- (IBAction)userPhotoTapped:(UITapGestureRecognizer *)sender {
    [PhotoHelper displayImagePicker:self delegate:self];
    self.userPhotoSelected = YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    if (info[UIImagePickerControllerOriginalImage]) {
        if (self.userPhotoSelected) {
            NSData *data = [PhotoHelper setView:self.userPhotoImageView toImage:info[UIImagePickerControllerOriginalImage]];
            User.currentUser.userPhoto = [PFFile fileWithData:data];
        } else {
            NSData *data = [PhotoHelper setView:self.photoImageView toImage:info[UIImagePickerControllerOriginalImage]];
            User.currentUser.coverPhoto = [PFFile fileWithData:data];
        }
    }
    
    [User.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
        } else {
            NSLog(@"Error saving cover photo");
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Collection View Delegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return (self.userIdeasControl.selectedSegmentIndex == 0) ?
      self.createdDateIdeas.count:
      self.heartedDateIdeas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserProfileDateIdeasCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"userIdeaCell" forIndexPath:indexPath];
    
    if (self.userIdeasControl.selectedSegmentIndex == 0) {
        if (self.createdDateIdeas.count) {
            [cell setDateIdea:self.createdDateIdeas[indexPath.item]];
        }
    } else {
        if (self.heartedDateIdeas.count) {
            [cell setDateIdea:self.heartedDateIdeas[indexPath.item]];
        }
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *dateDetail = (DetailViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    dateDetail.idea = (self.userIdeasControl.selectedSegmentIndex == 0) ?
        self.createdDateIdeas[indexPath.item]:
        self.heartedDateIdeas[indexPath.item];
    [self presentViewController:dateDetail animated:YES completion:nil];
}

#pragma mark - Cover Photo Mask

- (void)addDiagonalMaskToImage {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    UIBezierPath *trianglePath = [[UIBezierPath alloc]init];
    [trianglePath moveToPoint:(CGPointMake(0, 0))];
    [trianglePath addLineToPoint:CGPointMake(self.headerView.frame.size.width, 0)];
    [trianglePath addLineToPoint:CGPointMake(self.headerView.frame.size.width, self.headerView.frame.size.height - coverPhotoOffset)];
    [trianglePath addLineToPoint:CGPointMake(0, self.headerView.frame.size.height)];
    [trianglePath closePath];
    maskLayer.path = trianglePath.CGPath;
    self.headerView.layer.mask = maskLayer;
}

#pragma mark - Navigation

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    return YES;
}

#pragma mark - Segmented Control

- (IBAction)userIdeasControlAction:(UISegmentedControl *)sender {
    [self.collectionView reloadData];
}

@end
