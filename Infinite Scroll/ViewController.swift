//
//  ViewController.swift
//  Infinite Scroll
//
//  Created by FISH on 2021/9/1.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var viewModel: ViewControllerViewModel = {
        let viewModel = ViewControllerViewModel()
        
        return viewModel
    }()
    
    private lazy var collectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .darkGray
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "\(CollectionViewCell.self)")
        
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = viewModel.numberOfItems() - 2
        pageControl.isEnabled = false
        
        return pageControl
    }()
    
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
    }

    private func initViews() {
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 0)
        ])
    }
    
    private func adjustDisplayIndex(oldIndex: Int) {
        let lastIndex = viewModel.numberOfItems() - 1
        var newIndex = oldIndex
        
        if oldIndex == 0 {
            newIndex = lastIndex - 1
            collectionView.scrollToItem(at: IndexPath(item: newIndex, section: 0), at: .centeredHorizontally, animated: false)
            
        } else if oldIndex == lastIndex {
            newIndex = 1
            collectionView.scrollToItem(at: IndexPath(item: newIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
        
        viewModel.displayIndex = newIndex
        pageControl.currentPage = newIndex - 1
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fireTimer(_:)), userInfo: nil, repeats: true)
    }
    
    @objc private func fireTimer(_ timer: Timer) {
        let nextIndex = viewModel.displayIndex + 1
        collectionView.scrollToItem(at: IndexPath(item: nextIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(CollectionViewCell.self)", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.contentView.backgroundColor = viewModel.getColor(indexPath: indexPath)
        cell.text = "\(indexPath.item)"
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width - 20, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if viewModel.isFirst {
            collectionView.scrollToItem(at: IndexPath(item: viewModel.displayIndex, section: 0), at: .centeredHorizontally, animated: false)
            viewModel.isFirst = false
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let displayIndex = Int(scrollView.contentOffset.x / view.frame.width)
        adjustDisplayIndex(oldIndex: displayIndex)
        startTimer()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let displayIndex = Int(scrollView.contentOffset.x / view.frame.width)
        adjustDisplayIndex(oldIndex: displayIndex)
    }
}
