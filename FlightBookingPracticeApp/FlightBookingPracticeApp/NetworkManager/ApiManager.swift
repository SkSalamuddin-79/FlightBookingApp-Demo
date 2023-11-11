//
//  ApiManager.swift
//  FlightBookingPracticeApp
//
//  Created by Salamuddin on 10/11/23.
//

import Foundation
import Alamofire

class ApiManager {
    
    
   
    
    static func getCalenderData(parameters: [String:Any], completion: @escaping(Result<CalenderModel, Error>) -> Void) {
        
        let from = parameters["From"] as! String
        let to = parameters["To"] as! String
        let request = ApiManager.EndPoint.getCalender.rawValue + "From=\(from)&To=\(to)"
        NetworkingManager.allRequest(urlString: request , method: .get, parameters: [:], success: { json in
             do {
                 let model = try JSONDecoder().decode(CalenderModel.self, from: json)
                 completion(.success(model))
             } catch let DecodingError.dataCorrupted(context) {
                 print(context)
             } catch let DecodingError.keyNotFound(key, context) {
                 print("Key '\(key)' not found:", context.debugDescription)
                 print("codingPath:", context.codingPath)
             } catch let DecodingError.valueNotFound(value, context) {
                 print("Value '\(value)' not found:", context.debugDescription)
                 print("codingPath:", context.codingPath)
             } catch let DecodingError.typeMismatch(type, context)  {
                 print("Type '\(type)' mismatch:", context.debugDescription)
                 print("codingPath:", context.codingPath)
             } catch {
                 print("error: ", error)
             }
         }, failure: { error in
             completion(.failure(error))
         })
     }
}

extension ApiManager {
    
    enum EndPoint: String {
        
        case getCalender = "https://daallo.com/api/flight/calendar?"
    }
    
}
