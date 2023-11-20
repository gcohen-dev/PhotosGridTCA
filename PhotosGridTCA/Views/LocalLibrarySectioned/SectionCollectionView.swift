//
//  SectionCollectionView.swift
//  PhotosGridTCA
//
//  Created by Guy Cohen on 19/11/2023.
//

import SwiftUI

struct SectionCollectionView: View {
    @StateObject var sectionCollection : SectionCollection = SectionCollection(smartAlbum: .smartAlbumUserLibrary) /// Represents the entire photo library.
    
    @Environment(\.displayScale) private var displayScale
        
    private static let itemSpacing: CGFloat = 0//12.0
    private static let itemCornerRadius = 15.0
    private static let itemSize = CGSize(width: 90, height: 90)
    
    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2), height: Self.itemSize.height * min(displayScale, 2))
    }
    
    private let columns = [GridItem(.flexible(), spacing: 0),
                           GridItem(.flexible(), spacing: 0),
                           GridItem(.flexible(), spacing: 0)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Self.itemSpacing, pinnedViews: [.sectionHeaders]) {
                
                ForEach(sectionCollection.photoSectioned) { section in
                    
                    Section(header: Text("\(section.month) - \(section.year)")) {
                        
                        ForEach(section.fetchResult) { asset in
                         
                            NavigationLink {
                                PhotoView(asset: asset, cache: sectionCollection.cache)
                            } label: {
                                photoItemView(asset: asset)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel(asset.accessibilityLabel)
                        }
                    }
                }
            }
            .padding([.vertical], Self.itemSpacing)
        }
        .navigationTitle("Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.visible)
        .statusBar(hidden: false)
        .task({
            do {
                try await sectionCollection.load()
            } catch {
                print("error:\(error)")
            }
        })
    }
    
    private func photoItemView(asset: PhotoAsset) -> some View {
        PhotoItemView(asset: asset, cache: sectionCollection.cache, imageSize: imageSize)
//            .frame(width: Self.itemSize.width, height: Self.itemSize.height)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)

            .clipped()
            .overlay(alignment: .bottomLeading) {
                if asset.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: 4, y: -4)
                }
            }
            .onAppear {
                Task {
                    await sectionCollection.cache.startCaching(for: [asset], targetSize: imageSize)
                }
            }
            .onDisappear {
                Task {
                    await sectionCollection.cache.stopCaching(for: [asset], targetSize: imageSize)
                }
            }
    }
}

//#Preview {
//    SectionCollectionView()
//}
