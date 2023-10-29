//
//  TabFeatureView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 29/10/2023.
//

import SwiftUI
import ComposableArchitecture

struct TabFeatureView: View {
    
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: \.selectedTab ) { viewStore in
            TabView(selection: viewStore.binding(send: AppFeature.Action.tabSelected)) {
                
                RemotePickerView(store: self.store.scope(state: \.remotePicker,
                                                         action: AppFeature.Action.remotePickerActions))
                    .tabItem({ Text("Remote")})
                    .tag(AppFeature.Tab.remote)
                
                Text("Local TBA")
                    .tabItem({ Text("Local")})
                    .tag(AppFeature.Tab.local)
                
                PaginationView()
                    .tabItem({ Text("Pagination Concept")})
                    .tag(AppFeature.Tab.paginationConcept)
                
            }
        }
    }
}

#Preview {
    TabFeatureView(store: Store(initialState: AppFeature.State(),
                                reducer: { AppFeature() }))
}
