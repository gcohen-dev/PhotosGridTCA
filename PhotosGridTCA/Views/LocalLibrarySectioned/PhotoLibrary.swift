//
//  PhotoLibrary.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 19/11/2023.
//

import Photos
import os.log

class PhotoLibrary {
    
    static func checkAuthorization() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            logger.debug("Photo library access authorized.")
            return true
        case .notDetermined:
            logger.debug("Photo library access not determined.")
            return await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
        case .denied:
            logger.debug("Photo library access denied.")
            return false
        case .limited:
            logger.debug("Photo library access limited.")
            return false
        case .restricted:
            logger.debug("Photo library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    // Function to determine the dat. e range of the user's photo library
    static func fetchDateRangeOfLibrary() -> (Date?, Date?) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        options.fetchLimit = 1
        
        // Fetch the oldest photo
        if let oldestAsset = PHAsset.fetchAssets(with: options).firstObject {
            // Change sort order to fetch the newest photo
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            if let newestAsset = PHAsset.fetchAssets(with: options).firstObject {
                return (oldestAsset.creationDate, newestAsset.creationDate)
            } else {
                return (nil, nil)
            }
        } else {
            return(nil, nil)
        }
    }
    
    
    
    // Function to fetch photos grouped by month over the years
    static func fetchPhotosGroupedByMonth(startYear: Int, endYear: Int) -> [PhotoSectioned] {
        
        var photoSectioned = [PhotoSectioned]()
        
        for year in startYear...endYear {
            for month in 1...12 {
                let (startDate, endDate) = self.startAndEndDatesForMonth(year: year, month: month)
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate <= %@", startDate as NSDate, endDate as NSDate)
                let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: fetchOptions)
//                monthlyFetchResults.append((year, month, fetchResult))
                if fetchResult.count == 0 {
                    continue
                }
                photoSectioned.append(PhotoSectioned(id: "\(month)-\(year)",
                                                     year: year,
                                                     month: month,
                                                     fetchResult: PhotoAssetCollection(fetchResult)))
            }
        }
        
        return photoSectioned
    }
    
    // Helper function to get the start and end dates for a given month of a year
    private static func startAndEndDatesForMonth(year: Int, month: Int) -> (Date, Date) {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        let calendar = Calendar.current
        let startDate = calendar.date(from: dateComponents)!
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        return (startDate, endDate)
    }
    
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "PhotoLibrary")
