//
//  AppServiceBrowser.swift
//  HSS - iPhone
//
//  Created by Jonathan Huang on 12/23/24.
//

import Network

/*
Goal:
 
1) Browse for network services on the local network using Bonjour
2) Connect with a service after finding it
 
*/

class AppServiceBrowser {
    var browser: NWBrowser?
    var discoveredServices: [NWBrowser.Result] = []
    
    // gets called which is useful for notifying UI to update itself
    var onServicesUpdated: (() -> Void)?
    
    func startBrowsing() {
        let browserDescriptor = NWBrowser.Descriptor.bonjour(type: "HSS._tcp", domain: "local.") // look for the mac service that matches HSS tag
        let parameters = NWParameters()
        
        browser = NWBrowser(for: browserDescriptor, using: parameters)
        
        // handle discovered services
        // Gets called when new services are detected or old services drop out
        // iterate over all of the new services and resolve them
        browser?.browseResultsChangedHandler = { [weak self](results: Set<NWBrowser.Result>, changes: Set<NWBrowser.Result.Change>) in
            guard let self = self else { return }
            
            self.discoveredServices = Array(results)
            
            self.onServicesUpdated?()
        }
        
        
        // Handling Browser State. Just for helpful information
        browser?.stateUpdateHandler = { (state: NWBrowser.State) in
            switch state {
            case .ready:
                print("Browser is ready")
            case .failed(let error):
                print("Browser failed: \(error)")
            default:
                break
            }
        }
        
        browser?.start(queue: DispatchQueue.global())
    }
    
    // Resolves the service... duh
    func resolveService(_ result: NWBrowser.Result) {
        switch result.endpoint {
            case let .service(name, type, domain, _):
                print("Service found: \(name), \(type), \(domain)")
                let connection = NWConnection(to: .service(name: name, type: type, domain: domain, interface: nil), using: .tcp)
                connection.stateUpdateHandler = { (state: NWConnection.State) in
                    switch state {
                    case .ready:
                        print("Resolved service: \(name)")
                        connection.cancel()
                    case .failed(let error):
                        print("Connection failed: \(error)")
                    default:
                        break
                    }
                }
                
                connection.start(queue: DispatchQueue.global())
            default:
                print("Unknown endpoint type: \(result.endpoint)")
                return
        }
    }
}
