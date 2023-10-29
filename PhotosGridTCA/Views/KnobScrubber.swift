//
//  KnobScrubber.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 25/10/2023.
//

import SwiftUI

//struct KnobScrubberView: View {
//    @Binding var value: CGFloat
//
//      var body: some View {
//          Circle()
//              .fill(.gray)
//              .frame(width: 20, height: 20)
//              .overlay(
//                  Circle()
//                      .stroke(lineWidth: 2)
//                      .foregroundColor(.white)
//                      .frame(width: 20, height: 20)
//              )
//              .offset(y: -value)
//              .gesture(DragGesture(coordinateSpace: .global)
//                  .onChanged { gesture in
//                      gesture.location.y
//                      let deltaY = gesture.location.y - self.position.y
//                      self.value = max(min(self.value + deltaY / 100, 1), 0)
//                  }
//              )
//      }
//}
//
//
//#Preview {
//    KnobScrubberView(value: .constant(50))
//}
