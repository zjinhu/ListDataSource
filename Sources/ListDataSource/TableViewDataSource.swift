//
//  TableViewDataSource.swift
//  SwiftBrick
//
//  Created by iOS on 2021/7/16.
//  Copyright © 2021 狄烨 . All rights reserved.
//

import UIKit

public class TableViewDataSource<SectionType: Hashable, ItemType: Hashable>: NSObject, UITableViewDataSource, UITableViewDelegate{
    ///设置Cell动画
    public var defaultRowAnimation: UITableView.RowAnimation = .automatic
    ///设置Cell闭包
    public typealias CellHandle = (UITableView, IndexPath, ItemType) -> UITableViewCell
    private let setCell : CellHandle
    ///点击事件
    public typealias DidSelectRowHandle = (UITableView, IndexPath, ItemType) -> Void
    private var didSelectRow : DidSelectRowHandle?
    ///cell大小
    public typealias SetHeightForRowHandle = (UITableView, IndexPath, ItemType) -> CGFloat
    private var setHeightForRow : SetHeightForRowHandle?
    ///设置Header/Footer闭包
    public typealias HeaderHandle  = (UITableView, Int, SectionType) -> UIView?
    public typealias FooterHandle  = (UITableView, Int, SectionType) -> UIView?
    private var setHeaderView : HeaderHandle?
    private var setFooterView : FooterHandle?
    ///header/footer大小
    public typealias SetHeightForHeaderHandle = (UITableView, Int, SectionType) -> CGFloat
    public typealias SetHeightForFooterHandle = (UITableView, Int, SectionType) -> CGFloat
    private var setHeightForHeader : SetHeightForHeaderHandle?
    private var setHeightForFooter : SetHeightForFooterHandle?

    private weak var tableView: UITableView?
    private let dataSource = DataSource<SectionType, ItemType>()
    
    /// 初始化TableViewDataSource,默认配置数据源代理
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - needDelegate: 是否需要代理方法
    ///   - cellGetter: 配置cell
    public required init(_ tableView: UITableView, needDelegate: Bool = false, cellGetter: @escaping CellHandle) {
        self.setCell  = cellGetter
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        if needDelegate{
            tableView.delegate = self
        }
    }
    
    //MARK: 数据源代理 UITableViewDataSource
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

    //MARK:  代理 UITableViewDelegate
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        didSelectRow?(tableView, indexPath, item)
    }
}

extension TableViewDataSource{
    
    ///cell大小
    @discardableResult
    public func setHeightForRow(_ callback:@escaping SetHeightForRowHandle) -> Self{
        setHeightForRow = callback
        return self
    }
    
    ///点击事件
    @discardableResult
    public func didSelectRow(_ callback:@escaping DidSelectRowHandle) -> Self{
        didSelectRow = callback
        return self
    }
    
    ///设置Header/Footer闭包
    @discardableResult
    public func setHeaderView(_ callback:@escaping HeaderHandle) -> Self{
        setHeaderView = callback
        return self
    }
    
    @discardableResult
    public func setFooterView(_ callback:@escaping FooterHandle) -> Self{
        setFooterView = callback
        return self
    }
    
    ///header/footer大小
    @discardableResult
    public func setHeightForHeader(_ callback:@escaping SetHeightForHeaderHandle) -> Self{
        setHeightForHeader = callback
        return self
    }
    
    @discardableResult
    public func setHeightForFooter(_ callback:@escaping SetHeightForFooterHandle) -> Self{
        setHeightForFooter = callback
        return self
    }
    
    ///根据索引获取Item对象
    public func itemId(for indexPath: IndexPath) -> ItemType? {
        return dataSource.itemID(for: indexPath)
    }
    
    ///根据Item对象获取所在位置索引
    public func indexPath(for itemId: ItemType) -> IndexPath? {
        return dataSource.indexPath(for: itemId)
    }
    
    ///变更数据---相当于reload
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
    
    ///获取当前view快照
    public func snapshot() -> DataSourceSnapshot<SectionType, ItemType> {
        return dataSource.snapshot()
    }
    
///无数据比对方式情况下的数据操作
//    public func apply(_ snapshot: DataSourceSnapshot<SectionType, ItemType>) {
//        dataSource.sections = snapshot.structer.sections
//        tableView?.reloadData()
//    }
//
//    public func applyRows(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
//                          itemIndexPaths: [IndexPath]) {
//        dataSource.sections = snapshot.structer.sections
//        tableView?.reloadRows(at: itemIndexPaths, with: defaultRowAnimation)
//    }
//
//    public func applyRows(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
//                          itemIDs: [ItemType]) {
//        dataSource.sections = snapshot.structer.sections
//        var itemIndesPaths = [IndexPath]()
//        itemIDs.forEach { item in
//            guard let index = indexPath(for: item) else{return}
//            itemIndesPaths.append(index)
//        }
//        tableView?.reloadRows(at: itemIndesPaths, with: defaultRowAnimation)
//    }
//
//    public func applySections(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
//                              sectionIndex : Int) {
//        dataSource.sections = snapshot.structer.sections
//        tableView?.reloadSections(IndexSet(integer: sectionIndex), with: defaultRowAnimation)
//    }
}
