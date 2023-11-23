//
//  PhotoCollectionViewModel.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 19/11/2023.
//

import Foundation
import Photos
import os.log

final class PhotoCollectionViewModel: NSObject, ObservableObject {
    
    @Published var photoSectioned: [PhotoSectioned] = [PhotoSectioned]()
    
    var identifier: String? {
        assetCollection?.localIdentifier
    }
    
    var albumName: String?
    
    var smartAlbumType: PHAssetCollectionSubtype?
    
    let cache = CachedImageManager()
    
    private var assetCollection: PHAssetCollection?
    
    private var createAlbumIfNotFound = false
    
    enum PhotoCollectionError: LocalizedError {
        case missingAssetCollection
        case missingAlbumName
        case missingLocalIdentifier
        case unableToFindAlbum(String)
        case unableToLoadSmartAlbum(PHAssetCollectionSubtype)
        case addImageError(Error)
        case createAlbumError(Error)
        case removeAllError(Error)
    }
    
    init(smartAlbum smartAlbumType: PHAssetCollectionSubtype) {
        self.smartAlbumType = smartAlbumType
        super.init()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func load() async throws {
        
        PHPhotoLibrary.shared().register(self)
        
        if let smartAlbumType = smartAlbumType {
            if let assetCollection = Self.getSmartAlbum(subtype: smartAlbumType) {
                self.assetCollection = assetCollection
                await refreshPhotoAssets()
                return
            } else {
                throw PhotoCollectionError.unableToLoadSmartAlbum(smartAlbumType)
            }
        }
    }
    
    func addImage(_ imageData: Data) async throws {
        guard let assetCollection = self.assetCollection else {
            throw PhotoCollectionError.missingAssetCollection
        }
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                
                let creationRequest = PHAssetCreationRequest.forAsset()
                if let assetPlaceholder = creationRequest.placeholderForCreatedAsset {
                    creationRequest.addResource(with: .photo, data: imageData, options: nil)
                    
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection), assetCollection.canPerform(.addContent) {
                        let fastEnumeration = NSArray(array: [assetPlaceholder])
                        albumChangeRequest.addAssets(fastEnumeration)
                    }
                }
            }
            
            await refreshPhotoAssets()
            
        } catch let error {
            logger.error("Error adding image to photo library: \(error.localizedDescription)")
            throw PhotoCollectionError.addImageError(error)
        }
    }
    
    func removeAsset(_ asset: PhotoAsset) async throws {
        guard let assetCollection = self.assetCollection else {
            throw PhotoCollectionError.missingAssetCollection
        }
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection) {
                    albumChangeRequest.removeAssets([asset as Any] as NSArray)
                }
            }
            
            await refreshPhotoAssets()
            
        } catch let error {
            logger.error("Error removing all photos from the album: \(error.localizedDescription)")
            throw PhotoCollectionError.removeAllError(error)
        }
    }
    
    func removeAll() async throws {
        guard let assetCollection = self.assetCollection else {
            throw PhotoCollectionError.missingAssetCollection
        }
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection),
                    let assets = (PHAsset.fetchAssets(in: assetCollection, options: nil) as AnyObject?) as! PHFetchResult<AnyObject>? {
                    albumChangeRequest.removeAssets(assets)
                }
            }
            
            await refreshPhotoAssets()
            
        } catch let error {
            logger.error("Error removing all photos from the album: \(error.localizedDescription)")
            throw PhotoCollectionError.removeAllError(error)
        }
    }
    
    private func refreshPhotoAssets(_ fetchResult: PHFetchResult<PHAsset>? = nil) async { // TODO: pass updates via here
        
        let newFetchResult = fetchResult

        if newFetchResult == nil {
            let calendar = Calendar.current
            
            let dates = PhotoLibrary.fetchDateRangeOfLibrary()
            if let start = dates.0, let end = dates.1 {
                let startYear = calendar.component(.year, from: start)
                let endYear = calendar.component(.year, from: end)
                let sectionedMonths = PhotoLibrary.fetchPhotosGroupedByMonth(startYear: startYear, endYear: endYear)
                await MainActor.run {
                    self.photoSectioned = sectionedMonths
                }
            }
        }
    }

    private static func getAlbum(identifier: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier], options: fetchOptions)
        return collections.firstObject
    }
    

    
    private static func getSmartAlbum(subtype: PHAssetCollectionSubtype) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: fetchOptions)
        return collections.firstObject
    }
    
}

extension PhotoCollectionViewModel: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) { // TODO: update the library when changes happen
//        Task { @MainActor in
//            guard let changes = changeInstance.changeDetails(for: self.photoAssets.fetchResult) else { return }
//            await self.refreshPhotoAssets(changes.fetchResultAfterChanges)
//        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "PhotoCollection")
