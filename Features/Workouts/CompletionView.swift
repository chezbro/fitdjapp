import SwiftUI

struct WorkoutInsights {
    let weeklyCompletions: Int
    let totalCompletions: Int
    let bestWorkoutSeconds: Int?
    let averageWorkoutSeconds: Int?
    let estimatedCalories: Int
}

struct CompletionView: View {
    let workout: Workout
    let duration: TimeInterval
    let insights: WorkoutInsights?

    @Environment(\.dismiss) private var dismiss
    @State private var glow = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.fitdjBackground, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    trophyHeader
                    summaryCard

                    if let insights {
                        insightsGrid(insights)
                    }

                    actionRow
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .foregroundColor(.white)
        .onAppear {
            Haptics.success()
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }

    private var trophyHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.fitdjAccent.opacity(glow ? 0.42 : 0.24))
                    .frame(width: 84, height: 84)
                    .scaleEffect(glow ? 1.06 : 0.96)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("Workout Complete")
                .font(.largeTitle.bold())

            Text(momentumMessage)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.title)
                .font(.title3.bold())
            Text("Finished in \(Int(duration / 60)) min")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func insightsGrid(_ insights: WorkoutInsights) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Insights")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statTile(title: "Calories", value: "\(insights.estimatedCalories)")
                statTile(title: "This Week", value: "\(insights.weeklyCompletions)")
                statTile(title: "Total", value: "\(insights.totalCompletions)")
                statTile(title: "Average", value: insights.averageWorkoutSeconds.map(format) ?? "—")
                statTile(title: "Personal Best", value: insights.bestWorkoutSeconds.map(format) ?? "—")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statTile(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.68))
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var actionRow: some View {
        VStack(spacing: 10) {
            Button("Share the Win") {}
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.fitdjAccent)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Button("Done") {
                Haptics.tap()
                dismiss()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.white.opacity(0.1))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var momentumMessage: String {
        guard let insights else { return "Excellent effort. Keep stacking consistent days." }
        if insights.weeklyCompletions >= 5 {
            return "You’re in elite consistency mode this week."
        }
        if insights.weeklyCompletions >= 3 {
            return "Momentum is building fast—keep this streak alive."
        }
        return "Great start. One more session locks the habit in."
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
