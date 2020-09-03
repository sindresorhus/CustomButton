import Cocoa

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!

	func applicationDidFinishLaunching(_ notification: Notification) {
		let button = CustomButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.title = "CustomButton"
		button.activeBackgroundColor = .systemPink
		button.borderWidth = 1
		button.borderColor = .systemPink
		button.cornerRadius = 5
		button.textColor = .systemPink
		button.activeTextColor = .white

		let contentView = window.contentView!
		contentView.addSubview(button)

		NSLayoutConstraint.activate([
			button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			button.widthAnchor.constraint(equalToConstant: 100),
			button.heightAnchor.constraint(equalToConstant: 30)
		])
	}
}
