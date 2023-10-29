//
//  RemotePickerFeature.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 29/10/2023.
//

import Foundation
import ComposableArchitecture

struct RemotePickerFeature: Reducer {
    
    struct State: Equatable {
        var currentPhotoIndex = 0
        var isLoadingPhotosCounter = 0
        var photos: IdentifiedArrayOf<PhotoModel> = IdentifiedArrayOf<PhotoModel>()
    }
    
    enum Action: Equatable {
        case viewAppeared
        case updatedBatch(IdentifiedArrayOf<PhotoModel>)
        case addImages(Options)
        case append(IdentifiedArrayOf<PhotoModel>)
        case sort(IdentifiedArrayOf<PhotoModel>)
        case removeImage(PhotoModel)
        case removeImages(Options)
        case random
    }
    
    enum CancelID: Hashable {
        case cancelSort
    }
    
    @Dependency(\.generatorClient) var generatorClient
    
    var body: some ReducerOf<Self> {
      
        Reduce { state, action in

            switch action {
            case .viewAppeared:
                return .run { send in
                    await send(.addImages(.firstBatch))
                }
                
            case .updatedBatch(let batch):
                state.isLoadingPhotosCounter -= 1
                state.photos = batch
                return .none
                
            case .sort(let batch):
                state.isLoadingPhotosCounter = 0
                state.photos = batch
                print("### sort")
                return .none
                
            case .append(let batch):
                
                state.photos.append(contentsOf: batch)
                
                return .run { [statePhotos = state.photos] send in
                    if Task.isCancelled {
                        print("### Task Cancelled")
                        return
                    }
                    var copy = statePhotos
                    
                    copy.sort(by: { $0.date < $1.date })
                    
                    if Task.isCancelled {
                        print("### Task Cancelled")
                        return
                    }
                    
                    await send(.sort(copy))
                }
                .cancellable(id: CancelID.cancelSort)
                
            case .addImages(let options):
                state.isLoadingPhotosCounter += 1
                let start = state.currentPhotoIndex
                let end = start + options.amount
                state.currentPhotoIndex = end

                return .merge( .cancel(id: CancelID.cancelSort), // Cont
                               .run {  [start , end] send in
                                   let photos = await generatorClient.start(start,end)
                                   await send(.append(photos))
                               }
                )
                    
            case .removeImages(let options):
                if state.photos.count > options.amount {
                    state.photos.removeLast(options.amount)
                } else {
                    state.photos.removeAll()
                }
                
                state.currentPhotoIndex = state.photos.count

                return .none
                
            case .removeImage(let photoModel):
                state.currentPhotoIndex -= 1
                state.photos.remove(id: photoModel.id)
                return .none
            case .random:
                let shuffled = state.photos.shuffled()
                state.photos = IdentifiedArrayOf(uniqueElements: shuffled)
                return .none
            }
        }
    }
}
