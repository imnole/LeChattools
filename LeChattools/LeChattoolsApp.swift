//
//  LeChattoolsApp.swift
//  LeChattools
//
//  Created by Le  on 2025/4/22.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct LeChattoolsApp: App {
    var body: some Scene {
        DocumentGroup(editing: .itemDocument, migrationPlan: LeChattoolsMigrationPlan.self) {
            ContentView()
        }
    }
}

extension UTType {
    static var itemDocument: UTType {
        UTType(importedAs: "com.example.item-document")
    }
}

struct LeChattoolsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        LeChattoolsVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct LeChattoolsVersionedSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}
