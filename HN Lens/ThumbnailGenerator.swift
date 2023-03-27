import UIKit

struct ThumbnailGenerator {
    private static let noiseTexture = UIImage(named: "NoiseTexture.png")
    private static let pixelData: [UInt8]? = noiseTexture!.pixelData
    
    private static func cropGrayscaleImageArray(_ inputMatrix: [UInt8], inputMatrixSize: Int, outputMatrixSize: Int, cropPoint: CGPoint) -> [[UInt8]]? {
        if inputMatrixSize * inputMatrixSize != inputMatrix.count {
            return nil
        }

        var croppedArray = Array(repeating: Array(repeating: UInt8(0), count: outputMatrixSize), count: outputMatrixSize)

        let startX = Int(cropPoint.x)
        let startY = Int(cropPoint.y)

        for y in 0..<outputMatrixSize {
            for x in 0..<outputMatrixSize {
                let inputIndex = (startY + y) * inputMatrixSize + (startX + x)
                croppedArray[y][x] = inputMatrix[inputIndex]
            }
        }

        return croppedArray
    }
    
    static func noiseMatrix(size: Int) -> [[UInt8]] {
        guard let noiseTexture, let inputWidth = noiseTexture.cgImage?.width, let bytes = pixelData else { return [] }
        let x = Int.random(in: 0..<inputWidth - size)
        let y = Int.random(in: 0..<inputWidth - size)
        let point: CGPoint = .init(x: x, y: y)
        guard let result: [[UInt8]] = cropGrayscaleImageArray(bytes, inputMatrixSize: inputWidth, outputMatrixSize: size, cropPoint: point) else { return [] }
        
        return result
    }
}
