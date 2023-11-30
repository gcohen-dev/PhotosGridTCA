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
    @StateObject private var dataManager = ViewModel()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3)

    
    var body: some View {
        ZStack {
            ScrollViewReader { scrollView in
                ScrollView(.vertical) {
                    LazyVGrid(columns: columns, spacing: 6, pinnedViews: [.sectionHeaders]) {
                        ForEach(dataManager.snapshotOfData) { sectionRow in
                            Section(content: {
                                ForEach(sectionRow.data) { row in
                                    Text("\(row.number)")
                                        .font(.largeTitle)
                                        .foregroundStyle(.red)
                                        .frame(width: 120, height: 120)
                                        .background(.black)
                                        .scrollTargetLayout()
                                        .id(row)
                                    
                                }
                            }, header: {
                                Text(sectionRow.header)
                                    .foregroundStyle(.black)
                                    .padding(25)
                                    .background(Color.white)
                                    .scrollTargetLayout()
                                    .id(sectionRow)
                            })
                        }
                    }
                }
            }
            .scrollIndicators(.never)
            .scrollPosition(id: $dataManager.currentSection)
            .scrollPosition(id: $dataManager.currentItem)
            HStack {
                Spacer()
                CustomScrubber(onScrub: { percentage in
                    dataManager.scrubberTouched(percentage: percentage)
                }, onEnded: { percentage in
                    dataManager.scrubberTouchedEnded(percentage: percentage)
                })
            }
        }.onDisappear(perform: dataManager.onDisappear)
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
        @Published var currentItem: MyData?
        @Published var currentSection: SectionData?
        
        /// Represent the partial of the data, all sections will be here and also the first and last 20 items of each section
        @Published var snapshotOfData: [SectionData] = []
        
        var itemToTriggerBackwardSectionLoading: MyData?
        
        // MARK: Underline data
        /// Represents the SQL layer, could be core data for example.
        private var _underlinedData: [Int:SectionData] = [Int: SectionData]()
        private static var _onGoingCounter = 0
        private static let itemsPerSectionThershould = 20
        
        
        
        init() {
            
            var orderedSection = [SectionData]()
            var sectionNumber = 0
            for _ in 0...1199 { // 1199 Sections = 12 month * 100 Years.
                let section = generateUnderlineData()
                orderedSection.append(section)
                /// Generating SQL database here
                _underlinedData[sectionNumber] = section
                sectionNumber += 1
            }
            currentSection = _underlinedData[0]
            snapshotOfData = [_underlinedData[0]!]
            //            sections = representiveData
        }
        
        
        // MARK: Private
        
        private static var sectionNumber = 0
        private func generateUnderlineData() -> SectionData {
            let randomSectionItems = Int.random(in: 1...1000) // Generate random row for each section
            var myDataArr = [MyData]()
            for _ in 0...randomSectionItems {
                let data = MyData(id: UUID().uuidString, number: Self._onGoingCounter)
                Self._onGoingCounter += 1
                myDataArr.append(data)
            }
            Self.sectionNumber += 1
            return SectionData(id: UUID().uuidString,
                               header: "Section Number:\(Self.sectionNumber), totalCount:\(myDataArr.count)",
                               allDataCount: myDataArr.count,
                               data: myDataArr)
        }
        
        
        // MARK: Public
        
        func onDisappear() {
            Self._onGoingCounter = 0
        }
        
        func loadEntireSectionIfNeeded(currentSection: SectionData, row: MyData) {
            
            //            guard !isScrubberInUsed else { // Disable while scrubbering
            //                return
            //            }
            //
            //            if currentSection.isSectionLoaded {
            //                return
            //            }
            //
            //            if currentSection.data.isEmpty {
            //                return
            //            }
            //
            //            let middleCell = currentSection.data.count / 2
            //
            //            if currentSection.data[middleCell].id != row.id {
            //                return
            //            }
            //            print("### Loading entire section:\(currentSection.header)")
            //
            //            guard let underlinedSection = _underlinedData[currentSection.id] else {
            //                assertionFailure("No section has been found, something funky is going on.")
            //                return
            //            }
            //
            //            if (currentSection.data.count == underlinedSection.data.count) { // We loaded everything
            //                print("### Section \(currentSection.header) loaded everything")
            //                return
            //            }
            //
            //            guard let indexSection = self.sections.firstIndex(of: currentSection) else {
            //                assertionFailure("No index has been found, something funky is going on.")
            //                return
            //            }
            //
            //            sections[indexSection].isSectionLoaded = true
            //
            //            self.sections[indexSection].data = underlinedSection.data
        }
        
        func scrubberTouched(percentage: CGFloat) {

            snapshotOfData = [SectionData]()
            
            let sectionTarget = Int(percentage * CGFloat(_underlinedData.count - 1))
            let selectedSection = _underlinedData[sectionTarget]
            
            snapshotOfData = [selectedSection!]
            
            if !isScrubberInUsed {
                currentSection = selectedSection
                isScrubberInUsed = true
            }
            
        }

        
        
        func scrubberTouchedEnded(percentage: CGFloat) {
            
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let sectionTarget = Int(percentage * CGFloat(self._underlinedData.count - 1))
            
            let selectedSection = self._underlinedData[sectionTarget]
            
            var sectionsToAdd = [SectionData]()
            sectionsToAdd.append(selectedSection!)
            
            let limitOfPhotos = 2000
            var sectionIndex = sectionTarget - 1
            var currentSectionCount = selectedSection?.data.count ?? 0
            
            var itemToTriggerBackwardSectionLoading: MyData?
            
            while(sectionIndex >= 0 && currentSectionCount < limitOfPhotos) {
                let priorSection = self._underlinedData[sectionIndex]
                currentSectionCount += priorSection?.data.count ?? 0
                sectionsToAdd.insert(priorSection!, at: 0)
                sectionIndex -= 1
                itemToTriggerBackwardSectionLoading = priorSection?.data.first
            }
            
            self.itemToTriggerBackwardSectionLoading = itemToTriggerBackwardSectionLoading
            
            // TODO: we need to add logic of loading forward as well, but for now let's keep it simple
            //            withAnimation {
            //                DispatchQueue.main.async {
            
            self.snapshotOfData = sectionsToAdd
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
    var data: [MyData]
    var isSectionLoaded = false
    
    static func == (lhs: SectionData, rhs: SectionData) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(header) }
}

struct MyData: Identifiable, Hashable, Equatable {
    
    let id: String
    let number: Int
    
    static func == (lhs: MyData, rhs: MyData) -> Bool { lhs.id == rhs.id }
    
    func hash(into hasher: inout Hasher) { hasher.combine(number) }
    
}
