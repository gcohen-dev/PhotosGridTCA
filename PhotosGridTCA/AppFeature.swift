//
//  AppFeature.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 24/10/2023.
//

import Foundation
import ComposableArchitecture

struct AppFeature: Reducer {
    
    enum Tab { case remote, local, paginationConcept }
    
    struct State: Equatable {
        var remotePicker: RemotePickerFeature.State = RemotePickerFeature.State()
        var selectedTab: Tab = .paginationConcept
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
        case remotePickerActions(RemotePickerFeature.Action)
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .remotePickerActions:
                return .none
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            }
        }
        Scope(state: \.remotePicker, 
              action: /Action.remotePickerActions) {
            RemotePickerFeature()
        }
    }
    
}
