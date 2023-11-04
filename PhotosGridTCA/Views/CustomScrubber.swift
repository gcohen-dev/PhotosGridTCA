//
//  CustomScrubber.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 29/10/2023.
//

import Foundation
import SwiftUI

struct CustomScrubber: View {
    // The height of the entire scrubber track.
    private let trackHeight: CGFloat = UIScreen.main.bounds.height * 0.75

    // The height of the knob within the scrubber.
    private let knobHeight: CGFloat = 50

    // The current position of the knob within the scrubber.
    @State private var knobPosition: CGFloat = 0

    // The action to perform when scrubbing. This closure can accept the current percentage of the scrub.
    var onScrub: ((CGFloat) -> Void)?
    var onEnded: ((CGFloat) -> Void)?

    var body: some View {
        let dragGesture = DragGesture()
            .onChanged { value in
                // Update the knob position while ensuring it doesn't exceed the bounds of the track.
                knobPosition = min(max(0, value.location.y - (knobHeight / 2)), trackHeight - knobHeight)

                // Calculate the current scrub percentage and call the action.
                let scrubPercentage = knobPosition / (trackHeight - knobHeight)
                onScrub?(scrubPercentage)
            }.onEnded { value in
                // Update the knob position while ensuring it doesn't exceed the bounds of the track.
                knobPosition = min(max(0, value.location.y - (knobHeight / 2)), trackHeight - knobHeight)

                // Calculate the current scrub percentage and call the action.
                let scrubPercentage = knobPosition / (trackHeight - knobHeight)
                onEnded?(scrubPercentage)
            }

        return VStack {
            // The track of the scrubber.
            ZStack(alignment: .top) {
                Rectangle()
                    .frame(width: 20, height: trackHeight)
                    .foregroundColor(.gray.opacity(0.5))

                // The knob of the scrubber.
                Rectangle()
                    .frame(width: 40, height: knobHeight)  // Making the knob wider and easier to grab.
                    .foregroundColor(.white)
                    .shadow(radius: 4)  // Optional: for better visual effect.
                    .offset(y: knobPosition)
                    .gesture(dragGesture)  // Attach the drag gesture.
            }
        }
        .frame(height: trackHeight)
    }
}

#Preview {
    CustomScrubber()
}
