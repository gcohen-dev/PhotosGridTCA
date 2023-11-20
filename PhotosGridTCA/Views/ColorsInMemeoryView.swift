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
    
    
    @State var data: [SomeSection] = [SomeSection]()
    @State var scrollPosition: UUID? = nil
    @State var flashScrollView = false
    @State var section = ""
    
    var body: some View {
        ZStack(alignment: .topLeading) {
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
                .onChange(of: data) {
                    flashScrollView.toggle()
                }
                .scrollIndicatorsFlash(trigger: flashScrollView)
                
            }
            
            Text(section)
                .font(.largeTitle)
                .shadow(radius: 4)
                .foregroundColor(.white)
                .padding()
            
        }.task {
            var sections = [SomeSection]()
            for i in 0..<1_000 { /// Number of sections
                let newData = SomeSection(id: UUID(), title: "Section \(i)", items: createData())
                sections.append(newData)
            }
            await MainActor.run {
                self.data =  sections
            }
            
        }
        
    }
    
    static var num = 0
    func createData() -> [SomeObject] {
        var data = [SomeObject]()
        for _ in 0..<250 { /// Number of items in sections
            data.append(SomeObject(id: UUID(), text: "Text \(Self.num)", color: Color.random))
            Self.num += 1
        }
        return data
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


extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
