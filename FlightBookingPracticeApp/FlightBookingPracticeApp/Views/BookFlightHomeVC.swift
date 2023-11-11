//
//  BookFlightHomeVC.swift
//  FlightBookingPracticeApp
//
//  Created by Salamuddin on 09/11/23.
//

import UIKit
import DropDown
import SwiftDate
import FSCalendar

enum DateFormatTypes {
    public enum RequiredDateFormat:String {
        case onlnyTimeWithZone = "HH:mm:ss.SSS'Z'"
        case fullDateWithZone = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case onlyTimeHH = "HH:mm"
        case onlyTimeWithMeridian = "hh:mm a"
        case onlyDateWithT = "yyyy-MM-dd'T'"
        case dateYearMonth = "yyyy-MM-dd"
        case dummyTime = "00:00:00.000Z"
    }
}

class BookFlightHomeVC: UIViewController {
    
    @IBOutlet weak var bookFlightView: UIView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var departureDateTxt: UITextField!
    @IBOutlet weak var returnDateTxt: UITextField!
    @IBOutlet weak var fromTxtField: UITextField!
    @IBOutlet weak var toTxtField: UITextField!
    @IBOutlet weak var toView: UIView!
    @IBOutlet weak var classTxtField: UITextField!
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var classView: UIView!
    @IBOutlet weak var roundWayBtn: UIButton!
    @IBOutlet weak var oneWayBtn: UIButton!
    @IBOutlet weak var passengersView: UIView!
    @IBOutlet weak var departureCalView: UIView!
    @IBOutlet weak var returnCalView: UIView!
    @IBOutlet weak var findFlightBtn: UIButton!
    @IBOutlet weak var findFlightView: UIView!
    @IBOutlet weak var passengersTxt: UITextField!
    
    var passengersData = ["Adult(12) 1", "Child(2-12) 1", "Infant(0-2) 1"]
    var classData = ["All", "Economy", "Premium"]
    var fromData = ["Dubai (DXB)", "Jeddah (JED)"]
    var toJeddiah = ["Nairobi (NBO)", "Bosaso (BSA)", "Garowe (GGR)", "Mogadishu (MGQ)", "Hargeisa (HGA)"]
    var toDubai = ["Bosaso (BSA)", "Mogadishu (MGQ)", "Hargeisa (HGA)" ]
    var isFromDubai = false
    let popupTransitioningDelegate = PopupTransitioningDelegate()
    var popupViewController: PopupViewController?
    var count = 0
    var countForChild = 0
    var countForInfant = 0
    let fromDropDown = DropDown()
    let toDropDown = DropDown()
    let classDropDown = DropDown()
    let passengerDropDown = DropDown()
    var allAvailableWeekDayNumbers = [Int]()
    var apiParams = [String:Any]()
    
    var oneWay = true
    
    private var datePicker: UIDatePicker!
    private var returnDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        departureDateTxt.delegate = self
        fromTxtField.delegate = self
        toTxtField.delegate = self
        
        uiSetUp()
        startLocationDropDown()
        selectClassDropDown()
        selectPassengerDropDown()
        
