//
//  RootView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 29/10/2023.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    
    let store: StoreOf<AppFeature>
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Demonstrate the concept of memory storage by downloading photos from a server. Users can add an unlimited number of photos, each assigned a random date. Photos are initially sorted by date, with an option to randomize their order. When new photos are added, they are automatically sorted by date again. This is implemented using TCA")
                    .font(.caption2)) {
                        NavigationLink(destination: {
                            RemotePickerView(store: self.store.scope(state: \.remotePicker,
                                                                     action: AppFeature.Action.remotePickerActions))
                        }, label: {
                            Text("Remote Picker View TCA")
                        })
                    }
                
                Section(header: Text("Demonstrate smooth scrolling across a library sectioned by months, leveraging the lazy-loading capabilities of PHFetchResult for efficient memory management. inspired by Apple")
                    .font(.caption2)) {
                        NavigationLink(destination: {
                            SectionCollectionView()
                        }, label: {
                            VStack {
                                Text("Local Library PHAsset ")
                                Text("")
                                    .font(.caption)
                            }
                        })
                    }
                
                Section(header: Text("We use a custom scrubber with snapshots for efficient navigation, fetching only the initial and final 'X' items of each section. However, loading adjacent sections during scrubbing introduces a glitch due to mid-list item appends, resulting in an unintended animation.")
                    .font(.caption2)) {
                        
                        NavigationLink("Pagination Dynamic Adding Concept",
                                       destination: {
                            PaginationDynamicAddingView()
                                .navigationTitle("Pagination Dynamic Adding Concept")
                        })
                    }
                
                Section(header: Text("Employing a custom scrubber, we initially load placeholders instead of actual objects, intending to replace these placeholders with real objects when displayed. However, this approach was less effective due to the continued memory retention of objects.")
                    .font(.caption2)) {
                        NavigationLink("Pagination Placeholder Adding Concept",
                                       destination: {
                            PaginationPlaceHolderView()
                                .navigationTitle("Pagination Placeholder Adding Concept")
                        })
                    }
                
                Section(header: Text("We're testing memory capacity with sections, providing a useful environment for adding objects and sections to evaluate the native scrolling indicator's performance.")
                    .font(.caption2)) {
                        NavigationLink("Colors in Memory in order to test the indicator",
                                       destination: {
                            ColorsInMemeoryView()
                                .navigationTitle("Colors in memory")
                        })
                    }
                
                Section(header: Text("Simple list which test the iOS 17 scrolling API using scrollPosition")
                    .font(.caption2)) {
                        NavigationLink("Add Items Experiment",
                                       destination: {
                            AddExperimentItemsView()
                                .navigationTitle("Add Items Experiment")
                        })
                        
                
                    }
                
                Section(header: Text("A simple playground to test inserting items at index 0")
                    .font(.caption2)) {
                        NavigationLink("Scroll To View POC",
                                       destination: {
                            ScrollToView()
                                .navigationTitle("Scroll To View POC")
                        })
                    }
            }
        }
    }
}

#Preview {
    RootView(store: Store(initialState: AppFeature.State(),
                          reducer: { AppFeature() }))
}
