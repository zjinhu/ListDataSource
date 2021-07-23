//
//  ViewController.swift
//  ListDataSource
//
//  Created by iOS on 2021/7/16.
//

import UIKit
import SwiftBrick
import SwiftMediator

struct Section: Hashable {
    var title : String
    var color : UIColor?
}

struct Item: Hashable {
    var name : String
    var color : UIColor?
}

class ViewController: JHTableViewController {

    lazy var dataSource = TableViewDataSource<Section, Item>.init(tableView!, needDelegate: true) { tableView, indexPath, model in
        let cell = tableView.dequeueReusableCell(JHTableViewCell.self)
        cell.textLabel?.text = model.name
        return cell
    }
    
    var shot = DataSourceSnapshot<Section,Item>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtons()
        
        tableViewConfig()
    }
    
    func tableViewConfig(){
        shot.appendSections([Section(title: "1")])
        shot.appendItems([Item(name: "1"),Item(name: "11"),Item(name: "111"),Item(name: "1111")])
        dataSource.apply(shot)
        
        dataSource.setHeaderView { tableView, index, sectionModel in
            let view = UIView()
            if sectionModel.title == "1"{
                view.backgroundColor = .red
            }else{
                view.backgroundColor = .yellow
            }
            return view
        }
        
        dataSource.setHeightForHeader { tableView, index, sectionModel in
            if sectionModel.title == "1"{
                return 100
            }else{
                return 20
            }
        }
        
        dataSource.didSelectRow { tableView, index, model in
            print("index,\(index)")
        }
    }
    
    func addButtons(){
        
        addLeftBarButton(text: "清空", normalColor: .darkGray, highlightColor: .lightGray) { [weak self] _ in
            guard let `self` = self else{return}
            self.shot.deleteAllItems()
            self.dataSource.apply(self.shot)
        }
        
        addRightBarButton(text: "跳转", normalColor: .darkGray, highlightColor: .lightGray, touchUp: { _ in
            SwiftMediator.shared.push("CollectionViewController")
        })
        
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
}
