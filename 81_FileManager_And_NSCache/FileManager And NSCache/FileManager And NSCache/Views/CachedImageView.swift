//
//  CachedImageView.swift
//  FileManager And NSCache
//
//  Created by Bambang Tri Rahmat Doni on 07/12/23.
//

import SwiftUI

struct CachedImageView<Content>: View where Content: View {
    let item: (name: String, url: String)
    var animation: Animation = .easeInOut
    var transition: AnyTransition = .scale
    
    @ViewBuilder let content: (AsyncImagePhase) -> Content
    
    @StateObject private var manager = ImageCacheManager()
    
    var body: some View {
        ZStack {
            switch self.manager.state {
            case .loading:
                self.content(.empty)
                    .transition(self.transition)
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.content(
                        .success(Image(uiImage: image))
                    )
                    .transition(self.transition)
                } else {
                    self.content(
                        .failure(CachedImageError
                            .invalidData(error: "Failed to load Image"))
                    )
                    .transition(self.transition)
                }
            case .failed(let error):
                self.content(.failure(error))
                    .transition(self.transition)
            default:
                self.content(.empty)
                    .transition(self.transition)
            }
        }
        .animation(self.animation, value: self.manager.state)
        .task {
            await self.manager.loadImage(self.item)
        }
    }
}

#Preview {
    CachedImageView(
        item: (
            name: "",
            url: "https://infatuation.imgix.net/media/images/guides/6-diy-burger-meal-kits/banners/1606222689.1394382.png"
        )
    ) { _ in return EmptyView() }
}

extension CachedImageView {
    enum CachedImageError: Error {
        case invalidData(error: String)
    }
}


