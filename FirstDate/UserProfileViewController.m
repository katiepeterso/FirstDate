//
//  UserProfileViewController.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-24.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "UserProfileViewController.h"
#import "User.h"

@interface UserProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fullNameLabel.text = [User currentUser].name;
    self.ageLabel.text = [NSString stringWithFormat:@"%lu",[User currentUser].age];
    if ([[User currentUser].photo isDataAvailable]) {
        [[User currentUser].photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
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

@end
