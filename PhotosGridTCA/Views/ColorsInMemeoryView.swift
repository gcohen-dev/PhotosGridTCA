//
//  ColorsInMemeoryView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 19/11/2023.
//

import SwiftUI

struct ColorsInMemeoryView: View {
    
    private let threeColumnGrid = [GridItem(.flexible(), spacing: 0),
                                   GridItem(.flexible(), spacing: 0),
                                   GridItem(.flexible(), spacing: 0)]
    
    
    let data: [SomeSection] = [SomeSection]()
    @State var scrollPosition: UUID? = nil
    @State var flashScrollView = false
    @State var section = ""
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            //            ScrollViewReader { value in
            ScrollView {
                LazyVGrid(columns: threeColumnGrid, alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(data) { section in
                        Section(header: Text(section.title.uppercased())) {
                            
                            ForEach(section.items) { item in
                                Rectangle()
                                    .fill(item.color)
                                    .overlay(
                                        Text(item.text + "\n" + section.title)
                                            .foregroundColor(.white)
                                    )
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                    .aspectRatio(1, contentMode: .fill)
                                    .onAppear {
                                        self.section = section.title
                                    }
                                    .id(item.id)
                            }
                        }
                    }
                }
                .scrollTargetLayout()
                
                //                }
                .onChange(of: data) {
                    flashScrollView.toggle()
                    //                    Task {
                    //                        try? await Task.sleep(for: .seconds(1))
                    //                        value.scrollTo(data.last?.items.last?.id)
                    
                    //                    }
                    //                    value.scrollTo(data.last?.items.last?.id)
                    
                    //                        scrollPosition = data.last?.items.last?.id
                    
                    //                    scrollPosition = data.first?.items.first?.id
                }
                .scrollIndicatorsFlash(trigger: flashScrollView)
                
                //
                
            }
            //                .scrollPosition(id: $scrollPosition, anchor: .bottom)
            
            //            Button("Scroll to top") {
            ////                    value.scrollTo(data.first?.items.first?.id)
            ////                scrollPosition = data.first?.items.first?.id
            //                                        scrollPosition = data.last?.items.last?.id
            //
            //            }
            
            
            Text(section)
                .font(.largeTitle)
                .shadow(radius: 4)
                .foregroundColor(.white)
                .padding()
        }
        
    }
    
    struct SomeSection: Identifiable, Equatable {
        let id: UUID
        let title: String
        var items: [SomeObject]
    }
    
    struct SomeObject: Identifiable, Equatable {
        let id: UUID
        var text: String
        let color: Color
    }
}

#Preview {
    ColorsInMemeoryView()
}
