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
        return structer.allSections
    }
    ///获取所有item数组
    public var itemIDs: [ItemType] {
        return structer.allItems
    }
    ///得到当前Section下边的item数量
    public func numberOfItems(inSection identifier: SectionType) -> Int {
        return itemIdentifiers(inSection: identifier).count
    }
    ///得到当前Section下边的Item对象数组
    public func itemIdentifiers(inSection identifier: SectionType) -> [ItemType] {
        return structer.items(in: identifier)
    }
    ///得到某一个item所在的Section
    public func sectionIdentifier(containingItem identifier: ItemType) -> SectionType? {
        return structer.section(containing: identifier)
    }
    ///获取item在section中的位置---第几个
    public func indexOfItem(_ identifier: ItemType) -> Int? {
        return itemIDs.firstIndex { $0.isEqualHash(to: identifier) }
    }
    ///获取section在table中的位置---第几个
    public func indexOfSection(_ identifier: SectionType) -> Int? {
        return sectionIDs.firstIndex { $0.isEqualHash(to: identifier) }
    }
    ///添加item到特定section的最后
    public mutating func appendItems(_ identifiers: [ItemType], toSection sectionIdentifier: SectionType? = nil) {
        structer.append(itemIDs: identifiers, to: sectionIdentifier)
    }
    ///插入item到特定item之前
    public mutating func insertItems(_ identifiers: [ItemType], beforeItem beforeIdentifier: ItemType) {
        structer.insert(itemIDs: identifiers, before: beforeIdentifier)
    }
    ///插入item到特定item之后
    public mutating func insertItems(_ identifiers: [ItemType], afterItem afterIdentifier: ItemType) {
        structer.insert(itemIDs: identifiers, after: afterIdentifier)
    }
    ///删除指定item
    public mutating func deleteItems(_ identifiers: [ItemType]) {
        structer.remove(itemIDs: identifiers)
    }
    
    public mutating func updateItem(old: ItemType, new: ItemType) {
        
    }
    
    public mutating func updateItem(index: IndexPath, new: ItemType) {
        
    }
    
    ///删除所有item---section还存在,内部数据为空
    public mutating func deleteAllItems() {
        structer.removeAllItems()
    }
    ///添加Section
    public mutating func appendSections(_ identifiers: [SectionType]) {
        structer.append(sectionIDs: identifiers)
    }
    ///插入section到指定的section之前
    public mutating func insertSections(_ identifiers: [SectionType], beforeSection toIdentifier: SectionType) {
        structer.insert(sectionIDs: identifiers, before: toIdentifier)
    }
    ///插入section到指定的section之后
    public mutating func insertSections(_ identifiers: [SectionType], afterSection toIdentifier: SectionType) {
        structer.insert(sectionIDs: identifiers, after: toIdentifier)
    }
    ///删除指定的section
    public mutating func deleteSections(_ identifiers: [SectionType]) {
        structer.remove(sectionIDs: identifiers)
    }
    ///删除所有数据---包括section,都会清空
    public mutating func deleteAll() {
        structer.removeAll()
    }
    
    public mutating func updateSection(old: SectionType, new: SectionType) {
        
    }
    
    public mutating func updateSection(index: IndexPath, new: SectionType) {
        
    }
}
