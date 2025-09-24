import SwiftUI

struct LibraryView: View {
    let workouts: [Workout]

    var body: some View {
        List(workouts) { workout in
            Text(workout.title)
                .foregroundColor(.white)
        }
        .listStyle(.plain)
        .background(Color.black)
        .navigationTitle("Library")
    }
}
