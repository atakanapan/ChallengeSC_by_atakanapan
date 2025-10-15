//
//  Coordinator.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

// MARK: - Coordinator Protocol
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

extension Coordinator {
    func addChildCoordinator(_ child: Coordinator) {
        childCoordinators.append(child)
    }
    
    func removeChildCoordinator(_ child: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== child }
    }
}