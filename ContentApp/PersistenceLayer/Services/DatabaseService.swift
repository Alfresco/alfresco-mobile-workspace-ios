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

import Foundation
import ObjectBox

let databaseName = "MobileWorkspaceDB"

class DatabaseService: Service {
    private var store: Store?

    init() {
        do {
            let appSupport = try FileManager.default.url(for: .documentDirectory,
                                                         in: .userDomainMask,
                                                         appropriateFor: nil,
                                                         create: true)
                                                         .appendingPathComponent(Bundle.main.bundleIdentifier!)
            let directory = appSupport.appendingPathComponent(databaseName)
            try? FileManager.default.createDirectory(at: directory,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)

            self.store = try Store(directoryPath: directory.path)
        } catch let error {
            AlfrescoLog.error("Unable to initialize persistence store: \(error)")
        }
    }

    ///
    /// Stores an entity in the database
    /// - Parameter entity: Entity to be stored in the database
    func store<E>(entity: ObjectBox.Box<E>.EntityType) {
        let entityBox = store?.box(for: E.self)

        do {
            _ = try entityBox?.put(entity)
        } catch let error {
            AlfrescoLog.error("Unable to persist entity \(E.Type.self). Reason: \(error.localizedDescription)")
        }
    }
    
    ///
    /// Stores an array of entities in the database
    /// - Parameter entity: Entity to be stored in the database
    func store<E>(entities: [ObjectBox.Box<E>.EntityType]) {
        let entityBox = store?.box(for: E.self)
        do {
            _ = try entityBox?.put(entities)
        } catch let error {
            AlfrescoLog.error("Unable to persist entities \(E.Type.self). Reason: \(error.localizedDescription)")
        }
    }

    ///
    /// Removes an entity from the database.
    /// - Note: Entity must exist in the database to be removed. That means the *id* property of the object to be removed must be
    ///  different than 0.
    /// - Parameter entity: Entity to be removed from the database
    func remove<E>(entity: ObjectBox.Box<E>.EntityType) {
        let entityBox = store?.box(for: E.self)
        do {
            _ = try entityBox?.remove(entity)
        } catch let error {
            AlfrescoLog.error("Unable to remove entity \(E.Type.self). Reason: \(error.localizedDescription)")
        }
    }

    ///
    /// Fetches database managed context for a specific entity
    /// - Parameter entity: Entity for which the managed context is fetched
    /// - Returns: Database managed object context
    func box<E>(entity: E.Type = E.self) -> ObjectBox.Box<E>?  where E: ObjectBox.EntityInspectable,
                                                                     E: ObjectBox.__EntityRelatable,
                                                                     E == E.EntityBindingType.EntityType {
        return store?.box(for: E.self)
    }

    ///
    ///  Fetches all entities from the databse given an entity type
    /// - Parameter entity: Entity type for which the query is executed
    /// - Returns: An array of entities from the databse matching the entity type
    func queryAll<E>(entity: E.Type = E.self) -> [E]? where E: ObjectBox.EntityInspectable,
                                                            E: ObjectBox.__EntityRelatable,
                                                            E == E.EntityBindingType.EntityType {
        let entityBox = store?.box(for: E.self)

        do {
            return try entityBox?.all()
        } catch let error {
            AlfrescoLog.error("Unable to feth entities \(E.Type.self). Reason: \(error.localizedDescription)")
        }

        return nil
    }
}
