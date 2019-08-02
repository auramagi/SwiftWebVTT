# Swift WebVTT

## Overview

**Swift WebVTT** is a parser of [WebVTT](https://en.wikipedia.org/wiki/WebVTT) files that is based on a sample parser in the [specification](https://www.w3.org/TR/webvtt1/#file-parsing).

Originally written as part of [Skipjack](https://skipjack.app).


## Functionality

Functionality is currently limited to extracting a list of cues with their timings and text content. Extracting regions, stylesheets etc. is not implemented. Text styling such as bold, italics, ruby etc. is also not implemented.

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
```

#### Making automatically-generated WebVTT from YouTube readable

YouTube has a different native format (SRV3) for captions, but their servers are able to convert to several different formats including WebVTT. However, for their ASR (automatic speech recognition) captions, YouTube bakes in a certain presentation that effectively duplicates cues.

This doesn't have a negative effect when presenting caption-by-caption, but makes content unreadable when extracting all text or just presenting all captions at once.

**Swift WebVTT** has a helper function to de-duplicate and reformat such files.

```swift
// var webVTT: WebVTT // A parsed file
let filteredCues = WebVTTParser.deduplicateCues(webVTT.cues)
webVTT = WebVTT(cues: filteredCues)
```

#### HTML Character References

The custom parser for HTML Character References can also be used standalone to decode text with HTML entities.

```swift
let text = "&#x48;&#x65;&#x6C;&#x6C;&#x6F;&comma;&#x20;&#x77;&#x6F;&#x72;&#x6C;&#x64;&excl;&#x20;&#x1F44B;"
print(text.decodingHTMLEntities())
// > "Hello, world! 👋"
```


## Performance

This implementation is reasonably fast and not memory-intensive.
A ~1 MB file with 2h30m worth of captions loads in less than 1 second on an iPhone 7 Plus.


## License

**Swift WebVTT** is available under the MIT license. See the LICENSE file for more info.
