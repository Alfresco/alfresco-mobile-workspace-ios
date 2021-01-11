// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata


extension ListNode: ObjectBox.__EntityRelatable {
    internal typealias EntityType = ListNode

    internal var _id: EntityId<ListNode> {
        return EntityId<ListNode>(self.id.value)
    }
}

extension ListNode: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = ListNodeBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "ListNode", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: ListNode.self, id: 1, uid: 4787515528091542272)
        try entityBuilder.addProperty(name: "id", type: Id.entityPropertyType, flags: [.id], id: 1, uid: 6291738575692826112)
        try entityBuilder.addProperty(name: "parentGuid", type: String.entityPropertyType, id: 15, uid: 5941047176527043840)
        try entityBuilder.addProperty(name: "guid", type: String.entityPropertyType, id: 2, uid: 6072982276334486528)
        try entityBuilder.addProperty(name: "siteID", type: String.entityPropertyType, id: 3, uid: 6504946368521243136)
        try entityBuilder.addProperty(name: "destination", type: String.entityPropertyType, id: 4, uid: 2325907641381107456)
        try entityBuilder.addProperty(name: "mimeType", type: String.entityPropertyType, id: 5, uid: 2111228495610437376)
        try entityBuilder.addProperty(name: "title", type: String.entityPropertyType, id: 6, uid: 80770848759604480)
        try entityBuilder.addProperty(name: "path", type: String.entityPropertyType, id: 7, uid: 2355487130584533248)
        try entityBuilder.addProperty(name: "modifiedAt", type: Date.entityPropertyType, id: 8, uid: 5604197784113814784)
        try entityBuilder.addProperty(name: "favorite", type: Bool.entityPropertyType, id: 11, uid: 6507941571178712320)
        try entityBuilder.addProperty(name: "trashed", type: Bool.entityPropertyType, id: 14, uid: 6548674364965640960)
        try entityBuilder.addProperty(name: "markedAsOffline", type: Bool.entityPropertyType, id: 18, uid: 6010654626593675520)
        try entityBuilder.addProperty(name: "markedForDeletion", type: Bool.entityPropertyType, id: 19, uid: 269961487045141504)
        try entityBuilder.addProperty(name: "nodeType", type: String.entityPropertyType, id: 10, uid: 5852693191752956672)
        try entityBuilder.addProperty(name: "siteRole", type: String.entityPropertyType, id: 13, uid: 7254106165676034048)
        try entityBuilder.addProperty(name: "allowableOperations", type: String.entityPropertyType, id: 12, uid: 7364912097151763200)

        try entityBuilder.lastProperty(id: 19, uid: 269961487045141504)
    }
}

