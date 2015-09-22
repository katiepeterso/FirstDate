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

@interface IdeasFeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) DateIdea *dateIdea;

@property (nonatomic, strong) NSMutableArray *ideas;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation IdeasFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.ideas = appDelegate.ideas;
    
    DateIdea *dateIdea = [[DateIdea alloc] initWithUser:[[User alloc] initWithUsername:@"alperenc"
                                                                                   sex:SexMale
                                                                      datingPreference:DatingPreferenceFemale]
                                                  title:@"Dinner&Movie"
                                                details:@"Going to The Keg for dinner and Scotiabank Theater for Mission Impossible: Rouge Nation"];
    
    [self.ideas addObject:dateIdea];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ideas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     IdeaFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ideaFeedCell" forIndexPath:indexPath];
     
     cell.dateIdea = self.ideas[indexPath.row];
 
     return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    IdeaDetailViewController *ideaDetailVC = segue.destinationViewController;
    DateIdea *dateIdea = self.ideas[path.row];
    
    ideaDetailVC.dateIdea = dateIdea;
}


@end
