//
//  HeaderView.swift
//  CharactersGrid
//
//  Created by Ari Supriatna on 23/05/21.
//

import UIKit
import SwiftUI

class HeaderView: UICollectionReusableView {
    
    private let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Xib/Storyboard is not supported.")
    }
    
    private func setupLayout() {
        textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        textLabel.adjustsFontForContentSizeCategory = true
        
        addSubview(textLabel)
        
        textLabel.snp.makeConstraints {
            $0.leading.top.equalTo(16.0)
            $0.trailing.bottom.equalTo(-16.0)
        }
    }
    
    func setup(text: String) {
        textLabel.text = text
    }
    
}

struct HeaderViewRepresentable: UIViewRepresentable {
    
    let text: String
    
    func updateUIView(_ uiView: HeaderView, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> HeaderView {
        let headerView = HeaderView()
        headerView.setup(text: text)
        
        return headerView
    }
    
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderViewRepresentable(text: "Heroes")
    }
}
