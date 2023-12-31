//
//  PaginationPlaceHolderView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 05/11/2023.
//

import Foundation

import SwiftUI
import Foundation
import Combine

struct PaginationPlaceHolderView: View {
    
    @StateObject private var dataManager = ViewModel()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3)
    
    var body: some View {
        ZStack {
            ScrollViewReader { scrollView in
                ScrollView(.vertical) {
                    LazyVGrid(columns: columns, spacing: 6, pinnedViews: [.sectionHeaders]) {
                        ForEach(dataManager.sections) { sectionRow in
                            Section(content: {
                                ForEach(sectionRow.data, id: \.self) { element in
                                    switch element {
                                    case .placeholder:
                                        Rectangle()
                                            .frame(width: 120, height: 120)
                                            .foregroundStyle(.dynamic(light: .gray, dark: .gray))
                                            .onAppear(perform: {
                                                /// Enable here to load more object
//                                                dataManager.loadEntireSectionIfNeeded(currentSection: sectionRow, row: element)
                                            })
                                    case .concrete(let item):
                                        Text("\(item.number)")
                                            .font(.largeTitle)
                                            .foregroundStyle(.red)
                                            .frame(width: 120, height: 120)
                                            .background(.black)
                                           
                                    }
                                }
                            }, header: {
                                Text(sectionRow.header)
                                    .foregroundStyle(.black)
                                    .padding(25)
                                    .id(sectionRow)
                                    .background(Color.white)
                                    
                            })
                        }
                    }
                    
                }
                .scrollIndicators(.never)
                .scrollPosition(id: $dataManager.scrollToSectionData)
                .onChange(of: dataManager.currentSectionId, {
                    scrollView.scrollTo(dataManager.currentSectionId, anchor: .top)
                })
                .onChange(of: dataManager.sections, initial: true) { oldValue, newValue in
                    if let currentSection = dataManager.scrollToSectionData,
                       let currentIndex = newValue.firstIndex(of: currentSection)
                    //                        let newItem = newValue.indices.contains(currentIndex) ? newValue[currentIndex] : nil
                    {
                        dataManager.scrollToSectionData = newValue[currentIndex]
                    } else {
                        let newScrollPosition = dataManager.sections.count > 0 ? newValue[0] : nil
                        if newScrollPosition != dataManager.scrollToSectionData {
                            dataManager.scrollToSectionData = newScrollPosition
                        }
                    }
                }
            }
            
            HStack {
                Spacer()
                CustomScrubber(onScrub: { percentage in
                    dataManager.scrubberTouched(percentage: percentage)
                }, onEnded: { percentage in
                    dataManager.scrubberTouchedEnded(percentage: percentage)
                })
            }
        }
    }
}

// MARK: Preview

#Preview {
    PaginationDynamicAddingView()
}

// MARK: ViewModel
extension PaginationPlaceHolderView {
    
    class ViewModel: ObservableObject {
        /// Represent the UI, any manipulation of the data will be on this array, loading entire setions or reseting it to the saved snapshot
        @Published var sections: [PHSectionData] = []
        @Published var isScrubberInUsed = false
        @Published var currentSectionId: String = "0"
        @Published var scrollToSectionData: PHSectionData?
        
        
        /// Represent the partial of the data, all sections will be here and also the first and last 20 items of each section
        private var firstSnapshotOfData: [PHSectionData] = []
        
        // MARK: Underline data
        /// Represents the SQL layer, could be core data for example.
        private var _underlinedData: [String:PHSectionData] = [String: PHSectionData]()
        private static var _onGoingCounter = 0
        private static let itemsPerSectionThershould = 20
        
        
        
        init() {
            
            var orderedSection = [PHSectionData]()
            
            for _ in 0...100 { // 1199 Sections = 12 month * 100 Years.
                let section = generateUnderlineData()
                orderedSection.append(section)
                /// Generating SQL database here
                _underlinedData[section.id] = section
            }
            
            /// Let's create our first query, bring section with 20 item
            var representiveData = [PHSectionData]()
            for item in orderedSection {
                
                var copiedItem = item
                print("!!! item count:\(item.allDataCount)")
                if copiedItem.data.count >= Self.itemsPerSectionThershould * 2 {
                    //                copiedItem.data = Array(copiedItem.data.prefix(itemsPerSectionThershould))
                    let firstItems =  Array(copiedItem.data.prefix(Self.itemsPerSectionThershould))
                    let lastItems = Array(copiedItem.data.suffix(Self.itemsPerSectionThershould))
                    let numberOfMiddlePlaceholders = item.allDataCount - firstItems.count - lastItems.count
                    let placeHolders = (0..<numberOfMiddlePlaceholders).compactMap { _ in PHState.placeholder(UUID().uuidString)}
                    copiedItem.data = firstItems +  placeHolders + lastItems
                    print("!!! data count:\(copiedItem.data.count)")
                }
                
                representiveData.append(copiedItem)
            }
            
            firstSnapshotOfData = representiveData
            sections = representiveData
        }
        
        
        // MARK: Private
        
