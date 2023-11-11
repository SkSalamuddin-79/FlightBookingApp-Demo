//
//  ResponseModel.swift
//  FlightBookingPracticeApp
//
//  Created by Salamuddin on 09/11/23.
//

import Foundation


struct ErrorResponseModel: Codable {
    let status: Int
    let error: String
    let time: String
}
struct ErrorMessageResponseModel: Codable {
    let message: String
}
