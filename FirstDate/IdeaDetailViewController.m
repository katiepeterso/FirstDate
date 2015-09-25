//
//  IdeaDetailViewController.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "IdeaDetailViewController.h"
#import "FirstDate-Swift.h"
#import "IdeaDescriptionCell.h"
#import "CommentCell.h"
#import "NumberOfHeartsCell.h"

@interface IdeaDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *dateIdeaImageView;
@property (nonatomic) Comment *dateIdeaComment;
@property (nonatomic) NSArray *comments;

@end

@implementation IdeaDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.dateIdea.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.dateIdeaImageView.image = [UIImage imageWithData:data];
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchComments];
    [self.tableView reloadData];
}

- (void)fetchComments {
    PFQuery *getComments = [PFQuery queryWithClassName:@"Comment"];
    [getComments whereKey:@"dateIdea" equalTo:self.dateIdea];
    [getComments findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (results.count) {
            self.comments = results;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.comments.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        NumberOfHeartsCell *heartsCell = [tableView dequeueReusableCellWithIdentifier:@"numberOfHeartsCell" forIndexPath:indexPath];
        [heartsCell setDateIdea:self.dateIdea];
        return heartsCell;
    }else if (indexPath.row == 1) {
        IdeaDescriptionCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"ideaDescriptionCell" forIndexPath:indexPath];
        [descriptionCell setDateIdea:self.dateIdea];
        return descriptionCell;
    }else {
        CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
        [commentCell setDateIdea:self.dateIdea andComment:self.comments[indexPath.row - 2]];
        return commentCell;
    }
}

@end
