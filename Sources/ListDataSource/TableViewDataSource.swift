//
//  TableViewDataSource.swift
//  SwiftBrick
//
//  Created by iOS on 2021/7/16.
//  Copyright © 2021 狄烨 . All rights reserved.
//

import UIKit

open class TableViewDataSource<SectionType: Hashable, ItemType: Hashable>: NSObject, UITableViewDataSource{

    public var defaultRowAnimation: UITableView.RowAnimation = .automatic
    
    public typealias CellProvider = (UITableView, IndexPath, ItemType) -> UITableViewCell
    
    public let cellProvider : CellProvider

    private weak var tableView: UITableView?
    private let dataSource = DataSource<SectionType, ItemType>()
    
    public required init(_ tableView: UITableView, cellGetter: @escaping CellProvider) {
        self.cellProvider  = cellGetter
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("cell nil")
        }
        let cell = cellProvider (tableView, indexPath, item)
        return cell
    }
    
    public func itemId(for indexPath: IndexPath) -> ItemType? {
        return dataSource.itemID(for: indexPath)
    }
    
    public func indexPath(for itemId: ItemType) -> IndexPath? {
        return dataSource.indexPath(for: itemId)
    }
    
    public func apply(_ snapshot: DataSourceSnapshot<SectionType, ItemType>) {
        dataSource.sections = snapshot.structer.sections
        tableView?.reloadData()
    }
    
    public func applyRows(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
                          itemIndexPaths: [IndexPath]) {
        dataSource.sections = snapshot.structer.sections
        tableView?.reloadRows(at: itemIndexPaths, with: defaultRowAnimation)
    }
    
    public func applyRows(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
                          itemIDs: [ItemType]) {
        dataSource.sections = snapshot.structer.sections
        var itemIndesPaths = [IndexPath]()
        itemIDs.forEach { item in
            guard let index = indexPath(for: item) else{return}
            itemIndesPaths.append(index)
        }
        tableView?.reloadRows(at: itemIndesPaths, with: defaultRowAnimation)
    }
    
    public func applySections(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
                              sectionIndex : Int) {
        dataSource.sections = snapshot.structer.sections
        tableView?.reloadSections(IndexSet(integer: sectionIndex), with: defaultRowAnimation)
    }
    
}
