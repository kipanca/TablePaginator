//
//  ViewController.swift
//  TablePaginator
//
//  Created by Alex Kisel on 08/27/2018.
//  Copyright (c) 2018 Alex Kisel. All rights reserved.
//

import UIKit
import MulticastDelegateKit
import TablePaginator

class ViewController: UIViewController {
  @IBOutlet weak var tableView: MultidelegateTableView!
  let tableViewPaginator = TableViewPaginator<ViewController>()
  var dataSourceArray = [User]()
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action:
      #selector(ViewController.handleRefresh(_:)),
                             for: UIControlEvents.valueChanged)
    refreshControl.tintColor = UIColor.red
    
    return refreshControl
  }()
  
  // let dataProvider = DataProvider()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSourceArray = skeletonUsers()
    tableView.addSubview(refreshControl)
    tableViewPaginator.paginableVC = self
    tableViewPaginator.pageSize = 50
    tableViewPaginator.preloadItemsOffset = 25
    
    tableView.multiDelegate.add(delegate: tableViewPaginator)
    tableView.multiDelegate.add(delegate: self)
    tableViewPaginator.loadFirstPage(tableView: tableView)
  }
  
  func decorate(users: [User]?) -> [User] {
    var decoratedUsers = [User]()
    for user in users ?? [User]() {
      decoratedUsers.append(user)
      let decoration = User()
      decoration.name = "Decoration"
      decoratedUsers.append(decoration)
    }
    return decoratedUsers
  }
  
  func skeletonUsers() -> [User] {
    var users = [User]()
    for _ in 0..<3 {
      let user = User()
      user.name = "..."
      users.append(user)
    }
    return users
  }
  
  @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    tableViewPaginator.loadFirstPage(tableView: tableView)
    refreshControl.endRefreshing()
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSourceArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = dataSourceArray[indexPath.row].name
    return cell
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ViewController: PaginableVC {
  
  func load(page: Int, pageSize: Int, completion: @escaping (([User]?, Int?, Error?) -> Void)) {
    API.getUsers(page: page, pageSize: pageSize) { [weak self] (users, error) in
      guard let strongSelf = self else { return }
      let decoratedUsers = strongSelf.decorate(users: users)
      completion(decoratedUsers, decoratedUsers.count - (users?.count ?? 0), error)
    }
  }
  
  func loadingView() -> UIView? {
    let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 50))
    footerView.backgroundColor = .red
    return footerView
  }
}

