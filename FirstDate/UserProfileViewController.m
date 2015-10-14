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
#import "WZLBadgeImport.h"

const CGFloat coverPhotoOffset = 50;

@interface UserProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *userIdeasControl;

@property (nonatomic) NSMutableArray *createdDateIdeas;
@property (strong, nonatomic) NSMutableArray *heartedDateIdeas;
@property (nonatomic) BOOL userPhotoSelected;
@property (nonatomic) NSMutableDictionary *unreadMessagesCount;


@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.createdDateIdeas = [NSMutableArray array];
    self.heartedDateIdeas = [NSMutableArray array];
    self.unreadMessagesCount = [NSMutableDictionary dictionary];
    
    self.fullNameLabel.text = self.selectedUser.username;
    self.ageLabel.text = [NSString stringWithFormat:@"Age: %lu",self.selectedUser.age];
    
    [PhotoHelper makeCircleImageView:self.userPhotoImageView];
    
    [PhotoHelper getPhotoInBackground:self.selectedUser.userPhoto completionHandler:^(UIImage *userPhoto) {
        self.userPhotoImageView.image = userPhoto;
    }];
    [PhotoHelper getPhotoInBackground:self.selectedUser.coverPhoto completionHandler:^(UIImage *coverPhoto) {
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
    PFQuery *getCreatedIdeas = [DateIdea query];
    [getCreatedIdeas whereKey:@"user" equalTo:self.selectedUser];
    [getCreatedIdeas findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            self.createdDateIdeas = [objects mutableCopy];
            [self.collectionView reloadData];
        }
    }];
}

- (void)fetchHearts {
    PFQuery *getHearts = [DateIdea query];
    [getHearts whereKey:@"heartedBy" equalTo:self.selectedUser];
    [getHearts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            self.heartedDateIdeas = [objects mutableCopy];
            [self.collectionView reloadData];
            for (DateIdea *idea in self.heartedDateIdeas) {
                PFQuery *getUnreadMessagesCount = [Message query];
                [getUnreadMessagesCount includeKey:@"idea"];
                [getUnreadMessagesCount whereKey:@"idea" equalTo:idea];
                [getUnreadMessagesCount whereKey:@"isRead" equalTo:[NSNumber numberWithBool:false]];
                [getUnreadMessagesCount countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
                    if (!error && number > 0) {
                        self.unreadMessagesCount[idea.objectId] = [NSNumber numberWithInt:number];
                        NSLog(@"%d", number);
                        [self.userIdeasControl showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
                        [self.collectionView reloadData];
                    }
                }];
            }
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
            self.selectedUser.userPhoto = [PFFile fileWithData:data];
        } else {
            NSData *data = [PhotoHelper setView:self.photoImageView toImage:info[UIImagePickerControllerOriginalImage]];
            self.selectedUser.coverPhoto = [PFFile fileWithData:data];
        }
    }
    
    [self.selectedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
            DateIdea *heartedIdea = self.heartedDateIdeas[indexPath.item];
            [cell setDateIdea:heartedIdea];
            if ([self.unreadMessagesCount[heartedIdea.objectId] intValue]) {
                [cell showBadgeWithStyle:WBadgeStyleNumber value:[self.unreadMessagesCount[heartedIdea.objectId] intValue] animationType:WBadgeAnimTypeNone];
                cell.badgeCenterOffset = CGPointMake(-16, 12);
            }
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
    [collectionView.visibleCells[indexPath.row] clearBadge];
    [self.navigationController pushViewController:dateDetail animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = (self.view.frame.size.width - 30.0) / 2.0;
    return CGSizeMake(cellWidth, cellWidth);
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
