//
//  TableViewDataSource.swift
//  SwiftBrick
//
//  Created by iOS on 2021/7/16.
//  Copyright © 2021 狄烨 . All rights reserved.
//

import UIKit

open class TableViewDataSource<SectionType: Hashable, ItemType: Hashable>: NSObject, UITableViewDataSource, UITableViewDelegate{

    public var defaultRowAnimation: UITableView.RowAnimation = .automatic
    
    public typealias CellHandle = (UITableView, IndexPath, ItemType) -> UITableViewCell
    public typealias DidSelectRowHandle = (UITableView, IndexPath, ItemType) -> Void
    public typealias SetHeightForRowHandle = (UITableView, IndexPath, ItemType) -> CGFloat
    
    public typealias HeaderHandle  = (UITableView, Int, SectionType) -> UIView?
    public typealias FooterHandle  = (UITableView, Int, SectionType) -> UIView?
    public typealias SetHeightForHeaderHandle = (UITableView, Int, SectionType) -> CGFloat
    public typealias SetHeightForFooterHandle = (UITableView, Int, SectionType) -> CGFloat
    
    public let setCell : CellHandle
    public var didSelectRow : DidSelectRowHandle?
    public var setHeightForRow : SetHeightForRowHandle?
    
    public var setHeaderView : HeaderHandle?
    public var setFooterView : FooterHandle?
    public var setHeightForHeader : SetHeightForHeaderHandle?
    public var setHeightForFooter : SetHeightForFooterHandle?

    private weak var tableView: UITableView?
    private let dataSource = DataSource<SectionType, ItemType>()
    
    public required init(_ tableView: UITableView, needDelegate: Bool = false, cellGetter: @escaping CellHandle) {
        self.setCell  = cellGetter
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        if needDelegate{
            tableView.delegate = self
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        let cell = setCell(tableView, indexPath, item)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        didSelectRow?(tableView, indexPath, item)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionID = dataSource.sectionID(for: section),
              let height = setHeightForHeader?(tableView, section, sectionID) else {
            return CGFloat.leastNormalMagnitude
        }
        return height
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let sectionID = dataSource.sectionID(for: section),
              let height = setHeightForFooter?(tableView, section, sectionID) else {
            return CGFloat.leastNormalMagnitude
        }
        return height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let sectionID = dataSource.sectionID(for: section),
              let view = setHeaderView?(tableView, section, sectionID) else {
            return UIView()
        }
        return view
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let sectionID = dataSource.sectionID(for: section),
              let view = setFooterView?(tableView, section, sectionID) else {
            return UIView()
        }
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let itemID = dataSource.itemID(for: indexPath),
              let height = setHeightForRow?(tableView, indexPath, itemID) else {
            return UITableView.automaticDimension
        }
        return height
    }
}

extension TableViewDataSource{
    
    public func itemId(for indexPath: IndexPath) -> ItemType? {
        return dataSource.itemID(for: indexPath)
    }
    
    public func indexPath(for itemId: ItemType) -> IndexPath? {
        return dataSource.indexPath(for: itemId)
    }
    
    public func setHeightForRow(_ callback:@escaping SetHeightForRowHandle) {
        setHeightForRow = callback
    }
    
    public func didSelectRow(_ callback:@escaping DidSelectRowHandle) {
        didSelectRow = callback
    }
    
    public func setHeaderView(_ callback:@escaping HeaderHandle) {
        setHeaderView = callback
    }
    
    public func setFooterView(_ callback:@escaping FooterHandle) {
        setFooterView = callback
    }
    
    public func setHeightForHeader(_ callback:@escaping SetHeightForHeaderHandle) {
        setHeightForHeader = callback
    }
    
    public func setHeightForFooter(_ callback:@escaping SetHeightForFooterHandle) {
        setHeightForFooter = callback
    }

    ////apply申请时检查Diff
    public func apply(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
                      animation: Bool = false,
                      completion: (() -> Void)? = nil) {
        dataSource.apply(
            snapshot,
            view: tableView,
            animatingDifferences: animation,
            performUpdates: { tableView, changeset, setSections in
                tableView.reload(using: changeset, with: self.defaultRowAnimation, setData: setSections)
        },
            completion: completion
        )
    }

    public func snapshot() -> DataSourceSnapshot<SectionType, ItemType> {
        return dataSource.snapshot()
    }
}
