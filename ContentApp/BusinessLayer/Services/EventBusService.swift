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

protocol EventBusServiceProtocol {
    /** Registers  observer with the current event bus for a given event type.
     - Parameter observer: Observer object able to handle a subset of events
     - Parameter eventType: Event type for which the observer is registered
     */
    func register(observer: EventObservable, for eventType: BaseNodeEvent.Type)

    /** Publishes an event on the bus to be handled by available subscribers. If no subscribers can handle the event, then no action
     is taken by the event bus.
     - Parameter event: Event object passed to subscribers
     - Parameter queue: Queue on which events will be delivered
     */
    func publish<E: BaseNodeEvent>(event: E, on queue: EventQueueType)
}

class EventBusService: EventBusServiceProtocol, Service {
    /// The event bus is comprised of events acting as keys and weak references to event observers
    private var eventObserverAssociation: [HashableNodeEvent<BaseNodeEvent>: NSPointerArray] = [:]

    func register(observer: EventObservable, for eventType: BaseNodeEvent.Type) {
        if let observers = eventObserverAssociation[eventType] {
            observers.addObject(observer)
            eventObserverAssociation[eventType] = observers
        } else {
            let array = NSPointerArray.weakObjects()
            array.addObject(observer)
            eventObserverAssociation[eventType] = array
        }
    }

    func publish<E: BaseNodeEvent>(event: E, on queue: EventQueueType) {
        if let observers = eventObserverAssociation[E.self] {
            for idx in 0 ..< observers.count {
                if let registeredObserver = observers.object(at: idx) as? EventObservable {

                    var dispatchQueue: DispatchQueue

                    switch queue {
                    case .backgroundQueue:
                        dispatchQueue = DispatchQueue.global(qos: .userInitiated)
                    case .mainQueue:
                        dispatchQueue = DispatchQueue.main
                    }

                    dispatchQueue.async {
                        registeredObserver.handle(event: event, on: queue)
                    }
                }
            }
        }
    }
}
