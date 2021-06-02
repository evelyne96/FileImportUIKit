//
//  FileExportCell.swift
//  FileImport2
//
//  Created by Suto, Evelyne on 25/05/2021.
//

import Foundation
import UIKit

protocol ViewControllerPresenter: class {
    func showViewController(vc: UIViewController)
}

class FileExportCell: UITableViewCell {
    class Consts {
        class var padding: CGFloat { 12 }
    }
    
    private var viewModel: FileExportViewModel?
    private var cancellables: DisposeBag = []
    weak var viewControllerPresenter: ViewControllerPresenter?
    
    weak var buttonAccessory: UIButton!
    weak var label: UILabel!
    weak var progressBar: UIProgressView!
    
    deinit {
        cancellables.dispose()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let text = UILabel(frame: .zero)
        let button = UIButton(frame: .zero)
        let progress = UIProgressView(progressViewStyle: .bar)
        
        text.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        progress.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(text)
        contentView.addSubview(button)
        contentView.addSubview(progress)
        
        NSLayoutConstraint.activate([
            text.topAnchor.constraint(equalTo: contentView.topAnchor),
            text.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            text.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:Consts.padding),
            text.trailingAnchor.constraint(equalTo: progress.leadingAnchor, constant:-Consts.padding),
            progress.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant:-Consts.padding),
            progress.topAnchor.constraint(equalTo: contentView.topAnchor, constant:Consts.padding),
            progress.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:-Consts.padding),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-Consts.padding),
        ])
        
        progressBar = progress
        label = text
        label.textAlignment = .left
        buttonAccessory = button
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
        
        label.text = nil
        buttonAccessory.removeTarget(self, action: #selector(accessoryTouched), for: .touchUpInside)
        
        viewModel = nil
    }
    
    
    func configure(with viewModel: FileExportViewModel, presenter: ViewControllerPresenter) {
        self.viewModel = viewModel
        self.viewControllerPresenter = presenter
        bindViewModels()
        
        label?.text = viewModel.name
        
        buttonAccessory?.setImage(UIImage(systemName: viewModel.image), for: .normal)
        buttonAccessory?.addTarget(self, action: #selector(accessoryTouched), for: .touchUpInside)
        buttonAccessory?.sizeToFit()
    }
    
    private func bindViewModels() {
        viewModel?.$exportStatus
            .didSet.sink { [weak self] status in
                guard let self = self, let vm = self.viewModel else { return }
                
                self.buttonAccessory.setImage(UIImage(systemName: vm.image), for: .normal)
                self.buttonAccessory.addTarget(self, action: #selector(self.accessoryTouched), for: .touchUpInside)
                
                self.buttonAccessory.sizeToFit()
            }
            .store(in: &cancellables)
        
        viewModel?.$exportProgressValue
            .didSet.sink { [weak self] progress in
                guard let self = self else { return }
                
                self.progressBar.progress = Float(progress)
                self.progressBar.isHidden = progress >= 1.0
            }
            .store(in: &cancellables)
        
        viewModel?.$presentShare
            .didSet.sink { [weak self] presented in
                if let url = self?.viewModel?.url, presented {
                    let items = [url]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    self?.viewControllerPresenter?.showViewController(vc: ac)
                    
                    self?.viewModel?.presentShare = false
                }
        }
        .store(in: &cancellables)
    }
    
    @objc func accessoryTouched() {
        viewModel?.actionForCurrentState()
    }
}
