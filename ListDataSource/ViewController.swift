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

///注意修改单条数据的情况struct是不支持的,如果单纯是增删展示struct是最佳的,但是涉及到单挑修改的尽量采用对象
class Item: Hashable {
    
    var name : String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

class ViewController: JHTableViewController {


    let section1 = Section(title: "1", color: .yellow)

    
    let section2 = Section(title: "2", color: .purple)
    
    let item1 = Item(name: "1")
    let item2 = Item(name: "2")
    let item3 = Item(name: "3")
    let item4 = Item(name: "4")
    var item5 = Item(name: "5")
    let item6 = Item(name: "1111")
    let item7 = Item(name: "7")
    let item8 = Item(name: "8")
    let item9 = Item(name: "9")
    
    let item11 = Item(name: "11")
    let item12 = Item(name: "12")
    let item13 = Item(name: "13")
    let item14 = Item(name: "14")
    let item15 = Item(name: "15")
    
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
        shot.appendSections([section1])
        shot.appendItems([item1,
                          item2,
                          item3,
                          item4,
                          item5,
                          item6])
        dataSource.apply(shot)
        
        dataSource.setHeaderView { tableView, index, sectionModel in
            let view = UILabel()
            view.backgroundColor = sectionModel.color
            view.text = "-------------\(sectionModel.title)---------------"
            view.textAlignment = .center
            return view
        }
        .setHeightForHeader { tableView, index, sectionModel in
            if sectionModel.title == "1"{
                return 100
            }else{
                return 50
            }
        }
        .didSelectRow { tableView, index, model in
            print("index,\(index)")
        }
    }
    
    func addButtons(){
        
        addLeftBarButton(text: "清空", normalColor: .darkGray, highlightColor: .lightGray) { [weak self] _ in
            guard let `self` = self else{return}
            self.shot.deleteAll()
            self.dataSource.apply(self.shot)
        }
        
        addRightBarButton(text: "跳转", normalColor: .darkGray, highlightColor: .lightGray, touchUp: { _ in
            SwiftMediator.shared.push("CollectionViewController")
        })
        
        
        UIButton.snpButton(supView: view, backColor: .orange, title: "列表操作", touchUp: { (_) in
            
            self.addAction()
            
        }) { (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
    }
    
    func addAction(){
        let optionMenu = UIAlertController(title: nil, message: "列表操作", preferredStyle: .actionSheet)

        let action1 = UIAlertAction(title: "添加指定section", style: .default, handler:{ (alert: UIAlertAction!) -> Void in
            self.shot.appendSections([self.section2])

            self.shot.appendItems([self.item11,
                                   self.item12,
                                   self.item13,
                                   self.item14,
                                   self.item15], toSection: self.section2)
            self.dataSource.apply(self.shot)
        })

        let action2 = UIAlertAction(title: "指定s1添加元素", style: .default, handler:{(alert: UIAlertAction!) -> Void in
            ///清空后 section1也会从数组中移除,再次添加元素会找不到Section
            self.shot.appendItems([self.item7,
                                   self.item8,
                                   self.item9], toSection: self.section1)

            self.dataSource.apply(self.shot)
        })

        let action3 = UIAlertAction(title: "删s1中的1111", style: .default, handler:{(alert: UIAlertAction!) -> Void in
            self.shot.deleteItems([self.item6])
            self.dataSource.apply(self.shot)
        })
        
        let action4 = UIAlertAction(title: "更改编号5为100", style: .default, handler:{(alert: UIAlertAction!) -> Void in

            let item = self.dataSource.itemId(for: IndexPath(item: 4, section: 0))
            item?.name = "100"
            self.shot.reloadItems([item!])
            self.dataSource.apply(self.shot)

        })
        
        let action5 = UIAlertAction(title: "添加随机Section", style: .default, handler:{(alert: UIAlertAction!) -> Void in

            let section = Section(title: "\(Int.random(in: 0...99))", color: .random)
            self.shot.appendSections([section])
            
            let item = Item(name: "\(Int.random(in: 0...99))")
            self.shot.appendItems([item], toSection: section)
        
            self.dataSource.apply(self.shot)
        })
        
        optionMenu.addAction(action1)
        optionMenu.addAction(action2)
        optionMenu.addAction(action3)
        optionMenu.addAction(action4)
        optionMenu.addAction(action5)
        self.present(optionMenu, animated: true, completion: nil)
    }
}
