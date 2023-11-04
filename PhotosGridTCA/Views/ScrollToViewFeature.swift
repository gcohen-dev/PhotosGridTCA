//
//  ScrollToViewFeature.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 01/11/2023.
//

import SwiftUI
import ComposableArchitecture

struct ScrollToViewFeature: Reducer {
    
    struct State: Equatable {
        var items = IdentifiedArrayOf<Item>()
        @BindingState var scrollPosition: String?
        var counter: Int = 0
    }
    
    enum Action: BindableAction, Equatable {
        case addItemsAtIndexZero
        case oneCase
        case viewAppeared
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
                
            case .viewAppeared:
                for _ in 0...500 {
                    state.counter += 1
                    state.items.append(Item(id: UUID().uuidString, value: "\(state.counter)"))
                }
                //                let newScrollPosition = newValue.count > 0 ? newValue[0] : nil
                //                        if newScrollPosition != self.scrollPosition {
                //                            self.scrollPosition = newScrollPosition
                //                        } // TODO: For production we should use the above code, but for simplicity let's just grab the first item
                state.scrollPosition = state.items.first?.id
                return .none
            case .addItemsAtIndexZero:
                var copiedItems = state.items
                for _ in 0...98 {
                    state.counter += 1
                    copiedItems.insert(Item(id:UUID().uuidString, value: "\(state.counter)"), at: 0)
                }
                state.items = copiedItems
                if let currentItemId: String = state.scrollPosition,
                   let currentIndex: Int = state.items.index(id: currentItemId)
                {
                    let newItemToScroll = state.items.elements[currentIndex]
                    state.scrollPosition = newItemToScroll.id
                }
                //                state.scrollPosition = firstItem
                return .none
            case .oneCase:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

struct ScrollToViewTCAFeature: View {
    
    let store: StoreOf<ScrollToViewFeature>
    
    var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3)
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                ScrollView(.vertical) {
                    LazyVGrid(columns: columns) {
                        ForEach(viewStore.items) { item  in
                            Text("\(item.value)")
                                .id(item.id)
                        }
                    }.scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollPosition(id: viewStore.$scrollPosition)
                
                Button(action: { viewStore.send(.addItemsAtIndexZero) },
                       label: { Text("Add numbers before") })
                
            }.onAppear { viewStore.send(.viewAppeared) }
        }
    }
}

#Preview {
    ScrollToViewTCAFeature(store: .init(initialState: ScrollToViewFeature.State(), reducer: {
        ScrollToViewFeature()
    }))
}
