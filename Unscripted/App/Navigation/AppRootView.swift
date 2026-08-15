//
//  AppRootView.swift
//  Unscripted
//
//  Created by Aykut Güven on 15.08.26.
//

import SwiftUI

struct AppRootView: View {
    @Environment(\.router) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            @Bindable var router = router
            AppTabBar()
                .navigationTitle(router.selectedTab.title)
                .navigationDestination(
                    for: AppRoute.self,
                    destination: router.destination(for:)
                )
                .toolbar {
                    if router.selectedTab != .search {
                        ToolbarItem {
                            Button("", systemImage: "gearshape") {
                                router.navigate(to: .settings)
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    AppRootView()
        .environment(\.router, AppRouter())
}