extension ListNode {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.id == myId }
    internal static var id: Property<ListNode, Id, Id> { return Property<ListNode, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.parentGuid.startsWith("X") }
    internal static var parentGuid: Property<ListNode, String?, Void> { return Property<ListNode, String?, Void>(propertyId: 15, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.guid.startsWith("X") }
    internal static var guid: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.siteID.startsWith("X") }
    internal static var siteID: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.destination.startsWith("X") }
    internal static var destination: Property<ListNode, String?, Void> { return Property<ListNode, String?, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.mimeType.startsWith("X") }
    internal static var mimeType: Property<ListNode, String?, Void> { return Property<ListNode, String?, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.title.startsWith("X") }
    internal static var title: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 6, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.path.startsWith("X") }
    internal static var path: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.modifiedAt > 1234 }
    internal static var modifiedAt: Property<ListNode, Date?, Void> { return Property<ListNode, Date?, Void>(propertyId: 8, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.favorite > 1234 }
    internal static var favorite: Property<ListNode, Bool?, Void> { return Property<ListNode, Bool?, Void>(propertyId: 11, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.trashed > 1234 }
    internal static var trashed: Property<ListNode, Bool?, Void> { return Property<ListNode, Bool?, Void>(propertyId: 14, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.markedAsOffline > 1234 }
    internal static var markedAsOffline: Property<ListNode, Bool?, Void> { return Property<ListNode, Bool?, Void>(propertyId: 18, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.markedForDeletion > 1234 }
    internal static var markedForDeletion: Property<ListNode, Bool?, Void> { return Property<ListNode, Bool?, Void>(propertyId: 19, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.nodeType.startsWith("X") }
    internal static var nodeType: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 10, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.siteRole.startsWith("X") }
    internal static var siteRole: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 13, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { ListNode.allowableOperations.startsWith("X") }
    internal static var allowableOperations: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 12, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == ListNode {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<ListNode, Id, Id> { return Property<ListNode, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .parentGuid.startsWith("X") }

    internal static var parentGuid: Property<ListNode, String?, Void> { return Property<ListNode, String?, Void>(propertyId: 15, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .guid.startsWith("X") }

    internal static var guid: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .siteID.startsWith("X") }

    internal static var siteID: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .destination.startsWith("X") }

    internal static var destination: Property<ListNode, String?, Void> { return Property<ListNode, String?, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .mimeType.startsWith("X") }

    internal static var mimeType: Property<ListNode, String?, Void> { return Property<ListNode, String?, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .title.startsWith("X") }

    internal static var title: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 6, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .path.startsWith("X") }

    internal static var path: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .modifiedAt > 1234 }

    internal static var modifiedAt: Property<ListNode, Date?, Void> { return Property<ListNode, Date?, Void>(propertyId: 8, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .favorite > 1234 }

    internal static var favorite: Property<ListNode, Bool?, Void> { return Property<ListNode, Bool?, Void>(propertyId: 11, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .trashed > 1234 }

    internal static var trashed: Property<ListNode, Bool?, Void> { return Property<ListNode, Bool?, Void>(propertyId: 14, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .markedAsOffline > 1234 }

    internal static var markedAsOffline: Property<ListNode, Bool?, Void> { return Property<ListNode, Bool?, Void>(propertyId: 18, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .markedForDeletion > 1234 }

    internal static var markedForDeletion: Property<ListNode, Bool?, Void> { return Property<ListNode, Bool?, Void>(propertyId: 19, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .nodeType.startsWith("X") }

    internal static var nodeType: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 10, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .siteRole.startsWith("X") }

    internal static var siteRole: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 13, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .allowableOperations.startsWith("X") }

    internal static var allowableOperations: Property<ListNode, String, Void> { return Property<ListNode, String, Void>(propertyId: 12, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `ListNode.EntityBindingType`.
internal class ListNodeBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = ListNode
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_parentGuid = propertyCollector.prepare(string: entity.parentGuid)
        let propertyOffset_guid = propertyCollector.prepare(string: entity.guid)
        let propertyOffset_siteID = propertyCollector.prepare(string: entity.siteID)
        let propertyOffset_destination = propertyCollector.prepare(string: entity.destination)
        let propertyOffset_mimeType = propertyCollector.prepare(string: entity.mimeType)
        let propertyOffset_title = propertyCollector.prepare(string: entity.title)
        let propertyOffset_path = propertyCollector.prepare(string: entity.path)
        let propertyOffset_nodeType = propertyCollector.prepare(string: entity.nodeType.rawValue)
        let propertyOffset_siteRole = propertyCollector.prepare(string: entity.siteRole.rawValue)
        let propertyOffset_allowableOperations = propertyCollector.prepare(string: AllowableOperationsConverter.convert(entity.allowableOperations))

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.modifiedAt, at: 2 + 2 * 8)
        propertyCollector.collect(entity.favorite, at: 2 + 2 * 11)
        propertyCollector.collect(entity.trashed, at: 2 + 2 * 14)
        propertyCollector.collect(entity.markedAsOffline, at: 2 + 2 * 18)
        propertyCollector.collect(entity.markedForDeletion, at: 2 + 2 * 19)
        propertyCollector.collect(dataOffset: propertyOffset_parentGuid, at: 2 + 2 * 15)
        propertyCollector.collect(dataOffset: propertyOffset_guid, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_siteID, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_destination, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_mimeType, at: 2 + 2 * 5)
        propertyCollector.collect(dataOffset: propertyOffset_title, at: 2 + 2 * 6)
        propertyCollector.collect(dataOffset: propertyOffset_path, at: 2 + 2 * 7)
        propertyCollector.collect(dataOffset: propertyOffset_nodeType, at: 2 + 2 * 10)
        propertyCollector.collect(dataOffset: propertyOffset_siteRole, at: 2 + 2 * 13)
        propertyCollector.collect(dataOffset: propertyOffset_allowableOperations, at: 2 + 2 * 12)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = ListNode()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.parentGuid = entityReader.read(at: 2 + 2 * 15)
        entity.guid = entityReader.read(at: 2 + 2 * 2)
        entity.siteID = entityReader.read(at: 2 + 2 * 3)
        entity.destination = entityReader.read(at: 2 + 2 * 4)
        entity.mimeType = entityReader.read(at: 2 + 2 * 5)
        entity.title = entityReader.read(at: 2 + 2 * 6)
        entity.path = entityReader.read(at: 2 + 2 * 7)
        entity.modifiedAt = entityReader.read(at: 2 + 2 * 8)
        entity.favorite = entityReader.read(at: 2 + 2 * 11)
        entity.trashed = entityReader.read(at: 2 + 2 * 14)
        entity.markedAsOffline = entityReader.read(at: 2 + 2 * 18)
        entity.markedForDeletion = entityReader.read(at: 2 + 2 * 19)
        entity.nodeType = optConstruct(NodeType.self, rawValue: entityReader.read(at: 2 + 2 * 10)) ?? .unknown
        entity.siteRole = optConstruct(SiteRole.self, rawValue: entityReader.read(at: 2 + 2 * 13)) ?? .unknown
        entity.allowableOperations = AllowableOperationsConverter.convert(entityReader.read(at: 2 + 2 * 12))

        return entity
    }
}


/// Helper function that allows calling Enum(rawValue: value) with a nil value, which will return nil.
fileprivate func optConstruct<T: RawRepresentable>(_ type: T.Type, rawValue: T.RawValue?) -> T? {
    guard let rawValue = rawValue else { return nil }
    return T(rawValue: rawValue)
}

// MARK: - Store setup

fileprivate func cModel() throws -> OpaquePointer {
    let modelBuilder = try ObjectBox.ModelBuilder()
    try ListNode.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 1, uid: 4787515528091542272)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    /// A store with a fully configured model. Created by the code generator with your model's metadata in place.
    ///
    /// - Parameters:
    ///   - directoryPath: The directory path in which ObjectBox places its database files for this store.
    ///   - maxDbSizeInKByte: Limit of on-disk space for the database files. Default is `1024 * 1024` (1 GiB).
    ///   - fileMode: UNIX-style bit mask used for the database files; default is `0o644`.
    ///     Note: directories become searchable if the "read" or "write" permission is set (e.g. 0640 becomes 0750).
    ///   - maxReaders: The maximum number of readers.
    ///     "Readers" are a finite resource for which we need to define a maximum number upfront.
    ///     The default value is enough for most apps and usually you can ignore it completely.
    ///     However, if you get the maxReadersExceeded error, you should verify your
    ///     threading. For each thread, ObjectBox uses multiple readers. Their number (per thread) depends
    ///     on number of types, relations, and usage patterns. Thus, if you are working with many threads
    ///     (e.g. in a server-like scenario), it can make sense to increase the maximum number of readers.
    ///     Note: The internal default is currently around 120.
    ///           So when hitting this limit, try values around 200-500.
    /// - important: This initializer is created by the code generator. If you only see the internal `init(model:...)`
    ///              initializer, trigger code generation by building your project.
    internal convenience init(directoryPath: String, maxDbSizeInKByte: UInt64 = 1024 * 1024,
                            fileMode: UInt32 = 0o644, maxReaders: UInt32 = 0, readOnly: Bool = false) throws {
        try self.init(
            model: try cModel(),
            directory: directoryPath,
            maxDbSizeInKByte: maxDbSizeInKByte,
            fileMode: fileMode,
            maxReaders: maxReaders,
            readOnly: readOnly)
    }
}

// swiftlint:enable all
