//
//  ArtDocument.swift
//  Art
//
//  Created by Chinmay Bansal on 8/2/22.
//

import SwiftUI

class ArtDocument: ObservableObject {
    @Published private(set) var art: ArtModel
    
    init() {
        art = ArtModel()
        art.addEmoji("⚽️", at: (-200, -100), size: 80)
        art.addEmoji("🥃", at: (50, 100), size: 40)

    }
    
    var emojis: [ArtModel.Emoji] { art.emojis }
    var background: ArtModel.Background { art.background}
    
    //Mark: - Intent(s)
    
    
    func setBackground(_ background: ArtModel.Background) {
        art.background = background
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
