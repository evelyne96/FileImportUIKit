//
//  FileImportViewModel.swift
//  FileImportApp
//
//  Created by Suto, Evelyne on 17/05/2021.
//

import Foundation
import Combine
import UIKit

class FileImportViewModel {
    private let folder: String
    private let imageGenQueue = DispatchQueue(label: "com.FileImport.imageGenQueue")
    
    @Published var importedFiles: [FileViewModel] = []
    let numberOfSections = 1
    
    
    init(folder: String = Constants.importFolder) {
        self.folder = folder
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard section < numberOfSections else { return 0 }
        return importedFiles.count
    }
    
    func item(at index: IndexPath) -> FileViewModel? {
        guard importedFiles.count > index.row else { return nil }
        return importedFiles[index.row]
    }
    
    
    func reloadFiles() {
        importedFiles = FileManager.loadFileURLs(from: folder, type: .shapr).map { FileViewModel(fileURL: $0) }
        importedFiles.forEach { generateImage(for: $0) }
    }
    
    func importFiles(files: [URL]) {
        let savedFiles = FileManager.save(files: files, folder: folder)
        savedFiles.forEach { url in
            let importedFile = importedFiles.first { $0.fileURL == url }
            if importedFile == nil {
                let fileViewModel = FileViewModel(fileURL: url)
                importedFiles.append(fileViewModel)
                generateImage(for: fileViewModel)
            }
        }
    }
    
    private func generateImage(for fileViewModel: FileViewModel) {
        imageGenQueue.async { [weak fileViewModel] in
            guard let fileVM = fileViewModel else { return }
            let image = UIColor.random(with: fileVM.fileName).image(CGSize(width: 1200, height: 1200))
            try? image.write(to: fileVM.imageURL)
            let thumbnail = image.resized(width: 300)
            try? thumbnail?.write(to: fileVM.thumbnailImageURL)
            fileVM.thumbnailImage = thumbnail
        }
    }
}
