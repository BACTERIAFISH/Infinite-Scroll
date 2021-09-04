//
//  ViewControllerViewModel.swift
//  Infinite Scroll
//
//  Created by FISH on 2021/9/1.
//

import UIKit

class ViewControllerViewModel {
    
    var colors: [UIColor] = [
        .cyan,
        .red,
        .yellow,
        .blue,
        .green,
        .orange,
        .systemPink,
        .purple,
        .cyan,
        .red
    ]
    
    var isFirst = true
    var displayIndex: Int = 1
    
    func numberOfItems() -> Int {
        colors.count
    }
    
    func getColor(indexPath: IndexPath) -> UIColor {
        guard indexPath.item < colors.count else {
            return .black
        }
        
        return colors[indexPath.item]
    }
    
//    func nextAutoDisplayIndex() -> Int {
//        if displayIndex == numberOfItems() - 2 {
//            return 1
//        }
//        
//        return displayIndex + 1
//    }
}
