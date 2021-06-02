//
//  FileExportViewController.swift
//  FileImport2
//
//  Created by Suto, Evelyne on 24/05/2021.
//

import Foundation
import UIKit

class FileExportViewController: UIViewController {
    private var viewModel: FileViewModel
    weak var tableView: UITableView!
    weak var imageView: UIImageView!
    weak var presenter: ViewControllerPresenter?
    private var cancellables: DisposeBag = []
    
    init(viewModel: FileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.dispose()
    }
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModels()
        viewModel.loadImage()
    }

    private func bindViewModels() {
        viewModel.imagePublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (image) in
            self?.imageView.image = image
        }).store(in: &cancellables)
    }
}

// MARK: Private helpers
fileprivate extension FileExportViewController {
    
    func setupViews() {
        let tableView = UITableView(frame: .zero)
        let imageView = UIImageView(frame: .zero)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            tableView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        self.tableView = tableView
        self.imageView = imageView
        
        
        imageView.image = UIImage.systemPhoto
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(FileExportCell.self, forCellReuseIdentifier: FileExportCell.reuseIdentifier)
        
        tableView.reloadData()
    }
}

extension FileExportViewController: ViewControllerPresenter {
    // https://dushyant37.medium.com/how-to-present-uiactivityviewcontroller-on-iphone-and-ipad-ae72013d2a5a
    // I don't really understand why can't I show this in something else than a popover
    func showViewController(vc: UIViewController) {
        dismiss(animated: false, completion: nil)
        vc.popoverPresentationController?.sourceView = self.popoverPresentationController?.sourceView
        presenter?.showViewController(vc: vc)
    }
}

extension FileExportViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}

extension FileExportViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfExports
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel.exportAtIndexPath(index: indexPath),
              let cell = tableView.dequeueReusableCell(withIdentifier: FileExportCell.reuseIdentifier, for: indexPath) as? FileExportCell else {
            return UITableViewCell()
        }
        cell.configure(with: item, presenter: self)
        cell.selectionStyle = .none
        
        return cell
    }
}
