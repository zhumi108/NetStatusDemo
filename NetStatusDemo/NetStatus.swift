//
//  NetStatus.swift
//  NetStatusDemo
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import Network

class NetStatus {
    
    static let shared = NetStatus()
    
    var monitor: NWPathMonitor?
    
    var isMonitoring = false
    
    var didStartMonitoringHandler: (() -> Void)?
    
    var didStopMonitoringHandler: (() -> Void)?
    
    var netStatusChangeMonitoring: (() -> Void)?
    
    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    
    var interfaceType: NWInterface.InterfaceType? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.filter { monitor.currentPath.usesInterfaceType($0.type)
            }.first?.type
    }
    
    var availableInterfaceTypes: [NWInterface.InterfaceType]? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map { $0.type }
    }
    
    var isExpensive: Bool {
        return monitor?.currentPath.isExpensive ?? false
    }
    
    
    private init() {}
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        
        guard !isMonitoring else { return }
        
        let queue = DispatchQueue(label: "NetStatus_Monitoring")
        monitor = NWPathMonitor()
        monitor?.start(queue: queue)
        
        isMonitoring = true
        didStartMonitoringHandler?()
        
        monitor?.pathUpdateHandler = { [weak self] path in
            print(path)
            self?.netStatusChangeMonitoring?()
        }
    }
    
    func stopMonitoring() {
        
        guard isMonitoring else { return }
        
        monitor?.cancel()
        monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
    
}
