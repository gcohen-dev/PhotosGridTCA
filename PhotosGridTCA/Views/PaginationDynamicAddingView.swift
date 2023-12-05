//
//  PaginationView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 27/10/2023.
//

import SwiftUI
import Foundation
import Combine

struct PaginationDynamicAddingView: View {
    @StateObject private var viewModel = ViewModel()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3)

    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 6, pinnedViews: [.sectionHeaders]) {
                    ForEach(viewModel .dataToLoad) { sectionRow in
                        Section(content: {
                            ForEach(sectionRow.data) { row in
                                Text("\(row.number)")
                                    .font(.largeTitle)
                                    .foregroundStyle(.red)
                                    .frame(width: 120, height: 120)
                                    .background(.black)
                                    .onAppear {
                                        viewModel.itemAppeared(item: row, section: sectionRow)
                                    }
                            }
                        }, header: {
                            Text(sectionRow.header)
                                .foregroundStyle(.black)
                                .padding(25)
                                .background(Color.white)
                                .id(sectionRow)
                                .scrollTargetLayout()
                        })
                    }
                }
            }
            .scrollIndicators(.never)
            .scrollPosition(id: $viewModel.currentSection)
            HStack {
                Spacer()
                CustomScrubber(onScrub: { percentage in
                    viewModel.scrubberTouched(percentage: percentage)
                }, onEnded: { percentage in
                    viewModel.scrubberTouchedEnded(percentage: percentage)
                })
            }
        }.onDisappear(perform: viewModel.onDisappear)
    }

}

// MARK: Preview

#Preview {
    PaginationDynamicAddingView()
}

// MARK: ViewModel
extension PaginationDynamicAddingView {
    
    class ViewModel: ObservableObject {
        /// Represent the UI, any manipulation of the data will be on this array, loading entire setions or reseting it to the saved snapshot
        //        @Published var sections: [Int: SectionData] = [:]
        @Published var isScrubberInUsed = false
        @Published var currentSectionId: String = "0"
//        @Published var currentItem: MyData?
        @Published var currentSection: SectionData?
        
        var itemToTriggerBackwardSectionLoading: MyData?
        
        // MARK: Underline data
        /// Represents the SQL layer, could be core data for example.
        private var _underlinedData: [Int :SectionData] = [Int: SectionData]()
        private static var _onGoingCounter = 0
        private static let itemsPerSectionThershould = 40
        
        
        // MARK: Representive data
        var representiveDataSnapshot: [Int: SectionData] // All the month data should be here, 20 image of each month, and the rest will be loaded on demand.
        
        /// Data that we going to manupliate on, will be reset to representiveDataSnapshot when scrubber is in use.
        @Published var dataToLoad: [SectionData] = []
        
        init() {
            
            var orderedSection = [SectionData]()
            var sectionNumber = 0
            representiveDataSnapshot = [Int: SectionData]()
            for _ in 0...1199 { // 1199 Sections = 12 month * 100 Years.
                let section = generateUnderlineData()
                orderedSection.append(section)
                /// Generating SQL database here
                _underlinedData[sectionNumber] = section
                
                // Representive
                let data = section.data.prefix(Self.itemsPerSectionThershould)
                var sectionWithSubSequenceData = section
                sectionWithSubSequenceData.data = Array(data)
                representiveDataSnapshot[sectionNumber] = sectionWithSubSequenceData
                
                sectionNumber += 1
            }
//            let firstBatchToPresent = 50
//            var index = 0
//            var count = 0
//            while (count < 50) {
//                guard let chunk = representiveDataSnapshot[index] else {
//                    break
//                }
//                index += 1
//                count += chunk.data.count
//                var currentChunk = chunk
//                if chunk.data.count < Self.itemsPerSectionThershould {
//                    currentChunk.isSectionLoaded = true
//                    loadedSection.insert(chunk.id)
//                    representiveDataSnapshot[index]?.isSectionLoaded = true
//                }
//                dataToLoad.append(currentChunk)
//            }
            dataToLoad.append(_underlinedData[0]!)
            
            
            currentSection = _underlinedData[0]
        }
        
        
        // MARK: Private
        
        private static var sectionNumber = 0
        private func generateUnderlineData() -> SectionData {
            let currentSectionNumber = Self.sectionNumber
            let randomSectionItems = Int.random(in: 20...800) // Generate random row for each section
            var myDataArr = [MyData]()
            for index in 0...randomSectionItems {
                let data = MyData(id: UUID().uuidString, number: Self._onGoingCounter, index: index)
                Self._onGoingCounter += 1
                myDataArr.append(data)
            }
            Self.sectionNumber += 1
            let isSectionIsLoaded = myDataArr.count < Self.itemsPerSectionThershould
            return SectionData(id: UUID().uuidString,
                               header: "Section Number:\(currentSectionNumber), totalCount:\(myDataArr.count)",
                               allDataCount: myDataArr.count,
                               sectionNumber: currentSectionNumber,
                               data: myDataArr, isSectionLoaded: isSectionIsLoaded)
        }
        
        
        // MARK: Public
        
