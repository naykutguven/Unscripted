//
//  AppRouter.swift
//  Unscripted
//
//  Created by Aykut Güven on 14.08.26.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class AppRouter {
    var selectedTab: AppTab = .journal

    var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .journal:
            JournalView()
        case .calendar:
            CalendarView()
        case .reflections:
            ReflectionsView()
        case .search:
            SearchView()
        case .settings:
            SettingsView()
        case .entryDetail:
            EntryDetailView()
        case .recording:
            RecordingView()
        }
    }
}
