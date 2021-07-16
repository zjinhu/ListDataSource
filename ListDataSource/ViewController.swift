//
//  ViewController.swift
//  ListDataSource
//
//  Created by iOS on 2021/7/16.
//

import UIKit
import SwiftBrick

struct Section: Hashable {
    var title : String
}

struct Item: Hashable {
    var name : String
}

class ViewController: JHTableViewController {

    lazy var dataSource = TableViewDataSource<Section, Item>(tableView!, cellGetter: { (tableView, indexPath, model) -> UITableViewCell in
        let cell = tableView.dequeueReusableCell(JHTableViewCell.self)
        cell.textLabel?.text = model.name
        return cell
    })
    
    var shot = DataSourceSnapshot<Section,Item>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addRightBarButton(text: "清空", normalColor: .darkGray, highlightColor: .lightGray, touchUp: { [weak self] _ in
            guard let `self` = self else{return}
            self.shot.deleteAllItems()
            self.dataSource.apply(self.shot)
        })

        
        shot.appendSections([Section(title: "1")])
        shot.appendItems([Item(name: "1"),Item(name: "11"),Item(name: "111"),Item(name: "1111")])
        dataSource.apply(shot)

        
        
        UIButton.snpButton(supView: view, backColor: .orange, title: "添加section", touchUp: { (_) in
            let sec = Section(title: "2")
            self.shot.appendSections([sec])
//            self.shot.insertSections([sec], beforeSection: Section(title: "1"))
            self.shot.appendItems([Item(name: "2"),Item(name: "3"),Item(name: "4"),Item(name: "5")], toSection: sec)
            self.dataSource.apply(self.shot)
        }) { (m) in
            m.left.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        
        UIButton.snpButton(supView: view, backColor: .orange, title: "s1添加元素", touchUp: { (_) in
            self.shot.appendItems([Item(name: "6"),Item(name: "7"),Item(name: "8"),Item(name: "9")], toSection: Section(title: "1"))
//            self.shot.insertItems([Item(name: "6"),Item(name: "7"),Item(name: "8"),Item(name: "9")], beforeItem: Item(name: "11"))
            self.dataSource.apply(self.shot)
        }) { (m) in
            m.right.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        
        UIButton.snpButton(supView: view, backColor: .orange, title: "删s1中的1111", touchUp: { (_) in
            self.shot.deleteItems([Item(name: "1111")])
            self.dataSource.apply(self.shot)
        }) { (m) in
            m.centerX.bottom.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        

    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

}
