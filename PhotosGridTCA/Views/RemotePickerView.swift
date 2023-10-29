//
//  ContentView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 24/10/2023.
//

import SwiftUI
import ComposableArchitecture
import Nuke
import NukeUI

struct RemotePickerView: View {
    
    let store: StoreOf<RemotePickerFeature>
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3)

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                header(viewStore: viewStore)
                    .onAppear(perform: {
                        viewStore.send(.viewAppeared)
                    })

                if !viewStore.photos.isEmpty {
                    list(viewStore: viewStore)
                } else {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                }
            }
        }
    }
    
    func header(viewStore: ViewStore<RemotePickerFeature.State, RemotePickerFeature.Action>) -> some View {
        HStack {
            
            Button(action: {
                viewStore.send(.addImages(.large), animation: .default)
            }, label: {
                Text("+++")
            })
            
            Button(action: {
                viewStore.send(.addImages(.medium), animation: .default)
            }, label: {
                Text("++")
            })
            
            Button(action: {
                viewStore.send(.addImages(.small), animation: .default)
            }, label: {
                Text("+")
            })
            
            Button(action: {
                viewStore.send(.removeImages(.small), animation: .default)
            }, label: {
                Text("-")
            })
            
            Button(action: {
                viewStore.send(.removeImages(.medium), animation: .default)
            }, label: {
                Text("--")
            })
            
            Button(action: {
                viewStore.send(.removeImages(.large), animation: .default)
            }, label: {
                Text("---")
            })
            VStack {
                Text("Expected Count:\(viewStore.currentPhotoIndex)")
                    .font(.footnote)
                Text("Real Count:\(viewStore.photos.count)")
                    .font(.footnote)
            }
            
            
            Button(action: {
                viewStore.send(.random)
            }, label: {
                Text("random")
                .font(.footnote)
            })
            
        }
        .frame(maxWidth: .infinity)
        .background(viewStore.isLoadingPhotosCounter != 0 ? .red : .green)
    }
    
    
    @MainActor
    func list(viewStore:  ViewStore<RemotePickerFeature.State, RemotePickerFeature.Action>) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(viewStore.photos) { image in

                    // Create a request with resizing options
                    let request = ImageRequest(
                        url: URL(string: image.url)!,
                        processors: [
                            ImageProcessors.Resize(size: CGSize(width: 100, height: 100))
                        ]
                    )
                    
                   return LazyImage(request: request) { state in
                        if let remoteImage = state.image {
                            ZStack {
                                remoteImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(4)
                                    .frame(width: 120, height: 120)
                                    .padding(4)
                                VStack {
                                    Spacer()
                                    Text(image.dateDescription)
                                        .foregroundColor(.white)
                                        .shadow(color: .black, radius: 4, x: 4, y: 4)
                                }
                                
                            }
                            .onTapGesture(perform: {
                                viewStore.send(.removeImage(image))
                            })
                        } else {
                            ZStack {
                                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                    .fill(Color.gray)
                                    .aspectRatio(contentMode: .fit)
                                Text(image.url)
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 4, x: 4, y: 4)
                            }
                            .frame(width: 120, height: 120)
                        }
                    }
                }
            }
            .animation(.easeIn, value: viewStore.photos)
        }
    }
}

#Preview {
    RemotePickerView(store: Store(initialState: 
                                    RemotePickerFeature.State(), reducer: {
        RemotePickerFeature()
    }))
}

