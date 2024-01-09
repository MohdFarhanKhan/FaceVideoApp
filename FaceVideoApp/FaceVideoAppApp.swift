//
//  FaceVideoAppApp.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 27/06/1445 AH.
//

import SwiftUI

@main
struct FaceVideoAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
