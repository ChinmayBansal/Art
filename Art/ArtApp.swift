//
//  ArtApp.swift
//  Art
//
//  Created by Chinmay Bansal on 8/2/22.
//

import SwiftUI

@main
struct ArtApp: App {
    @StateObject var document = ArtDocument()
    @StateObject var paletteStorage = PaletteStorage(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            ArtDocumentView(document: document)
                .environmentObject(paletteStorage)
        }
    }
}
