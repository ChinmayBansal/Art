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
    }
    
    var emojis: [ArtModel.Emoji] { art.emojis }
    var background: [ArtModel.Emoji] { art.background }
    
    

}
