//
//  ChooseActivitiesTableViewController.swift
//  onMyFeet
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 OnMyFeet Group. All rights reserved.
//

import UIKit
import CoreData

class ChooseActivitiesTableViewController: UITableViewController {
    
    var occpationalActs = ["Toilet", "Bath/Shower", "Dressing", "Grooming", "Eating", "Meal Preparation", "Gathering Items", "Carrying Groceries"]
    var physicalActs = ["Transfers", "Bed Mobility", "Walking", "Balance", "Stairs", "Coordination", "Strenthening", "Endurance"]
    
    var names = ["Toilet", "Bath/Shower", "Dressing", "Grooming", "Eating", "Meal Preparation", "Gathering Items", "Carrying Groceries", "Transfers", "Bed Mobility", "Walking", "Balance", "Stairs", "Coordination", "Strenthening", "Endurance"]
    
    var selectedIndexes = [NSIndexPath]() {
        didSet {
            tableView.reloadData()
        }
    }
    var theIndexes = [Int]()
    
//    var index: Int = 0
    var goals = [Goal]()
    var activities = [Activity]()
    var theGoal: Goal?
    var theActivity: Activity?
    var footerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        goals = Goal.MR_findAll() as! [Goal]
//        theGoal = goals[index]
        
        //        let backBtn = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChooseActivitiesTableViewController.goBack))
        //        backBtn.tintColor = UIColor.whiteColor()
        //        navigationItem.leftBarButtonItem = backBtn
        
        let nextBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChooseActivitiesTableViewController.done))
        nextBtn.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = nextBtn
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return occpationalActs.count
        case 1:
            return physicalActs.count
        case 2:
            return 0
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooseActivitiesTableViewCell", forIndexPath: indexPath) as! ChooseActivitiesTableViewCell
        
        switch (indexPath.section) {
        case 0:
            cell.label.text = occpationalActs[indexPath.row]
        case 1:
            cell.label.text = physicalActs[indexPath.row]
        default:
            cell.label.text = "Other"
        }
        
        if self.selectedIndexes.indexOf(indexPath) == nil {
            cell.checkView.hidden = true
        }
        else {
            cell.checkView.hidden = false
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section) {
        case 0:
            if let indexSelected = selectedIndexes.indexOf(indexPath) {
                selectedIndexes.removeAtIndex(indexSelected)
                theIndexes.removeAtIndex(indexSelected)
            }
            else {
                selectedIndexes.append(indexPath)
                theIndexes.append(indexPath.row)
            }
        case 1:
            if let indexSelected = selectedIndexes.indexOf(indexPath) {
                selectedIndexes.removeAtIndex(indexSelected)
                theIndexes.removeAtIndex(indexSelected)
            }
            else {
                selectedIndexes.append(indexPath)
                theIndexes.append(indexPath.row + occpationalActs.count)
            }
        default:
            if let indexSelected = selectedIndexes.indexOf(indexPath) {
                selectedIndexes.removeAtIndex(indexSelected)
            }
            else {
                selectedIndexes.append(indexPath)
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
        
        switch (section) {
        case 0:
            headerCell.button.hidden = true
            headerCell.label.text = "Occupational Therapy Activities"
            headerCell.backgroundColor = UIColor (red: 248/255, green: 235/255, blue: 195/255, alpha: 0.95)
        case 1:
            headerCell.button.hidden = true
            headerCell.label.text = "Physical Therapy Activities"
            headerCell.backgroundColor = UIColor (red: 234/255, green: 253/255, blue: 251/255, alpha: 0.95)
        case 2:
            headerCell.button.hidden = false
            headerCell.label.hidden = true
            headerCell.button.addTarget(self, action: #selector(ChooseActivitiesTableViewController.setPersonalActivity), forControlEvents: .TouchUpInside)

        default:
            headerCell.label.text = "Others"
        }
        
        return headerCell
    }

    
    func setPersonalActivity() {
        let setAct = UIAlertController(title: "Add a personal activity that is important to you", message: "", preferredStyle: .Alert)
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .Alert)
        setAct.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Enter your personal activity here"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler:{ (action) -> Void in
            let theName = setAct.textFields![0].text
            
            let predicate = NSPredicate(format: "name == %@", theName!)
            self.theActivity = Activity.MR_findFirstWithPredicate(predicate)
            if(self.theActivity == nil) {
                self.theActivity = Activity.MR_createEntity()
                self.theActivity?.name = theName!
                self.theActivity?.status = 0
            }
            
            let actGoalRelation = self.theGoal?.mutableSetValueForKey("activities")
            actGoalRelation?.addObject(self.theActivity!)
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        })
        
        alert.addAction(cancelAction)
        setAct.addAction(saveAction)
        setAct.addAction(cancelAction)
        presentViewController(setAct, animated: true, completion: nil)
    }
    
    func done() {
        for index in 0..<theIndexes.count {
            let theIndex = theIndexes[index]
            let theName = names[theIndex]
            
            let predicate = NSPredicate(format: "name == %@", theName)
            theActivity = Activity.MR_findFirstWithPredicate(predicate)
            if theActivity == nil {
                theActivity = Activity.MR_createEntity()
                theActivity?.name = theName
                theActivity?.status = 0
            }
            
            let actGoalRelation = theGoal!.mutableSetValueForKey("activities")
            actGoalRelation.addObject(theActivity!)
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        }
        goBack()
    }
    
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
}
