//
//  ApiVM.swift
//  FlightBookingPracticeApp
//
//  Created by Salamuddin on 09/11/23.
//

import Foundation
import UIKit
import Alamofire

protocol CalenderProtocol: UIViewController{
    
    func getCalender(result: CalenderModel)
    
}
extension CalenderProtocol {
    func getCalender(result: CalenderModel){ }
}

class CalenderViewModel {
    
    var getCalenderData : CalenderModel?
    
    weak var delegate: CalenderProtocol?
    
    init(delegate: CalenderProtocol) {
        self.delegate = delegate
    }
    
    
    func getCalenderApi(parameters: [String: Any]) {
        
        ApiManager.getCalenderData(parameters: parameters) { [weak self] response in
            switch response {
            case .success(let result):
                print (result)
                self?.getCalenderData = result
                self?.delegate?.getCalender(result: result)
                
            case .failure(let error):
                print(error.localizedDescription)
                print("error")
            }
        }
    }
}
