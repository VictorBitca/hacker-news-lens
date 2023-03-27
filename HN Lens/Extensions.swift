import UIKit

extension String {
    func insert(string: String, stride: Int = 6) -> String {
        var result = ""
        let characters = Array(self)
        
        for (index, character) in characters.enumerated() {
            result.append(character)
            if (index + 1) % stride == 0 && index != characters.count - 1 {
                result.append(string)
            }
        }
        
        return result
    }
}

extension FloatingPoint {
    func remap(form inputRange: ClosedRange<Self>, to outputRange: ClosedRange<Self>) -> Self {
        guard (inputRange.upperBound - inputRange.lowerBound) != .zero else { return .zero }
 
        let remapped = outputRange.lowerBound + (self - inputRange.lowerBound) *
        (outputRange.upperBound - outputRange.lowerBound) /
        (inputRange.upperBound - inputRange.lowerBound)
 
        return remapped.clamp(to: outputRange.lowerBound...outputRange.upperBound)
    }
}
 
extension Comparable {
    func clamp(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension UIImage {
    var pixelData: [UInt8]? {
        guard let cgImage = self.cgImage,
            let data = cgImage.dataProvider?.data,
            let bytes = CFDataGetBytePtr(data) else {
            fatalError("Couldn't access image data")
        }

        let dataSize = size.width * size.height
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        for y in 0 ..< cgImage.height {
            for x in 0 ..< cgImage.width {
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                pixelData[y * Int(size.width) + x] = bytes[offset]
            }
        }
        
        return pixelData
    }
 }
