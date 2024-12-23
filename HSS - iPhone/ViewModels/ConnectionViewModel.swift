//
//  ConnectionViewModel.swift
//  HSS - iPhone
//
//  Created by Jonathan Huang on 12/23/24.
//

import SwiftUI
import Network


/*
1) Uses the AppServiceBrowswer to discover Macbooks around
2) Maintains the list of discovered services
3) Manages connection to a single service
*/
class ConnectionViewModel: ObservableObject {
    // get services using bonjour
    private let serviceBrowser = AppServiceBrowser()
    
    // all connections
    @Published var services: [NWBrowser.Result] = []
    
    // tracks state of the current connection
    @Published var connectionState: NWConnection.State = .setup
    
    // the current connection it is on
    private var connection: NWConnection?

    init() {
        // This is called when the list of discovered services changes
        serviceBrowser.onServicesUpdated = {[weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.services = self.serviceBrowser.discoveredServices
            }
        }
        
        // searches for the services using Bonjour
        serviceBrowser.startBrowsing()
    }
    
    // connect with a specified service
    func connect(to service: NWBrowser.Result) {
        // cancel current connection
        connection?.cancel()
        connection = nil
        
        switch service.endpoint {
        case let.service(name, type, domain, _):
            let newConnection = NWConnection(to: .service(name: name, type: type, domain: domain, interface: nil), using: .tcp)
            
            // monitors the connection's lifecycle.
            // 
            newConnection.stateUpdateHandler = {[weak self] newState in
                DispatchQueue.main.async {
                    self?.connectionState = newState
                }
                switch newState {
                case .ready:
                    print("Connection is ready to \(name).")
                case .failed(let error):
                    print("Connection failed: \(error)")
                default:
                    break
                }
            }
            
            connection = newConnection
            connection?.start(queue: DispatchQueue.global())
        default:
            print("Unknown endpoint type: \(service.endpoint)")
        }
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        
        DispatchQueue.main.async {
            self.connectionState = .setup
        }
    }
}
