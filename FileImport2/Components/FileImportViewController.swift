//
//  FileImportViewController.swift
//  FileImport2
//
//  Created by Suto, Evelyne on 24/05/2021.
//

import Combine
import UIKit
import UniformTypeIdentifiers.UTType

class FileImportViewController: UIViewController {
    class Consts {
        class var detailViewSize: CGSize { CGSize(width: 400, height: 400) }
        class var spacing: CGFloat { 8 }
        class var collectionInset:UIEdgeInsets { UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8) }
    }
    
    private var viewModel = FileImportViewModel()
    private var cancellables: DisposeBag = []
    weak var collectionView: UICollectionView!
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
        bindViewModels()
    }
    
    deinit {
        cancellables.dispose()
    }
    
    @objc func showFileImport() {
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.shapr])
        documentPickerController.allowsMultipleSelection = true
        documentPickerController.delegate = self
        present(documentPickerController, animated: true, completion: nil)
    }
}

// MARK: Private helpers
fileprivate extension FileImportViewController {
    
    func setupViews() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        self.collectionView = collectionView
    }
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(showFileImport))
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self

        self.collectionView.register(FileCell.self, forCellWithReuseIdentifier: FileCell.reuseIdentifier)
    }
    
    func bindViewModels() {
        viewModel.$importedFiles
            .didSet.sink { [weak self] _ in
                self?.dismiss(animated: false, completion: nil)
                self?.collectionView.reloadData() }
            .store(in: &cancellables)
        
        viewModel.reloadFiles()
    }
}

// MARK: Document Picker Delegate
extension FileImportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        viewModel.importFiles(files: urls)
    }
}

// MARK: CollectionView DataSource
extension FileImportViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel.item(at: indexPath),
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileCell.reuseIdentifier, for: indexPath) as? FileCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: item)
        return cell
    }
}

extension FileImportViewController: ViewControllerPresenter {
    func showViewController(vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
}


// MARK: CollectionView Delegate
extension FileImportViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Open details
        guard let item = viewModel.item(at: indexPath), let cell = collectionView.cellForItem(at: indexPath) else { return }
        let fileExportDetail = FileExportViewController(viewModel: item)
        fileExportDetail.presenter = self
        fileExportDetail.preferredContentSize = Consts.detailViewSize
        fileExportDetail.modalPresentationStyle = .popover
        fileExportDetail.popoverPresentationController?.sourceView = cell
        
        present(fileExportDetail, animated: true, completion: nil)
    }
}

// MARK: CollectionView Delegate FlowLayout

extension FileImportViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemsPerRow: CGFloat = UIDevice.current.isPad ? 3 : 2
        let sectionInsets = Consts.collectionInset
        let sectionInsetSpacing = sectionInsets.left + sectionInsets.right
        let totalInterItemSpacing: CGFloat = (itemsPerRow - 1) * Consts.spacing
        let width = floor((collectionView.bounds.width - sectionInsetSpacing - totalInterItemSpacing) / itemsPerRow)

        let height = width * 0.9
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Consts.spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Consts.spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return Consts.collectionInset
    }
}

