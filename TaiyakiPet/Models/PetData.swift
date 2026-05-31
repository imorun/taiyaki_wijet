import Foundation
import SwiftUI

enum PetType: String, Codable, CaseIterable {
    case character
    
    var imageName: String {
        return "pet_character"
    }
    
    var displayName: String {
        return "たいやき（うさぎ）"
    }
}

enum PetState: String, Codable {
    case born = "born" // 生まれたて
    case fine = "fine" // 元気（大人）
}

struct PetData: Codable {
    var type: PetType = .character
    var state: PetState = .born
    var birthDate: Date = Date()
    var hunger: Double = 100.0 // おなか
    var fluffiness: Double = 100.0 // ふわふわ度
    var happiness: Double = 100.0 // しあわせ
    var poopLevel: Int = 0 // うんちの数 (0-3)
    var lastUpdate: Date = Date()
    var currentSpeech: String = "はじめまして！"
    
    // Decrease stats and manage lifecycle
    mutating func updateStats() {
        let now = Date()
        
        // Lifecycle: born -> fine after 1 minute (for testing/demo)
        if state == .born && now.timeIntervalSince(birthDate) > 60 {
            state = .fine
            currentSpeech = "大きくなったよ！"
        }
        
        let elapsedSeconds = now.timeIntervalSince(lastUpdate)
        let hoursElapsed = elapsedSeconds / 3600.0
        
        hunger = max(0, hunger - (5.0 * hoursElapsed))
        fluffiness = max(0, fluffiness - (8.0 * hoursElapsed))
        happiness = max(0, happiness - (4.0 * hoursElapsed))
        
        // Randomly increase poop level (roughly every 4 hours)
        if state == .fine && Double.random(in: 0...1) < (hoursElapsed / 4.0) {
            poopLevel = min(3, poopLevel + 1)
        }
        
        updateSpeech()
        lastUpdate = now
    }
    
    mutating func updateSpeech() {
        if state == .born {
            let bornSpeeches = ["おりぇ〜", "おりぇ〜", "おれぇ",]
            currentSpeech = bornSpeeches.randomElement() ?? ""
            return
        }
        
        // Status based priority
        if poopLevel > 0 {
            currentSpeech = "おれうんちだぜぇ"
            return
        }
        
        if hunger < 30 {
            let hungrySpeeches = ["おりぇ〜 えさよこせ〜", "ぺこぺこおれぇだぜぇ"]
            currentSpeech = hungrySpeeches.randomElement() ?? ""
            return
        }
        
        if happiness < 30 {
            let sadSpeeches = ["おれぇ", "おりぇ〜", ]
            currentSpeech = sadSpeeches.randomElement() ?? ""
            return
        }
        
        if fluffiness < 30 {
            let tiredSpeeches = ["ねむいぜぇおれぇ...zZZ", "おりぇ", "すーぴーだぜぇ"]
            currentSpeech = tiredSpeeches.randomElement() ?? ""
            return
        }
        
        // Default speeches
        let defaultSpeeches = ["おりぇ", "だっこはいやだぜぇ", "ねむいぜぇ", "おやつくれ"]
        currentSpeech = defaultSpeeches.randomElement() ?? ""
    }
    
    mutating func feed() {
        hunger = min(100, hunger + 20)
        happiness = min(100, happiness + 5)
        currentSpeech = "うめぇぜ～"
        lastUpdate = Date()
    }
    
    mutating func play() {
        happiness = min(100, happiness + 25)
        fluffiness = max(0, fluffiness - 15)
        currentSpeech = "たのしいおりぇ～"
        lastUpdate = Date()
    }
    
    mutating func sleep() {
        fluffiness = min(100, fluffiness + 40)
        hunger = max(0, hunger - 10)
        currentSpeech = "（寝てるから邪魔すんな）"
        lastUpdate = Date()
    }
    
    mutating func clean() {
        poopLevel = 0
        happiness = min(100, happiness + 10)
        currentSpeech = "はよしろよぜ"
        lastUpdate = Date()
    }
    
    var currentStateImageName: String {
        // Example: pet_cat_born or pet_cat_fine
        return "\(type.imageName)_\(state.rawValue)"
    }
}

class PetManager: ObservableObject {
    @Published var pet: PetData
    
    private let appGroupIdentifier = "group.com.taiyaki.pet" // Replace with your actual App Group ID
    private let storageKey = "PetData"
    
    init() {
        self.pet = PetData()
        load()
        update()
    }
    
    func update() {
        pet.updateStats()
        save()
    }
    
    func feed() {
        pet.feed()
        save()
    }
    
    func play() {
        pet.play()
        save()
    }
    
    func sleep() {
        pet.sleep()
        save()
    }
    
    func clean() {
        pet.clean()
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(pet) {
            UserDefaults(suiteName: appGroupIdentifier)?.set(encoded, forKey: storageKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults(suiteName: appGroupIdentifier)?.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(PetData.self, from: data) {
            self.pet = decoded
        }
    }
}
