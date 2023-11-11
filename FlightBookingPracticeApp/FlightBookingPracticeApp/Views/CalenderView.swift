//
//  CalenderView.swift
//  FlightBookingPracticeApp
//
//  Created by Salamuddin on 10/11/23.
//

import Foundation
import FSCalendar
import SwiftDate


class PopupViewController: UIViewController, FSCalendarDelegate {
    
    var yearLbl: UILabel!
    var btnForward: UIButton!
    var btnBackward: UIButton!
    var calendarView: FSCalendar!
    var stackView: UIStackView!
    var apiParams = [String:Any]()
    var viewModel: CalenderViewModel?
    
    var selectedDate: ((String) -> Void)?
    var allAvailableWeekDayNumbers = [Int]()
    
    var onlyDates = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // api delegate
        viewModel = CalenderViewModel(delegate: self)
        // api calling or hit api
        
        viewModel?.getCalenderApi(parameters: self.apiParams)
        calendarView = FSCalendar(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        calendarView.delegate = self
        
        calendarView.backgroundColor = .systemBackground
        self.view.addSubview(calendarView)
        self.view.backgroundColor = .clear
        
        
        
        // Create the stack view
        let stackView = UIStackView()
        stackView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8.0
        // Create left chevron image view
        btnBackward = UIButton()
        btnBackward.setImage( UIImage(systemName: "chevron.left"), for: .normal)
        btnBackward.tintColor = .black
        btnBackward.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        // Create label
        yearLbl = UILabel()
        yearLbl.text = "November 2023"
        yearLbl.font = UIFont.systemFont(ofSize: 18.0)
        yearLbl.textColor = .black
        yearLbl.textAlignment = .center
        // Create right chevron image view
        btnForward = UIButton()
        btnForward.setImage( UIImage(systemName: "chevron.right"), for: .normal)
        btnForward.tintColor = .black
        btnForward.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        // Add views to the stack view
        stackView.addArrangedSubview(btnBackward)
        stackView.addArrangedSubview(yearLbl)
        stackView.addArrangedSubview(btnForward)
        // Add the stack view to the main view
        view.addSubview(stackView)
        // Set up constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0),     stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),    stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0)
        ])
        
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 12)
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 14)
        calendarView.appearance.headerMinimumDissolvedAlpha = 0
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 16)
        calendarView.appearance.titleOffset = CGPoint(x: 0.0, y: 2.5)
        calendarView.placeholderType = .none
        calendarView.calendarHeaderView.isHidden = true
        //calendarView.calendarWeekdayView.tintColor = .black
        calendarView.appearance.weekdayTextColor = .black
        btnForward.addTarget(self, action: #selector(nextMonthBtnTapped), for: .touchUpInside)
        btnBackward.addTarget(self, action: #selector(previousMonthBtnTapped), for: .touchUpInside)
    }
    
    // next month button action
    @objc func nextMonthBtnTapped() {
        let val = 1
        let gregorian = NSCalendar.init(calendarIdentifier: .gregorian)
        let mmdate = gregorian?.date(byAdding: .month, value: val, to: calendarView.currentPage, options: .matchLast)
        calendarView.setCurrentPage(mmdate!, animated: true)
        
        btnBackward.alpha = 1
        
        yearLbl.text = "\(self.calendarView.currentPage.month) \(mmdate!.getFormattedDate(format: "yyyy"))"
    }
    
    // previous month btn action
    
    @objc func previousMonthBtnTapped() {
        let val = -1
        let gregorian = NSCalendar.init(calendarIdentifier: .gregorian)
        let mmdate = gregorian?.date(byAdding: .month, value: val, to: calendarView.currentPage, options: .matchLast)
        calendarView.setCurrentPage(mmdate!, animated: true)
        
        btnBackward.alpha = 1
        
        yearLbl.text = "\(self.calendarView.currentPage.month) \(mmdate!.getFormattedDate(format: "yyyy"))"
    }
    
}

// pop transitioning delegate

class PopupTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PopupPresentationController(presentedViewController: presented, presenting: presenting)
        
    }
    
}

// popup calender presentation controller and their constraints setup
class PopupPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerSize = containerView?.bounds.size ?? CGSize.zero
        return CGRect(x: 20, y: containerSize.height / 2, width: containerSize.width - 40, height: containerSize.height / 2)
        
    }
    
}

// Date extension
extension Date {
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    func localDate() -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else {return Date()}
        return localDate
    }
}

// calender delegate apperance for set up calender according the api dates

extension PopupViewController: FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        let calendar = Calendar.current
        if allAvailableWeekDayNumbers.contains(calendar.component(.weekday, from: date)) && date.isInFuture {
            return true
        }
        return false
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        let calendar = Calendar.current
        if allAvailableWeekDayNumbers.contains(calendar.component(.weekday, from: date)) && date.isInFuture {
            return .black
        }
        return .lightGray
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.dismiss(animated: true) {
            let dat = date.localDate().toString(.custom("MM/dd/yyyy"))
            self.selectedDate?(dat)
        }
    }
}

// confrom the api protocol

extension PopupViewController: CalenderProtocol {
    
    func getCalender(result: CalenderModel) {
        print(result)
        allAvailableWeekDayNumbers.removeAll()
        result.to.forEach { to in
            let availableDay = to.day.capitalized
            if let weekDayNum = getWeekdayNumber(from: availableDay) {
                allAvailableWeekDayNumbers.append(weekDayNum)
                calendarView.reloadData()
            }
        }
        
    }
}

// get the weekdays which days api gives us

extension PopupViewController {
    
    func getWeekdayNumber(from weekdayName: String) -> Int?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        // Set the format for the abbreviated weekday name
        if let date = dateFormatter.date(from: weekdayName)
        {
            let calendar = Calendar.current
            let weekdayNumber = calendar.component(.weekday, from: date)
            return weekdayNumber
            
        }
        return nil
        
    }
}
