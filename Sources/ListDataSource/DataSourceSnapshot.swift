//
//  DataSource.swift
//  SwiftBrick
//
//  Created by iOS on 2021/7/16.
//  Copyright © 2021 狄烨 . All rights reserved.
//

import Foundation
public struct DataSourceSnapshot<SectionType: Hashable, ItemType: Hashable> {
    internal var structer = SectionStruct<SectionType, ItemType>()
    
    public init() {}
    
    public var numberOfItems: Int {
        return itemIDs.count
    }

    public var numberOfSections: Int {
        return sectionIDs.count
    }

    public var sectionIDs: [SectionType] {
        return structer.allSections
    }

    public var itemIDs: [ItemType] {
        return structer.allItems
    }
    
    public func numberOfItems(inSection identifier: SectionType) -> Int {
        return itemIdentifiers(inSection: identifier).count
    }

    public func itemIdentifiers(inSection identifier: SectionType) -> [ItemType] {
        return structer.items(in: identifier)
    }

    public func sectionIdentifier(containingItem identifier: ItemType) -> SectionType? {
        return structer.section(containing: identifier)
    }
    
    public func indexOfItem(_ identifier: ItemType) -> Int? {
        return itemIDs.firstIndex { $0.isEqualHash(to: identifier) }
    }
    
    public func indexOfSection(_ identifier: SectionType) -> Int? {
        return sectionIDs.firstIndex { $0.isEqualHash(to: identifier) }
    }
    
    public mutating func appendItems(_ identifiers: [ItemType], toSection sectionIdentifier: SectionType? = nil) {
        structer.append(itemIDs: identifiers, to: sectionIdentifier)
    }

    public mutating func insertItems(_ identifiers: [ItemType], beforeItem beforeIdentifier: ItemType) {
        structer.insert(itemIDs: identifiers, before: beforeIdentifier)
    }

    public mutating func insertItems(_ identifiers: [ItemType], afterItem afterIdentifier: ItemType) {
        structer.insert(itemIDs: identifiers, after: afterIdentifier)
    }

    public mutating func deleteItems(_ identifiers: [ItemType]) {
        structer.remove(itemIDs: identifiers)
    }

    public mutating func deleteAllItems() {
        structer.removeAllItems()
    }

    public mutating func appendSections(_ identifiers: [SectionType]) {
        structer.append(sectionIDs: identifiers)
    }

    public mutating func insertSections(_ identifiers: [SectionType], beforeSection toIdentifier: SectionType) {
        structer.insert(sectionIDs: identifiers, before: toIdentifier)
    }

    public mutating func insertSections(_ identifiers: [SectionType], afterSection toIdentifier: SectionType) {
        structer.insert(sectionIDs: identifiers, after: toIdentifier)
    }

    public mutating func deleteSections(_ identifiers: [SectionType]) {
        structer.remove(sectionIDs: identifiers)
    }
    
    public mutating func deleteAll() {
        structer.removeAll()
    }
}
