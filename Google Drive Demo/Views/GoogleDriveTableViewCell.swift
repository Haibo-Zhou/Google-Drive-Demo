//
//  GoogleDriveTableViewCell.swift
//  Google Drive Demo
//
//  Created by HaiboZhou on 2021/8/24.
//

import TransitionButton
import UIKit

class GoogleDriveTableViewCell: UITableViewCell {
    static var cell_ID = "GoogleDriveTableViewCell"
    var tapAction: ((UITableViewCell) -> Void)?
    
    // set UI elements
    var cellImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var downloadButton: TransitionButton = {
        let button = TransitionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold, scale: .default)
        let image = UIImage(systemName: "arrow.down", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(downloadButtonTapped(_:)), for: .touchUpInside)
        button.spinnerColor = .white
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: GoogleDriveTableViewCell.cell_ID)
        
        setViews()
    }
    
    func setViews() {
        let g = contentView
        g.addSubview(cellImageView)
        g.addSubview(nameLabel)
        g.addSubview(downloadButton)
        
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: g.topAnchor, constant: 10),
            cellImageView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
            cellImageView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20),
            cellImageView.widthAnchor.constraint(equalToConstant: 44),
            
            nameLabel.centerYAnchor.constraint(equalTo: g.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 20),
            nameLabel.widthAnchor.constraint(equalTo: g.widthAnchor, multiplier: 0.6),
            
            //            downloadButton.topAnchor.constraint(equalTo: g.topAnchor, constant: 10),
            downloadButton.centerYAnchor.constraint(equalTo: g.centerYAnchor),
            downloadButton.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20),
            //            downloadButton.widthAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // this is for custom animation
        // Configure the view for the selected state
    }
    
    @objc func downloadButtonTapped(_ sender: Any) {
        downloadButton.startAnimation()
        tapAction?(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
