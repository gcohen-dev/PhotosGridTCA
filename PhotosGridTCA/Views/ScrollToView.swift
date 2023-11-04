//
//  ScrollToView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 01/11/2023.
//

import SwiftUI

struct ScrollToView: View {
    @State var items = [Item]()
    @State var scrollPosition: Item?
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3)
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                ForEach(0..<10) { section in
                    Section {
                        LazyVGrid(columns: columns) {
                            ForEach(items) { item  in
                                Text("\(item.value)")
                                    .id(item)
                            }
                        }.scrollTargetLayout()
                    } header: {
                        Text(" Section:\(section)")
                    }

                    
                }
                
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $scrollPosition)
            .onChange(of: items, initial: true) { oldValue, newValue in
                if let currentItem = scrollPosition,
                   let currentIndex = newValue.firstIndex(of: currentItem),
                   let newItem = newValue.indices.contains(currentIndex) ? newValue[currentIndex] : nil
                {
                    self.scrollPosition = newItem
                } else {
                    // newItem is nil. Choose any other if one exists,
                    // otherwise set it to nil:
                    let newScrollPosition = newValue.count > 0 ? newValue[0] : nil
                    if newScrollPosition != self.scrollPosition {
                        self.scrollPosition = newScrollPosition
                    }
                }
            }
            
            
            Button(action: {
                buttonPressed()
            }, label: {
                Text("Add numbers before")
            })
            
            
        }.onAppear {
            viewAppeared()
        }
    }
    static var counter = 0
    func viewAppeared() {
        for _ in 0...500 {
            Self.counter += 1
            items.append(Item(id: UUID().uuidString, value: "\(Self.counter)"))
        }
    }
    
    func buttonPressed() {
        var copiedItems = self.items
        for _ in 0...98 {
            Self.counter += 1
            copiedItems.insert(Item(id:UUID().uuidString, value: "\(Self.counter)"), at: 0)
        }
        
        self.items = copiedItems
    }
}

struct Item: Identifiable, Hashable {
    let id: String
    let value: String
}


#Preview {
    ScrollToView()
}
