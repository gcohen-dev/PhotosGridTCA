//
//  Generators.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 24/10/2023.
//

import Foundation
import Dependencies
import ComposableArchitecture


struct GeneratorClient {
    var start: @Sendable (_ start: Int, _ end: Int) async -> IdentifiedArrayOf<PhotoModel>
}

extension GeneratorClient: DependencyKey {
    static var liveValue: GeneratorClient = Self(start: { start, end in
        
        var photoModels = IdentifiedArrayOf<PhotoModel>()
        
//        let urlString = "https://placehold.co/200x200/000000/FFFFFF/png"
        let urlString = "https://placehold.co/1000x1000/000000/FFFFFF/png"
        for i in start..<end {
            
            let newURLString = urlString.replacingOccurrences(of: "000000", with: String(format: "%06d", i))
            
            let photoModel = PhotoModel(id: "\(UUID().uuidString)", 
                                        url: newURLString,
                                        date: getRandomDate())
            
            photoModels.append(photoModel)
        }
        return photoModels
    })
    
    static var previewValue: GeneratorClient = Self { start, end in
        let urlString = "https://placehold.co/600x400/000000/FFFFFF/png"
        let photoModel = PhotoModel(id: "1", url: urlString, date: Date())
        var photoModels = IdentifiedArrayOf<PhotoModel>()
        photoModels.append(photoModel)
        return photoModels
    }
    
    static var testValue: GeneratorClient = .previewValue
}


extension DependencyValues {
  var generatorClient: GeneratorClient {
    get { self[GeneratorClient.self] }
    set { self[GeneratorClient.self] = newValue }
  }
}


struct PhotoModel: Identifiable, Equatable {
    let id: String
    let url: String
    let date: Date
    
    var dateDescription: String { DFormatter.year.string(from: date) }
}
