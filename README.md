# Swift WebVTT

## Overview

**Swift WebVTT** is a parser of [WebVTT](https://en.wikipedia.org/wiki/WebVTT) files that is based on a sample parser in the [specification](https://www.w3.org/TR/webvtt1/#file-parsing).

Originally written as part of [Skipjack](https://skipjack.app).


## Functionality

Functionality is currently limited to extracting a list of cues with their timings and text content. Cue text can be converted to plain-text `String` or rich `NSAttributedString`, and the latter supports text styling such as bold, italics, and underline.
Extracting regions, stylesheets, timestamps in cue content, and language tags is not implemented. 

As part of parsing text content of cues, this project implements a custom parser for HTML Character Entities based on the [HTML 5.1 specification](https://www.w3.org/TR/html51/syntax.html#consume-a-character-reference).

Saving files in WebVTT format and showing cues on screen is considered outside of scope of this project.


## Installation

#### Carthage

Put `github "auramagi/SwiftWebVTT"` in your `Cartfile`.

#### CocoaPods

Put `pod 'SwiftWebVTT'` in your `Podfile`.


## Usage

```swift
// Assuming `fileContents` is a `String` with WebVTT file data
let parser = WebVTTParser(string: fileContents)
let webVTT = try? parser.parse()
// webVTT?.cues holds an array of cues

let text = webVTT?.cues.map({ $0.text }).joined()
// text: String? is all the text in the file

let font = UIFont.preferredFont(forTextStyle: .body)
let attributedText = NSMutableAttributedString(string: "")
webVTT?.cues.map({ $0.attributedText(baseFont: font) }).forEach({ attributedText.append($0) })
// text: NSAttributedString is all the text in the file in rich format
```

#### HTML Character References

The custom parser for HTML Character References can be used separately to decode text with HTML entities. Encoding is not supported.

```swift
let text = "&#x48;&#x65;&#x6C;&#x6C;&#x6F;&comma;&#x20;&#x77;&#x6F;&#x72;&#x6C;&#x64;&excl;&#x20;&#x1F44B;"
print(text.decodingHTMLEntities())
// > "Hello, world! 👋"
```

#### YouTube ASR captions

YouTube serves WebVTT captions, but files created by their automatic speech recognition (ASR) have some quirks.

**Swift WebVTT** has a helper function to de-duplicate and reformat such files. This function can be also used in general to filter out empty cues or empty lines in cues.

See [Deduplication.md](/Deduplication.md) for details.


## Performance

This implementation is reasonably fast and not memory-intensive.
A ~1 MB file with 2h30m worth of captions loads in less than 1 second on an iPhone 7 Plus.


## License

**Swift WebVTT** is available under the MIT license. See the LICENSE file for more info.
