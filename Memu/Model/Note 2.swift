//
//  Note.swift
//  Memu
//
//  Created by Beatriz Sato on 09/11/20.
//

import UIKit


class Note: Hashable {
    var id = UUID()
    var name: String
    var soundFile: String
    var color: String
    var image: UIImage
    
    init(name: String, soundFile: String, color: String) {
        self.name = name
        self.soundFile = soundFile
        self.color = color
        // começa sempre desligado
        image = UIImage(named: "key\(self.color)Off")!
    }
    
    func turnOn() {
        image = UIImage(named: "key\(color)On")!
    }
    
    func turnOff() {
        image = UIImage(named: "key\(color)Off")!
    }
    
    // MARK: Hashable Protocol Methods
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
