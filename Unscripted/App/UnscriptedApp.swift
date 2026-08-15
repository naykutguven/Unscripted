//
//  UnscriptedApp.swift
//  Unscripted
//
//  Created by Aykut Güven on 25.07.26.
//

import SwiftUI

@main
struct UnscriptedApp: App {
    // TODO: Build it via AppComposition / AppComposer in the future
    @State private var router: AppRouter = .init()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.router, router)
        }
    }
}
