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
#import "Heart.h"

@interface IdeasFeedViewController () <FeedCellDelegate>

@property (nonatomic, strong) DateIdea *dateIdea;
@property (nonatomic, strong) NSMutableArray *ideas;
@property (nonatomic, strong) User *currentUser;

@end

@implementation IdeasFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor orangeColor];
    
    [self.refreshControl addTarget:self action:@selector(fetchDateIdeas) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    
    self.currentUser = [User currentUser];
    
    if (!self.currentUser) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
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

- (void)fetchDateIdeas {
    if (self.currentUser) {
        NSLog(@"Current user: %@", self.currentUser.username);
        PFQuery *query = [PFQuery queryWithClassName:@"DateIdea"];
        query.limit = 30;
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            NSLog(@"Finished Query %@", error);
            self.ideas = [objects mutableCopy];
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
    cell.delegate = self;
    
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

#pragma mark - Feed Cell Delegate

- (void)showAlertController:(UIAlertController *)alertController {
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
