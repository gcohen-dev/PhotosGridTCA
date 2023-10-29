//
//  PaginationView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 27/10/2023.
//

import SwiftUI


struct PaginationView: View {
    @StateObject private var dataManager = DataManager()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 1)
       
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(dataManager.sections, id: \.self) { sectionRow in 
                        Section(content: {
                            ForEach(sectionRow.data) { row in
                                Text("\(row.number)")
                                    .onAppear(perform: {
                                        /// Enable here to load more object
                                        dataManager.loadMoreContentIfNeeded(currentSection: sectionRow, currentItem: row)
                                    })
                            }
                        }, header: {
                            Text(sectionRow.id)
                                .foregroundStyle(.black)
                                .padding(10)
                        })
                    }
                }
            }
            
            HStack {
                Spacer()
                CustomScrubber { percentage in
//                    $dataManager.scrubberTouched()
                }
            }
        }
    }
}



#Preview {
    PaginationView()
}


import Foundation
import Combine

class DataManager: ObservableObject {
    // Constants for data loading logic
    private let totalObjects = 1_000_000 // Simulating 1 million objects
    private let pageSize = 200 // Number of objects per page
    private var currentPage = 0 // Keeps track of the page that we are currently on
    
    
    @Published var sections: [SectionData] = [] // TODO: Create Date section in order to do paginaton // should be identified array
    var firstSnapshotOfData: [SectionData] = []
    // MARK: Underline data
    static var _onGoingCounter = 0
    private var _underlinedData: [String:SectionData] = [String: SectionData]() // Represents our SQL where the whole data lays
    private let itemsPerSectionThershould = 20
    
    
    init() {
        /// Generating SQL database
        var orderedSection = [SectionData]()
        
        for _ in 0...1200 { // 1200 Sections = 12 month * 100 Years.
            let section = generateUnderlineData()
            orderedSection.append(section)
            _underlinedData[section.id] = section
        }
        
        /// Let's create our first query, bring section with 20 item
        var representiveData = [SectionData]()
        for item in orderedSection {
            var copiedItem = item
            copiedItem.data = Array(copiedItem.data.prefix(itemsPerSectionThershould))
            representiveData.append(copiedItem)
        }
        
        firstSnapshotOfData = representiveData
        sections = representiveData
    }
    
    static var sectionNumber = 0
    func generateUnderlineData() -> SectionData {
        let randomSectionItems = Int.random(in: 1...1000) // Generate random row for each section
        var myDataArr = [MyData]()
        for _ in 0...randomSectionItems {
            let data = MyData(id: UUID().uuidString, number: Self._onGoingCounter)
            Self._onGoingCounter += 1
            myDataArr.append(data)
        }
        Self.sectionNumber += 1
        return SectionData(id: "Section Number: \(Self.sectionNumber), totalCount:\(myDataArr.count)", header: "Count:\(myDataArr.count)", data: myDataArr)
    }
    
    
    func loadMoreContentIfNeeded(currentSection: SectionData, currentItem: MyData) {

        guard let section = _underlinedData[currentSection.id] else { return }
        guard currentSection.data.last?.id == currentItem.id else {
            print("### not last item")
            return
        }
        
        let diff = section.data.count - currentSection.data.count
        
        if diff <= 0  { /// No diff we returning here
            return
        }
        
        if diff < 50 { // 50 more items Left let's get them
            let appendDiff = section.data[currentSection.data.count..<section.data.count]
            guard let indexSection = self.sections.firstIndex(of: currentSection) else {
                return
            }
            print("### Appending 50")
            //            self.sections[indexSection].data += appendDiff
            
            var copySections = self.sections
            copySections[indexSection].data += appendDiff
            self.sections = copySections

            
            return
        }
        let calculateThreshould = currentSection.data.count + itemsPerSectionThershould
        let appendDiff = section.data[currentSection.data.count...calculateThreshould]
        
        guard let indexSection = self.sections.firstIndex(of: currentSection) else {
            return
        }
        print("### Appending \(appendDiff.count)")
        var copySections = self.sections
        copySections[indexSection].data += appendDiff
        self.sections = copySections
    }
    
    func scrubberTouched(percentage: CGFloat) {
        let sectionTarget = percentage * CGFloat(_underlinedData.count)
        self.sections = firstSnapshotOfData
        
    }
}

struct SectionData: Identifiable, Hashable {
    
    static func == (lhs: SectionData, rhs: SectionData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(header)
    }
    
    let id: String
    let header: String
    var data: [MyData]
}

struct MyData: Identifiable, Hashable {
    let id: String
    let number: Int
    
    static func == (lhs: MyData, rhs: MyData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
    
}
