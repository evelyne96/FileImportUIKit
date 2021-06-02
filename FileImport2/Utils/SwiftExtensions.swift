//
//  SwiftExtensions.swift
//  FileImport2
//
//  Created by Suto, Evelyne on 24/05/2021.
//

import Foundation
import UIKit
import UniformTypeIdentifiers.UTType
import Combine

extension UTType {
    public static let shapr = UTType(filenameExtension: "shapr")!
}

extension UIImage {
    class var systemPlus: UIImage? { UIImage(systemName: "plus") }
    class var systemPhoto: UIImage? { UIImage(systemName: "photo") }
    
    func write(to url: URL) throws {
        if let data = self.pngData() {
            try data.write(to: url)
        }
    }
    
    static func load(from url: URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: url)
            return UIImage(data: imageData)
        } catch { return nil }
    }
    
    func resized(width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        draw(in: CGRect(origin: .zero, size: canvasSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        defer { UIGraphicsEndImageContext() }
        return resizedImage
    }
}

extension UICollectionViewCell {
    class var reuseIdentifier: String { return String(describing: self) }
}

extension UITableViewCell {
    class var reuseIdentifier: String { return String(describing: self) }
}

extension UIDevice {
    var isPad: Bool {
        return userInterfaceIdiom == .pad
    }
}

// https://forums.swift.org/t/is-this-a-bug-in-published/31292/61
extension Published.Publisher {
    var didSet: AnyPublisher<Value, Never> {
        // Any better ideas on how to get the didSet semantics?
        // This works, but I'm not sure if it's ideal.
        self.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}

typealias DisposeBag = Set<AnyCancellable>
extension DisposeBag {
    mutating func dispose() {
        forEach { $0.cancel() }
        removeAll()
    }
}

//https://stackoverflow.com/questions/29779128/how-to-make-a-random-color-with-swift
extension UIColor {
    class func random(with seed: String) -> UIColor {
        var total: Int = 0
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }
        
        srand48(total * 200)
        let r = CGFloat(drand48())
        
        srand48(total)
        let g = CGFloat(drand48())
        
        srand48(total / 200)
        let b = CGFloat(drand48())
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
