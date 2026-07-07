import Foundation
import Compression

class Brotli: Compression {

    func decompress(_ data: Data) -> Data? {
        if data.isEmpty {
            return nil
        }

        let size = Constants.initialBufferSizeMultiplier * data.count + Constants.extraBufferSize
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        defer {
            buffer.deallocate()
        }

        let read = data.withUnsafeBytes {
            compression_decode_buffer(
                buffer,
                size,
                $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                data.count,
                nil,
                COMPRESSION_BROTLI
            )
        }

        if read == 0 {
            return nil
        }

        return Data(bytes: buffer, count: read)
    }

    func compress(data: Any) -> Data? {
        var sourceBuffer: [UInt8]

        if let stringData = data as? String {
            sourceBuffer = Array(stringData.utf8)
        } else if let byteArrayData = data as? [UInt8] {
            sourceBuffer = byteArrayData
        } else {
            return nil
        }

        let destinationBufferSize = sourceBuffer.count + (sourceBuffer.count / Constants.compressionRatioDenominator) + Constants.compressionOverhead
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
        defer {
            destinationBuffer.deallocate()
        }

        let compressedSize = compression_encode_buffer(
            destinationBuffer, destinationBufferSize,
            &sourceBuffer, sourceBuffer.count,
            nil,
            COMPRESSION_BROTLI
        )

        if compressedSize == 0 {
            return nil
        }

        return Data(bytes: destinationBuffer, count: compressedSize)
    }
}
