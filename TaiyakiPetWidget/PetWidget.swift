import WidgetKit
import SwiftUI
import AppIntents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PetEntry {
        PetEntry(date: Date(), pet: PetData())
    }

    func getSnapshot(in context: Context, completion: @escaping (PetEntry) -> ()) {
        let manager = PetManager()
        let entry = PetEntry(date: Date(), pet: manager.pet)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let manager = PetManager()
        manager.update()
        
        let currentDate = Date()
        let entry = PetEntry(date: currentDate, pet: manager.pet)

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct PetEntry: TimelineEntry {
    let date: Date
    let pet: PetData
}

struct PetWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ZStack {
                    Image(entry.pet.currentStateImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    if entry.pet.poopLevel > 0 {
                        Image("poop_\(entry.pet.poopLevel)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .offset(x: 12, y: 12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    WidgetStatMini(iconName: "Hunger_level", value: entry.pet.hunger, color: .orange)
                    WidgetStatMini(iconName: "Mood_level", value: entry.pet.happiness, color: .pink)
                }
            }
            
            HStack(spacing: 10) {
                if entry.pet.poopLevel > 0 {
                    Button(intent: CleanIntent()) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                } else {
                    Button(intent: FeedIntent()) {
                        Image(systemName: "carrot.fill")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                    Button(intent: PlayIntent()) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct WidgetStatMini: View {
    let iconName: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(iconName)
                .resizable()
                .frame(width: 10, height: 10)
            
            Capsule()
                .fill(color.opacity(0.3))
                .frame(width: 40, height: 4)
                .overlay(
                    GeometryReader { geo in
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * CGFloat(value / 100.0))
                    }, alignment: .leading
                )
        }
    }
}

@main
struct PetWidget: Widget {
    let kind: String = "TaiyakiPetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Taiyaki Pet Widget")
        .description("Take care of your pet directly from your home screen.")
        .supportedFamilies([.systemSmall])
    }
}
