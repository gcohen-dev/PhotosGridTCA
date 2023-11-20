//
//  PhotoSectioned.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 19/11/2023.
//

import Foundation

struct PhotoSectioned: Identifiable {
    let id: String
    let year: Int
    let month: Int
    let fetchResult: PhotoAssetCollection
}
