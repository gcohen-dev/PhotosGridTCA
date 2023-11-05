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
                Section(header: Text("Getting started")) {
                    
                    NavigationLink("Remote Picker View TCA", destination: {
                        RemotePickerView(store: self.store.scope(state: \.remotePicker,
                                                                 action: AppFeature.Action.remotePickerActions))
                    })
                    
                    NavigationLink("PHAsset, still in progres", 
                                   destination: {
                        Text("Local TBA")
                    })
                    
                    NavigationLink("Pagination Dynamic Adding Concept",
                                   destination: {
                        PaginationDynamicAddingView()
                            .navigationTitle("Pagination Dynamic Adding Concept")
                    })
                    
                    NavigationLink("Pagination Placeholder Adding Concept",
                                   destination: {
                        PaginationPlaceHolderView()
                            .navigationTitle("Pagination Placeholder Adding Concept")
                    })
                    
                    
                    
                    
                    //                PaginationConceptTCAView(store: self.store.scope(state: \.paginationConcept, action: AppFeature.Action.paginationConcept))
                    //                    .tabItem({ Text("Pagination Concept TCA") })
                    //                    .tag(AppFeature.Tab.paginationConceptTCA)
                    //
                    
                    NavigationLink("Scroll To View POC",
                                   destination: {
                        ScrollToView()
                            .navigationTitle("Pagination Concept")
                    })
                    
                    
                    //
                    //                ScrollToViewTCAFeature(store: self.store.scope(state: \.scrollViewFeature,
                    //                                                               action: AppFeature.Action.scrollViewFeature
                    //                                                              ))
                    //                .tabItem({ Text("ScrollToView TCA")})
                    //                .tag(AppFeature.Tab.scrollViewFeature)
                }
            }
        }
    }
}

#Preview {
    RootView(store: Store(initialState: AppFeature.State(),
                          reducer: { AppFeature() }))
}
