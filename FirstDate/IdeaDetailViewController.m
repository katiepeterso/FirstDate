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
    
    PFQuery *getComments = [PFQuery queryWithClassName:@"Comment"];
    [getComments whereKey:@"dateIdea" equalTo:self.dateIdea];
    [getComments findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (results.count) {
            self.comments = results;
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.comments.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IdeaDescriptionCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"ideaDescriptionCell" forIndexPath:indexPath];
    CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    NumberOfHeartsCell *heartsCell = [tableView dequeueReusableCellWithIdentifier:@"numberOfHeartsCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        [heartsCell setDateIdea:self.dateIdea];
        return heartsCell;
    }else if (indexPath.row == 1) {
        [descriptionCell setDateIdea:self.dateIdea];
        return descriptionCell;
    }else {
        [commentCell setDateIdea:self.dateIdea];
        return commentCell;
    }
}

@end
