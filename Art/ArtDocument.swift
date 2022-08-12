//
//  ArtDocument.swift
//  Art
//
//  Created by Chinmay Bansal on 8/2/22.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
    static let art = UTType(exportedAs: "Chinmay-Bansal.Art")
}

class ArtDocument: ReferenceFileDocument {
    
    static var readableContentTypes = [UTType.art]
    static var writableContentTypes = [UTType.art]

    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            art = try ArtModel(json: data)
            fetchBackgroundImageDataIfNecessary()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try art.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    @Published private(set) var art: ArtModel {
        didSet {
            if art.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    init() {
            art = ArtModel()
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

        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }

    //  MARK: - Intent(s)

    
    
    func setBackground(_ background: ArtModel.Background, undoManager: UndoManager?) {
        undoablyPerform(operation: "Set Background", with: undoManager) {
            art.background = background
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat, undoManager: UndoManager?) {
        undoablyPerform(operation: "Add \(emoji)", with: undoManager) {
            art.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func moveEmoji(_ emoji: ArtModel.Emoji, by offset: CGSize, undoManager: UndoManager?) {
        if let index = art.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Move", with: undoManager) {
                art.emojis[index].x += Int(offset.width)
                art.emojis[index].y += Int(offset.height)
                
            }
        }
    }
    
    func scaleEmoji(_ emoji: ArtModel.Emoji, by scale: CGFloat, undoManager: UndoManager?) {
        if let index = art.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Scale", with: undoManager) {
                art.emojis[index].size = Int((CGFloat(art.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
            }
        }
    }
    
    // MARK: - Undo
    
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldArt = art
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(operation: operation, with: undoManager) {
                myself.art = oldArt
            }
        }
        undoManager?.setActionName(operation)
    }
}

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id})
    }
}
