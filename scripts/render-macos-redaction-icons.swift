import AppKit

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "docs/assets")
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let icons = [
    ("blur-macos", "drop"),
    ("mosaic-macos", "rectangle.checkered"),
]

let size = 256
let tint = NSColor(red: 0.482, green: 0.902, blue: 0.847, alpha: 1)

for (filename, symbolName) in icons {
    guard let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
        .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 220, weight: .regular)) else {
        fatalError("Could not load macOS symbol: \(symbolName)")
    }

    let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { _ in
        let rect = NSRect(x: 18, y: 18, width: size - 36, height: size - 36)
        symbol.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
        NSGraphicsContext.current?.compositingOperation = .sourceAtop
        tint.setFill()
        NSBezierPath(rect: rect).fill()
        return true
    }

    guard let tiff = image.tiffRepresentation,
          let rendered = NSBitmapImageRep(data: tiff),
          let data = rendered.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
        fatalError("Could not encode \(symbolName) as PNG")
    }
    try data.write(to: outputDirectory.appendingPathComponent("\(filename).png"))
}
