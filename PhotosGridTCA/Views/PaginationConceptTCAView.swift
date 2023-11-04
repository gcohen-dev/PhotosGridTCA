//
//  PaginationConceptTCAView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 02/11/2023.
//

import SwiftUI
import ComposableArchitecture

struct PaginationConceptFeature: Reducer {
    
    struct State: Equatable {
        var firstSnapshotOfData = IdentifiedArrayOf<SectionDataModel>()
        var sections = IdentifiedArrayOf<SectionDataModel>()
        var scrubberInUsed = false
        @BindingState var currentSectionId: String = ""
        @BindingState var scrollPosition: String?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case scrubberTouched(percentage: CGFloat)
        case scrubberTouchedEnded(percentage: CGFloat)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .scrubberTouchedEnded(let percentage):
                let sectionTarget = Int(percentage * CGFloat(state.sections.count - 1))
                let firstSectionToUpdate = state.sections[sectionTarget]
                var priorSection: SectionDataModel?
                if sectionTarget > 0 {
                    priorSection = state.sections[sectionTarget - 1]
                }
//                state.currentSectionId = firstSectionToUpdate.id // TODO: after
                
                return .none
            case .scrubberTouched(let percentage) :
                let sectionTarget = Int(percentage * CGFloat(state.sections.count - 1))
                if !state.scrubberInUsed {
                    state.scrubberInUsed = true
                    state.sections = state.firstSnapshotOfData
                }
                state.currentSectionId = state.sections[sectionTarget].id
                return .none
            case .binding:
                return .none
            }
        }
    }

}

struct PaginationConceptTCAView: View {
    
    let store: StoreOf<PaginationConceptFeature>
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3)
    
    var body: some View {
        WithViewStore(self.store, observe: { $0}) { viewStore in
            ZStack {
                ScrollViewReader { scrollView in
                    ScrollView(.vertical) {
                        LazyVGrid(columns: columns, spacing: 6) {
                            ForEach(viewStore.sections) { sectionRow in
                                Section(content: {
                                    ForEach(sectionRow.data) { row in
                                        Text("\(row.number)")
                                            .font(.largeTitle)
                                            .foregroundStyle(.red)
                                            .frame(width: 120, height: 120)
                                            .background(.black)
    //                                        .id(row.id)
                                            .onAppear(perform: {
                                                /// Enable here to load more object
    //                                            dataManager.loadMoreContentIfNeeded(currentSection: sectionRow, currentItem: row)
    //                                            dataManager.loadMoreContentBothEndsIfNeeded(currentSection: sectionRow, row: row)
                                            })
                                    }
                                }, header: {
                                    Text(sectionRow.header)
                                        .foregroundStyle(.black)
                                        .padding(10)
                                        .id(sectionRow.id)
                                })
                            }
                        }
                        
                    }
                    .scrollIndicators(.never)
                    .scrollPosition(id: viewStore.$scrollPosition)
                    .onChange(of: viewStore.currentSectionId, {
                        scrollView.scrollTo(viewStore.currentSectionId, anchor: .top)
                    })
                }

                    
                HStack {
                    Spacer()
                    CustomScrubber(onScrub: { percentage in
                        viewStore.send(.scrubberTouched(percentage: percentage))
                    }, onEnded: { percentage in
//                        viewStore.send(.) //.scrubberTouchedEnded(percentage: percentage)
                    })
                }
            }
        }
    }
}

#Preview {
    PaginationConceptTCAView(store: .init(initialState: PaginationConceptFeature.State(), reducer: {
        PaginationConceptFeature()
    }))
}




struct SectionDataModel: Identifiable, Hashable, Equatable {
    
    static func == (lhs: SectionDataModel, rhs: SectionDataModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(header)
    }
    
    let id: String
    let header: String
    let allDataCount: Int
    var data: [MyDataModel]
    var isSectionLoaded = false
    // TODO: Section expected total count
}

struct MyDataModel: Identifiable, Hashable, Equatable {
    let id: String
    let number: Int
    
    static func == (lhs: MyDataModel, rhs: MyDataModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
    
}


struct DataGenerator {
    
    static var dataCounter: Int = 0
    static var sectionCounter: Int = 0
    static let itemsPerSectionThershould = 20
    
    /// Represents our SQL where the whole data lays
    static var _underlineData: [String: SectionDataModel] = {
        var ud: [String:SectionDataModel] = [String: SectionDataModel]()
        for _ in 0...1199 { // 1200 Sections = 12 month * 100 Years.
            let section = Self.generateUnderlineSectionData()
            ud[section.id] = section
        }
        return ud
    }()
    
    
    static func getFirstSnapshotOfData() -> IdentifiedArrayOf<SectionDataModel> {
        /// Let's create our first query, bring section with 20 item from the start and from the end
        var representiveData = IdentifiedArrayOf<SectionDataModel>()
        for item in Self._underlineData.values {
            var copiedItem = item
            if copiedItem.data.count >= Self.itemsPerSectionThershould * 2 {
                let firstItems =  Array(copiedItem.data.prefix(Self.itemsPerSectionThershould))
                let lastItems = Array(copiedItem.data.suffix(Self.itemsPerSectionThershould))
                let bothItems = firstItems + lastItems
                copiedItem.data = bothItems
            }
            
            representiveData.append(copiedItem)
        }
        
        let firstSnapshotOfData = representiveData
        return firstSnapshotOfData
    }
    
    
    private static func generateUnderlineSectionData() -> SectionDataModel {
        let randomSectionItems = Int.random(in: 1...1000) // Generate random row for each section
        var myDataArr = [MyDataModel]()
        for _ in 0...randomSectionItems {
            let data = MyDataModel(id: UUID().uuidString, number: Self.dataCounter)
            Self.dataCounter += 1
            myDataArr.append(data)
        }
        Self.sectionCounter += 1
        return SectionDataModel(id: UUID().uuidString,
                           header: "Section Number:\(Self.sectionCounter), totalCount:\(myDataArr.count)",
                           allDataCount: myDataArr.count,
                           data: myDataArr)
    }
}
