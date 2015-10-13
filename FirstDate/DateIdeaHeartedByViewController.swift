//
//  DateIdeaHeartedByViewController.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-12.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit

class DateIdeaHeartedByViewController: UITableViewController {
    
    var idea: DateIdea?
    var hearts = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let heartQuery = idea?.heartedBy.query()
        heartQuery?.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if let users = result as? [User] where result!.count>0 {
                self.hearts += users
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source -

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.hearts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("heartedByCell", forIndexPath: indexPath) as! DateIdeaHeartedByCell
        cell.user = self.hearts[indexPath.row]

        return cell
    }
    
    
    // MARK: - Navigation -
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showConversation" {
            let messageVC = segue.destinationViewController as! MessagingViewController
//            messageVC.receiver = self.hearts[]
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }

   
}
