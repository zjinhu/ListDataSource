//
//  DataSource.swift
//  SwiftBrick
//
//  Created by iOS on 2021/7/16.
//  Copyright © 2021 狄烨 . All rights reserved.
//

import Foundation
class DataSource <SectionType: Hashable, ItemType: Hashable>{
    
    typealias Section = SectionStruct<SectionType, ItemType>.Section
    ///构建数据源
    var sections: [Section] = []
    ///获取section个数------代理方法里用
    func numberOfSections() -> Int{
        return sections.count
    }
    ///获取section中item个数------代理方法里用
    func numberOfItems(in section: Int) -> Int{
        return sections[section].elements.count
    }
    ///根据数字位置获取Section对象
    func sectionID(for section: Int) -> SectionType? {
        let section = sections[section]
        return section.sectionID
    }
    ///根据IndexPath获取item对象
    func itemID(for indexPath: IndexPath) -> ItemType? {
        guard 0..<sections.endIndex ~= indexPath.section else {
            return nil
        }

        let items = sections[indexPath.section].elements

        guard 0..<items.endIndex ~= indexPath.item else {
            return nil
        }

        return items[indexPath.item].itemID
    }
    ///根据item获取其所在IndexPath
    func indexPath(for itemIdentifier: ItemType) -> IndexPath? {
        let indexPathMap: [ItemType: IndexPath] = sections.enumerated()
            .reduce(into: [:]) { result, section in
                for (itemIndex, item) in section.element.elements.enumerated() {
                    result[item.itemID] = IndexPath(
                        item: itemIndex,
                        section: section.offset
                    )
                }
        }
        return indexPathMap[itemIdentifier]
    }
}
