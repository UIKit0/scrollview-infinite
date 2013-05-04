This is a paged infinite scroll using 3 views. The whole code is in the controller [InfiniteScrollVC.m](https://github.com/j4n0/scrollview-infinite/blob/master/scrollview-infinite/sources/InfiniteScrollVC.m).

The trick is to scroll to the central view after any movement and rewrite the content of the three views. 
The views have backgrounds red, green, blue to better visualize the trick. 
You'll see that after scrolling to the red or blue view, you are instantly back to the green view, that now has the element you moved to.

![screenshot](https://raw.github.com/j4n0/scrollview-infinite/master/scrollview-infinite/sources/resources/screenshot.png)

Other techniques:
- Some people uses duplicated end caps, that is, eg: CABCA instead ABC. I don't see any benefit (?).
- If you want fast scroll (instead paged) you need a bigger contentSize like in Apple's [StreetScroller](http://developer.apple.com/library/ios/#samplecode/StreetScroller/Introduction/Intro.html#//apple_ref/doc/uid/DTS40011102).
- If you want infinite zoom instead infinite scrolling, resize the image and reset UIScrollerView's zoom to 1.0 after each zoom.
- A more reusable design would be to code it in a UIScrollView delegate of itself, with a protocol to provide data and view format.
