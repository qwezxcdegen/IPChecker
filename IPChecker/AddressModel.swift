//
//  AddressModel.swift
//  IPChecker
//
//  Created by Степан Фоминцев on 27.03.2023.
//

import Foundation

// MARK: - Address
struct Address: Codable {
    let country, countryCode, regionName: String
    let city, zip, timezone, org, query: String
    let lat, lon: Double
}