        datePicker = UIDatePicker()
        datePicker.minimumDate = Date()
        returnDatePicker = UIDatePicker()
        returnDatePicker.minimumDate = Date()
        returnCalView.isHidden = true
        oneWayBtn.isSelected = true
        oneWayBtn.addTarget(self, action: #selector(toggleButton(_: )), for: .touchUpInside)
        roundWayBtn.addTarget(self, action: #selector(toggleButton(_: )), for: .touchUpInside)
    }
    
    // one way and round trip btn functionalities
    
    @objc func toggleButton(_ sender: UIButton) {
        // Toggle the state of the toggle.
        oneWay = !oneWay
        // Update the appearance of the buttons accordingly.
        if oneWay {
            returnCalView.isHidden = true
            oneWayBtn.isSelected = true
            roundWayBtn.isSelected = false
        } else {
            returnCalView.isHidden = false
            oneWayBtn.isSelected = false
            roundWayBtn.isSelected = true
        }
    }
    
    
    func uiSetUp() {
        findFlightView.layer.cornerRadius = 10
        bookFlightView.layer.cornerRadius = 10
        detailsView.layer.cornerRadius = 10
        toView.layer.cornerRadius = 5
        fromView.layer.cornerRadius = 5
        classView.layer.cornerRadius = 5
        departureCalView.layer.cornerRadius = 5
        returnCalView.layer.cornerRadius = 5
        passengersView.layer.cornerRadius = 5
        roundWayBtn.layer.cornerRadius = 5
        oneWayBtn.layer.cornerRadius = 5
        toView.layer.borderWidth = 1
        toView.layer.borderColor = UIColor.gray.cgColor
        fromView.layer.borderWidth = 1
        fromView.layer.borderColor = UIColor.gray.cgColor
        classView.layer.borderWidth = 1
        classView.layer.borderColor = UIColor.gray.cgColor
        departureCalView.layer.borderWidth = 1
        departureCalView.layer.borderColor = UIColor.gray.cgColor
        returnCalView.layer.borderWidth = 1
        returnCalView.layer.borderColor = UIColor.gray.cgColor
        passengersView.layer.borderWidth = 1
        passengersView.layer.borderColor = UIColor.gray.cgColor
        roundWayBtn.layer.borderWidth = 1
        roundWayBtn.layer.borderColor = UIColor.gray.cgColor
        oneWayBtn.layer.borderWidth = 1
        oneWayBtn.layer.borderColor = UIColor.gray.cgColor
        //returnDateTxt.isUserInteractionEnabled = false
        fromTxtField.isUserInteractionEnabled = false
        toTxtField.isUserInteractionEnabled = false
        classTxtField.isUserInteractionEnabled = false
        
    }
    
    // get the value beween the drop down parenthesis
    
    func getValueBetweenParentheses(in input: String) -> String?{
        do{
            
            let regex = try NSRegularExpression(pattern: "\\((.*?)\\)")
            let matches = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))
            if let match = matches.first {
                let range = Range(match.range(at: 1), in: input)
                return range.map { String(input[$0])
                }
            }
        } catch {
            print("Error creating regular expression: \(error)")
            
        }
        return nil
        
    }
    @IBAction func passegerBtnTapped(_ sender: UIButton) {
        passengerDropDown.show()
    }
    
    
    @IBAction func fromBtnTapped(_ sender: UIButton) {
        if fromTxtField.text == "Dubai (DXB)"{
            isFromDubai = true
        }else{
            isFromDubai = false
        }
        fromDropDown.show()
    }
    
    @IBAction func toBtnTapped(_ sender: UIButton) {
        if isFromDubai == true{
            toDropDown.dataSource = toDubai
            toDropDown.anchorView = toView
            toDropDown.bottomOffset = CGPoint(x: 0, y: (toDropDown.anchorView?.plainView.bounds.height)!)
            toDropDown.topOffset = CGPoint(x: 0, y:-(toDropDown.anchorView?.plainView.bounds.height)!)
            toDropDown.direction = .bottom
            toDropDown.cellHeight = 47
            toDropDown.selectionAction = { [unowned self]
                (index: Int, item: String) in
                print("selected item: \(item) at index: \(index) ")
                self.toTxtField.text = toDubai[index]
                // set the parameters value
                if let from = getValueBetweenParentheses(in: fromTxtField.text ?? ""),
                   let to = getValueBetweenParentheses(in: toTxtField.text ?? "") {
                    let params = ["From": from, "To": to] as [String: Any]
                    self.apiParams = params
                }
                
            }
        }else{
            toDropDown.dataSource = toJeddiah
            toDropDown.anchorView = toView
            toDropDown.bottomOffset = CGPoint(x: 0, y: (toDropDown.anchorView?.plainView.bounds.height)!)
            toDropDown.topOffset = CGPoint(x: 0, y:-(toDropDown.anchorView?.plainView.bounds.height)!)
            toDropDown.direction = .bottom
            toDropDown.cellHeight = 47
            toDropDown.selectionAction = { [unowned self]
                (index: Int, item: String) in
                print("selected item: \(item) at index: \(index) ")
                self.toTxtField.text = toJeddiah[index]
            }
        }
        toDropDown.show()
    }
    
    @IBAction func classBtnTapped(_ sender: UIButton) {
        classDropDown.show()
    }
    
    // find flight btn
    
    @IBAction func findFlightBtnTapped(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ShowingFlightVC") as! ShowingFlightVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // from drop down
    func startLocationDropDown() {
        
        fromDropDown.anchorView = fromView
        fromDropDown.dataSource = fromData
        fromDropDown.bottomOffset = CGPoint(x: 0, y: (fromDropDown.anchorView?.plainView.bounds.height)!)
        fromDropDown.topOffset = CGPoint(x: 0, y:-(fromDropDown.anchorView?.plainView.bounds.height)!)
        fromDropDown.direction = .bottom
        fromDropDown.cellHeight = 47
        fromDropDown.selectionAction = { [unowned self]
            (index: Int, item: String) in
            print("selected item: \(item) at index: \(index) ")
            self.fromTxtField.text = fromData[index]
            
            if fromTxtField.text == "Dubai (DXB)"{
                isFromDubai = true
            }else{
                isFromDubai = false
            }
            
        }
    }
    // class drop down
    func selectClassDropDown() {
        classDropDown.anchorView = classView
        classDropDown.dataSource = classData
        classDropDown.bottomOffset = CGPoint(x: 0, y: (classDropDown.anchorView?.plainView.bounds.height)!)
        classDropDown.topOffset = CGPoint(x: 0, y:-(classDropDown.anchorView?.plainView.bounds.height)!)
        classDropDown.direction = .bottom
        classDropDown.cellHeight = 47
        classDropDown.selectionAction = { [unowned self]
            (index: Int, item: String) in
            print("selected item: \(item) at index: \(index) ")
            self.classTxtField.text = classData[index]
        }
        
        
    }
    // passengers drop down
    func selectPassengerDropDown() {
        passengerDropDown.anchorView = passengersView
        passengerDropDown.dataSource = passengersData
        passengerDropDown.bottomOffset = CGPoint(x: 0, y: (passengerDropDown.anchorView?.plainView.bounds.height)!)
        passengerDropDown.topOffset = CGPoint(x: 0, y:-(passengerDropDown.anchorView?.plainView.bounds.height)!)
        passengerDropDown.direction = .bottom
        passengerDropDown.cellHeight = 47
        passengerDropDown.selectionAction = { [unowned self]
            (index: Int, item: String) in
            print("selected item: \(item) at index: \(index) ")
            self.passengersTxt.text = passengersData[index]
        }
        
        
    }
}

