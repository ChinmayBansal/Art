//
//  PaletteEditor.swift
//  Art
//
//  Created by Chinmay Bansal on 8/8/22.
//

import SwiftUI

struct PaletteEditor: View {
    @State private var palette: Palette = PaletteStorage(named: "Test").palette(at: 2)
    
    var body: some View {
        TextField("Name",text: $palette.name)
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor()
    }
}
