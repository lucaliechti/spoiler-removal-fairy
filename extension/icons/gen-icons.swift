// Renders the Apple Color Emoji "fairy" (🧚, red-haired in Apple's art) to a PNG
// master. Run on macOS:  swift gen-icons.swift   then downscale with ImageMagick.
import AppKit

let emoji = "🧚🏻‍♀️"  // woman fairy, light skin tone — Apple renders her with red/auburn hair
let canvas: CGFloat = 320
let fontSize: CGFloat = 256

let font = NSFont(name: "Apple Color Emoji", size: fontSize)
  ?? NSFont.systemFont(ofSize: fontSize)
let para = NSMutableParagraphStyle()
para.alignment = .center
let attrs: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: para]
let str = NSAttributedString(string: emoji, attributes: attrs)

let img = NSImage(size: NSSize(width: canvas, height: canvas))
img.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .high
let bounds = str.boundingRect(
  with: NSSize(width: canvas, height: canvas),
  options: [.usesLineFragmentOrigin]
)
let rect = NSRect(
  x: (canvas - bounds.width) / 2,
  y: (canvas - bounds.height) / 2,
  width: bounds.width,
  height: bounds.height
)
str.draw(with: rect, options: [.usesLineFragmentOrigin])
img.unlockFocus()

guard let tiff = img.tiffRepresentation,
  let rep = NSBitmapImageRep(data: tiff),
  let png = rep.representation(using: .png, properties: [:])
else { fatalError("png encode failed") }
try! png.write(to: URL(fileURLWithPath: "icon-master.png"))
print("wrote icon-master.png")
