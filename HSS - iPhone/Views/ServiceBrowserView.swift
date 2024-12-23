//
//  ServiceBrowserView.swift
//  HSS - iPhone
//
//  Created by Jonathan Huang on 12/23/24.
//

import SwiftUI
import Network

struct ServiceBrowserView: View {
    
    @StateObject private var viewModel = ConnectionViewModel()
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.services, id: \.self) { service in
                    ServiceRow(service: service, onConnect: {
                        viewModel.connect(to: service)
                    })
                }
                
                Text("Connection State: \(connectionStateDescription(viewModel.connectionState))").padding()
                
                Button("Disconnect") {
                    viewModel.disconnect()
                }
                .padding(.bottom, 10)
            }
            .navigationTitle("Available Services")
        }
    }
    
    private func connectionStateDescription(_ state: NWConnection.State) -> String {
        switch state {
        case .setup:
            return "Not connected"
        case .waiting(let error):
            return "Waiting: \(error.localizedDescription)"
        case .preparing:
            return "Preparing..."
        case .ready:
            return "Connected"
        case .failed(let error):
            return "Failed: \(error.localizedDescription)"
        case .cancelled:
            return "Cancelled"
        @unknown default:
            return "Unknown"
        }
    }
    
    struct ServiceRow: View {
        let service: NWBrowser.Result
        let onConnect: () -> Void
        
        var body: some View {
            switch service.endpoint {
            case let .service(name: name, type: type, domain: domain, _):
                HStack {
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.headline)
                        Text("\(type) @ \(domain)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Connect", action: onConnect)
                        .buttonStyle(.borderedProminent)
                    
                }
            default:
                Text("Unknown Service Endpoint")
            }
        }
    }
}
