#  Deduplicating cues

## Why?

YouTube uses a different native format (SRV3) for captions, but their servers are able to convert to several different formats including WebVTT.
However, for their ASR (automatic speech recognition) captions, upon conversion YouTube bakes in a presentation style to simulate vertical wiping of captions line-by-line. 
This results in duplicate cues, which is not an issue when presenting caption-by-caption, but makes content unreadable when extracting all text or presenting all captions at once.

## What?

These captions look like this:

```
// Cue #1 (normal duration)
[empty line]
line1

// Cue #2 (10 ms)
line1
[empty line]

// Cue #3 (normal duration)
line1
line2

// Cue #4 (10 ms)
line2
[empty line]

// Cue #5 (normal duration)
line2
line3
```

Also, the first time a line appears (cue #1 for line1, #3 for line2, #5 for line3 in the example), it may have an additional timing information.

## How?

**Swift WebVTT** has a helper function to de-duplicate and reformat such files.
This function can be also used in general to filter out empty cues or empty lines in cues.

```swift
// var webVTT: WebVTT // A parsed file
webVTT = webVTT.deduplicated()
```

This will:
1. Remove empty lines in cues.
2. Remove lines in cues if a previous cue contained that exact line, but only for cues that are back-to-back.
3. Filter out empty cues.


## Performance

`WebVTT.deduplicated()` returns a **copy** of cues which leads to a corresponding increase of memory usage.
This operation is faster but comparable to the time it takes to parse the cues in the first place.
