//
//  FileViewModel.swift
//  FileImportApp
//
//  Created by Suto, Evelyne on 17/05/2021.
//

import UIKit
import Combine

class FileViewModel {
    var fileName: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }
    
    // https://www.swiftbysundell.com/articles/building-custom-combine-publishers-in-swift/
    private let imageSubject = PassthroughSubject<UIImage?, Never>()
    var imagePublisher: AnyPublisher<UIImage?, Never> {
        imageSubject.eraseToAnyPublisher()
    }
    
    @Published var thumbnailImage: UIImage? = UIImage.systemPhoto
    
    var numberOfExports: Int {
        return exports.count
    }
    
    var imageURL: URL {
        fileURL.deletingLastPathComponent().appendingPathComponent(fileName+".png")
    }
    
    var thumbnailImageURL: URL {
        fileURL.deletingLastPathComponent().appendingPathComponent(fileName+"thumb.png")
    }
    
    let fileURL: URL
    let exports: [FileExportViewModel]
    
    private var exportStatusLoaded = false
    private let supportedExportTypes: [FileExportType] = [.step, .stl, .obj]
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        self.exports = supportedExportTypes.map { FileExportViewModel(type: $0, source: fileURL, exportStatus: .none) }
        loadThumbImage()
    }
    
    func loadExportStatusIfNeeded() {
        guard !exportStatusLoaded else { return }
        for fileExport in exports {
            if FileManager.fileExists(at: fileExport.url) && fileExport.exportStatus == .none {
                fileExport.exportStatus = .done
            }
        }
        exportStatusLoaded = true
    }
    
    func exportAtIndexPath(index: IndexPath) -> FileExportViewModel? {
        guard exports.count > index.row else { return nil }
        
        return exports[index.row]
    }
    
    func loadImage() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let url = self?.imageURL else {
                self?.imageSubject.send(UIImage.systemPhoto)
                return
            }
            let image = UIImage.load(from: url)
            self?.imageSubject.send(image)
        }
    }
    
    private func loadThumbImage() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let url = self?.thumbnailImageURL else { return }
            self?.thumbnailImage = UIImage.load(from: url)
        }
    }
}

extension FileViewModel: Hashable, Identifiable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileURL)
    }
    
    static func == (lhs: FileViewModel, rhs: FileViewModel) -> Bool {
        return lhs.fileURL == rhs.fileURL
    }
}
