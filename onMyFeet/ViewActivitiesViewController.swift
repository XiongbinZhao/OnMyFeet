//
//  ViewActivitiesViewController.swift
//  onMyFeet
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 OnMyFeet Group. All rights reserved.
//

import UIKit
import CoreData

class ViewActivitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ViewActivitesTableViewCellDelegate {
    
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityTable: UITableView!
    @IBOutlet weak var RainbowView: UIView!
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var DailyView: UIView!
    @IBOutlet weak var WeeklyView: UIView!
    @IBOutlet weak var theLine: LineChart!
    @IBOutlet weak var theSlider: GradientSlider!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var actLabel: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var setStatusBtn: UIButton!
    @IBOutlet weak var viewProgressBtn: UIButton!
    
    
    
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    
//    var index: Int = 0
    var goals = [Goal]()
    var theGoal: Goal?
    var theActivity: Activity?
    var relations: NSMutableSet = []
    var progressRelations: NSMutableSet = []
    var flag = false
    var theStatus: Float = 0.0
    var theName: String = ""
    var headerView: UIView?
    var footerView: UIView?
    var isWeeklyGraphShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityTable.delegate = self
        activityTable.dataSource = self
        
        relations = (theGoal!.mutableSetValue(forKey: "activities"))
        
        self.title = "My Activities"
        
        show()
        
        RainbowView.isHidden = true
        stackView.isHidden = false
        textView.isHidden = false
        textView.delegate = self
        

        let homeBtn = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewActivitiesViewController.goHome))
        homeBtn.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = homeBtn
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        doneBtn.layer.cornerRadius = 5.0;
        doneBtn.layer.borderColor = UIColor.gray.cgColor
        doneBtn.layer.borderWidth = 1.5
        //DailyView.layer.cornerRadius = 10.0
        greenView.layer.cornerRadius = 10.0
        //redView.layer.cornerRadius = 10.0
        
        //setStatusBtn.layer.cornerRadius = 5.0
        setStatusBtn.layer.borderColor = UIColor.gray.cgColor
        setStatusBtn.layer.borderWidth = 1.5
        
        //viewProgressBtn.layer.cornerRadius = 5.0
        viewProgressBtn.layer.borderColor = UIColor.gray.cgColor
        viewProgressBtn.layer.borderWidth = 1.5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        relations = (theGoal!.mutableSetValue(forKey: "activities"))
        activityTable.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
//    func getStatus(slider: GradientSlider) {
//        var status: Float = 0.0
//        var name: String = ""
//        slider.endBlock = {slider, newValue, newLocation in
//            let point = newLocation
//            let pointInCell = slider.convertPoint(point, toView: self.activityTable)
//            let index = self.activityTable.indexPathForRowAtPoint(pointInCell)!.row
//            
//            status = Float(newValue)
//            name = String(self.relations.allObjects[index].valueForKey("name")!)
//            
//            self.changeStatus(name, status: status)
//        }
//    }
    
    func getDate() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components ([.day, .month, .year], from: date)
        
        let year = String(describing: components.year!)
        let month = String(format: "%02d", components.month!)
        let day = String(format: "%02d", components.day!)
        
        let theDate = (year + month + day)
        return theDate
    }
    
