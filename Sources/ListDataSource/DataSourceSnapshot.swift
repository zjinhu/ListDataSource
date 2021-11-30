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

    ///获取item数量
    public var numberOfItems: Int {
        return itemIDs.count
    }

    ///获取section数量
    public var numberOfSections: Int {
        return sectionIDs.count
    }

    ///获取所有section数组
    public var sectionIDs: [SectionType] {
        return structer.allSectionIDs
    }

    ///获取所有item数组
    public var itemIDs: [ItemType] {
        return structer.allItemIDs
    }

    ///得到当前Section下边的item数量
    public func numberOfItems(inSection section: SectionType) -> Int {
        return itemIDs(inSection: section).count
    }

    ///得到当前Section下边的Item对象数组
    public func itemIDs(inSection section: SectionType) -> [ItemType] {
        return structer.items(in: section)
    }

    ///得到某一个item所在的Section
    public func sectionID(containingItem section: ItemType) -> SectionType? {
        return structer.section(containing: section)
    }

    ///获取item在section中的位置---第几个
    public func indexOfItem(_ item: ItemType) -> Int? {
        return itemIDs.firstIndex { $0.isEqualHash(to: item) }
    }

    ///获取section在table中的位置---第几个
    public func indexOfSection(_ section: SectionType) -> Int? {
        return sectionIDs.firstIndex { $0.isEqualHash(to: section) }
    }

    ///添加item到特定section的最后
    public mutating func appendItems(_ items: [ItemType], toSection: SectionType? = nil) {
        structer.append(itemIDs: items, to: toSection)
    }

    ///插入item到特定item之前
    public mutating func insertItems(_ items: [ItemType], beforeItem: ItemType) {
        structer.insert(itemIDs: items, before: beforeItem)
    }

    ///插入item到特定item之后
    public mutating func insertItems(_ items: [ItemType], afterItem: ItemType) {
        structer.insert(itemIDs: items, after: afterItem)
    }

    ///删除指定item
    public mutating func deleteItems(_ items: [ItemType]) {
        structer.remove(itemIDs: items)
    }

    ///删除所有item,不影响Section数量
    public mutating func deleteAllItems() {
        structer.removeAllItems()
    }

    public mutating func moveItem(_ item: ItemType, beforeItem: ItemType) {
        structer.move(itemID: item, before: beforeItem)
    }

    public mutating func moveItem(_ item: ItemType, afterItem: ItemType) {
        structer.move(itemID: item, after: afterItem)
    }

    public mutating func reloadItems(_ items: [ItemType]) {
        structer.update(itemIDs: items)
    }

    ///添加Section
    public mutating func appendSections(_ sections: [SectionType]) {
        structer.append(sectionIDs: sections)
    }

    ///插入section到指定的section之前
    public mutating func insertSections(_ sections: [SectionType], beforeSection: SectionType) {
        structer.insert(sectionIDs: sections, before: beforeSection)
    }

    ///插入section到指定的section之后
    public mutating func insertSections(_ sections: [SectionType], afterSection: SectionType) {
        structer.insert(sectionIDs: sections, after: afterSection)
    }

    ///删除指定的section
    public mutating func deleteSections(_ sections: [SectionType]) {
        structer.remove(sectionIDs: sections)
    }

    public mutating func moveSection(_ section: SectionType, beforeSection: SectionType) {
        structer.move(sectionID: section, before: beforeSection)
    }

    public mutating func moveSection(_ section: SectionType, afterSection: SectionType) {
        structer.move(sectionID: section, after: afterSection)
    }

    public mutating func reloadSections(_ sections: [SectionType]) {
        structer.update(sectionIDs: sections)
    }
    
    ///删除所有数据---包括section,都会清空
    public mutating func deleteAll() {
        structer.removeAll()
    }
}
