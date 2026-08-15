//
//  MoodPillView.swift
//  Unscripted
//
//  Created by Aykut Güven on 15.08.26.
//

import SwiftUI

struct MoodPillView: View {
    let mood: Mood
    private let palette: MoodPillPalette

    init(mood: Mood) {
        self.mood = mood
        self.palette = MoodPillPalette(mood: mood)
    }

    var body: some View {
        Text(mood.localizedLabel)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(palette.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(palette.background, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(palette.border, lineWidth: 1)
            }
    }
}

#Preview {
    ForEach(Mood.allCases, id: \.self) { mood in
        MoodPillView(mood: mood)
    }
}