        func onDisappear() {
            Self._onGoingCounter = 0
            Self.sectionNumber = 0
        }
        
        var loadedSection: Set<String> = []
        var loadedSectionSnapshot: Set<String> = []
        
        let itemsToTriggerFullSectionLoading = 5
        
        func itemAppeared(item: MyData,section: SectionData) {
            print("section:\(section.sectionNumber), row:\(item.number)")
            guard isScrubberInUsed == false else {
                return
            }
            
            if section.isSectionLoaded {
                // We are loading here the upcoming section
                let nextSection = section.sectionNumber + 1
                
                if let getNextSection = _underlinedData[nextSection] {
                    if loadedSection.contains(getNextSection.id) {
                        return
                    }
                    loadedSection.insert(getNextSection.id)
                    loadedSectionSnapshot.insert(getNextSection.id)
                    var nxtSection = getNextSection
                    nxtSection.isSectionLoaded = true
                    /// This code shouldn't be on production, we should not filter on the dataToLoad.
                    if let dataFound = dataToLoad.first(where: { $0.id == nxtSection.id}) {
                        print(dataFound)
                        return // Already loaded
                    } else {
                        dataToLoad.append(nxtSection)
                        print("Loading Next Section: \(nxtSection.sectionNumber)")
                    }
                }

            } else {

                let allSectionDataCountItemIndexDiff = Self.itemsPerSectionThershould - item.index
                
                if allSectionDataCountItemIndexDiff <= itemsToTriggerFullSectionLoading {
                    
                    guard var currentSection = self._underlinedData[section.sectionNumber] else {
                        return
                    }
                    
                    if loadedSection.contains(currentSection.id) {
                        return
                    }

                    print("Loading Full section: \(currentSection.sectionNumber)")
                    currentSection.isSectionLoaded = true
                    loadedSection.insert(currentSection.id)
                    if let index = dataToLoad.firstIndex(where: { $0.id == section.id }) {
                        dataToLoad[index] = currentSection
                    }
                }
            }
            
        }

        
        func scrubberTouched(percentage: CGFloat) {
            
            if !isScrubberInUsed {
                isScrubberInUsed = true
            }
            
            // Clean the current count
//            dataToLoad = [SectionData]()
            currentSection = nil
            loadedSection = []
            
            let sectionTarget = Int(percentage * CGFloat(representiveDataSnapshot.count - 1))
            let selectedSection = representiveDataSnapshot[sectionTarget]
//            self.dataToLoad = [selectedSection!]
            self.dataToLoad = [selectedSection!]
            
        }

        
        
        func scrubberTouchedEnded(percentage: CGFloat) {
            
            loadedSection = loadedSectionSnapshot
            
            let sectionTarget = Int(percentage * CGFloat(self.representiveDataSnapshot.count - 1))
            
            let selectedSection = self.representiveDataSnapshot[sectionTarget]
            
            var sectionsToAdd = [SectionData]()
            sectionsToAdd.append(selectedSection!)
            self.loadedSection.insert(selectedSection!.id)
            
            let limitOfPhotosPerPriorSection = 50
            var priorSectionIndex = sectionTarget - 1
            var priorSectionPhotosCount = 0
            
            
            while(priorSectionIndex >= 0 && priorSectionPhotosCount < limitOfPhotosPerPriorSection) {
                var priorSection = self._underlinedData[priorSectionIndex]
                priorSection?.isSectionLoaded = true // Important!  We are fully loading the prior section
                self.loadedSection.insert(priorSection!.id)
                priorSectionPhotosCount += priorSection?.data.count ?? 0
                sectionsToAdd.insert(priorSection!, at: 0)
                priorSectionIndex -= 1
            }
            
//            self.itemToTriggerBackwardSectionLoading = itemToTriggerBackwardSectionLoading
            
            self.dataToLoad = sectionsToAdd
            
            self.currentSection = selectedSection!
            
            self.isScrubberInUsed = false
            
        }
        
    }
}

// MARK: Models

struct SectionData: Identifiable, Hashable, Equatable {
    
    let id: String
    let header: String
    let allDataCount: Int
    let sectionNumber: Int
    var data: [MyData]
    var isSectionLoaded: Bool
    
    static func == (lhs: SectionData, rhs: SectionData) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(header) }
}

struct MyData: Identifiable, Hashable, Equatable {
    
    let id: String
    let number: Int
    let index: Int
    static func == (lhs: MyData, rhs: MyData) -> Bool { lhs.id == rhs.id }
    
    func hash(into hasher: inout Hasher) { hasher.combine(number) }
    
}
