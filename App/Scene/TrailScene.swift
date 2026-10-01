import CoreMotion
import SpriteKit
import UIKit

/// The Trail Cam scene: one world, one camera.
///
/// - Everything on the slope is positioned by trail distance (flights from Base Camp) through `trailPoint(_:)`,
///   anchored at its feet, and lives in `world` (speed 1.0). Nothing on the slope is animated on its own.
/// - Background and foreground layers are children of the camera and offset themselves by camera × speed.
///   Their strips are periodic, so they repeat sideways without visible edges.
/// - Dragging moves the camera along the trail (±`maxScroll` flights with rubber-banding) and springs back to you.
final class TrailScene: SKScene {

    // MARK: Configuration

    /// World points per flight along the trail.
    let stepLength: CGFloat = 22
    /// Slope angle of the trail on screen.
    let slopeAngle: CGFloat = .pi * 0.19
    /// How far you can look up or down the slope, in flights.
    let maxScroll: Double = 40
    /// Seconds after letting go before the camera returns to you.
    let returnDelay: Double = 2

    var onAwayChanged: ((Bool) -> Void)?
    var onClimberTapped: ((String) -> Void)?

    private let mountain: Mountain
    private let palette: ScenePalette

    // MARK: Nodes

    private let cam = SKCameraNode()
    private let world = SKNode()
    private var layers: [ParallaxLayer] = []
    private var skyNode = SKNode()
    private var foreground: ParallaxLayer?
    private var climberNodes: [String: ClimberNode] = [:]

    // MARK: State

    private var climbers: [ClimberState] = []
    private var myFlights: Double = 0
    private var displayFlights: Double = 0
    private var catchUp: (from: Double, to: Double, duration: Double, elapsed: Double)?

    private var scrollOffset: Double = 0
    private var scrollVelocity: Double = 0
    private var isDragging = false
    private var idleTime: Double = 0
    private var lastTouch: CGPoint?
    private var touchTravel: CGFloat = 0
    private var isAway = false

    private var lastUpdate: TimeInterval = 0
    private let motion = CMMotionManager()
    private var tilt = CGVector.zero
    private var built = false

    // MARK: Init

