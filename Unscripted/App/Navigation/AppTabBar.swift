//
//  AppTabBar.swift
//  Unscripted
//
//  Created by Aykut Güven on 14.08.26.
//

import SwiftUI

struct AppTabBar: View {
    @Environment(\.router) private var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab(
                "",
                systemImage: AppTab.journal.symbolName,
                value: .journal,
                role: AppTab.journal.role
            ) {
                JournalView()
            }

            Tab(
                "",
                systemImage: AppTab.calendar.symbolName,
                value: .calendar,
                role: AppTab.calendar.role
            ) {
                CalendarView()
            }

            Tab(
                "",
                systemImage: AppTab.reflections.symbolName,
                value: .reflections,
                role: AppTab.reflections.role
            ) {
                ReflectionsView()
            }

            Tab(
                "",
                systemImage: AppTab.search.symbolName,
                value: .search,
                role: AppTab.search.role
            ) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    AppTabBar()
}
