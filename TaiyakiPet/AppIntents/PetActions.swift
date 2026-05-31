import AppIntents
import Foundation

struct FeedIntent: AppIntent {
    static var title: LocalizedStringResource = "ごはんをあげる"
    static var description = IntentDescription("ペットにごはんをあげて、おなかを満たします。")

    func perform() async throws -> some IntentResult {
        let manager = PetManager()
        manager.feed()
        return .result()
    }
}

struct PlayIntent: AppIntent {
    static var title: LocalizedStringResource = "あそぶ"
    static var description = IntentDescription("ペットとあそんで、しあわせを増やします。")

    func perform() async throws -> some IntentResult {
        let manager = PetManager()
        manager.play()
        return .result()
    }
}

struct CleanIntent: AppIntent {
    static var title: LocalizedStringResource = "そうじする"
    static var description = IntentDescription("うんちを掃除して、しあわせを増やします。")

    func perform() async throws -> some IntentResult {
        let manager = PetManager()
        manager.clean()
        return .result()
    }
}
