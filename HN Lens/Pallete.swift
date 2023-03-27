import SwiftUI

public struct Pallete {
    public static let background = UIColor.init(named: "Background")!
    public static let textPrimary = UIColor.init(named: "TextPrimary")!
    public static let textSecondary = UIColor.init(named: "TextSecondary")!
    
    public static let grayLight = UIColor.init(named: "GrayLight")!
    public static let grayMedium = UIColor.init(named: "GrayMedium")!
    public static let grayDark = UIColor.init(named: "GrayDark")!
    
    public static let appleGreen = UIColor.init(named: "AppleGreen")!
    public static let appleYellow = UIColor.init(named: "AppleYellow")!
    public static let appleOrange = UIColor.init(named: "AppleOrange")!
    public static let appleRed = UIColor.init(named: "AppleRed")!
    public static let appleViolet = UIColor.init(named: "AppleViolet")!
    public static let appleBlue = UIColor.init(named: "AppleBlue")!
    
    public static var randomAccent: UIColor {
        return rainbowColors.randomElement()!
    }
    
    public static var rainbowColors: [UIColor] {
        return [appleGreen, appleYellow, appleOrange, appleRed, appleViolet, appleBlue]
    }
    
    public static func rainbowColors(at: Int) -> UIColor {
        let colorCount = Self.rainbowColors.count
        return Self.rainbowColors[at %  colorCount]
    }
}

public extension UIColor {
    var color: Color {
        return Color(self)
    }
    
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1
        )
    }
}

extension Color {
    public static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

extension UIColor {
    public func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: abs(percentage))
    }

    public func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage))
    }

    public func adjust(by percentage: CGFloat = 30.0) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
          if b < 1.0 {
            let newB: CGFloat = max(min(b + (percentage/100.0)*b, 1.0), 0.0)
            return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
          } else {
            let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
            return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
          }
        }
        
        return self
    }
}
