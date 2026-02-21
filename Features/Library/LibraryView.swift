import SwiftUI

struct LibraryView: View {
    let workouts: [Workout]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Library")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                ForEach(workouts) { workout in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(workout.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(workout.duration) min · \(workout.level.rawValue.capitalized)")
                            .font(.subheadline)
                            .foregroundColor(Color.fitdjMutedText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fitdjCard()
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .fitdjScreenBackground()
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.inline)
    }
}
