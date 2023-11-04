//
//  AppFeature.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 24/10/2023.
//

import Foundation
import ComposableArchitecture

struct AppFeature: Reducer {
    
    struct State: Equatable {
        var paginationConcept: PaginationConceptFeature.State = PaginationConceptFeature.State()
        var remotePicker: RemotePickerFeature.State = RemotePickerFeature.State()
        var scrollViewFeature: ScrollToViewFeature.State = ScrollToViewFeature.State()
    }
    
    enum Action: Equatable {
        case remotePickerActions(RemotePickerFeature.Action)
        case scrollViewFeature(ScrollToViewFeature.Action)
        case paginationConcept(PaginationConceptFeature.Action)
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .paginationConcept:
                return .none
            case .scrollViewFeature:
                return .none
            case .remotePickerActions:
                return .none
            }
        }
        Scope(state: \.paginationConcept, action: /Action.paginationConcept) {
            PaginationConceptFeature()
        }
        Scope(state: \.remotePicker,
              action: /Action.remotePickerActions) {
            RemotePickerFeature()
        }
        Scope(state: \.scrollViewFeature, action: /Action.scrollViewFeature) {
            ScrollToViewFeature()
        }
    }
}
