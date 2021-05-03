//
//  ContentView.swift
//  Frame
//
//  Created by George Livas on 03/05/2021.
//

import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    deinit {
        cancel()
    }
    
    private var cancellable: AnyCancellable?

    func load() {
        UIApplication.shared.isIdleTimerDisabled = true
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader

    init(url: URL) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        content.onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if loader.image != nil {
                GeometryReader { geo in
                   Image(uiImage: loader.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                }
            } else {
                Text("Loading...")
            }
        }
    }
}

struct ContentView: View {

    let url = URL(string: "https://glivas-frame.s3.eu-west-2.amazonaws.com/frame.png")!
    
    var body: some View {
            AsyncImage(url: url)
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
