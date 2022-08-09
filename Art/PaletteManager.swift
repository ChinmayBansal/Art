//
//  PaletteManager.swift
//  Art
//
//  Created by Chinmay Bansal on 8/9/22.
//

import SwiftUI

struct PaletteManager: View {
    @EnvironmentObject var store: PaletteStorage
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .previewDevice("iPhone 11 Pro Max")
            .environmentObject(PaletteStorage(named: "Preview"))
    }
}
