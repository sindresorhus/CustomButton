import Cocoa

@IBDesignable
open class CustomButton: NSButton {
	private let titleLayer = CATextLayer()
	private var isMouseDown = false

	public static func circularButton(title: String, radius: Double, center: CGPoint) -> CustomButton {
		with(CustomButton()) {
			$0.title = title
			$0.frame = CGRect(x: Double(center.x) - radius, y: Double(center.y) - radius, width: radius * 2, height: radius * 2)
			$0.cornerRadius = radius
			$0.font = NSFont.systemFont(ofSize: CGFloat(radius * 2 / 3))
		}
	}

	override open var wantsUpdateLayer: Bool { true }

	@IBInspectable override public var title: String {
		didSet {
			setTitle()
		}
	}

	@IBInspectable public var textColor: NSColor = .labelColor {
		didSet {
			titleLayer.foregroundColor = textColor.cgColor
		}
	}

	@IBInspectable public var activeTextColor: NSColor = .labelColor {
		didSet {
			if state == .on {
				titleLayer.foregroundColor = textColor.cgColor
			}
		}
	}

	@IBInspectable public var cornerRadius: Double = 0 {
		didSet {
			layer?.cornerRadius = CGFloat(cornerRadius)
		}
	}

	@IBInspectable public var borderWidth: Double = 0 {
		didSet {
			layer?.borderWidth = CGFloat(borderWidth)
		}
	}

	@IBInspectable public var borderColor: NSColor = .clear {
		didSet {
			layer?.borderColor = borderColor.cgColor
		}
	}

	@IBInspectable public var activeBorderColor: NSColor = .clear {
		didSet {
			if state == .on {
				layer?.borderColor = activeBorderColor.cgColor
			}
		}
	}

	@IBInspectable public var backgroundColor: NSColor = .clear {
		didSet {
			layer?.backgroundColor = backgroundColor.cgColor
		}
	}

	@IBInspectable public var activeBackgroundColor: NSColor = .clear {
		didSet {
			if state == .on {
				layer?.backgroundColor = activeBackgroundColor.cgColor
			}
		}
	}

	@IBInspectable public var shadowRadius: Double = 0 {
		didSet {
			layer?.shadowRadius = CGFloat(shadowRadius)
		}
	}

	@IBInspectable public var activeShadowRadius: Double = -1 {
		didSet {
			if state == .on {
				layer?.shadowRadius = CGFloat(activeShadowRadius)
			}
		}
	}

	@IBInspectable public var shadowOpacity: Double = 0 {
		didSet {
			layer?.shadowOpacity = Float(shadowOpacity)
		}
	}

	@IBInspectable public var activeShadowOpacity: Double = -1 {
		didSet {
			if state == .on {
				layer?.shadowOpacity = Float(activeShadowOpacity)
			}
		}
	}

	@IBInspectable public var shadowColor: NSColor = .clear {
		didSet {
			layer?.shadowColor = shadowColor.cgColor
		}
	}

	@IBInspectable public var activeShadowColor: NSColor? {
		didSet {
			if state == .on, let activeShadowColor = activeShadowColor {
				layer?.shadowColor = activeShadowColor.cgColor
			}
		}
	}

	override public var font: NSFont? {
		didSet {
			setTitle()
		}
	}

	override public var isEnabled: Bool {
		didSet {
			alphaValue = isEnabled ? 1 : 0.6
		}
	}

