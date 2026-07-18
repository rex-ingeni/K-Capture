import AppKit

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "docs/assets")
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

enum IconSource {
    case system(String)
    case textTool
}

let icons: [(String, IconSource)] = [
    ("capture-macos", .system("camera.viewfinder")),
    ("pencil-macos", .system("pencil")),
    ("copy-macos", .system("doc.on.doc")),
    ("floating-macos", .system("macwindow")),
    ("ocr-macos", .system("text.viewfinder")),
    ("lasso-macos", .system("lasso")),
    ("subject-macos", .system("sparkles")),
    ("blur-macos", .system("drop")),
    ("mosaic-macos", .system("rectangle.checkered")),
    ("favorite-macos", .system("star")),
    ("update-macos", .system("arrow.down.to.line")),
    ("move-macos", .system("arrow.up.and.down.and.arrow.left.and.right")),
    ("highlighter-macos", .system("highlighter")),
    ("save-macos", .system("square.and.arrow.down")),
    ("rectangle-macos", .system("rectangle")),
    ("arrow-macos", .system("arrow.up.right")),
    ("text-macos", .textTool),
    ("checkmark-macos", .system("checkmark")),
]

let size = 256
let tint = NSColor(red: 0.482, green: 0.902, blue: 0.847, alpha: 1)

func sourceImage(for source: IconSource) -> NSImage {
    switch source {
    case .system(let symbolName):
        guard let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 220, weight: .regular)) else {
            fatalError("Could not load macOS symbol: \(symbolName)")
        }
        return symbol
    case .textTool:
        // The app draws its text tool as a Latin T so it stays unambiguous in Korean.
        return NSImage(size: NSSize(width: size, height: size), flipped: false) { _ in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 196, weight: .bold),
                .foregroundColor: NSColor.black,
            ]
            let text = "T" as NSString
            let textSize = text.size(withAttributes: attributes)
            text.draw(
                at: NSPoint(x: (CGFloat(size) - textSize.width) / 2, y: (CGFloat(size) - textSize.height) / 2),
                withAttributes: attributes
            )
            return true
        }
    }
}

for (filename, source) in icons {
    let symbol = sourceImage(for: source)

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
        fatalError("Could not encode \(filename) as PNG")
    }
    try data.write(to: outputDirectory.appendingPathComponent("\(filename).png"))
}
