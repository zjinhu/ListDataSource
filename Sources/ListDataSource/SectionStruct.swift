//
//  SectionStruct.swift
//  SwiftBrick
//
//  Created by iOS on 2020/7/31.
//  Copyright © 2020 狄烨 . All rights reserved.
//

import Foundation
import DifferenceKit

struct SectionStruct<SectionID: Hashable, ItemID: Hashable> {
    struct Item: Differentiable, Equatable {
        var differenceIdentifier: ItemID
        var isReloaded: Bool

        init(id: ItemID, isReloaded: Bool) {
            self.differenceIdentifier = id
            self.isReloaded = isReloaded
        }

        init(id: ItemID) {
            self.init(id: id, isReloaded: false)
        }

        func isContentEqual(to source: Item) -> Bool {
            return !isReloaded && differenceIdentifier == source.differenceIdentifier
        }
    }

    struct Section: DifferentiableSection, Equatable {
        var differenceIdentifier: SectionID
        var elements: [Item] = []
        var isReloaded: Bool

        init(id: SectionID, items: [Item], isReloaded: Bool) {
            self.differenceIdentifier = id
            self.elements = items
            self.isReloaded = isReloaded
        }

        init(id: SectionID) {
            self.init(id: id, items: [], isReloaded: false)
        }

        init<C: Swift.Collection>(source: Section, elements: C) where C.Element == Item {
            self.init(id: source.differenceIdentifier, items: Array(elements), isReloaded: source.isReloaded)
        }

        func isContentEqual(to source: Section) -> Bool {
            return !isReloaded && differenceIdentifier == source.differenceIdentifier
        }
    }

    var sections: [Section] = []

    var allSectionIDs: [SectionID] {
        return sections.map { $0.differenceIdentifier }
    }

    var allItemIDs: [ItemID] {
        return sections.lazy
            .flatMap { $0.elements }
            .map { $0.differenceIdentifier }
    }

    func items(in sectionID: SectionID) -> [ItemID] {
        guard let sectionIndex = sectionIndex(of: sectionID) else {
            sectionIsNotFound(sectionID)
        }

        return sections[sectionIndex].elements.map { $0.differenceIdentifier }
    }

    func section(containing itemID: ItemID) -> SectionID? {
        return itemPositionMap()[itemID]?.section.differenceIdentifier
    }

    mutating func append(itemIDs: [ItemID], to sectionID: SectionID? = nil) {
        let index: Array<Section>.Index

        if let sectionID = sectionID {
            guard let sectionIndex = sectionIndex(of: sectionID) else {
                sectionIsNotFound(sectionID)
            }

            index = sectionIndex
        }
        else {
            guard !sections.isEmpty else {
                noSections()
            }

            index = sections.index(before: sections.endIndex)
        }

        let items = itemIDs.lazy.map(Item.init)
        sections[index].elements.append(contentsOf: items)
    }

    mutating func insert(itemIDs: [ItemID], before beforeItemID: ItemID) {
        guard let itemPosition = itemPositionMap()[beforeItemID] else {
            itemIsNotFound(beforeItemID)
        }

        let items = itemIDs.lazy.map(Item.init)
        sections[itemPosition.sectionIndex].elements.insert(contentsOf: items, at: itemPosition.itemRelativeIndex)
    }

    mutating func insert(itemIDs: [ItemID], after afterItemID: ItemID) {
        guard let itemPosition = itemPositionMap()[afterItemID] else {
            itemIsNotFound(afterItemID)
        }

        let itemIndex = sections[itemPosition.sectionIndex].elements.index(after: itemPosition.itemRelativeIndex)
        let items = itemIDs.lazy.map(Item.init)
        sections[itemPosition.sectionIndex].elements.insert(contentsOf: items, at: itemIndex)
    }

    mutating func remove(itemIDs: [ItemID]) {
        let itemPositionMap = self.itemPositionMap()
        var removeIndexSetMap = [Int: IndexSet]()

        for itemID in itemIDs {
            guard let itemPosition = itemPositionMap[itemID] else {
                continue
            }

            removeIndexSetMap[itemPosition.sectionIndex, default: []].insert(itemPosition.itemRelativeIndex)
        }

        for (sectionIndex, removeIndexSet) in removeIndexSetMap {
            for range in removeIndexSet.rangeView.reversed() {
                sections[sectionIndex].elements.removeSubrange(range)
            }
        }
    }

    mutating func removeAllItems() {
        for sectionIndex in sections.indices {
            sections[sectionIndex].elements.removeAll()
        }
    }
    
    mutating func removeAll() {
        sections.removeAll()
    }
    
    mutating func move(itemID: ItemID, before beforeItemID: ItemID) {
        guard let removed = remove(itemID: itemID) else {
            itemIsNotFound(itemID)
        }

        guard let itemPosition = itemPositionMap()[beforeItemID] else {
            itemIsNotFound(beforeItemID)
        }

        sections[itemPosition.sectionIndex].elements.insert(removed, at: itemPosition.itemRelativeIndex)
    }

