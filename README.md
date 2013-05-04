
- This is a paged infinite scroll using 3 views.
- It is implemented in the controller using a regular UISCrollView.
- The trick is to always scroll to the central page and rewrite the three views.
- The whole code is in [InfiniteScrollVC.m](https://github.com/j4n0/scrollview-infinite/blob/master/scrollview-infinite/sources/InfiniteScrollVC.m)

The views have backgrounds red, green, blue to better visualize the trick. 
You'll see that after scrolling to the red or blue view, you are instantly back to the green view, that now has the element you moved to.
