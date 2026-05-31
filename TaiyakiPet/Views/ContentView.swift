import SwiftUI

struct ContentView: View {
    @StateObject private var manager = PetManager()
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.94, blue: 0.92).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("うさぎのたいやき")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.brown)
                
                // Pet Display
                ZStack {
                    Image(manager.pet.currentStateImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    if manager.pet.poopLevel > 0 {
                        Image("poop_\(manager.pet.poopLevel)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .offset(x: 40, y: 40)
                    }
                    
                    // Speech Bubble
                    ZStack {
                        Image("speech_bubble")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 90)
                        
                        Text(manager.pet.currentSpeech)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.brown)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                            .frame(width: 90)
                    }
                    .offset(x: -70, y: -70)
                }
                .padding(30)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                
                // Stats
                VStack(spacing: 15) {
                    StatBar(iconName: "Hunger_level", gaugeName: "Hunger_level_gauge", label: "おなか", value: manager.pet.hunger, color: .orange)
                    StatBar(iconName: "Fluffiness_level", gaugeName: "Fluffiness_Level_Gauge", label: "ふわふわ", value: manager.pet.fluffiness, color: .yellow)
                    StatBar(iconName: "Mood_level", gaugeName: "Mood_level_gauge", label: "しあわせ", value: manager.pet.happiness, color: .pink)
                }
                .padding(.horizontal, 40)
                
                // Actions
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        ActionButton(label: "ごはん", icon: "carrot.fill") {
                            manager.feed()
                        }
                        ActionButton(label: "あそぶ", icon: "gamecontroller.fill") {
                            manager.play()
                        }
                        ActionButton(label: "ねる", icon: "moon.stars.fill") {
                            manager.sleep()
                        }
                    }
                    
                    if manager.pet.poopLevel > 0 {
                        ActionButton(label: "そうじ", icon: "sparkles") {
                            manager.clean()
                        }
                    }
                }
                
                // Settings Button
                Button(action: { /* settings */ }) {
                    Image("setting_button")
                        .resizable()
                        .frame(width: 44, height: 44)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .onAppear {
            manager.update()
        }
    }
}

struct StatBar: View {
    let iconName: String
    let gaugeName: String
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(iconName)
                .resizable()
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                ZStack(alignment: .leading) {
                    // Gauge Background
                    Image(gaugeName)
                        .resizable()
                        .frame(height: 12)
                        .opacity(0.3)
                    
                    // Gauge Progress (Masking or Simple Overlay)
                    GeometryReader { geometry in
                        Image(gaugeName)
                            .resizable()
                            .frame(width: geometry.size.width, height: 12)
                            .mask(
                                Rectangle()
                                    .frame(width: geometry.size.width * CGFloat(value / 100.0))
                            )
                    }
                    .frame(height: 12)
                }
            }
        }
    }
}

struct ActionButton: View {
    let label: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image("button")
                    .resizable()
                    .frame(width: 80, height: 80)
                
                VStack {
                    Image(systemName: icon)
                        .font(.title2)
                    Text(label)
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ContentView()
}