    mutating func move(itemID: ItemID, after afterItemID: ItemID) {
        guard let removed = remove(itemID: itemID) else {
            itemIsNotFound(itemID)
        }

        guard let itemPosition = itemPositionMap()[afterItemID] else {
            itemIsNotFound(afterItemID)
        }

        let itemIndex = sections[itemPosition.sectionIndex].elements.index(after: itemPosition.itemRelativeIndex)
        sections[itemPosition.sectionIndex].elements.insert(removed, at: itemIndex)
    }

    mutating func update(itemIDs: [ItemID]) {
        let itemPositionMap = self.itemPositionMap()

        for itemID in itemIDs {
            guard let itemPosition = itemPositionMap[itemID] else {
                itemIsNotFound(itemID)
            }

            sections[itemPosition.sectionIndex].elements[itemPosition.itemRelativeIndex].isReloaded = true
        }
    }

    mutating func append(sectionIDs: [SectionID]) {
        let newSections = sectionIDs.lazy.map(Section.init)
        sections.append(contentsOf: newSections)
    }

    mutating func insert(sectionIDs: [SectionID], before beforeSectionID: SectionID) {
        guard let sectionIndex = sectionIndex(of: beforeSectionID) else {
            sectionIsNotFound(beforeSectionID)
        }

        let newSections = sectionIDs.lazy.map(Section.init)
        sections.insert(contentsOf: newSections, at: sectionIndex)
    }

    mutating func insert(sectionIDs: [SectionID], after afterSectionID: SectionID) {
        guard let beforeIndex = sectionIndex(of: afterSectionID) else {
            sectionIsNotFound(afterSectionID)
        }

        let sectionIndex = sections.index(after: beforeIndex)
        let newSections = sectionIDs.lazy.map(Section.init)
        sections.insert(contentsOf: newSections, at: sectionIndex)
    }

    mutating func remove(sectionIDs: [SectionID]) {
        for sectionID in sectionIDs {
            remove(sectionID: sectionID)
        }
    }

    mutating func move(sectionID: SectionID, before beforeSectionID: SectionID) {
        guard let removed = remove(sectionID: sectionID) else {
            sectionIsNotFound(sectionID)
        }

        guard let sectionIndex = sectionIndex(of: beforeSectionID) else {
            sectionIsNotFound(beforeSectionID)
        }

        sections.insert(removed, at: sectionIndex)
    }

    mutating func move(sectionID: SectionID, after afterSectionID: SectionID) {
        guard let removed = remove(sectionID: sectionID) else {
            sectionIsNotFound(sectionID)
        }

        guard let beforeIndex = sectionIndex(of: afterSectionID) else {
            sectionIsNotFound(afterSectionID)
        }

        let sectionIndex = sections.index(after: beforeIndex)
        sections.insert(removed, at: sectionIndex)
    }

    mutating func update(sectionIDs: [SectionID]) {
        for sectionID in sectionIDs {
            guard let sectionIndex = sectionIndex(of: sectionID) else {
                continue
            }

            sections[sectionIndex].isReloaded = true
        }
    }
}

private extension SectionStruct {
    struct ItemPosition {
        var item: Item
        var itemRelativeIndex: Int
        var section: Section
        var sectionIndex: Int
    }

    func sectionIndex(of sectionID: SectionID) -> Array<Section>.Index? {
        return sections.firstIndex { $0.differenceIdentifier.isEqualHash(to: sectionID) }
    }

    @discardableResult
    mutating func remove(itemID: ItemID) -> Item? {
        guard let itemPosition = itemPositionMap()[itemID] else {
            return nil
        }

        return sections[itemPosition.sectionIndex].elements.remove(at: itemPosition.itemRelativeIndex)
    }

    @discardableResult
    mutating func remove(sectionID: SectionID) -> Section? {
        guard let sectionIndex = sectionIndex(of: sectionID) else {
            return nil
        }

        return sections.remove(at: sectionIndex)
    }

    func itemPositionMap() -> [ItemID: ItemPosition] {
        return sections.enumerated().reduce(into: [:]) { result, section in
            for (itemRelativeIndex, item) in section.element.elements.enumerated() {
                result[item.differenceIdentifier] = ItemPosition(
                    item: item,
                    itemRelativeIndex: itemRelativeIndex,
                    section: section.element,
                    sectionIndex: section.offset
                )
            }
        }
    }
    
    func itemIsNotFound(_ id: ItemID) -> Never {
        fatalError("item\(id) 不存在")
    }

    func sectionIsNotFound(_ id: SectionID) -> Never {
        fatalError("section\(id) 不存在")
    }

    func noSections() -> Never {
        fatalError("列表没有一个可用的Section")
    }
}

extension Hashable {
    func isEqualHash(to other: Self) -> Bool {
        return hashValue == other.hashValue && self == other
    }
}
