# HTInfiniteScrollView

An infinitely scrollable `NSScrollView` clip view implementation

![tag](https://img.shields.io/github/v/tag/dagronf/HTInfiniteScrollView)
![Swift](https://img.shields.io/badge/Swift-5.4-orange.svg)
[![License MIT](https://img.shields.io/badge/license-MIT-magenta.svg)](https://github.com/dagronf/HTInfiniteScrollView/blob/master/LICENSE) 
![SPM](https://img.shields.io/badge/spm-compatible-maroon.svg)

![macOS](https://img.shields.io/badge/macOS-10.13+-darkblue)
![macCatalyst](https://img.shields.io/badge/macCatalyst-2+-orangered)

A pure Swift implementation of [Helftone Infinite Scroll View](https://github.com/helftone/infinite-nsscrollview/) ([archive.org](https://web.archive.org/web/20230911024330/https://blog.helftone.com/infinite-nsscrollview/)) supporting Swift Package Manager.

There is a basic demo application in the `Demo` subfolder.

## Implementation details

Your scrollview's document view must implement `HTInfiniteClipViewContent` which should reconfigure the view contents
around the visible region within the scrollable area. See the [demo implementation](./Demo/HTInfiniteDocument Demo/HTInfiniteDocument Demo/HTInfiniteDocumentView.swift)
for an example on how to do this.

# Credits

All credit for the original implementation goes to [Milen Dzhumerov](https://twitter.com/milend) at [Helftone](https://blog.helftone.com/infinite-nsscrollview/). 

Go and buy [Monodraw](https://monodraw.helftone.com/) if you spend any time putting drawings in your code comments (like UML diagrams) or any kind of ASCII art! It makes a laborious task so much easier.

# License

```
MIT License

Created by Milen Dzhumerov on 31/03/2015.
Copyright (c) 2015 Helftone. All rights reserved.

Converted to Swift by Darren Ford 11/9/2023

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
