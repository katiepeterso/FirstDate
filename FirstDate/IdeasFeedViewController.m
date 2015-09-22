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

@interface IdeasFeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) DateIdea *dateIdea;
@property (nonatomic, strong) NSMutableArray *ideas;
@property (nonatomic, strong) User *currentUser;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation IdeasFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.ideas = appDelegate.ideas;
    self.currentUser = appDelegate.currentUser;
    
    DateIdea *dateIdea = [[DateIdea alloc] initWithUser:[[User alloc] initWithUsername:@"alperenc"
                                                                                   sex:SexMale
                                                                      datingPreference:DatingPreferenceFemale]
                                                  title:@"Dinner&Movie"
                                                details:@"Going to The Keg for dinner and Scotiabank Theater for Mission Impossible: Rouge Nation"];
    
    [self.ideas addObject:dateIdea];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)hearted:(UIButton *)heartbutton {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    User *currentUser = appDelegate.currentUser;
    
    CGPoint touchedPoint = [self.tableView convertPoint:heartbutton.center fromView:[heartbutton superview]];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchedPoint];
    
    if (indexPath) {
        DateIdea *currentDateIdea = self.ideas[indexPath.row];
        
        if ([currentUser.hearts containsObject:currentDateIdea]) {
            [currentUser.hearts removeObject:currentDateIdea];
        } else {
            [currentUser.hearts addObject:self.ideas[indexPath.row]];
        }
        
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
            
            [currentDateIdea.comments addObject:comment];
        }
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{
        //
    }];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ideas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IdeaFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ideaFeedCell" forIndexPath:indexPath];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    
    NSArray *sortedArray = [self.ideas sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    cell.dateIdea = sortedArray[indexPath.row];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    DateIdea *dateIdea = self.ideas[path.row];
    
    IdeaDetailViewController *ideaDetailVC = segue.destinationViewController;
    ideaDetailVC.dateIdea = dateIdea;
}


@end
