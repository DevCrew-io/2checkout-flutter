//
//  SpinnerView.swift
//  Verifone2CO
//

import UIKit

class SpinnerView: UIView {
    // MARK: - PROPERTIES

    private let colors = [
        UIColor(hex: "#00adef"),
        UIColor(hex: "#00aeef"),
        UIColor(hex: "#0181bd"),
        UIColor(hex: "#8e969f")
    ]

    private let timeCount = 4

    override var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayers()
    }

    override func didMoveToWindow() {
        animate()
    }

    private func configureLayers() {
        layer.fillColor = nil
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 3
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
    }

    private struct Position {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }

    class final private var positions: [Position] {
        get {
            return [
                Position(0.0, 0.000, 0.7),
                Position(0.6, 0.500, 0.5),
                Position(0.6, 1.000, 0.3),
                Position(0.6, 1.500, 0.1),
                Position(0.2, 1.875, 0.1),
                Position(0.2, 2.250, 0.3),
                Position(0.2, 2.625, 0.5),
                Position(0.2, 3.000, 0.7)
            ]
        }
    }

    private func animate() {
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()

        let positions = type(of: self).positions
        let totalSeconds = positions.reduce(0) { $0 + $1.secondsSincePriorPose }

        for position in positions {
            time += position.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = position.start
            rotations.append(start * 2 * .pi)
            strokeEnds.append(position.length)
        }

        times.append(times.last!)
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])
        animateKeyPath(
            keyPath: "strokeEnd",
            duration: totalSeconds,
            times: times,
            values: strokeEnds)
        animateKeyPath(
            keyPath: "transform.rotation",
            duration: totalSeconds,
            times: times,
            values: rotations)
        animateStrokeHueWithDuration(duration: totalSeconds * 5)
    }

    private func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = .linear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }

    private func animateStrokeHueWithDuration(duration: CFTimeInterval) {
        let animation = CAKeyframeAnimation(keyPath: "strokeColor")
        animation.keyTimes = (0...timeCount).map {
            NSNumber(value: CFTimeInterval($0) / CFTimeInterval(timeCount))
        }
        animation.values = (0..<colors.count).map { colors[$0].cgColor }
        animation.duration = duration
        animation.calculationMode = .linear
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
}
