//
//  PaginationScrubberView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 29/10/2023.
//

import SwiftUI

struct PaginationScrubberView: View {
    var body: some View {
        ZStack {
            PaginationView()
            HStack {
                Spacer()
                CustomScrubber { percentage in
                    print("percenate")
                }
            }
        }
        
    }
}

#Preview {
    PaginationScrubberView()
}
