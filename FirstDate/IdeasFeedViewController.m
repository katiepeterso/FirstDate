//
//  ViewController.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-19.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "AppDelegate.h"
#import "IdeasFeedViewController.h"
#import "IdeaDetailViewController.h"
#import "IdeaFeedCell.h"
#import "DateIdea.h"
#import "FirstDate-Swift.h"
#import "HeartedDateIdea.h"

@interface IdeasFeedViewController () //<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) DateIdea *dateIdea;
@property (nonatomic, strong) NSArray *ideas;
@property (nonatomic, strong) User *currentUser;

@end

@implementation IdeasFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentUser = [User currentUser];
    
    if (!self.currentUser) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor orangeColor];
    
    [self.refreshControl addTarget:self action:@selector(fetchDateIdeas) forControlEvents:UIControlEventValueChanged];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [self fetchDateIdeas];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOut:(UIBarButtonItem *)sender {
    
    [User logOut];
    
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (IBAction)hearted:(UIButton *)heartbutton {
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    User *currentUser = [User currentUser];
    HeartedDateIdea *currentHeart = [[HeartedDateIdea alloc]init];
    
    CGPoint touchedPoint = [self.tableView convertPoint:heartbutton.center fromView:[heartbutton superview]];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchedPoint];

    if (indexPath) {
        DateIdea *currentDateIdea = self.ideas[indexPath.row];
        
        PFQuery *query = [PFQuery queryWithClassName:@"HeartedDateIdea"];
        [query whereKey:@"user" equalTo:currentUser];
        [query whereKey:@"dateIdea" equalTo:currentDateIdea];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (results.count) {
                [results[0] deleteInBackground];
            } else {
                currentHeart.user = currentUser;
                currentHeart.dateIdea = currentDateIdea;
                [currentHeart saveInBackground];
            }
        }];

        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];

    }
    
}

- (IBAction)comment:(UIButton *)commentButton {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter a comment" message:@"Please be respectful!" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Your comment goes here...";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    UITextField *commentTextField = alertController.textFields[0];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Comment *comment = [[Comment alloc] initWithUser:self.currentUser content:commentTextField.text];
        
        CGPoint touchedPoint = [self.tableView convertPoint:commentButton.center fromView:[commentButton superview]];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchedPoint];
        
        if (indexPath) {
            DateIdea *currentDateIdea = self.ideas[indexPath.row];
            
//            [currentDateIdea.comments addObject:comment];
        }
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{
        //
    }];
}

- (void)fetchDateIdeas {
    if (self.currentUser) {
        NSLog(@"Current user: %@", self.currentUser.username);
        PFQuery *query = [PFQuery queryWithClassName:@"DateIdea"];
        query.limit = 30;
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            NSLog(@"Finished Query %@", error);
            self.ideas = objects;
            [self.tableView reloadData];
        }];
        
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
        
    }
    
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ideas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IdeaFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ideaFeedCell" forIndexPath:indexPath];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    
    NSArray *sortedArray = [self.ideas sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    cell.dateIdea = sortedArray[indexPath.row];
    self.ideas = [sortedArray mutableCopy];
    
    [self.ideas[indexPath.row] saveInBackground];
    
    return cell;
}

#pragma mark - Table View Delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180.0;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    } else if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        DateIdea *dateIdea = self.ideas[path.row];
        
        IdeaDetailViewController *ideaDetailVC = segue.destinationViewController;
        ideaDetailVC.dateIdea = dateIdea;
    }
    
}


@end
