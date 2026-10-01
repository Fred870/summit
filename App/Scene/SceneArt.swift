import SpriteKit
import UIKit

/// Scene colours per time of day. Golden hour first; the other skies (design/design.md, 5.x boards) follow.
/// Placeholder art is drawn in code until the real layer assets exist.
struct ScenePalette {
    let skyTop, skyMid, skyLow, sun, cloud: UIColor
    let far, mid, near, pine: UIColor
    let slope, rim, rock, foreground: UIColor
    let flag, wood, hutWall, hutRoof, window, signBoard: UIColor

    static let goldenHour = ScenePalette(
        skyTop: UIColor(hex: 0xE0673A), skyMid: UIColor(hex: 0xF29A48), skyLow: UIColor(hex: 0xFBD27A),
        sun: UIColor(hex: 0xFFF1C2), cloud: UIColor(hex: 0xFFD9A8),
        far: UIColor(hex: 0xEDB389), mid: UIColor(hex: 0xD48A62), near: UIColor(hex: 0xA85C40), pine: UIColor(hex: 0x8A4632),
        slope: UIColor(hex: 0x7E3B2E), rim: UIColor(hex: 0xA9533B), rock: UIColor(hex: 0x5C2A22), foreground: UIColor(hex: 0x3E1A12),
        flag: UIColor(hex: 0xFFF1C2), wood: UIColor(hex: 0x3A1E14), hutWall: UIColor(hex: 0x5C2A22), hutRoof: UIColor(hex: 0x3A1E14),
        window: UIColor(hex: 0xFFD27A), signBoard: UIColor(hex: 0xF2E3C8))
}

