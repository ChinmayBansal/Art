//
//  ArtDocument.swift
//  Art
//
//  Created by Chinmay Bansal on 8/2/22.
//

import SwiftUI
import Combine

class ArtDocument: ObservableObject {
    @Published private(set) var art: ArtModel {
        didSet {
            scheduledAutosave()
            if art.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    private struct Autosave {
        static let filename = "Autosaved.art"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval = 5.0
    }
    private var autosaveTimer: Timer?
    
    private func scheduledAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
            self.autosave()
        }
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisfunc = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try art.json()
            print("\(thisfunc) json = \(String(data: data, encoding: .utf8) ?? "nil")")

            try data.write(to: url)
            print("\(thisfunc) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisfunc) coudln't encode art as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisfunc) error = \(error)")
        }
    }
    
    init() {
        if let url = Autosave.url, let autosavedArt = try? ArtModel(url: url) {
            art = autosavedArt
            fetchBackgroundImageDataIfNecessary()
        } else {
            art = ArtModel()

        }
    }
    
    
    var emojis: [ArtModel.Emoji] { art.emojis }
    var background: ArtModel.Background { art.background}
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch art.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            backgroundImageFetchCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { (data, URLResponse) in UIImage(data: data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
            
            backgroundImageFetchCancellable = publisher
                .sink { [weak self] image in
                    self?.backgroundImage = image
                    self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                }
//                .assign(to: \ArtDocument.backgroundImage, on: self)
//            DispatchQueue.global(qos: .userInitiated).async {
//                let imageData = try? Data(contentsOf: url)
//                DispatchQueue.main.async { [weak self] in
//                    if self?.art.background == ArtModel.Background.url(url) {
//                        self?.backgroundImageFetchStatus = .idle
//                        if imageData != nil {
//                            self?.backgroundImage = UIImage(data: imageData!)
//                        }
//                        if self?.backgroundImage == nil {
//                            self?.backgroundImageFetchStatus = .failed(url)
//                        }
//                    }
//                }
//            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }

    //  MARK: - Intent(s)

    
    
    func setBackground(_ background: ArtModel.Background) {
        art.background = background
        print("background set to \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        art.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: ArtModel.Emoji, by offset: CGSize) {
        if let index = art.emojis.index(matching: emoji) {
            art.emojis[index].x += Int(offset.width)
            art.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: ArtModel.Emoji, by scale: CGFloat) {
        if let index = art.emojis.index(matching: emoji) {
            art.emojis[index].size = Int((CGFloat(art.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    
    
}

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id})
    }
}