    init(mountain: Mountain, palette: ScenePalette = .goldenHour) {
        self.mountain = mountain
        self.palette = palette
        super.init(size: CGSize(width: 390, height: 844))
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = palette.skyLow
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: Public API

    /// Update climbers. `me` must be one of them (isMe == true).
    func setClimbers(_ newClimbers: [ClimberState]) {
        climbers = newClimbers
        if let me = newClimbers.first(where: \.isMe) {
            myFlights = me.flights
            if catchUp == nil { displayFlights = me.flights }
        }
        guard built else { return }
        syncClimberNodes()
    }

    /// Walk your climber from one position to another (the catch-up climb). Takes 1.2–4 s.
    func playCatchUp(from: Double, to: Double) {
        let duration = min(4, max(1.2, abs(to - from) * 0.06))
        displayFlights = from
        catchUp = (from, to, duration, 0)
        climberNodes["me"]?.setWalking(true)
    }

    /// Jump the camera back to your climber right away.
    func returnToMe() {
        idleTime = returnDelay
    }

    // MARK: Lifecycle

    override func didMove(to view: SKView) {
        if !built {
            build()
            built = true
        }
        startMotion()
    }

    override func willMove(from view: SKView) {
        motion.stopDeviceMotionUpdates()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard built else { return }
        layoutSky()
        foreground?.baseY = -size.height / 2 + 30
    }

    // MARK: Building

    private func build() {
        camera = cam
        addChild(cam)
        addChild(world)

        buildSky()
        buildBackgroundLayers()
        buildGround()
        buildProps()
        buildForeground()
        syncClimberNodes()
    }

    private func buildSky() {
        skyNode.zPosition = -100
        cam.addChild(skyNode)
        layoutSky()
    }

    private func layoutSky() {
        skyNode.removeAllChildren()
        let w = size.width + 200, h = size.height + 200
        let bands: [(UIColor, CGFloat)] = [(palette.skyLow, 0), (palette.skyMid, 0.42), (palette.skyTop, 0.70)]
        for (color, fromFraction) in bands {
            let band = SKSpriteNode(color: color, size: CGSize(width: w, height: h * (1 - fromFraction)))
            band.anchorPoint = CGPoint(x: 0.5, y: 0)
            band.position = CGPoint(x: 0, y: -h / 2 + h * fromFraction)
            skyNode.addChild(band)
        }
        let sunCenter = CGPoint(x: -size.width * 0.22, y: size.height * 0.08)
        for (radius, alpha) in [(130.0, 0.10), (92.0, 0.22), (56.0, 1.0)] {
            let disc = SKShapeNode(circleOfRadius: radius)
            disc.fillColor = palette.sun.withAlphaComponent(alpha)
            disc.strokeColor = .clear
            disc.position = sunCenter
            skyNode.addChild(disc)
        }
    }

    private func buildBackgroundLayers() {
        let tile: CGFloat = 900
        let clouds = ParallaxLayer(parallaxSpeed: 0.05, verticalFactor: 0.4, tiltDepth: 3, tileWidth: tile) { [palette] in
            let node = SKNode()
            for (x, y, s) in [(-320.0, 260.0, 1.2), (-60, 300, 1.0), (180, 220, 0.8), (380, 280, 0.9)] {
                let cloud = SKShapeNode(path: Shapes.cloud())
                cloud.fillColor = palette.cloud
                cloud.strokeColor = .clear
                cloud.position = CGPoint(x: x, y: y)
                cloud.setScale(s)
                node.addChild(cloud)
            }
            return node
        }
        let far = ParallaxLayer(parallaxSpeed: 0.15, verticalFactor: 0.5, tiltDepth: 6, tileWidth: tile) { [palette] in
            Shapes.ridge(width: tile, baseY: 20, waves: [(2, 34), (5, 14), (9, 6)], color: palette.far)
        }
        let mid = ParallaxLayer(parallaxSpeed: 0.35, verticalFactor: 0.7, tiltDepth: 10, tileWidth: tile) { [palette] in
            Shapes.ridge(width: tile, baseY: -70, waves: [(3, 26), (7, 10)], color: palette.mid)
        }
        let near = ParallaxLayer(parallaxSpeed: 0.6, verticalFactor: 0.85, tiltDepth: 16, tileWidth: tile) { [palette] in
            let node = Shapes.ridge(width: tile, baseY: -150, waves: [(4, 16), (11, 5)], color: palette.near)
            var x = -tile / 2
            var rng = SeededRandom(seed: 42)
            while x < tile / 2 {
                let pine = SKShapeNode(path: Shapes.pine())
                pine.fillColor = palette.pine
                pine.strokeColor = .clear
                let y = Shapes.ridgeY(x: x, width: tile, baseY: -150, waves: [(4, 16), (11, 5)])
                pine.position = CGPoint(x: x, y: y - 4)
                pine.setScale(CGFloat.random(in: 0.7...1.15, using: &rng))
                node.addChild(pine)
                x += 34
            }
            return node
        }
        for (index, layer) in [clouds, far, mid, near].enumerated() {
            layer.zPosition = -90 + CGFloat(index)
            cam.addChild(layer)
            layers.append(layer)
        }
        if !UIAccessibility.isReduceMotionEnabled {
            let drift = SKAction.sequence([.moveBy(x: 40, y: 0, duration: 18), .moveBy(x: -40, y: 0, duration: 18)])
            drift.timingMode = .easeInEaseOut
            clouds.children.forEach { $0.run(.repeatForever(drift)) }
        }
    }

    private func buildGround() {
        let sMin = -120.0
        let sMax = Double(mountain.totalFlights) + 120
        let depth: CGFloat = 4000

        let ground = CGMutablePath()
        ground.move(to: trailPoint(sMin))
        stride(from: sMin, through: sMax, by: 1).forEach { ground.addLine(to: trailPoint($0)) }
        let end = trailPoint(sMax), start = trailPoint(sMin)
        ground.addLine(to: CGPoint(x: end.x, y: end.y - depth))
        ground.addLine(to: CGPoint(x: start.x, y: start.y - depth))
        ground.closeSubpath()
        let groundNode = SKShapeNode(path: ground)
        groundNode.fillColor = palette.slope
        groundNode.strokeColor = .clear
        groundNode.zPosition = 0
        world.addChild(groundNode)

        // Light edge along the ridge.
        let rim = CGMutablePath()
        rim.move(to: trailPoint(sMin))
        stride(from: sMin, through: sMax, by: 1).forEach { rim.addLine(to: trailPoint($0)) }
        stride(from: sMax, through: sMin, by: -1).forEach {
            let p = trailPoint($0)
            rim.addLine(to: CGPoint(x: p.x, y: p.y - 18))
        }
        rim.closeSubpath()
        let rimNode = SKShapeNode(path: rim)
        rimNode.fillColor = palette.rim
        rimNode.strokeColor = .clear
        rimNode.zPosition = 1
        world.addChild(rimNode)
    }

    private func buildProps() {
        let total = mountain.totalFlights
        // Filler props: seeded per 10-flight segment, so every racer sees the same mountain.
        for segment in stride(from: -100, through: total + 100, by: 10) {
            var rng = SeededRandom(seed: UInt64(bitPattern: Int64(segment)) &+ 7)
            for _ in 0..<4 {
                let s = Double(segment) + Double.random(in: 0..<10, using: &rng)
                let p = trailPoint(s)
                let rock = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 18...46, using: &rng),
                                                         height: CGFloat.random(in: 7...14, using: &rng)))
                rock.fillColor = palette.rock.withAlphaComponent(0.45)
                rock.strokeColor = .clear
                rock.position = CGPoint(x: p.x + CGFloat.random(in: -40...40, using: &rng),
                                        y: p.y - CGFloat.random(in: 60...520, using: &rng))
                rock.zPosition = 2
                world.addChild(rock)
            }
            if segment % 30 == 0 {
                let post = Shapes.trailPost(flag: palette.flag, wood: palette.wood)
                post.position = trailPoint(Double(segment) + 5)
                post.zPosition = 5
                world.addChild(post)
            }
        }
        // Landmarks: a hut and sign at every camp, a marker at the summit.
        for camp in mountain.camps where camp.id > 0 {
            let s = Double(camp.flightsFromBase)
            if camp.id < mountain.camps.count - 1 {
                let hut = Shapes.hut(palette: palette)
                hut.position = trailPoint(s + 4)
                hut.zPosition = 4
                world.addChild(hut)
            }
            let sign = Shapes.sign(text: camp.name.uppercased(), palette: palette)
            sign.position = trailPoint(s - 1)
            sign.zPosition = 6
            world.addChild(sign)
        }
    }

    private func buildForeground() {
        let fg = ParallaxLayer(parallaxSpeed: 1.4, verticalFactor: 1.0, tiltDepth: 26, tileWidth: 900) { [palette] in
            let node = SKNode()
            var rng = SeededRandom(seed: 99)
            var x: CGFloat = -450
            while x < 450 {
                let tuft = SKShapeNode(path: Bool.random(using: &rng) ? Shapes.grassTuft() : Shapes.rockBump())
                tuft.fillColor = palette.foreground
                tuft.strokeColor = .clear
                tuft.setScale(CGFloat.random(in: 1.0...1.8, using: &rng))
                tuft.position = CGPoint(x: x, y: 0)
                node.addChild(tuft)
                x += CGFloat.random(in: 50...90, using: &rng)
            }
            return node
        }
        fg.zPosition = 50
        fg.baseY = -size.height / 2 + 30
        cam.addChild(fg)
        layers.append(fg)
        foreground = fg
    }

    private func syncClimberNodes() {
        let ids = Set(climbers.map(\.id))
        for (id, node) in climberNodes where !ids.contains(id) {
            node.removeFromParent()
            climberNodes[id] = nil
        }
        for climber in climbers {
            let node: ClimberNode
            if let existing = climberNodes[climber.id] {
                node = existing
            } else {
                node = ClimberNode(id: climber.id, color: climber.color.uiColor, isMe: climber.isMe)
                node.zPosition = climber.isMe ? 21 : 20
                world.addChild(node)
                climberNodes[climber.id] = node
            }
            if climber.isMe {
                let altitude = mountain.altitude(atFlights: climber.flights)
                node.setLabel(title: "You", subtitle: "\(altitude.formatted()) m")
            } else {
                let deltaMeters = Int(((climber.flights - myFlights) * Mountain.metersPerFlight).rounded())
                let subtitle = deltaMeters >= 0 ? "\(deltaMeters.formatted()) m ahead"
                                                : "\(abs(deltaMeters).formatted()) m behind"
                node.setLabel(title: climber.name, subtitle: subtitle)
                node.position = trailPoint(climber.flights)
            }
        }
    }

    // MARK: Trail geometry

    /// World position on the trail at `flights` from Base Camp (the ground under a climber's feet).
    func trailPoint(_ flights: Double) -> CGPoint {
        let distance = CGFloat(flights) * stepLength
        let wobble = CGFloat(sin(flights * 0.11)) * 6
        return CGPoint(x: distance * cos(slopeAngle), y: distance * sin(slopeAngle) + wobble)
    }

    /// The climber sits a little below the screen centre.
    private func cameraPoint(_ flights: Double) -> CGPoint {
        let p = trailPoint(flights)
        return CGPoint(x: p.x, y: p.y + size.height * 0.06)
    }

    // MARK: Frame update

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdate == 0 ? 1.0 / 60 : min(1.0 / 20, currentTime - lastUpdate)
        lastUpdate = currentTime

        advanceCatchUp(dt)
        advanceScroll(dt)
        readTilt()

        let shown = rubberBand(scrollOffset)
        let rest = cameraPoint(displayFlights)
        let focus = cameraPoint(displayFlights + shown)
        cam.position = focus
        climberNodes["me"]?.position = trailPoint(displayFlights)

        for layer in layers {
            layer.follow(cameraX: focus.x, deltaY: focus.y - rest.y, tilt: tilt)
        }

        let away = abs(shown) > 2.5
        if away != isAway {
            isAway = away
            onAwayChanged?(away)
        }
    }

    private func advanceCatchUp(_ dt: Double) {
        guard var anim = catchUp else { return }
        anim.elapsed += dt
        let t = min(1, anim.elapsed / anim.duration)
        let eased = t * t * (3 - 2 * t)
        displayFlights = anim.from + (anim.to - anim.from) * eased
        if t >= 1 {
            catchUp = nil
            displayFlights = anim.to
            climberNodes["me"]?.setWalking(false)
        } else {
            catchUp = anim
        }
    }

    private func advanceScroll(_ dt: Double) {
        guard !isDragging else { return }
        idleTime += dt
        guard idleTime >= returnDelay, scrollOffset != 0 || scrollVelocity != 0 else { return }
        // Critically damped spring back to you.
        let k = 90.0
        let c = 2 * k.squareRoot() * 0.95
        scrollVelocity += (-k * scrollOffset - c * scrollVelocity) * dt
        scrollOffset += scrollVelocity * dt
        if abs(scrollOffset) < 0.01 && abs(scrollVelocity) < 0.05 {
            scrollOffset = 0
            scrollVelocity = 0
        }
    }

    private func rubberBand(_ offset: Double) -> Double {
        let limit = maxScroll
        guard abs(offset) > limit else { return offset }
        let excess = abs(offset) - limit
        let resisted = limit + (1 - 1 / (excess * 0.08 + 1)) / 0.08 * 0.55
        return offset < 0 ? -resisted : resisted
    }

    // MARK: Touch: drag along the trail

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard catchUp == nil, let touch = touches.first, let view else {
            // A touch during the replay skips it to the end.
            if let anim = catchUp { catchUp = (anim.from, anim.to, anim.duration, anim.duration) }
            return
        }
        isDragging = true
        idleTime = 0
        scrollVelocity = 0
        lastTouch = touch.location(in: view)
        touchTravel = 0
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let touch = touches.first, let view, let last = lastTouch else { return }
        let point = touch.location(in: view)
        let dx = point.x - last.x
        let dyUp = -(point.y - last.y)
        lastTouch = point
        touchTravel += hypot(dx, dyUp)
        // Content follows the finger, so the camera moves the opposite way along the trail.
        let alongTrail = dx * cos(slopeAngle) + dyUp * sin(slopeAngle)
        scrollOffset -= Double(alongTrail / stepLength)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer { endDrag() }
        guard touchTravel < 8, let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let hit = nodes(at: location).compactMap({ $0.firstAncestor(of: ClimberNode.self) }).first {
            if hit.climberId == "me" {
                returnToMe()
            } else {
                onClimberTapped?(hit.climberId)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endDrag()
    }

    private func endDrag() {
        isDragging = false
        idleTime = 0
        // Keep what the user sees: store the rubber-banded value.
        scrollOffset = rubberBand(scrollOffset)
        lastTouch = nil
    }

    // MARK: Device tilt

    private func startMotion() {
        guard !UIAccessibility.isReduceMotionEnabled, motion.isDeviceMotionAvailable, !motion.isDeviceMotionActive else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 30
        motion.startDeviceMotionUpdates()
    }

    private func readTilt() {
        guard let attitude = motion.deviceMotion?.attitude else { return }
        let target = CGVector(dx: CGFloat(attitude.roll).clamped(to: -0.5...0.5),
                              dy: CGFloat(attitude.pitch - 0.7).clamped(to: -0.5...0.5))
        tilt.dx += (target.dx - tilt.dx) * 0.08
        tilt.dy += (target.dy - tilt.dy) * 0.08
    }
}

