import SwiftUI

struct CompletionView: View {
    let workout: Workout
    let duration: TimeInterval

    var body: some View {
        VStack(spacing: 24) {
            Text("Workout Complete!")
                .font(.largeTitle.bold())
            Text("You crushed \(workout.title) in \(Int(duration / 60)) minutes.")
            Button("Share") {}
                .buttonStyle(.borderedProminent)
                .tint(Color.fitdjAccent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}
