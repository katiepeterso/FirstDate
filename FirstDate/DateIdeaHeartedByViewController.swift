//
//  DateIdeaHeartedByViewController.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-12.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit

class DateIdeaHeartedByViewController: UITableViewController {
    
    var idea: DateIdea!
    var hearts = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBarHidden = false
        
        guard let heartQuery = idea.heartedBy.query() else {
            return
        }
        
        heartQuery.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if let users = result as? [User] where result!.count > 0 {
                self.hearts += users
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
        return cell
    }
    
    
    // MARK: - Navigation -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessaging" {
            let selectedCell = sender as! DateIdeaHeartedByCell
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