// MARK: - Parallax layer

/// A camera-attached layer whose content repeats every `tileWidth` points.
final class ParallaxLayer: SKNode {
    let parallaxSpeed: CGFloat
    let verticalFactor: CGFloat
    let tiltDepth: CGFloat
    let tileWidth: CGFloat
    var baseY: CGFloat = 0

    init(parallaxSpeed: CGFloat, verticalFactor: CGFloat, tiltDepth: CGFloat, tileWidth: CGFloat,
         makeTile: () -> SKNode) {
        self.parallaxSpeed = parallaxSpeed
        self.verticalFactor = verticalFactor
        self.tiltDepth = tiltDepth
        self.tileWidth = tileWidth
        super.init()
        for i in -1...1 {
            let tile = makeTile()
            tile.position.x = CGFloat(i) * tileWidth
            addChild(tile)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    /// `cameraX`: absolute camera x (drives the endless sideways scroll).
    /// `deltaY`: how far the camera is above its resting point (only scrolling moves layers vertically).
    func follow(cameraX: CGFloat, deltaY: CGFloat, tilt: CGVector) {
        // Camera children stay put on screen; shifting by -speed × camera movement makes the layer
        // move at `parallaxSpeed` relative to the world (0 = fixed sky, 1 = slope, >1 = foreground).
        let x = -(cameraX * parallaxSpeed).truncatingRemainder(dividingBy: tileWidth)
        let y = baseY - deltaY * parallaxSpeed * verticalFactor
        position = CGPoint(x: x + tilt.dx * tiltDepth, y: y + tilt.dy * tiltDepth)
    }
}

// MARK: - Climber

final class ClimberNode: SKNode {
    let climberId: String
    private let figure = SKNode()
    private let label = SKLabelNode()
    private let labelBackground = SKShapeNode()
    private let isMe: Bool

    init(id: String, color: UIColor, isMe: Bool) {
        self.climberId = id
        self.isMe = isMe
        super.init()
        let s: CGFloat = isMe ? 1.3 : 1.0

        if isMe {
            let ring = SKShapeNode(ellipseOf: CGSize(width: 44 * s, height: 12 * s))
            ring.fillColor = UIColor(hex: 0xF2B33D, alpha: 0.9)
            ring.strokeColor = .clear
            addChild(ring)
        }
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 28 * s, height: 7 * s))
        shadow.fillColor = UIColor.black.withAlphaComponent(0.25)
        shadow.strokeColor = .clear
        addChild(shadow)

        // Placeholder "Noodle" figure built from parts, feet at y = 0.
        let legs = CGMutablePath()
        legs.move(to: CGPoint(x: -6 * s, y: 2 * s)); legs.addLine(to: CGPoint(x: -4 * s, y: 20 * s))
        legs.move(to: CGPoint(x: 6 * s, y: 2 * s)); legs.addLine(to: CGPoint(x: 4 * s, y: 20 * s))
        let legsNode = SKShapeNode(path: legs)
        legsNode.strokeColor = color
        legsNode.lineWidth = 7 * s
        legsNode.lineCap = .round
        figure.addChild(legsNode)

        let body = SKShapeNode(rect: CGRect(x: -9 * s, y: 16 * s, width: 18 * s, height: 28 * s), cornerRadius: 9 * s)
        body.fillColor = color
        body.strokeColor = .clear
        figure.addChild(body)

        let head = SKShapeNode(circleOfRadius: 11 * s)
        head.fillColor = color
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: 54 * s)
        figure.addChild(head)
        for dx in [-3.0, 4.0] {
            let eye = SKShapeNode(ellipseOf: CGSize(width: 3.2 * s, height: 4.8 * s))
            eye.fillColor = UIColor(hex: 0x1A1A1A)
            eye.strokeColor = .clear
            eye.position = CGPoint(x: dx * s, y: 55 * s)
            figure.addChild(eye)
        }
        addChild(figure)

