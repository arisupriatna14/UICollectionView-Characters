//
//  SingleSectionCharactersViewController.swift
//  CharactersGrid
//
//  Created by Ari Supriatna on 23/05/21.
//

import UIKit
import SwiftUI

class SingleSectionCharactersViewController: UIViewController {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var characters = Universe.ff7r.stubs {
        didSet {
            collectionView.reloadData()
        }
    }
    let segmentedControl = UISegmentedControl(
        items: Universe.allCases.map { $0.title }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupLayout()
        setupSegmentedControl()
    }
    
    private func setupCollectionView() {
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .systemBackground
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        /// Register Cell
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        view.addSubview(collectionView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupLayout() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        flowLayout.sectionInset = .init(top: 0, left: 8, bottom: 0, right: 8)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        characters = sender.selectedUniverse.stubs
    }

}

extension SingleSectionCharactersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // 1
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }
    
    // 2
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let defaultCell = UICollectionViewCell()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CharacterCell
        
        if let cell = cell {
            let character = characters[indexPath.row]
            cell.setup(character: character)
        }
        
        return cell ?? defaultCell
    }
    
    // 3
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let defaultView = UICollectionReusableView()
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as? HeaderView
        
        headerView?.setup(text: "Character(s) \(characters.count)")
        
        return headerView ?? defaultView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = HeaderView()
        headerView.setup(text: "Character(s) \(characters.count)")
        
        return headerView.systemLayoutSizeFitting(.init(width: collectionView.bounds.width, height: UICollectionView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
}

// MARK: Live Previews with SwiftUI

struct SingleSectionCharactersViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: SingleSectionCharactersViewController())
    }
    
}

struct SingleSectionCharactersViewController_Previews: PreviewProvider {
    
    static var previews: some View {
        SingleSectionCharactersViewControllerRepresentable()
            .edgesIgnoringSafeArea(.top)
            .environment(\.sizeCategory, ContentSizeCategory.extraLarge)
    }
    
}
