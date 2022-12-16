//
//  SwitchStoreBugApp.swift
//  SwitchStoreBug
//
//  Created by Nate Mann on 12/16/22.
//

import SwiftUI

@main
struct SwitchStoreBugApp: App {
    var body: some Scene {
        WindowGroup {
          ParentView(store: .init(
            initialState: .init(
              number: 5,
              section: .other(.init(number: 0)),
              selectedTab: .other),
            reducer: Parent()))
        }
    }
}
