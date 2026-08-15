//
//  AppTab.swift
//  Unscripted
//
//  Created by Aykut Güven on 05.08.26.
//

import SwiftUI

enum AppTab: String, Identifiable {
    case journal
    case calendar
    case reflections
    case search

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .journal:
            "Journal"
        case .calendar:
            "Calendar"
        case .reflections:
            "Reflections"
        case .search:
            "Search"
        }
    }

    var symbolName: String {
        switch self {
        case .journal:
            "books.vertical"
        case .calendar:
            "calendar"
        case .reflections:
            "sparkles"
        case .search:
            "magnifyingglass"
        }
    }

    var role: TabRole? {
        self == .search ? .search : nil
    }
}
