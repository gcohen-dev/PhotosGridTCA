//
//  AddOptions.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 26/10/2023.
//

import Foundation

enum Options: Equatable {
    
    case firstBatch
    case small
    case medium
    case large
    case xlarge
    
    var amount: Int {
        switch self {
        case .firstBatch: return 20 //20 //250_000 //500_000
        case .small: return 1_000
        case .medium: return 5_000
        case .large: return 10_000
        case .xlarge: return 20_000
        }
    }
}
