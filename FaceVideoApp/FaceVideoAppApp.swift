//
//  FaceVideoAppApp.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 27/06/1445 AH.
//

import SwiftUI

@main
struct FaceVideoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistentStorage = PersistentStorage.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistentStorage.context)
        }
    }
}
