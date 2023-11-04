//
//  PhotosGridTCAApp.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 24/10/2023.
//

import SwiftUI
import Nuke
import ComposableArchitecture

@main
struct PhotosGridTCAApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            
            RootView(store: Store(initialState: AppFeature.State(paginationConcept: Self.prefetchPaginationConceptState()),
                                        reducer: {
                AppFeature()
                //                    ._printChanges()
            }))
            
            // Test Pagination
//            TestView()
        }
    }
    
    static func prefetchPaginationConceptState() -> PaginationConceptFeature.State {
        let firstTimeSnapshot = DataGenerator.getFirstSnapshotOfData()
        let state = PaginationConceptFeature.State(firstSnapshotOfData: firstTimeSnapshot, sections: firstTimeSnapshot)
        return state
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        ImagePipeline.shared = ImagePipeline(configuration: .withDataCache)
        ImagePipeline.shared = ImagePipeline(configuration: .withDataCache(name:"imagescache", sizeLimit: 1_000))
//        ImageCache.shared.costLimit = 1024 * 1024 * 1_000 // 1000 MB
        
        // Create a data cache that uses the file system for storage.
//          let dataCache = try! DataCache(name: "com.guycohen.imagecache")
//
//          // Set the maximum cache size (optional).
//          dataCache.sizeLimit = 1024 * 1024 * 1_000 // 1000 MB
//
//          // Customize the cache policies.
//          let pipeline = ImagePipeline {
//              // Enable disk caching for all downloaded images.
//              $0.dataCache = dataCache
//              // Customize other settings as needed, e.g., cache policies, transition animations, etc.
//          }
//
//          // Make the customized pipeline the default for Nuke.
//          ImagePipeline.shared = pipeline
        
        
//        ImageCache.shared.countLimit = 100
        return true
    }
}
