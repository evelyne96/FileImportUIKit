//
//  FileCell.swift
//  FileImport2
//
//  Created by Suto, Evelyne on 24/05/2021.
//

import UIKit

class FileCell: UICollectionViewCell {
    private var viewModel: FileViewModel?
    weak var imageView: UIImageView!
    weak var textLabel: UILabel!
    weak var exportStackView: UIStackView!
    private var cancellables: DisposeBag = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        let text = UILabel(frame: .zero)
        let image = UIImageView(frame: .zero)
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .trailing
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        text.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleToFill
        contentView.addSubview(text)
        contentView.addSubview(image)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: text.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 40),
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.bottomAnchor.constraint(equalTo: text.topAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            text.topAnchor.constraint(equalTo: image.bottomAnchor),
            text.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            text.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            text.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        imageView = image
        textLabel = text
        textLabel.textAlignment = .center
        exportStackView = stackView
        
        contentView.backgroundColor = .lightGray
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        fatalError("Interface Builder is not supported!")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        fatalError("Interface Builder is not supported!")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.dispose()
        textLabel.text = nil
        imageView.image = nil
        exportStackView.subviews.forEach { $0.removeFromSuperview() }
        viewModel = nil
    }
    
    
    func configure(with fileViewModel: FileViewModel) {
        layer.cornerRadius = 5
        clipsToBounds = true
        viewModel = fileViewModel
        textLabel.text = fileViewModel.fileName
        
        viewModel?.exports.forEach { exportStackView.addArrangedSubview(FileExportDescriptionLabel(viewModel: $0)) }
        
        viewModel?.loadExportStatusIfNeeded()
        
        bindViewModels()
    }
    
    private func bindViewModels() {
        viewModel?.$thumbnailImage.didSet.sink(receiveValue: { [weak self] (image) in
            self?.imageView.image = image
        }).store(in: &cancellables)
    }
}
