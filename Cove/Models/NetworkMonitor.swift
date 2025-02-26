//
//  NetworkMonitor.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/24/25.
//

import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var queue: DispatchQueue

    @Published var isConnected: Bool = false

    init() {
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "NetworkMonitor")
        
        self.monitor.pathUpdateHandler = { path in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                print("Network status: \(path.status)")
                self.isConnected = path.status == .satisfied
            }
        }
        
        self.monitor.start(queue: self.queue)
    }

    deinit {
        print("Cancelling network monitor")
        self.monitor.cancel()
    }
}
