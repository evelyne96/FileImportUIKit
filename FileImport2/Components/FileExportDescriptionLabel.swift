//
//  FileExportDescriptionLabel.swift
//  FileImport2
//
//  Created by Suto, Evelyne on 25/05/2021.
//

import UIKit

class FileExportDescriptionLabel: UILabel {
    class Consts {
        class var labelHeight: CGFloat { 30 }
        class var labelWidth: CGFloat { 40 }
        class var hiddenLabelWidth: CGFloat { 0 }
        class var fontSize: CGFloat { 10 }
        class var bgAlpha: CGFloat { 0.85 }
    }
    
    private var cancellables: DisposeBag = []
    private var viewModel: FileExportViewModel?
    private var widthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(viewModel: FileExportViewModel) {
        super.init(frame: .zero)
        setupViews()
        self.viewModel = viewModel
        bindViewModels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.dispose()
    }
    
    private func setupViews() {
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        textAlignment = .center
        backgroundColor = UIColor.white.withAlphaComponent(Consts.bgAlpha)
        font = UIFont.systemFont(ofSize: Consts.fontSize)
        clipsToBounds = true
        
        translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = widthAnchor.constraint(equalToConstant: Consts.hiddenLabelWidth)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Consts.labelHeight),
            widthConstraint
        ])
        self.widthConstraint = widthConstraint
        isHidden = true
    }
    
    private func bindViewModels() {
        viewModel?.$exportStatus
            .didSet.sink { [weak self] status in
                self?.updateViews(status: status)
            }
            .store(in: &cancellables)
    }
    
    private func updateViews(status: FileExportStatus) {
        text = viewModel?.name
        let (hidden, width): (Bool, CGFloat)
        switch status {
        case .done:
            (hidden, width) = (false, Consts.labelWidth)
        default:
            (hidden, width) = (true, Consts.hiddenLabelWidth)
        }

        widthConstraint?.constant = width
        isHidden = hidden
    }
}
