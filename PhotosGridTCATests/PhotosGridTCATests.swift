//
//  PhotosGridTCATests.swift
//  PhotosGridTCATests
//
//  Created by Guy Cohen on 25/10/2023.
//

import XCTest
import ComposableArchitecture
@testable import PhotosGridTCA

@MainActor
final class PhotosGridTCATests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async {
        let store = TestStore(initialState: AppFeature.State(), reducer: {
            AppFeature()
        })
    }

}