        private static var sectionNumber = 0
        private func generateUnderlineData() -> PHSectionData {
            let randomSectionItems = 1000//Int.random(in: 1...1000) // Generate random row for each section
            var myDataArr = [PHState]()
            for _ in 0...randomSectionItems {
                let data = PHState.concrete(PHMyData(id: UUID().uuidString, number: Self._onGoingCounter))
                Self._onGoingCounter += 1
                myDataArr.append(data)
            }
            Self.sectionNumber += 1
            return PHSectionData(id: UUID().uuidString,
                               header: "Section Number:\(Self.sectionNumber), totalCount:\(myDataArr.count)",
                               allDataCount: myDataArr.count,
                               data: myDataArr)
        }
        
        private func loadSections(currentSections: [PHSectionData], toId: String) {
            
            for currentSection in currentSections {
                if currentSection.isSectionLoaded {
                    continue
                }
                
                if currentSection.data.isEmpty {
                    continue
                }
                
                guard let underlinedSection = _underlinedData[currentSection.id] else {
                    continue
                }
                
                guard let indexSection = self.sections.firstIndex(of: currentSection) else {
                    continue
                }
                
                self.sections[indexSection].data = underlinedSection.data
                self.sections[indexSection].isSectionLoaded = true
                
            }
            
            if currentSections.first != scrollToSectionData {
                scrollToSectionData = currentSections.first ?? nil
            }
        }
        
        
        // MARK: Public
        
        func loadEntireSectionIfNeeded(currentSection: PHSectionData, row: PHState) {
            
            if case .concrete(_) = row {
                print ("Concrete item")
             return
            }
            guard !isScrubberInUsed else { // Disable while scrubbering
                return
            }
            
            if currentSection.isSectionLoaded {
                return
            }
            
            if currentSection.data.isEmpty {
                return
            }
            
            
        
            print("### Loading entire section:\(currentSection.header)")
            
            guard let underlinedSection = _underlinedData[currentSection.id] else {
                assertionFailure("No section has been found, something funky is going on.")
                return
            }
            
            
            guard let indexSection = self.sections.firstIndex(of: currentSection) else {
                assertionFailure("No index has been found, something funky is going on.")
                return
            }
            sections[indexSection].isSectionLoaded = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation {
                    self.sections[indexSection].data = underlinedSection.data
                }
            }
        }
        
        func scrubberTouched(percentage: CGFloat) {
            let sectionTarget = Int(percentage * CGFloat(_underlinedData.count - 1))
            if !isScrubberInUsed {
                self.sections = firstSnapshotOfData
            }
            isScrubberInUsed = true
            if currentSectionId != self.sections[sectionTarget].id {
                currentSectionId = self.sections[sectionTarget].id
            }
        }
        
        func scrubberTouchedEnded(percentage: CGFloat) {
            let sectionTarget = Int(percentage * CGFloat(_underlinedData.count - 1))
            let firstSectionToUpdate = self.sections[sectionTarget]
            let priorValue = max(sectionTarget - 1,0) /// incase we have section 0 as the first section
            let priorSection = self.sections[priorValue]
            self.loadSections(currentSections: [firstSectionToUpdate, priorSection], toId: firstSectionToUpdate.id)
            self.isScrubberInUsed = false
        }
        
    }
}



// MARK: Models

struct PHSectionData: Identifiable, Hashable, Equatable {

    let id: String
    let header: String
    let allDataCount: Int
    var data: [PHState]
    var isSectionLoaded = false
    
    static func == (lhs: PHSectionData, rhs: PHSectionData) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(header) }
}

enum PHState: Equatable, Hashable, Identifiable {
    var id: String {
        switch self {
        case .placeholder(let str): return str
        case .concrete(let data): return data.id
        }
    }
    
    case placeholder(String)
    case concrete(PHMyData)
}

struct PHMyData: Identifiable, Hashable, Equatable {
    
    let id: String
    let number: Int
    
    static func == (lhs: PHMyData, rhs: PHMyData) -> Bool { lhs.id == rhs.id }
    
    func hash(into hasher: inout Hasher) { hasher.combine(number) }
    
}



struct DynamicColorShapeStyle: ShapeStyle {
    let light: Color
    let dark: Color

    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        if environment.colorScheme == .light {
            return light
        } else {
            return dark
        }
    }
}

extension ShapeStyle where Self == DynamicColorShapeStyle {
    static func `dynamic`(light: Color, dark: Color) -> DynamicColorShapeStyle {
        DynamicColorShapeStyle(light: light, dark: dark)
    }
}
