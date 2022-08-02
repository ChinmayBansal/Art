//
//  ArtApp.swift
//  Art
//
//  Created by Chinmay Bansal on 8/2/22.
//

import SwiftUI

@main
struct ArtApp: App {
    let document = ArtDocument()
    
    var body: some Scene {
        WindowGroup {
            ArtDocumentView(document: document)
        }
    }
}
