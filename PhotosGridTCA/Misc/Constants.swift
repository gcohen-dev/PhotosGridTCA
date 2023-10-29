//
//  Constants.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 25/10/2023.
//

import Foundation

// MARK: Constants


// MARK: Date

class DFormatter {
    // Static property initialized once
    static let year: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
}

// Set the date format


func getRandomDate() -> Date {
    let year = Int.random(in: 1970...2023)
    let month = Int.random(in: 1...11)
    let day = Int.random(in: 1...28)
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = 0
    components.minute = 0
    components.second = 0

    let calendar = Calendar.current  // This will use the current system calendar (usually Gregorian)

    return calendar.date(from: components)!
}

func createDate(year: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = 1
    components.day = 1
    components.hour = 0
    components.minute = 0
    components.second = 0

    let calendar = Calendar.current  // This will use the current system calendar (usually Gregorian)

    return calendar.date(from: components)!
}