	public convenience init() {
		self.init(frame: .zero)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	// Ensure the button doesn't draw its default contents.
	override open func draw(_ dirtyRect: CGRect) {}
	override open func drawFocusRingMask() {}

	override open func layout() {
		super.layout()
		positionTitle()
	}

	override open func viewDidChangeBackingProperties() {
		super.viewDidChangeBackingProperties()

		if let scale = window?.backingScaleFactor {
			layer?.contentsScale = scale
			titleLayer.contentsScale = scale
		}
	}

	private lazy var trackingArea = TrackingArea(
		for: self,
		options: [
			.mouseEnteredAndExited,
			.activeInActiveApp
		]
	)

	override open func updateTrackingAreas() {
		super.updateTrackingAreas()
		trackingArea.update()
	}

	private func setup() {
		let isOn = state == .on

		wantsLayer = true

		layer?.masksToBounds = false

		layer?.cornerRadius = CGFloat(cornerRadius)
		layer?.borderWidth = CGFloat(borderWidth)
		layer?.shadowRadius = CGFloat(isOn && activeShadowRadius != -1 ? activeShadowRadius : shadowRadius)
		layer?.shadowOpacity = Float(isOn && activeShadowOpacity != -1 ? activeShadowOpacity : shadowOpacity)
		layer?.backgroundColor = isOn ? self.activeBackgroundColor.cgColor : self.backgroundColor.cgColor
		layer?.borderColor = isOn ? self.activeBorderColor.cgColor : self.borderColor.cgColor
		layer?.shadowColor = isOn ? (self.activeShadowColor?.cgColor ?? self.shadowColor.cgColor) : self.shadowColor.cgColor

		titleLayer.alignmentMode = .center
		titleLayer.contentsScale = window?.backingScaleFactor ?? 2
		titleLayer.foregroundColor = isOn ? self.activeTextColor.cgColor : self.textColor.cgColor
		layer?.addSublayer(titleLayer)
		setTitle()

		needsDisplay = true
	}

	public typealias ColorGenerator = () -> NSColor

	private var colorGenerators = [KeyPath<CustomButton, NSColor>: ColorGenerator]()

	/// Gets or sets the color generation closure for the provided key path.
	///
	/// - Parameter keyPath: The key path that specifies the color related property.
	public subscript(colorGenerator keyPath: KeyPath<CustomButton, NSColor>) -> ColorGenerator? {
		get { colorGenerators[keyPath] }
		set {
			colorGenerators[keyPath] = newValue
		}
	}

	private func color(for keyPath: KeyPath<CustomButton, NSColor>) -> NSColor {
		colorGenerators[keyPath]?() ?? self[keyPath: keyPath]
	}

	override open func updateLayer() {
		animateColor()
	}

	private func setTitle() {
		titleLayer.string = title

		if let font = font {
			titleLayer.font = font
			titleLayer.fontSize = font.pointSize
		}

		needsLayout = true
	}

	private func positionTitle() {
		let titleSize = title.size(withAttributes: [.font: font as Any])
		titleLayer.frame = titleSize.centered(in: bounds).roundedOrigin()
	}

	private func animateColor() {
		let isOn = state == .on
		let duration = isOn ? 0.2 : 0.1
		let backgroundColor = isOn ? color(for: \.activeBackgroundColor) : color(for: \.backgroundColor)
		let textColor = isOn ? color(for: \.activeTextColor) : color(for: \.textColor)
		let borderColor = isOn ? color(for: \.activeBorderColor) : color(for: \.borderColor)
		let shadowColor = isOn ? (activeShadowColor ?? color(for: \.shadowColor)) : color(for: \.shadowColor)

		layer?.animate(color: backgroundColor.cgColor, keyPath: #keyPath(CALayer.backgroundColor), duration: duration)
		layer?.animate(color: borderColor.cgColor, keyPath: #keyPath(CALayer.borderColor), duration: duration)
		layer?.animate(color: shadowColor.cgColor, keyPath: #keyPath(CALayer.shadowColor), duration: duration)
		titleLayer.animate(color: textColor.cgColor, keyPath: #keyPath(CATextLayer.foregroundColor), duration: duration)
	}

	private func toggleState() {
		state = state == .off ? .on : .off
		animateColor()
	}

	override open func hitTest(_ point: CGPoint) -> NSView? {
		isEnabled ? super.hitTest(point) : nil
	}

	override open func mouseDown(with event: NSEvent) {
		isMouseDown = true
		toggleState()
	}

	override open func mouseEntered(with event: NSEvent) {
		if isMouseDown {
			toggleState()
		}
	}

	override open func mouseExited(with event: NSEvent) {
		if isMouseDown {
			toggleState()
			isMouseDown = false
		}
	}

	override open func mouseUp(with event: NSEvent) {
		if isMouseDown {
			isMouseDown = false
			toggleState()
			_ = target?.perform(action, with: self)
		}
	}
}

extension CustomButton: NSViewLayerContentScaleDelegate {
	public func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool { true }
}
