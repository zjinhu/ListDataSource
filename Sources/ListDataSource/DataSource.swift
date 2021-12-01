//
//  DataSource.swift
//  SwiftBrick
//
//  Created by iOS on 2021/7/16.
//  Copyright © 2021 狄烨 . All rights reserved.
//

import Foundation
import QuartzCore
import DifferenceKit

class DataSource<SectionType: Hashable, ItemType: Hashable> {
    typealias Section = SectionStruct<SectionType, ItemType>.Section
    ////添加apply方法处理diff逻辑,判断哪些数据需要刷新
    private let dispatcher = MainThreadSerialDispatcher()
    private var currentSnapshot = DataSourceSnapshot<SectionType, ItemType>()
    ///构建数据源
    private var sections: [Section] = []
    
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
        return section.differenceIdentifier
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
        
        return items[indexPath.item].differenceIdentifier
    }

    ///根据item获取其所在IndexPath
    func indexPath(for itemID: ItemType) -> IndexPath? {
        let indexPathMap: [ItemType: IndexPath] = sections.enumerated()
            .reduce(into: [:]) { result, section in
                for (itemIndex, item) in section.element.elements.enumerated() {
                    result[item.differenceIdentifier] = IndexPath(
                        item: itemIndex,
                        section: section.offset
                    )
                }
            }
        return indexPathMap[itemID]
    }
    ///不安全的方式获取item对象,索引位置不正确可能获取为空
    func itemID(for indexPath: IndexPath) -> ItemType {
        guard let itemID = itemID(for: indexPath) else {
            fatalError("item\(indexPath) 不存在")
        }
        return itemID
    }
    ///使用DifferenceKit在子线程进行数据比对
    func apply<View: AnyObject>(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
                                view: View?,
                                animatingDifferences: Bool,
                                performUpdates: @escaping (View, StagedChangeset<[Section]>, @escaping ([Section]) -> Void) -> Void,
                                completion: (() -> Void)?) {
        dispatcher.dispatch { [weak self] in
            guard let self = self else {
                return
            }
            
            self.currentSnapshot = snapshot
            
            let newSections = snapshot.structer.sections
            
            guard let view = view else {
                return self.sections = newSections
            }
            
            func performDiffingUpdates() {
                let changeset = StagedChangeset(source: self.sections, target: newSections)
                performUpdates(view, changeset) { sections in
                    self.sections = sections
                }
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            
            if animatingDifferences {
                performDiffingUpdates()
            }
            else {
                CATransaction.setDisableActions(true)
                performDiffingUpdates()
            }
            
            CATransaction.commit()
        }
    }
    
    func snapshot() -> DataSourceSnapshot<SectionType, ItemType> {
        var snapshot = DataSourceSnapshot<SectionType, ItemType>()
        snapshot.structer.sections = currentSnapshot.structer.sections
        return snapshot
    }

}

final class MainThreadSerialDispatcher {
    private let executingCount = UnsafeMutablePointer<Int32>.allocate(capacity: 1)

    init() {
        executingCount.initialize(to: 0)
    }

    deinit {
        executingCount.deinitialize(count: 1)
        executingCount.deallocate()
    }

    func dispatch(_ action: @escaping () -> Void) {
        let count = OSAtomicIncrement32(executingCount)

        if Thread.isMainThread && count == 1 {
            action()
            OSAtomicDecrement32(executingCount)
        }
        else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                action()
                OSAtomicDecrement32(self.executingCount)
            }
        }
    }
}