//    @IBAction func dailyViewTap(_ gesture: UITapGestureRecognizer?) {
//        
//        if(isWeeklyGraphShowing) {
//            UIView.transition(from: WeeklyView, to: DailyView, duration: 1.0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
//        }
//        else {
//            UIView.transition(from: DailyView, to: WeeklyView, duration: 1.0, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
//        }
//        isWeeklyGraphShowing = !isWeeklyGraphShowing
//    }
    
    //MARK: Activities, Goals and Status
    
    func saveStatus(_ slider: GradientSlider, indexPath: IndexPath) {
        var status: Float = 0.0
        var name: String = ""
        slider.endBlock = {slider, newValue, newLocation in
            let theRelate = self.relations.allObjects[(indexPath as NSIndexPath).row] as! Activity
            name = theRelate.name
            status = Float(newValue)
            self.changeStatus(name, status: status)
        }
    }
    
    func changeStatus(_ name: String, status: Float) {
        let predicate = NSPredicate(format: "name == %@", name)
        var theActivity = Activity.mr_findFirst(with: predicate)
        if theActivity == nil {
            theActivity = Activity.mr_createEntity()
        }
        
        guard let activity = theActivity else {
            return
        }
        
        activity.name = name
        activity.status = status
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        let date = getDate()
        //        GoalDataManager().executeProgressUpdate(NSManagedObjectContext.MR_defaultContext(), theAct: activity, theDate: date, theStatus: status)
        
        let results = ActivityProgress.mr_findAllSorted(by: "date", ascending: true, with: NSPredicate(format: "activity.name == %@ AND date == %@", activity.name, date), in: NSManagedObjectContext.mr_default())
        
        guard let allProgress = results as? [ActivityProgress] else {
            return
        }
        
        print("pay attention here!!!!!!!!!!" + String(theStatus))
        
        if (allProgress.count == 0) {
            let progress = ActivityProgress.mr_createEntity()
            
            guard let newProgress = progress else {
                return
            }
            
            var progressActRelate = NSMutableSet()
            
            newProgress.date = date
            newProgress.status = status
            
            progressActRelate = activity.mutableSetValue(forKey: "activityProgresses")
            progressActRelate.add(newProgress)
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        }
        else {
            allProgress[0].status = status
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        }
        
        setLableText(name)
    }
    
    func deleteActivityAt(idx: IndexPath) {
        let theRelate = relations.allObjects[(idx as NSIndexPath).row] as! Activity
        let theName = theRelate.name
        
        let deletingAlertController = UIAlertController(title: "Deleting Activity \n\"\(theName)\"", message: "Are you sure you want to delete the activity \"\(theName)\"", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .default, handler: {(action) in
            deletingAlertController.dismiss(animated: true, completion: nil)
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            let theActivity = Activity.mr_findFirst(with: NSPredicate(format: "name == %@", theName))
            //            if theActivity == nil {
            //                theActivity = Activity.mr_createEntity()
            //                theActivity?.name = theName
            //                theActivity?.status = 0
            //            }
            
            if let activity = theActivity {
                self.relations.remove(activity)
                if (activity.mutableSetValue(forKey: "goals").count == 0) {
                    activity.mr_deleteEntity()
                }
                
                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
                
                DispatchQueue.main.async {
                    self.activityTable.deleteRows(at: [idx], with: .fade )
                    self.activityTable.reloadSections(IndexSet(integer: 0), with: .none)
                }
            }
            
            deletingAlertController.dismiss(animated: true, completion: nil)
        })
        
        deletingAlertController.addAction(noAction)
        deletingAlertController.addAction(deleteAction)
        self.present(deletingAlertController, animated: true, completion: nil)
    }
    
    func deleteGoal() {
        let deleteGoalAlertController = UIAlertController(title: "Deleting Goal", message: "Are you sure you want to delete the goal", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .default, handler: {(action) in
            deleteGoalAlertController.dismiss(animated: true, completion: nil)
        })
        let deleteGoalAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            //            let goal = Goal.mr_findFirst(with: NSPredicate(format: "answer == %@ AND question = %@", (self.theGoal?.answer!)!, (self.theGoal?.question)!))
            
            
            DispatchQueue.main.async {
                let goal = Goal.mr_findFirst(with: NSPredicate(format: "answer == %@ AND question = %@", (self.theGoal?.answer!)!, (self.theGoal?.question)!))
                goal?.mr_deleteEntity()
                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
                deleteGoalAlertController.dismiss(animated: true, completion: nil)
                self.goBack()
            }
        })
        
        deleteGoalAlertController.addAction(noAction)
        deleteGoalAlertController.addAction(deleteGoalAction)
        self.present(deleteGoalAlertController, animated: true, completion: nil)
    }
    
    //MARK: Setup UI
    func show() {
        imageView.image = UIImage(data: theGoal!.picture! as Data)
        textView.text = theGoal!.answer
    }
    
    func setLableText(_ name: String) {
        
        var dates: [String] = ["", "", "", "", "", "", ""]
        var theDates: [String] = ["", "", "", "", "", "", ""]
        var graphPoints = [Int]()
        
//        let theActivity = GoalDataManager().predicateFetchActivity(NSManagedObjectContext.MR_defaultContext(), theName: name)
        
        var theActivity = Activity.mr_findFirst(with: NSPredicate(format: "name == %@", theName))
        
        
        if theActivity == nil {
            theActivity = Activity.mr_createEntity()
            theActivity?.name = theName
            theActivity?.status = 0
        }
        
        guard let activity = theActivity else {
            return
        }
        
        progressRelations = activity.mutableSetValue(forKey: "activityProgresses")
        print(activity.name)
        print(activity.status)
        print(progressRelations)
        let theArray: NSArray = progressRelations.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as NSArray
        
        if progressRelations.count > 7 {
            for index in 0..<7 {
                let theRelate = theArray.object(at: progressRelations.count-(7-index)) as! ActivityProgress
                print(theRelate)
        
                dates[index] = theRelate.date
                
                theDates[index] = dates[index].substring(with: Range<String.Index> (dates[index].characters.index(dates[index].startIndex, offsetBy: 4)..<dates[index].characters.index(dates[index].endIndex, offsetBy: -2))) + "/" + dates[index].substring(with: Range<String.Index> (dates[index].characters.index(dates[index].endIndex, offsetBy: -2)..<dates[index].endIndex))
                
                graphPoints.append(Int(theRelate.status * 1000.0))
                //print(Int(theRelate.status * 1000.0))
                
            }
        }
        else {
            for index in 0..<progressRelations.count {
                let theRelate = theArray.object(at: index) as! ActivityProgress
                dates[index] = theRelate.date
                print(dates[index])
                
                if (dates[index].characters.count != 0) {
                    theDates[index] = dates[index].substring(with: Range<String.Index> (dates[index].characters.index(dates[index].startIndex, offsetBy: 4)..<dates[index].characters.index(dates[index].endIndex, offsetBy: -2))) + "/" + dates[index].substring(with: Range<String.Index> (dates[index].characters.index(dates[index].endIndex, offsetBy: -2)..<dates[index].endIndex))
                }
                else {
                    theDates[index] = dates[index]
                }
                graphPoints.append(Int(theRelate.status * 1000.0))
                print(Int(theRelate.status * 1000.0))
            }
        }
        
        label1.text = theDates[0]
        label2.text = theDates[1]
        label3.text = theDates[2]
        label4.text = theDates[3]
        label5.text = theDates[4]
        label6.text = theDates[5]
        label7.text = theDates[6]
        theLine.thePoints = graphPoints
        theLine.setNeedsDisplay()
    }
    
    //MARK: User Interaction
    @IBAction func setStatusClick(_ sender: AnyObject) {
        if (isWeeklyGraphShowing) {
            UIView.transition(from: WeeklyView, to: DailyView, duration: 1.0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
            isWeeklyGraphShowing = false
        }
    }
    
    @IBAction func viewProgressClick(_ sender: AnyObject) {
        if(!isWeeklyGraphShowing) {
            UIView.transition(from: DailyView, to: WeeklyView, duration: 1.0, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
            isWeeklyGraphShowing = true
        }
    }
    
    @IBAction func doneBtn(_ sender: UIButton) {
        RainbowView.isHidden = true
        stackView.isHidden = false
        activityTable.reloadData()
        UIView.transition(from: WeeklyView, to: DailyView, duration: 0.0, options: .showHideTransitionViews, completion: nil)
        isWeeklyGraphShowing = false
    }
    
    func chooseSlider(_ slider: GradientSlider, status: CGFloat) {
        slider.actionBlock = {slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            slider.thumbColor = UIColor(hue: newValue / 3, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            CATransaction.commit()
        }
        slider.thumbColor = UIColor(hue: status / 3, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    func goBack(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func goHome(){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func goNext(){
        let storyboardIdentifier = "ChooseActivitiesTableViewController"
        let desController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardIdentifier) as! ChooseActivitiesTableViewController
        //        desController.index = index
        desController.theGoal = theGoal
        self.navigationController!.pushViewController(desController, animated: true)
    }
    
    //MARK: TextView delegate
    func textViewDidEndEditing(_ textView: UITextView) {
        theGoal?.answer = textView.text
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //MARK: TableView Datasource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ViewActivitiesTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for:indexPath) as! ViewActivitiesTableViewCell
        
        let theRelate = relations.allObjects[(indexPath as NSIndexPath).row] as! Activity
        cell.currentIdx = indexPath
        cell.delegate = self
        
        let name = theRelate.name
        let status = CGFloat(theRelate.status)
        
        cell.label.text = name
        
        //        cell.theSlider.thumbColor = UIColor(hue: status / 3, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        //        cell.theSlider.value = status
        
        cell.status.backgroundColor = UIColor(hue: status / 3, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        cell.status.layer.cornerRadius = 5.0
        cell.status.clipsToBounds = true
        cell.status.layer.borderColor = UIColor.gray.cgColor
        cell.status.layer.borderWidth = 1.5
        
        
        cell.programBtn.layer.cornerRadius = 5.0
        cell.programBtn.clipsToBounds = true
        cell.programBtn.layer.borderColor = UIColor.gray.cgColor
        cell.programBtn.layer.borderWidth = 1.5
        
        //chooseSlider(cell.theSlider, status: status)
        //getStatus(cell.theSlider)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView = UIView (frame: CGRect (x: 0, y: 0, width: tableView.width, height: 45))
        headerView!.backgroundColor = UIColor.white
        let addBtn = UIButton (frame: CGRect (x: 30, y: 10, width: tableView.width - 60, height: 30))
        addBtn.setTitle("Tap here to add therapy activities", for: .normal)
        addBtn.setTitleColor(UIColor.white, for: .normal)
        addBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        addBtn.titleLabel?.textAlignment = .center
        addBtn.backgroundColor = UIColor.defaultGreenColor()
        addBtn.layer.cornerRadius = 5.0
        addBtn.clipsToBounds = true
        addBtn.addTarget(self, action: #selector(ViewActivitiesViewController.goNext), for: .touchUpInside)
        headerView!.addSubview(addBtn)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView = UIView (frame: CGRect (x: 0, y: 0, width: tableView.width, height: 45))
        footerView!.backgroundColor = UIColor.white
        let deleteBtn = UIButton (frame: CGRect (x: tableView.width/2-50, y: 10, width: 100, height: 30))
        deleteBtn.setTitle("Delete goal", for: .normal)
        deleteBtn.setTitleColor(UIColor.white, for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        deleteBtn.titleLabel?.textAlignment = .center
        deleteBtn.backgroundColor = UIColor.red
        deleteBtn.layer.cornerRadius = 5.0
        deleteBtn.clipsToBounds = true
        deleteBtn.addTarget(self, action: #selector(ViewActivitiesViewController.deleteGoal), for: .touchUpInside)
        footerView!.addSubview(deleteBtn)
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RainbowView.isHidden = false
        stackView.isHidden = true
        
        let theRelate = relations.allObjects[(indexPath as NSIndexPath).row] as! Activity
        theName = theRelate.name
        theStatus = theRelate.status
        
        actLabel.text = theName
        theSlider.value = CGFloat(theStatus)
        theSlider.thumbColor = UIColor(hue: CGFloat(theStatus) / 3, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        
        chooseSlider(theSlider, status: CGFloat(theStatus))
        saveStatus(theSlider, indexPath: indexPath)
        setLableText(theName)
    }
    
    //MARK: ViewActivitesTableViewCellDelegate
    func deleteBtnDidTapped(_ idx: IndexPath) {
        self.deleteActivityAt(idx: idx)
    }
    
}
