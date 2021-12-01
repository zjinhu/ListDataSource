//
//  SectionStruct.swift
//  SwiftBrick
//
//  Created by iOS on 2020/7/31.
//  Copyright © 2020 狄烨 . All rights reserved.
//

import Foundation
import DifferenceKit
///此处是所有数据数组的持有
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
    
    ///大数组
    var sections: [Section] = []
    
    ///获取所有Section对象
    var allSectionIDs: [SectionID] {
        return sections.map { $0.differenceIdentifier }
    }
    
    ///获取所有Item对象
    var allItemIDs: [ItemID] {
        return sections.lazy
            .flatMap { $0.elements }
            .map { $0.differenceIdentifier }
    }
    
    ///获取当前Section所有Item对象
    func items(in sectionID: SectionID) -> [ItemID] {
        guard let sectionIndex = sectionIndex(of: sectionID) else {
            sectionIsNotFound(sectionID)
        }

        return sections[sectionIndex].elements.map { $0.differenceIdentifier }
    }
    
    ///获取当前Item对象所在Section
    func section(containing itemID: ItemID) -> SectionID? {
        return itemPositionMap()[itemID]?.section.differenceIdentifier
    }
    
    ///添加Item对象到指定Section
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
    
    ///插入Item对象到指定Item前边
    mutating func insert(itemIDs: [ItemID], before beforeItemID: ItemID) {
        guard let itemPosition = itemPositionMap()[beforeItemID] else {
            itemIsNotFound(beforeItemID)
        }

        let items = itemIDs.lazy.map(Item.init)
        sections[itemPosition.sectionIndex].elements.insert(contentsOf: items, at: itemPosition.itemRelativeIndex)
    }
    
    ///插入Item对象到指定Item后边
    mutating func insert(itemIDs: [ItemID], after afterItemID: ItemID) {
        guard let itemPosition = itemPositionMap()[afterItemID] else {
            itemIsNotFound(afterItemID)
        }

        let itemIndex = sections[itemPosition.sectionIndex].elements.index(after: itemPosition.itemRelativeIndex)
        let items = itemIDs.lazy.map(Item.init)
        sections[itemPosition.sectionIndex].elements.insert(contentsOf: items, at: itemIndex)
    }
    
    ///删除部分指定Item
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
    
    ///删除所有Item---不影响Section数量
    mutating func removeAllItems() {
        for sectionIndex in sections.indices {
            sections[sectionIndex].elements.removeAll()
        }
    }
    
    ///删除所有Item-Section
    mutating func removeAll() {
        sections.removeAll()
    }
    
    ///移动Item对象到指定Item前边
    mutating func move(itemID: ItemID, before beforeItemID: ItemID) {
        guard let removed = remove(itemID: itemID) else {
            itemIsNotFound(itemID)
        }

        guard let itemPosition = itemPositionMap()[beforeItemID] else {
            itemIsNotFound(beforeItemID)
        }

        sections[itemPosition.sectionIndex].elements.insert(removed, at: itemPosition.itemRelativeIndex)
    }
    
    ///移动Item对象到指定Item后边
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
    
    ///更新Item---注意Item必须是Class,不能是struct,因为在数组中struct是深拷贝,无法修改
    mutating func update(itemIDs: [ItemID]) {
        let itemPositionMap = self.itemPositionMap()

        for itemID in itemIDs {
            guard let itemPosition = itemPositionMap[itemID] else {
                itemIsNotFound(itemID)
            }

            sections[itemPosition.sectionIndex].elements[itemPosition.itemRelativeIndex].isReloaded = true
        }
    }
    
    ///添加Section
    mutating func append(sectionIDs: [SectionID]) {
        let newSections = sectionIDs.lazy.map(Section.init)
        sections.append(contentsOf: newSections)
    }
    
    ///插入Section对象到指定Section前边
    mutating func insert(sectionIDs: [SectionID], before beforeSectionID: SectionID) {
        guard let sectionIndex = sectionIndex(of: beforeSectionID) else {
            sectionIsNotFound(beforeSectionID)
        }

        let newSections = sectionIDs.lazy.map(Section.init)
        sections.insert(contentsOf: newSections, at: sectionIndex)
    }
    
    ///插入Section对象到指定Section后边
    mutating func insert(sectionIDs: [SectionID], after afterSectionID: SectionID) {
        guard let beforeIndex = sectionIndex(of: afterSectionID) else {
            sectionIsNotFound(afterSectionID)
        }

        let sectionIndex = sections.index(after: beforeIndex)
        let newSections = sectionIDs.lazy.map(Section.init)
        sections.insert(contentsOf: newSections, at: sectionIndex)
    }
    
    ///删除所有Section,连带当前Section下的Item
    mutating func remove(sectionIDs: [SectionID]) {
        for sectionID in sectionIDs {
            remove(sectionID: sectionID)
        }
    }
    
    ///移动Section对象到指定Section前边
    mutating func move(sectionID: SectionID, before beforeSectionID: SectionID) {
        guard let removed = remove(sectionID: sectionID) else {
            sectionIsNotFound(sectionID)
        }

        guard let sectionIndex = sectionIndex(of: beforeSectionID) else {
            sectionIsNotFound(beforeSectionID)
        }

        sections.insert(removed, at: sectionIndex)
    }
    
    ///移动Section对象到指定Section后边
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
    
    ///更新section,如果需要修改Section中的数据也需要注意Section必须是Class,不能是struct,因为在数组中struct是深拷贝,无法修改,
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
