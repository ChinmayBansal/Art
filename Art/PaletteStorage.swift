//
//  PaletteStorage.swift
//  Art
//
//  Created by Chinmay Bansal on 8/4/22.
//

import SwiftUI

struct Palette: Identifiable, Codable, Hashable {
    var name: String
    var emojis: String
    var id: Int
    
    fileprivate init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}

class PaletteStorage: ObservableObject {
    let name: String
    
    @Published var palettes = [Palette]() {
        didSet {
            storeUserDefault()
        }
    }
    
    private var userDefaultsKey: String {
        "PaletteStorage:" + name
    }
    private func storeUserDefault() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
//        UserDefaults.standard.set(palettes.map { [$0.name, $0.emojis, String($0.id)] }, forKey: userDefaultsKey)
            
    }
    
    private func restoreUserDefault()  {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
        let decodedPalettes = try? JSONDecoder().decode(Array<Palette>.self, from: jsonData) {
            palettes = decodedPalettes 
        }
//        if let palettesAsPropertyList = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String]] {
//            for paletteAsArray in palettesAsPropertyList {
//                if paletteAsArray.count == 3, let id = Int(paletteAsArray[2]), !palettes.contains(where: { $0.id == id}) {
//                    let palette = Palette(name: paletteAsArray[0], emojis: paletteAsArray[1], id: id)
//                    palettes.append(palette)
//                }
//            }
//        }
    }
    
    init(named name: String) {
        self.name = name
        restoreUserDefault()
        if palettes.isEmpty {
            print("using built in palettes")
            insertPalette(named: "Vehicles", emojis: "ππππππππ»πππππππβοΈπ«π¬π©ππΈπ²ππΆβ΅οΈπ€π₯π³β΄π’ππππππππΊπ")
                      insertPalette(named: "Sports", emojis: "πβΎοΈπβ½οΈπΎππ₯πβ³οΈπ₯π₯πβ·π³")
                      insertPalette(named: "Music", emojis: "πΌπ€πΉπͺπ₯πΊπͺπͺπ»")
                      insertPalette(named: "Animals", emojis: "π₯π£πππππππ¦ππππππ¦π¦π¦π¦π’ππ¦π¦π¦πππ¦π¦π¦§π¦£ππ¦π¦πͺπ«π¦π¦π¦¬ππ¦ππ¦ππ©π¦?ππ¦€π¦’π¦©ππ¦π¦¨π¦‘π¦«π¦¦π¦₯πΏπ¦")
                      insertPalette(named: "Animal Faces", emojis: "π΅ππππΆπ±π­πΉπ°π¦π»πΌπ»ββοΈπ¨π―π¦π?π·πΈπ²")
                      insertPalette(named: "Flora", emojis: "π²π΄πΏβοΈππππΎππ·πΉπ₯πΊπΈπΌπ»")
                      insertPalette(named: "Weather", emojis: "βοΈπ€βοΈπ₯βοΈπ¦π§βπ©π¨βοΈπ¨βοΈπ§π¦πβοΈπ«πͺ")
                      insertPalette(named: "COVID", emojis: "ππ¦ π·π€§π€")
                      insertPalette(named: "Faces", emojis: "ππππππππ€£π₯²βΊοΈππππππππ₯°πππππππππ€ͺπ€¨π§π€ππ₯Έπ€©π₯³ππππππβΉοΈπ£ππ«π©π₯Ίπ’π­π€π π‘π€―π³π₯Άπ₯ππ€π€π€­π€«π€₯π¬ππ―π§π₯±π΄π€?π·π€§π€π€ ")
        } else {
            print("loaded palettes from UserDefaults: \(palettes)")
        }
    }
    
    // MARK: - Intent
    
    
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
}
