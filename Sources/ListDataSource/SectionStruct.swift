//
//  SectionStruct.swift
//  SwiftBrick
//
//  Created by iOS on 2020/7/31.
//  Copyright © 2020 狄烨 . All rights reserved.
//

import Foundation
struct SectionStruct<SectionID: Hashable, ItemID: Hashable> {
    
    public struct Item: Hashable {
        var itemID: ItemID
        init(id: ItemID) {
            self.itemID = id
        }
    }
    
    public struct Section: Hashable {
        var sectionID: SectionID
        var elements: [Item] = []

        init(id: SectionID, items: [Item]) {
            self.sectionID = id
            self.elements = items
        }
        
        init(id: SectionID) {
            self.init(id: id, items: [])
        }
    }
    
    var sections: [Section] = []
    
    var allSections: [SectionID] {
        return sections.map { $0.sectionID }
    }

    var allItems: [ItemID] {
        return sections.lazy
            .flatMap { $0.elements }
            .map { $0.itemID }
    }
    
    func items(in sectionID: SectionID, file: StaticString = #file, line: UInt = #line) -> [ItemID] {
        guard let sectionIndex = sectionIndex(of: sectionID) else {
            sectionIsNotFound(sectionID, file: file, line: line)
        }

        return sections[sectionIndex].elements.map { $0.itemID }
    }

    func section(containing itemID: ItemID) -> SectionID? {
        return itemPositionMap()[itemID]?.section.sectionID
    }
    
    mutating func append(itemIDs: [ItemID], to sectionID: SectionID? = nil, file: StaticString = #file, line: UInt = #line) {
         let index: Array<Section>.Index

         if let sectionID = sectionID {
             guard let sectionIndex = sectionIndex(of: sectionID) else {
                 sectionIsNotFound(sectionID, file: file, line: line)
             }

             index = sectionIndex
         }
         else {
             guard !sections.isEmpty else {
                 noSections(file: file, line: line)
             }

             index = sections.index(before: sections.endIndex)
         }

         let items = itemIDs.lazy.map(Item.init)
         sections[index].elements.append(contentsOf: items)
     }

     mutating func insert(itemIDs: [ItemID], before beforeItemID: ItemID, file: StaticString = #file, line: UInt = #line) {
         guard let itemPosition = itemPositionMap()[beforeItemID] else {
             itemIsNotFound(beforeItemID, file: file, line: line)
         }

         let items = itemIDs.lazy.map(Item.init)
         sections[itemPosition.sectionIndex].elements.insert(contentsOf: items, at: itemPosition.itemRelativeIndex)
     }

     mutating func insert(itemIDs: [ItemID], after afterItemID: ItemID, file: StaticString = #file, line: UInt = #line) {
         guard let itemPosition = itemPositionMap()[afterItemID] else {
             itemIsNotFound(afterItemID, file: file, line: line)
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
    
    mutating func append(sectionIDs: [SectionID]) {
        let newSections = sectionIDs.lazy.map(Section.init)
        sections.append(contentsOf: newSections)
    }

    mutating func insert(sectionIDs: [SectionID], before beforeSectionID: SectionID, file: StaticString = #file, line: UInt = #line) {
        guard let sectionIndex = sectionIndex(of: beforeSectionID) else {
            sectionIsNotFound(beforeSectionID, file: file, line: line)
        }

        let newSections = sectionIDs.lazy.map(Section.init)
        sections.insert(contentsOf: newSections, at: sectionIndex)
    }

    mutating func insert(sectionIDs: [SectionID], after afterSectionID: SectionID, file: StaticString = #file, line: UInt = #line) {
        guard let beforeIndex = sectionIndex(of: afterSectionID) else {
            sectionIsNotFound(afterSectionID, file: file, line: line)
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

    mutating func removeAll() {
        sections.removeAll()
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
        return sections.firstIndex { $0.sectionID.isEqualHash(to: sectionID) }
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
                result[item.itemID] = ItemPosition(
                    item: item,
                    itemRelativeIndex: itemRelativeIndex,
                    section: section.element,
                    sectionIndex: section.offset
                )
            }
        }
    }

    func itemIsNotFound(_ id: ItemID, file: StaticString, line: UInt) -> Never {
        fatalError("item\(id) 不存在", file: file, line: line)
    }

    func sectionIsNotFound(_ id: SectionID, file: StaticString, line: UInt) -> Never {
        fatalError("section\(id) 不存在", file: file, line: line)
    }

    func noSections(file: StaticString, line: UInt) -> Never {
        fatalError("列表没有一个可用的Section", file: file, line: line)
    }
}

extension Hashable {
    func isEqualHash(to other: Self) -> Bool {
        return hashValue == other.hashValue && self == other
    }
}

