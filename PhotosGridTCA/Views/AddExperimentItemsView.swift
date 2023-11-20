//
//  ScrollContentOffSetExperimentView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 07/11/2023.
//

import Foundation
import UIKit
import SwiftUI


struct AddExperimentItemsView: View {
    
    @State var data: [String] = (0 ..< 25).map { String($0) }
    
    @State var dataID: String?
    var body: some View {
        ScrollView {
            VStack {
                Text("Header")
                LazyVStack {
                    ForEach(data, id: \.self) { item in
                        Color.red
                            .frame(width: 100, height: 100)
                            .overlay {
                                Text("\(item)")
                                    .padding()
                                    .background()
                            }
                    }
                }
                .scrollTargetLayout()
            }
        }
        .scrollPosition(id: $dataID)
        .safeAreaInset(edge: .bottom) {
            VStack {
                Text("\(Text("Scrolled").bold()) \(dataIDText)")
                Spacer()
                Button {
                    dataID = data.first
                } label: {
                    Label("Top", systemImage: "arrow.up")
                }
                Button {
                    dataID = data.last
                } label: {
                    Label("Bottom", systemImage: "arrow.down")
                }
                Menu {
                    Button("Prepend") {
                        for _ in 0...100 {
                            let next = String(data.count)
                            data.insert(next, at: 0)
                        }
                    }
                    Button("Append") {
                        let next = String(data.count)
                        data.append(next)
                    }
                    Button("Remove First") {
                        data.removeFirst()
                    }
                    Button("Remove Last") {
                        data.removeLast()
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
    }
    var dataIDText: String {
        dataID.map(String.init(describing:)) ?? "None"
    }
}


#Preview {
    AddExperimentItemsView()
}
