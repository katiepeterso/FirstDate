//
//  DateIdeaHeartedByViewController.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-12.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import WZLBadge

class DateIdeaHeartedByViewController: UITableViewController {
    
    var idea: DateIdea!
    var hearts = [User]()
    var unreadMessageCountFromUser: [Int]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBarHidden = false
        
        guard let heartQuery = idea.heartedBy.query() else {
            return
        }
        
        heartQuery.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if let users = result as? [User] where result!.count > 0 {
                self.hearts += users
                self.unreadMessageCountFromUser = [Int](count: self.hearts.count, repeatedValue: 0)
                
                if let messages = self.idea.messages as? [Message] {
                    var userIndex = 0
                    for user in self.hearts {
                        for message in messages {
                            if message.sendingUser == user && message.isRead.isEqualToNumber(NSNumber(bool: false)) {
                                self.unreadMessageCountFromUser[userIndex]++
                            }
                        }
                        
                        userIndex++
                    }
                }
                
                self.tableView.reloadData()
            }
        })
        
        
    }

    // MARK: - Table view data source -

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hearts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("heartedByCell", forIndexPath: indexPath) as! DateIdeaHeartedByCell
        cell.user = self.hearts[indexPath.row]
        
        let unreadMessageCount = unreadMessageCountFromUser[indexPath.row]
        if unreadMessageCount > 0 {
            cell.usernameLabel.badgeCenterOffset = CGPointMake(-(cell.usernameLabel.frame.width + cell.usernameLabelLeading.constant), -cell.usernameLabelLeading.constant)
            cell.usernameLabel.badgeBgColor = UIColor(red: 255.0/255.0, green: 51.0/255.0, blue: 102.0/255.0, alpha: 1.0)
            cell.usernameLabel.showBadgeWithStyle(.Number, value: unreadMessageCount, animationType: .None)
        }
        
        return cell
    }
    
    // MARK: - Navigation -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessaging" {
            let selectedCell = sender as! DateIdeaHeartedByCell
            selectedCell.usernameLabel.clearBadge()
            let indexPath = tableView.indexPathForCell(selectedCell)
            let messageVC = segue.destinationViewController as! MessagingViewController
            messageVC.receiver = self.hearts[indexPath!.row]
            messageVC.idea = idea
        }
    }

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectedUserProfileVC = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        selectedUserProfileVC.selectedUser = self.hearts[indexPath.row]
        navigationController?.showViewController(selectedUserProfileVC, sender: self)
        
    }
}
