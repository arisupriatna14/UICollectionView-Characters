//
//  MultipleSectionCharactersViewController.swift
//  CharactersGrid
//
//  Created by Ari Supriatna on 24/05/21.
//

import UIKit
import SwiftUI

class MultipleSectionCharactersViewController: UIViewController {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var sectionedStubs = Universe.ff7r.sectionedStubs {
        didSet {
            updateCollectionView(oldSectionItems: oldValue, newSectionItems: sectionedStubs)
        }
    }
    let segmentedControl = UISegmentedControl(
        items: Universe.allCases.map { $0.title }
    )
    
    private var cellRegistration: UICollectionView.CellRegistration<CharacterCell, Character>!
    private var headerRegistration: UICollectionView.SupplementaryRegistration<HeaderView>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupCollectionView()
        setupNavigationItem()
        setupSegmentedControl()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func updateCollectionView(oldSectionItems: [SectionCharacters], newSectionItems: [SectionCharacters]) {
        
        var sectionsToRemove = IndexSet()
        var sectionsToInsert = IndexSet()
        
        var indexPathsToInsert = [IndexPath]()
        var indexPathsToRemove = [IndexPath]()
        
        let sectionDiff = newSectionItems.difference(from: oldSectionItems)
        sectionDiff.forEach { change in
            switch change {
            case let .remove(offset, _, _):
                sectionsToRemove.insert(offset)
            case let .insert(offset, _, _):
                sectionsToInsert.insert(offset)
            }
        }
        
        (0..<newSectionItems.count).forEach { index in
            let newSectionCharacter = newSectionItems[index]
            if let oldSectionIndex = oldSectionItems.firstIndex(of: newSectionCharacter) {
                let oldSectionCharacter = oldSectionItems[oldSectionIndex]
                let diff = newSectionCharacter.characters.difference(from: oldSectionCharacter.characters)
                
                diff.forEach { change in
                    switch change {
                    case let .remove(offset, _, _):
                        indexPathsToRemove.append(IndexPath(item: offset, section: oldSectionIndex))
                    case let .insert(offset, _, _):
                        indexPathsToInsert.append(IndexPath(item: offset, section: index))
                    }
                }
            }
        }
        
        collectionView.performBatchUpdates {
            self.collectionView.deleteSections(sectionsToRemove)
            self.collectionView.deleteItems(at: indexPathsToRemove)
            
            self.collectionView.insertSections(sectionsToInsert)
            self.collectionView.insertItems(at: indexPathsToInsert)
        } completion: { _ in
            let headerIndexPath = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
            headerIndexPath.forEach { indexPath in
                let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? HeaderView
                let section = self.sectionedStubs[indexPath.section]
                
                headerView?.setup(text: "\(section.category) \(section.characters.count)".uppercased())
            }
        }
   
    }
    
    private func setupCollectionView() {
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .systemBackground
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        registerCollectionViewCell()
        
        view.addSubview(collectionView)
    }
    
    private func registerCollectionViewCell() {
        cellRegistration = UICollectionView.CellRegistration(handler: { (cell: CharacterCell, _, character: Character)in
            cell.setup(character: character)
        })
        
        headerRegistration = UICollectionView.SupplementaryRegistration(
            elementKind: UICollectionView.elementKindSectionHeader,
            handler: { (header: HeaderView, _, indexPath) in
                let section = self.sectionedStubs[indexPath.section]
                header.setup(text: "\(section.category) \(section.characters.count)")
            }
        )
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
    
    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "shuffle"),
            style: .plain,
            target: self,
            action: #selector(shuffleTapped)
        )
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        sectionedStubs = sender.selectedUniverse.sectionedStubs
    }
    
    @objc func shuffleTapped() {
        sectionedStubs = sectionedStubs.shuffled().map {
            SectionCharacters(category: $0.category, characters: $0.characters.shuffled())
        }
    }
    
}

extension MultipleSectionCharactersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionedStubs.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        sectionedStubs[section].characters.count
    }
    
    /// Register CharacterCell
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let character = sectionedStubs[indexPath.section].characters[indexPath.item]
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: character)
        
        return cell
    }
    
    /// Setup HeaderView
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let headerView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        return headerView
    }
    
    /// Setup size HeaderView
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let headerView = HeaderView()
        let section = sectionedStubs[section]
        headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
        
        return headerView.systemLayoutSizeFitting(
            .init(
                width: collectionView.bounds.width,
                height: UICollectionView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

struct MultipleSectionCharactersViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: MultipleSectionCharactersViewController())
    }
    
}

struct MultipleSectionCharactersViewController_Previews: PreviewProvider {
    
    static var previews: some View {
        MultipleSectionCharactersViewControllerRepresentable()
            .edgesIgnoringSafeArea(.top)
    }
    
}