enum Shapes {
    /// Rounded cloud, base on y = 0.
    static func cloud() -> CGPath {
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: 0, y: 0, width: 36, height: 30))
        path.addEllipse(in: CGRect(x: 18, y: 4, width: 46, height: 40))
        path.addEllipse(in: CGRect(x: 50, y: 0, width: 34, height: 28))
        path.addRoundedRect(in: CGRect(x: 6, y: 0, width: 72, height: 18), cornerWidth: 9, cornerHeight: 9)
        return path
    }

    /// y of a periodic ridge line. `waves` are (cycles per tile, amplitude); whole cycles make tiles seamless.
    static func ridgeY(x: CGFloat, width: CGFloat, baseY: CGFloat, waves: [(Int, CGFloat)]) -> CGFloat {
        var y = baseY
        for (index, wave) in waves.enumerated() {
            let phase = CGFloat(index) * 1.7
            y += wave.1 * sin(2 * .pi * CGFloat(wave.0) * x / width + phase)
        }
        return y
    }

    static func ridge(width: CGFloat, baseY: CGFloat, waves: [(Int, CGFloat)], color: UIColor) -> SKShapeNode {
        let path = CGMutablePath()
        let left = -width / 2, right = width / 2, bottom: CGFloat = -2000
        path.move(to: CGPoint(x: left, y: bottom))
        var x = left
        while x <= right {
            path.addLine(to: CGPoint(x: x, y: ridgeY(x: x, width: width, baseY: baseY, waves: waves)))
            x += 6
        }
        path.addLine(to: CGPoint(x: right, y: ridgeY(x: right, width: width, baseY: baseY, waves: waves)))
        path.addLine(to: CGPoint(x: right, y: bottom))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor = color
        node.strokeColor = .clear
        return node
    }

    /// Simple pine, base at y = 0.
    static func pine() -> CGPath {
        let path = CGMutablePath()
        path.addLines(between: [
            CGPoint(x: 0, y: 44), CGPoint(x: 14, y: 22), CGPoint(x: 8, y: 22), CGPoint(x: 18, y: 6),
            CGPoint(x: -18, y: 6), CGPoint(x: -8, y: 22), CGPoint(x: -14, y: 22),
        ])
        path.closeSubpath()
        path.addRect(CGRect(x: -3, y: 0, width: 6, height: 7))
        return path
    }

    static func grassTuft() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -16, y: 0))
        path.addQuadCurve(to: CGPoint(x: -8, y: 34), control: CGPoint(x: -14, y: 26))
        path.addQuadCurve(to: CGPoint(x: -2, y: 4), control: CGPoint(x: -6, y: 14))
        path.addQuadCurve(to: CGPoint(x: 4, y: 42), control: CGPoint(x: 0, y: 30))
        path.addQuadCurve(to: CGPoint(x: 8, y: 6), control: CGPoint(x: 6, y: 16))
        path.addQuadCurve(to: CGPoint(x: 18, y: 30), control: CGPoint(x: 12, y: 28))
        path.addQuadCurve(to: CGPoint(x: 16, y: 0), control: CGPoint(x: 14, y: 10))
        path.closeSubpath()
        return path
    }

    static func rockBump() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -20, y: -4))
        path.addQuadCurve(to: CGPoint(x: 0, y: 16), control: CGPoint(x: -18, y: 14))
        path.addQuadCurve(to: CGPoint(x: 20, y: -4), control: CGPoint(x: 18, y: 14))
        path.closeSubpath()
        return path
    }

    /// Wooden trail post with a small flag, base at y = 0.
    static func trailPost(flag: UIColor, wood: UIColor) -> SKNode {
        let node = SKNode()
        let pole = SKShapeNode(rect: CGRect(x: -2, y: -2, width: 4, height: 34), cornerRadius: 1.5)
        pole.fillColor = wood
        pole.strokeColor = .clear
        node.addChild(pole)
        let pennant = CGMutablePath()
        pennant.addLines(between: [CGPoint(x: 2, y: 30), CGPoint(x: 18, y: 25), CGPoint(x: 2, y: 20)])
        pennant.closeSubpath()
        let flagNode = SKShapeNode(path: pennant)
        flagNode.fillColor = flag
        flagNode.strokeColor = .clear
        node.addChild(flagNode)
        if !UIAccessibility.isReduceMotionEnabled {
            let flutter = SKAction.sequence([.scaleX(to: 0.85, duration: 0.5), .scaleX(to: 1, duration: 0.5)])
            flagNode.run(.repeatForever(flutter))
        }
        return node
    }

    /// Mountain hut with lit windows and chimney smoke, base at y = 0.
    static func hut(palette: ScenePalette) -> SKNode {
        let node = SKNode()
        let wall = SKShapeNode(rect: CGRect(x: -34, y: 0, width: 68, height: 36), cornerRadius: 4)
        wall.fillColor = palette.hutWall
        wall.strokeColor = .clear
        node.addChild(wall)
        let roof = CGMutablePath()
        roof.addLines(between: [CGPoint(x: -42, y: 34), CGPoint(x: 0, y: 62), CGPoint(x: 42, y: 34)])
        roof.closeSubpath()
        let roofNode = SKShapeNode(path: roof)
        roofNode.fillColor = palette.hutRoof
        roofNode.strokeColor = .clear
        node.addChild(roofNode)
        for x in [-22.0, 8.0] {
            let window = SKShapeNode(rect: CGRect(x: x, y: 14, width: 14, height: 12), cornerRadius: 2)
            window.fillColor = palette.window
            window.strokeColor = .clear
            node.addChild(window)
        }
        let chimney = SKShapeNode(rect: CGRect(x: 18, y: 50, width: 8, height: 18))
        chimney.fillColor = palette.hutRoof
        chimney.strokeColor = .clear
        node.addChild(chimney)
        if !UIAccessibility.isReduceMotionEnabled {
            let puff = SKAction.run { [weak node] in
                guard let node else { return }
                let smoke = SKShapeNode(circleOfRadius: 6)
                smoke.fillColor = UIColor.white.withAlphaComponent(0.55)
                smoke.strokeColor = .clear
                smoke.position = CGPoint(x: 22, y: 72)
                node.addChild(smoke)
                smoke.run(.sequence([
                    .group([.moveBy(x: 10, y: 36, duration: 3), .scale(to: 2.2, duration: 3), .fadeOut(withDuration: 3)]),
                    .removeFromParent(),
                ]))
            }
            node.run(.repeatForever(.sequence([puff, .wait(forDuration: 1.1)])))
        }
        return node
    }

    /// Camp sign board on a post, base at y = 0.
    static func sign(text: String, palette: ScenePalette) -> SKNode {
        let node = SKNode()
        let post = SKShapeNode(rect: CGRect(x: -2, y: 0, width: 4, height: 42))
        post.fillColor = palette.wood
        post.strokeColor = .clear
        node.addChild(post)
        let board = SKShapeNode(rect: CGRect(x: -32, y: 30, width: 64, height: 20), cornerRadius: 4)
        board.fillColor = palette.signBoard
        board.strokeColor = .clear
        node.addChild(board)
        let label = SKLabelNode()
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: UIFont.rounded(11, .heavy),
            .foregroundColor: palette.wood,
        ])
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 40)
        node.addChild(label)
        return node
    }
}
