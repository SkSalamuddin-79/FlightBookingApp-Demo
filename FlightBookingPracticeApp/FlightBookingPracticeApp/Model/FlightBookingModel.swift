//
//  FlightBookingModel.swift
//  FlightBookingPracticeApp
//
//  Created by Salamuddin on 10/11/23.
//

import Foundation

// MARK: - Welcome
struct CalenderModel: Codable {
    let to, from: [From]
}

// MARK: - From
struct From: Codable {
    let id, day, from, to: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case day = "DAY"
        case from = "From"
        case to = "To"
    }
}
