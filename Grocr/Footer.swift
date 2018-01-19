//
//  Footer.swift
//  Grocr
//
//  Created by Home on 1/19/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

class Footer: UIView {
  
  let label: UILabel = UILabel()
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    configureView()
  }
  
  func configureView() {
    backgroundColor = UIColor.green
    alpha = 0.0
    
    // Configure label
    label.textAlignment = .center
    label.textColor = UIColor.white
    addSubview(label)
  }
  
  override func draw(_ rect: CGRect) {
    label.frame = bounds
  }
  
  //MARK: - Animation
  
  fileprivate func hideFooter() {
    UIView.animate(withDuration: 0.7) {[unowned self] in
      self.alpha = 0.0
    }
  }
  
  fileprivate func showFooter() {
    UIView.animate(withDuration: 0.7) {[unowned self] in
      self.alpha = 1.0
    }
  }
}

extension Footer {
  //MARK: - Public API
  
  public func setNotFiltering() {
    label.text = ""
    hideFooter()
  }
  
  public func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
    if (filteredItemCount == totalItemCount) {
      setNotFiltering()
    } else if (filteredItemCount == 0) {
      label.text = "No items match your query"
      showFooter()
    } else {
      label.text = "Filtering \(filteredItemCount) of \(totalItemCount)"
      showFooter()
    }
  }
  
}
