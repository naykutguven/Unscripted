//
//  CategoryPillView.swift
//  Unscripted
//
//  Created by Aykut Güven on 15.08.26.
//

import SwiftUI

struct CategoryPillView: View {
    let text: LocalizedStringKey

    var body: some View {
        Text(text)
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.categoryPillFill, in: Capsule())
    }
}

#Preview {
    CategoryPillView(text: "family")
}