        labelBackground.strokeColor = .clear
        labelBackground.fillColor = isMe ? UIColor(hex: 0x121A28) : UIColor.white.withAlphaComponent(0.85)
        addChild(labelBackground)
        label.numberOfLines = 2
        label.preferredMaxLayoutWidth = 220
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        labelBackground.addChild(label)

        if !UIAccessibility.isReduceMotionEnabled {
            let bob = SKAction.sequence([.moveBy(x: 0, y: 2, duration: 1.2), .moveBy(x: 0, y: -2, duration: 1.2)])
            bob.timingMode = .easeInEaseOut
            figure.run(.repeatForever(bob), withKey: "idle")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func setLabel(title: String, subtitle: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let text = NSMutableAttributedString(string: title, attributes: [
            .font: UIFont.rounded(13, .bold),
            .foregroundColor: isMe ? UIColor.white : UIColor(hex: 0x121A28),
            .paragraphStyle: paragraph,
        ])
        text.append(NSAttributedString(string: "\n" + subtitle, attributes: [
            .font: UIFont.rounded(11, .semibold),
            .foregroundColor: isMe ? UIColor(hex: 0xC9D0DB) : UIColor(hex: 0x566174),
            .paragraphStyle: paragraph,
        ]))
        label.attributedText = text
        let frame = label.calculateAccumulatedFrame()
        let size = CGSize(width: frame.width + 20, height: frame.height + 12)
        labelBackground.path = CGPath(roundedRect: CGRect(x: -size.width / 2, y: -size.height, width: size.width, height: size.height),
                                      cornerWidth: 12, cornerHeight: 12, transform: nil)
        labelBackground.position = CGPoint(x: 0, y: -12)
        label.position = CGPoint(x: 0, y: -6)
    }

    func setWalking(_ walking: Bool) {
        if walking {
            let step = SKAction.sequence([.rotate(toAngle: 0.08, duration: 0.18), .rotate(toAngle: -0.08, duration: 0.18)])
            figure.run(.repeatForever(step), withKey: "walk")
        } else {
            figure.removeAction(forKey: "walk")
            figure.run(.rotate(toAngle: 0, duration: 0.15))
        }
    }
}

// MARK: - Helpers

extension SKNode {
    func firstAncestor<T: SKNode>(of type: T.Type) -> T? {
        var node: SKNode? = self
        while let current = node {
            if let match = current as? T { return match }
            node = current.parent
        }
        return nil
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

/// SplitMix64: small, fast and the same on every device, so seeded props match for all racers.
struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
