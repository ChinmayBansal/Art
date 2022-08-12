//
//  ArtApp.swift
//  Art
//
//  Created by Chinmay Bansal on 8/2/22.
//

import SwiftUI

@main
struct ArtApp: App {
    @StateObject var paletteStorage = PaletteStorage(named: "Default")
    
    var body: some Scene {
        DocumentGroup(newDocument: { ArtDocument() }) { config in
            ArtDocumentView(document: config.document)
                .environmentObject(paletteStorage)
        }
    }
}
