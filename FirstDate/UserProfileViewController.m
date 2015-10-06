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

const CGFloat coverPhotoOffset = 30;

@interface UserProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) User *currentUser;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (nonatomic) NSMutableArray *createdDateIdeas;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (nonatomic) CGFloat kTableHeaderHeight;

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
    
    [PhotoHelper getPhotoInBackground:self.currentUser.userPhoto completionHandler:^(UIImage *userPhoto) {
        self.userPhotoImageView.image = userPhoto;
    }];
    [PhotoHelper getPhotoInBackground:self.currentUser.coverPhoto completionHandler:^(UIImage *coverPhoto) {
        self.photoImageView.image = coverPhoto;
    }];
    
    self.kTableHeaderHeight = self.photoImageView.frame.size.height;
//    [self updateHeaderView];
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
    [PhotoHelper displayImagePicker:self delegate:self];
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

#pragma mark - Cover Photo Mask
-(void)updateHeaderView {
    self.collectionView.contentInset = UIEdgeInsetsMake(self.kTableHeaderHeight-coverPhotoOffset, 0, 0, 0);
    CGRect headerOriginFrame = CGRectMake(0, coverPhotoOffset-self.kTableHeaderHeight, self.collectionView.bounds.size.width, self.photoImageView.frame.size.height);
    self.photoImageView.frame = headerOriginFrame;
    
    if (self.collectionView.contentOffset.y < coverPhotoOffset-self.kTableHeaderHeight) {
        CGRect frame = CGRectMake(self.photoImageView.frame.origin.x, self.collectionView.contentOffset.y, self.photoImageView.frame.size.width, -self.collectionView.contentOffset.y+coverPhotoOffset);
        self.photoImageView.frame = frame;
    }
    [self addDiagonalMaskToImage];
}

-(void)addDiagonalMaskToImage {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    UIBezierPath *trianglePath = [[UIBezierPath alloc]init];
    [trianglePath moveToPoint:(CGPointMake(self.photoImageView.frame.origin.x, self.photoImageView.frame.origin.y))];
    [trianglePath addLineToPoint:CGPointMake(self.photoImageView.frame.size.width, self.photoImageView.frame.origin.y)];
    [trianglePath addLineToPoint:CGPointMake(self.photoImageView.frame.size.width, self.photoImageView.frame.size.height)];
    [trianglePath addLineToPoint:CGPointMake(self.photoImageView.frame.origin.x, self.photoImageView.frame.size.height - coverPhotoOffset)];
    [trianglePath closePath];
    maskLayer.fillColor = (__bridge CGColorRef _Nullable)([UIColor whiteColor]);
    maskLayer.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    maskLayer.path = trianglePath.CGPath;
    self.photoImageView.layer.mask = maskLayer;
}



@end
