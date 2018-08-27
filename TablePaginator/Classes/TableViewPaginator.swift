//
//  TableViewPaginator.swift
//  Aggregation
//
//  Created by Alex Kisel on 8/20/18.
//  Copyright © 2018 BRANDER. All rights reserved.
//

import UIKit

public protocol PaginableVC: class {
  associatedtype Entity
  func load(page: Int, pageSize: Int, completion: @escaping (([Entity]?, Int?, Error?) -> Void))
  func loadingView() -> UIView?
  var dataSourceArray: [Entity] { get set }
}

open class TableViewPaginator<T: PaginableVC>: NSObject, UITableViewDelegate  {
  
  public weak var paginableVC: T?
  
  public var preloadItemsOffset = 0
  public var pageSize = 20
  
  private(set) var isAllPagesLoaded = false
  private(set) var isLoadingData = false
  private(set) var decorationItemsCount = 0
  
  private var loadOperation = BlockOperation()
  private let loadQueue = OperationQueue()
  
  // MARK: - Public
  
  public func loadFirstPage(tableView: UITableView) {
    isAllPagesLoaded = false
    decorationItemsCount = 0
    isLoadingData = false
    load(tableView: tableView)
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let paginableVC = paginableVC else { return }
    
    if indexPath.row == paginableVC.dataSourceArray.count - preloadItemsOffset - 1,
       !isAllPagesLoaded, !isLoadingData {
      load(tableView: tableView, cell: cell, indexPath: indexPath)
    }
  }
  
  // MARK: - Private
  
  private func load(tableView: UITableView, cell: UITableViewCell? = nil, indexPath: IndexPath? = nil) {
    guard let paginableVC = paginableVC else { return }
    let page = cell == nil ? 0 : (paginableVC.dataSourceArray.count - decorationItemsCount) / pageSize
    isLoadingData = true
    
    loadOperation.cancel()
    loadOperation = BlockOperation()
    loadOperation.addExecutionBlock(createNewLoadWorkItem(page: page, tableView: tableView, cell: cell,
                                                          indexPath: indexPath, paginableVC: paginableVC,
                                                          loadOperation: loadOperation))
    
    loadQueue.addOperation(loadOperation)
  }
  
  private func createNewLoadWorkItem<T: PaginableVC>(page: Int,
                                                     tableView: UITableView,
                                                     cell: UITableViewCell?,
                                                     indexPath: IndexPath?,
                                                     paginableVC: T,
                                                     loadOperation: BlockOperation) -> (() -> Void) {
    
    return { [weak self, weak loadOperation] in
      
      guard let strongSelf = self else { return }
      
      paginableVC.load(page: page, pageSize: strongSelf.pageSize) { (results, decorationCount, error) in
        
        guard loadOperation != nil else { return }
        
        strongSelf.isLoadingData = false
        strongSelf.decorationItemsCount += decorationCount ?? 0
        
        if error != nil {
          
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { [weak self] in
            self?.load(tableView: tableView, cell: cell, indexPath: indexPath)
          }
        } else if let results = results {
          
          if page == 0 {
            paginableVC.dataSourceArray = results
            strongSelf.showLoadingView(in: tableView)
          } else {
            paginableVC.dataSourceArray += results
          }
          
          strongSelf.isAllPagesLoaded = ((results.count - (decorationCount ?? 0)) < strongSelf.pageSize)
          
          if strongSelf.isAllPagesLoaded == true {
            strongSelf.hideLoadingView(in: tableView)
          }
          
          tableView.reloadData()
        }
      }
    }
  }
  
  private func showLoadingView(in tableView: UITableView) {
    guard let paginableVC = paginableVC else { return }
    tableView.tableFooterView = paginableVC.loadingView()
  }
  
  private func hideLoadingView(in tableView: UITableView) {
    tableView.tableFooterView = nil
  }
}
