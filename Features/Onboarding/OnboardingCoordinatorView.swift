import SwiftUI

struct OnboardingCoordinatorView: View {
    let container: DependencyContainer
    let completion: () async -> Void
    @State private var step: Int = 0
    @State private var goal: String = "Strength"
    @State private var equipment: Set<Equipment> = []
    @State private var musicPreference: Double = 0.5

    var body: some View {
        VStack {
            TabView(selection: $step) {
                GoalStep(goal: $goal)
                    .tag(0)
                EquipmentStep(selection: $equipment)
                    .tag(1)
                MusicStep(level: $musicPreference)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .background(Color.fitdjBackground)

            Button(action: next) {
                Text(step == 2 ? "Continue" : "Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.fitdjAccent)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .animation(.easeInOut, value: step)
        .task {
            await container.musicService.authorize()
        }
    }

    private func next() {
        if step < 2 {
            step += 1
        } else {
            Task { await completion() }
        }
    }
}

private struct GoalStep: View {
    @Binding var goal: String

    var body: some View {
        VStack(spacing: 24) {
            Text("What brings you to FITDJ?")
                .font(.title2.bold())
            Picker("Goal", selection: $goal) {
                Text("Strength").tag("Strength")
                Text("Endurance").tag("Endurance")
                Text("Mobility").tag("Mobility")
            }
            .pickerStyle(.segmented)
        }
        .padding()
    }
}

private struct EquipmentStep: View {
    @Binding var selection: Set<Equipment>
    let options: [Equipment] = Equipment.allCases

    var body: some View {
        VStack(spacing: 16) {
            Text("What equipment do you have?")
                .font(.title2.bold())
            ForEach(options) { item in
                Toggle(item.rawValue.capitalized, isOn: Binding(
                    get: { selection.contains(item) },
                    set: { isOn in
                        if isOn { selection.insert(item) } else { selection.remove(item) }
                    }
                ))
                .toggleStyle(.switch)
            }
        }
        .padding()
    }
}

private struct MusicStep: View {
    @Binding var level: Double

    var body: some View {
        VStack(spacing: 32) {
            Text("Coach or Music?")
                .font(.title2.bold())
            Slider(value: $level, in: 0...1)
            Text("Balance: \(Int(level * 100))% coach")
        }
        .padding()
    }
}
