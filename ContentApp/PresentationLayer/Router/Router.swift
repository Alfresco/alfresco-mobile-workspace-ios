//
// Copyright (C) 2005-2020 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

typealias NavigationRoute = String
typealias ViewControllerFactory = (_ url: NavigationURL, _ values: [String: Any]) -> UIViewController?

protocol RouterProtocol {
    func register(route: NavigationRoute, factory: @escaping ViewControllerFactory)
    func push(route: NavigationRoute, from: UINavigationController?, animated: Bool) -> UIViewController?
    func present(route: NavigationRoute, inside: UINavigationController?, from: UIViewController?, animated: Bool) -> UIViewController?
}

class Router: RouterProtocol {
    private var viewControllerFactories = [NavigationRoute: ViewControllerFactory]()

    @discardableResult
    func present(route: NavigationRoute, inside: UINavigationController?, from: UIViewController?, animated: Bool) -> UIViewController? {
        guard let viewController = factory(for: route) else { return nil }
        guard let navigationController = from ?? UIViewController.applicationTopMost?.navigationController else { return nil }

        var viewControllerToPresent = viewController
        if let navigationControllerToPresentIn = inside {
            if (viewController is UINavigationController) == false {
                navigationControllerToPresentIn.viewControllers = [viewControllerToPresent]
                viewControllerToPresent = navigationControllerToPresentIn
            }
        }

        navigationController.present(viewControllerToPresent, animated: animated, completion: nil)
        return viewController
    }

    func register(route: NavigationRoute, factory: @escaping (NavigationURL, [String: Any]) -> UIViewController?) {
        viewControllerFactories[route] = factory
    }

    @discardableResult
    func push(route: NavigationRoute, from: UINavigationController? = nil, animated: Bool = true) -> UIViewController? {
        guard let viewController = factory(for: route) else { return nil }
        guard let navigationController = from ?? UIViewController.applicationTopMost?.navigationController else { return nil }
        navigationController.pushViewController(viewController, animated: animated)
        return viewController
    }

    // MARK: - Private interfacce

    private func factory(for route: NavigationRoute) -> UIViewController? {
        let routes = Array(self.viewControllerFactories.keys)
        guard let match = match(route: route, from: routes) else { return nil }
        guard let viewControllerFactory = self.viewControllerFactories[match.route] else { return nil }

        return viewControllerFactory(NavigationURL(route: route), match.values)
    }

    private func match(route: NavigationRoute, from candidates: [NavigationRoute]) -> NavigationURLMatchResult? {
        let navigationURL = NavigationURL(route: route)
        let scheme = navigationURL.url?.scheme
        let components = pathComponents(for: navigationURL)
        var results = [NavigationURLMatchResult]()

        for candidate in candidates {
            let candidateURL = NavigationURL(route: candidate)
            if scheme == candidateURL.url?.scheme {
                if let result = match(pathComponents: components, with: NavigationURL(route: candidate)) {
                    results.append(result)
                }
            }
        }

        if results.count > 1 {
            AlfrescoLog.error("Router collision for route:\(route)")
            return nil
        }

        return results.first
    }

    private func match(pathComponents: [String], with candidate: NavigationURL) -> NavigationURLMatchResult? {
        guard let navigationRoute = candidate.route else { return nil }

        let candidateStringPathComponents = self.pathComponents(for: candidate)
        let candidatePathComponents = candidateStringPathComponents.map { (path) -> NavigationURLPathComponent in
            return NavigationURLPathComponent.init(with: path)
        }

        var matchedValues: [String: Any] = [:]
        for idx in 0..<min(pathComponents.count, candidatePathComponents.count) {
            let candidateStringPathComponent = pathComponents[idx]
            let candidatePathComponent = candidatePathComponents[idx]

            switch candidatePathComponent.type {
            case .stringValue(let value):
                if value != candidateStringPathComponent {
                    return nil
                }
            case .placeholderValue(_, let value): // Can implement extension point for matching placeholder types
                matchedValues[value] = candidateStringPathComponent
            }
        }

        return NavigationURLMatchResult(route: navigationRoute, values: matchedValues)
    }

    private func pathComponents(for navigationURL: NavigationURL) -> [String] {
        let components = navigationURL.route?.components(separatedBy: "/").enumerated().filter { offset, element in
            return !element.isEmpty && !isScheme(offset: offset, element: element)
        }.map({ (_, element) -> String in
            return element
        })

        return components ?? []
    }

    private func isScheme(offset: Int, element: String) -> Bool {
        return offset == 0 && element.hasSuffix(":")
    }

}
