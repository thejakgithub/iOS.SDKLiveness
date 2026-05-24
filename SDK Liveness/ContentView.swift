//
//  ContentView.swift
//  SDK Liveness
//
//  Created by mdc on 29/4/2569 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LivenessFlowCoordinator()
            .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
