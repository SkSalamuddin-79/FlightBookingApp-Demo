//
//  NetworkingManager.swift
//  FlightBookingPracticeApp
//
//  Created by Salamuddin on 09/11/23.
//

import Foundation
import Alamofire

class NetworkingManager {
    
    static var alamofireManager: Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 240
        config.timeoutIntervalForResource = 240
        return Session(configuration: config)
    }()
    
   
    static func allRequest(urlString: String, method: HTTPMethod, parameters: [String: Any], encoding: ParameterEncoding = URLEncoding.default, success: @escaping(Data) -> Void, failure: @escaping(Error) -> Void) {
        
        alamofireManager.request(urlString, method: method, encoding: encoding).response{resp in
            switch resp.result {
            case .success(let data):
                
                do {
                    let dataa = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                }catch {
                    print(error)
                }
                
                if let status = resp.response?.statusCode, status == 200 {
                    if let data = resp.data {
                        if let errorResult = try? JSONDecoder().decode(ErrorResponseModel.self, from: data) {
                            let error = NSError(domain: "", code: errorResult.status, userInfo: [NSLocalizedDescriptionKey: errorResult.error, "response": errorResult])
                            print("Failure:- \(errorResult.error)")
                            failure(error)
                        }else {
                            success(data)
                        }
                    }
                }else {
                    print("response statusCode:\(resp.response?.statusCode ?? 0)")
                    
                    if let status = resp.response?.statusCode, status == 401 {
                        
                    }else {
                        if let data = resp.data {
                            if let errorResult = try? JSONDecoder().decode(ErrorMessageResponseModel.self, from: data) {
                                let error = NSError(domain: "", code: resp.response?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: errorResult.message, "response": resp.result])
                                failure(error)
                            }
                        }
                    }
                }
                
            case .failure(let error):
                
                print("failure: \(error.localizedDescription)")
                failure(error)
                
            }
        }
    }
}
