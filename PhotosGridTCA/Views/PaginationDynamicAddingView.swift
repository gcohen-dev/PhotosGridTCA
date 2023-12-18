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
    let columns1: [GridItem] = [GridItem(.flexible())]
    
    // Important ! Until now I had the assumpation of changing the data while the scrubbing should reflect immediately
    // but this concept is completely wrong, we should not change the data according to the scrubber pace
    // or according to @State refresh rate
    // we should update it efficiently with debounce and dispatch,
    
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                if viewModel.isScrubberInUsed == false || viewModel.shouldDisplayPriorViewForReloading == true {
                    
                    LazyVGrid(columns: columns1) {
                        Color
                            .red
                            .frame(height: 1)
                            .id("Color Clear start")
                            .onAppear {
                                viewModel.viewForPriorLoading()
                            }
                    }
                }
                
                LazyVGrid(columns: columns, spacing: 6, pinnedViews: [.sectionHeaders]) {

                    
                    ForEach(viewModel.dataToLoad, id: \.id) { sectionRow in
                        Section(content: {
                            ForEach(sectionRow.data, id: \.id) { row in
                                Text("\(row.number)")
                                    .font(.largeTitle)
                                    .foregroundStyle(.red)
                                    .frame(width: 120, height: 120)
                                    .background(.black)
                                    
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
                
                if viewModel.isScrubberInUsed == false || viewModel.shouldDisplayPriorViewForReloading == true {
                    LazyVGrid(columns: columns1) {
                        Color
                            .red
                            .frame(height: 1)
                            .id("Color Clear start")
                            .onAppear {
                                viewModel.lastViewShown()
                            }
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
        }
        .onDisappear(perform: viewModel.onDisappear)
        .navigationBarItems(trailing:
                                Button(action: {
            viewModel.buttonTapped()
        }) {
            Text("add prior")
        }
        )
        .navigationBarItems(leading:
                                Button(action: {
            viewModel.addFurther()
        }) {
            Text("add further")
        }
        )
    }
    
    
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
            for _ in 0...2000 { // 1199 Sections = 12 month * 100 Years.
                let section = generateUnderlineData()
                orderedSection.append(section)
                /// Generating SQL database here
                _underlinedData[sectionNumber] = section
                
                if section.data.count < Self.itemsPerSectionThershould {
                    //                    section.isSectionLoaded = true
                    loadedSectionSnapshot.insert(section.id)
                }
                
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
            let randomSectionItems = Int.random(in: 100...1000) // Generate random row for each section
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
        
        func buttonTapped() {
            guard let firstSection = dataToLoad.first else {
                return
            }
            
            let priorSection = firstSection.sectionNumber - 1
            guard let prSection = _underlinedData[priorSection] else {
                return
            }
            
            let currentSectionDisplayed = firstSection
            
            let data = [prSection] + self.dataToLoad
            
            //            self.dataToLoad.insert(prSection, at: 0)
            self.dataToLoad = data
            
            
            self.currentSection = currentSectionDisplayed
            
            
        }
        
        func addFurther() {
            guard let lastSection = dataToLoad.last else {
                return
            }
            
            let nextSection = lastSection.sectionNumber + 1
            guard let prSection = _underlinedData[nextSection] else {
                return
            }
            
            let currentSectionDisplayed = lastSection
            
            
            //            self.dataToLoad.insert(prSection, at: 0)
            self.dataToLoad.append(prSection)
            
            
        }
        
        
        @Published var shouldDisplayPriorViewForReloading = false
        
        func viewForPriorLoading() {
            shouldDisplayPriorViewForReloading = false
            
            if isScrubberInUsed {
                return
            }
            if scrubberTouchedEnededInProgress {
                return
            }
            
            guard let firstSection = dataToLoad.first else {
                return
            }
            
            let priorSection = firstSection.sectionNumber - 1
            guard let prSection = _underlinedData[priorSection] else {
                return
            }
            
            if loadedSection.contains(prSection.id) {
                return
            }
            
            loadedSection.insert(prSection.id)
            
            let currentSectionDisplayed = firstSection
            
            let data = [prSection] + self.dataToLoad // We should add more than 20 items
            
            
            
            //            self.dataToLoad.insert(prSection, at: 0)
            self.dataToLoad = data
            
            
            self.currentSection = currentSectionDisplayed
            
            shouldDisplayPriorViewForReloading = true
            
            print("## prior Cell Appeared - loading:\(prSection.header)")
            
        }
        
                
        func lastViewShown() {
            
            if isScrubberInUsed {
                return
            }
            
            
            if scrubberTouchedEnededInProgress {
                return
            }
            guard let lastSection = dataToLoad.last else {
                return
            }
            
            let priorSection = lastSection.sectionNumber + 1
            guard let prSection = _underlinedData[priorSection] else {
                return
            }
            
            if loadedSection.contains(prSection.id) {
                return
            }
            
            print("## Last Cell Appeared - loading:\(prSection.header)")
            
            
            loadedSection.insert(prSection.id)
            
            
            //            self.dataToLoad.insert(prSection, at: 0)
            self.dataToLoad.append(prSection)
            
            
        }
        
        
        func sectionAppeared(_ sectionRow: SectionData) {
            if isScrubberInUsed {
                return
            }
            if scrubberTouchedEnededInProgress == true {
                return
            }
            guard let firstSection = dataToLoad.first else {
                return
            }
            
            let priorSection = firstSection.sectionNumber - 1
            guard let prSection = _underlinedData[priorSection] else {
                return
            }
            
            if loadedSection.contains(prSection.id) {
                print("Doing nothing: prior section is loaded")
                return
            }
            
            loadedSection.insert(prSection.id)
            
            let currentSectionDisplayed = firstSection
            
            let data = [prSection] + self.dataToLoad
            
            //            self.dataToLoad.insert(prSection, at: 0)
            self.dataToLoad = data
            
            
            self.currentSection = currentSectionDisplayed
            
            
            print("## Sectioned Appeared loading prior:\(prSection.header)")
        }
        
        var debounce = Debounce(delay: 0.005)
        
        func scrubberTouched(percentage: CGFloat) {
            
            shouldDisplayPriorViewForReloading = false
            
            self.dataToLoad = [SectionData]()
            debounce.callback = { [weak self] in
                guard let self = self else { return }
                if !self.isScrubberInUsed {
                    
                    self.isScrubberInUsed = true
                    self.loadedSection = []
                }
                self.currentSection = nil
                
                let sectionTarget = Int(percentage * CGFloat(self.representiveDataSnapshot.count - 1))
                let selectedSection = self.representiveDataSnapshot[sectionTarget]
                if selectedSection?.id == self.dataToLoad.first?.id {
                    print("Scrubber touche same section")
                    return
                }
                self.dataToLoad = [selectedSection!]
                
            }
            
            debounce.call()
        }
        
        var scrubberTouchedEnededInProgress = false
        
        func scrubberTouchedEnded(percentage: CGFloat) {
            
            scrubberTouchedEnededInProgress = true
            
            loadedSection = loadedSectionSnapshot
            
            
            guard let ss = self.dataToLoad.first else {
                print("This print doesnt make senseס")
                return
            }
            
            
            var sectionsToAdd = [SectionData]()
            
            let limitOfPhotosPerPriorSection = 50
            
            var priorSectionIndex = ss.sectionNumber - 1
            var priorSectionPhotosCount = 0
            //
            //
            /// Here we are FULLY loading sections prior to the current section, we should consider loading enough sections so the iteamAppeared will naturally work
            while(priorSectionIndex >= 0 && priorSectionPhotosCount < limitOfPhotosPerPriorSection) {
                let priorSection = self._underlinedData[priorSectionIndex]
                self.loadedSection.insert(priorSection!.id)
                priorSectionPhotosCount += priorSection?.data.count ?? 0
                sectionsToAdd.insert(priorSection!, at: 0)
                priorSectionIndex -= 1
            }
            
            // We have not loaded the currentSectionData but we will on the asyncAfter, therfore we wants to mark it as loaded
            self.dataToLoad.forEach { section in
                loadedSection.insert(section.id)
            }
            self.dataToLoad.insert(contentsOf: sectionsToAdd, at: 0)
            
            currentSection = ss
            
            self.isScrubberInUsed = false
            
            // Simulate loading the whole object
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if self.isScrubberInUsed == true {
                    print("Attempting to load current section")
                    return
                }
                
                guard let currentSection = self._underlinedData[ss.sectionNumber] else {
                    print("Presented section not found")
                    return
                }
                
                if let index = self.dataToLoad.firstIndex(where: { $0.id == currentSection.id }) {
                    print("Loading the whole current section after scrubbing")
                    //                    self.loadedSection.insert(currentSection.id)
                    self.dataToLoad[index] = currentSection // TODO: if current section is small load the next objects
                }
                
                self.scrubberTouchedEnededInProgress =  false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("Attempting to show loaders views")
                    self.shouldDisplayPriorViewForReloading = true
                }
                
            }
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




class Debounce {
    
    public var callback: (() -> ())?
    
    /// Delay Time in seconds
    private let delay: TimeInterval
    
    /// Timer to fire the callback event
    private var timer: DispatchSourceTimer?
    
    public var callerQueue: DispatchQueue
    
    /// Start the debouncer
    ///
    public func call() {
        let isMainThread = Thread.current == Thread.main
        
        /// Using barrier to avoid possible crash on concurrent queues
        /// On serial queues this flag has no effect
        callerQueue.async(flags: .barrier) { [weak self] in self?.setupCallback(isMainThread: isMainThread) }
    }
    
    /// Init with delay time as argument, callback can be set later
    ///
    /// - Parameters:
    ///   - delay: delay in seconds
    ///   - dispatchQueue: the thread we should retrieve our callback
    public init(delay: TimeInterval){
        self.delay = delay
        self.callerQueue = DispatchQueue(label: "sfg.debounce.serial")
    }
    
    /// Init with delay time and callback as arguments
    ///
    /// - Parameters:
    ///   - delay: delay in seconds
    ///   - dispatchQueue: the thread we should retrieve our callback
    ///   - callback: the call back that should be invoked
    public init(delay: TimeInterval, callerQueue:DispatchQueue? = nil, callback: (() -> ())? = nil){
        self.delay = delay
        self.callback = callback
        self.callerQueue = callerQueue ?? DispatchQueue(label: "sfg.debounce.serial")
    }
    
    private func setupCallback(isMainThread: Bool) {
        /// Cancel timer, if already running
        timer?.setEventHandler(handler: nil)
        timer?.cancel()
        /// If we do not have a callback we should not schedule anything
        guard callback != nil else { return }
        
        /// Reset timer to fire next event
        timer = DispatchSource.makeTimerSource(queue: callerQueue)
        timer?.schedule(deadline: .now() + delay)
        
        /// If custom queue provided and it is concurrent - barrier flag ensure that any code
        /// will be exucuted before or after event handler, not in same time
        ///
        /// If custom queue is serial or we use default queue - barrier has no effect
        timer?.setEventHandler(flags: .barrier, handler: { [weak self] in
            if isMainThread {
                DispatchQueue.main.async {
                    self?.callback?()
                }
            } else {
                self?.callback?()
            }
        })
        timer?.resume()
    }
}
