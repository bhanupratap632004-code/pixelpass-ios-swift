import Foundation

class CompressionFactory {

    static func create(type: CompressionType) -> Compression {

        switch type {

        case .zlib:
            return Zlib()

        case .brotli:
            if #available(iOS 15.0, *) {
                return Brotli()
            } else {
                return Zlib()
            }
        }
    }
}
