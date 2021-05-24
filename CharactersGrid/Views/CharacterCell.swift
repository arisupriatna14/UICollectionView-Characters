//
//  CharacterCell.swift
//  CharactersGrid
//
//  Created by Ari Supriatna on 23/05/21.
//

import UIKit
import SwiftUI
import SnapKit

class CharacterCell: UICollectionViewCell {
    
    let imageView = RoundedImageView()
    let textLabel = UILabel()
    let vStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Xib/Storyboard is not supported")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let padding: CGFloat = 8.0
        let noOfItems = traitCollection.horizontalSizeClass == .compact ? 4 : 8
        let itemWidth = floor((UIScreen.main.bounds.width - (padding * 2)) / CGFloat(noOfItems))
        
        return super.systemLayoutSizeFitting(.init(width: itemWidth, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    private func setupLayout() {
        imageView.contentMode = .scaleAspectFill
        
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.textAlignment = .center
        
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 8.0
        
        contentView.addSubview(vStack)
        vStack.addArrangedSubview(imageView)
        vStack.addArrangedSubview(textLabel)
        
        vStack.snp.makeConstraints {
            $0.leading.top.equalTo(8.0)
            $0.trailing.bottom.equalTo(-8.0)
        }
        
        imageView.snp.makeConstraints {
            $0.height.equalTo(imageView.snp.width)
        }
    }
    
    func setup(character: Character) {
        textLabel.text = character.name
        imageView.image = UIImage(named: character.imageName)
    }
    
}

struct CharacterCellViewRepresentable: UIViewRepresentable {
    
    let charater: Character
    
    func updateUIView(_ uiView: CharacterCell, context: Context) { }
    
    func makeUIView(context: Context) -> CharacterCell {
        let cell = CharacterCell()
        cell.setup(character: charater)
        
        return cell
    }
    
}

class RoundedImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        clipsToBounds = true
        layer.cornerRadius = bounds.width / 2
    }
    
}

struct CharacterCell_Previews: PreviewProvider {
    
    static var previews: some View {
        let columns: [GridItem] = [.init(.flexible()), .init(.flexible()), .init(.flexible())]
        
        Group {
            CharacterCellViewRepresentable(charater: Universe.marvel.stubs[0])
                .frame(width: 120, height: 150)
            
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(Universe.ff7r.stubs) {
                            CharacterCellViewRepresentable(charater: $0)
                                .frame(width: 120, height: 150)
                        }
                    }
                }
                .navigationTitle(Text("ff7r".uppercased()))
            }
        }
    }
    
}