// Text field delegate
extension BookFlightHomeVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == departureDateTxt {
            showCalendarPopup()
        }
        if textField == returnDateTxt {
            showCalendarPopup()
        }
    }
}

// date extension

extension Date {
    var startOfWeek: Date {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    var startOfMonth: Date {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.month, .weekOfMonth], from: self))!
    }
    
    var addingOneWeek: Date {
        return Calendar.gregorian.date(byAdding: DateComponents(weekOfYear: 1), to: self)!
    }
    var nextDay: Date {
        return Calendar.gregorian.date(byAdding: DateComponents(day: 1), to: self)!
    }
    var nextWeekDay: Date {
        return addingOneWeek
    }
    var addingWeekDay: Date {
        return nextDay
    }
    
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    var dat: String {
        let dateFormatter = DateFormatter()
        //  dateFormatter.calendar = .gregorian
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    
    // append the days into the array
    
    func nextFollowingdays(_ limit: Int) -> [Date] {
        precondition(limit > 0)
        var sundays = [nextWeekDay]
        sundays.reserveCapacity(limit)
        return [addingWeekDay] + (0..<limit-1).compactMap { _ in
            guard let next = sundays.last?.addingOneWeek else { return nil }
            sundays.append(next)
            return next
        }
    }
    
    func nexDay() -> Date{
        return Calendar.gregorian.date(byAdding: DateComponents(day: 1), to: self)!
    }
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

// PopoverPresentationControllerDelegate extension for calender
extension BookFlightHomeVC: UIPopoverPresentationControllerDelegate {
    
    func showCalendarPopup() {
        // Instantiate the popup view controller
        popupViewController = PopupViewController()
        // Set the presentation style to popover
        popupViewController?.modalPresentationStyle = .popover
        // Set the transitioning delegate to handle the custom presentation
        popupViewController?.popoverPresentationController?.delegate = self
        // Set the source view and rect for the popover
        popupViewController?.popoverPresentationController?.sourceView = departureDateTxt
        popupViewController?.popoverPresentationController?.sourceRect = departureDateTxt.frame
        // Set the size of the popover (you can adjust this based on your needs)
        popupViewController?.preferredContentSize = CGSize(width: 300, height: 300)
        popupViewController?.selectedDate = { dat in
            self.departureDateTxt.resignFirstResponder()
            self.departureDateTxt.text = dat
            
        }
        
        // Present the popover
        if let popup = popupViewController {
            popup.apiParams = self.apiParams
            present(popup, animated: true, completion: nil)
            
        }
        
    }
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {         return .none
        
    }
}


