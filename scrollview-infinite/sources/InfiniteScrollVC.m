
// BSD License. Created by jano@jano.com.es

#import "InfiniteScrollVC.h"

CGRect CGRectSetX(CGRect rect, CGFloat x){
    return CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height);
}


@implementation InfiniteScrollVC
{
    UIScrollView *_scrollView;
    NSArray *_data;              // array of data to show in the scroll view
    NSMutableArray *_pageViews;  // views that simulate infinite scrolling (3 views or less)
    NSUInteger _fakePageIndex;   // scroll view page the user thinks he is in
    NSUInteger _realPageIndex;   // scroll view page the user really is
}


#pragma mark - data logic


-(void) updatePageViews
{
    NSArray *data = [self sliceFromData:_data withRange:NSMakeRange(0,[_pageViews count])];
    [self updatePageViews:_pageViews withData:data];
}


// Update page views with the given data. -count MUST match for both arrays.
-(void) updatePageViews:(NSArray*)pageViews withData:(NSArray*)data
{
    NSParameterAssert([pageViews count]==[data count]);
    for (NSUInteger i = 0; i<[data count]; i++) {
        ((UILabel*)pageViews[i]).text = [data[i] description];
    }
}


-(NSArray*) sliceFromData:(NSArray*)data withRange:(NSRange)range
{
    return [data objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}


#pragma mark - scrollview logic


// Scroll the scroll view to the given page. First page is 0.
- (void) scroll:(UIScrollView*)scrollView toPage:(NSUInteger)page
{
    NSUInteger offsetX = scrollView.frame.size.width * page;
    NSAssert(offsetX < scrollView.contentSize.width, @"Can't scroll beyond the content size");
    
    [scrollView setContentOffset:CGPointMake(offsetX,0)];
}


#pragma mark - UIScrollViewDelegate


-(void) recenterIfNeeded:(UIScrollView*)scrollView
{
    NSInteger newPage = (NSUInteger) ceil((scrollView.contentOffset.x - scrollView.frame.size.width/2) / scrollView.frame.size.width);
    NSInteger pagesForward = newPage-_realPageIndex;
    
    if (_realPageIndex!=newPage)
    {
        // user scrolled one page, update indexes
        _fakePageIndex += pagesForward;
        _realPageIndex += pagesForward;
        
        // recenter if page is not first or last
        BOOL shouldRecenter = _fakePageIndex!=0 && _fakePageIndex!=[_data count]-1;
        if (shouldRecenter)
        {
            // data range for _fakePageIndex
            NSRange range = NSMakeRange(_fakePageIndex-1, [_pageViews count]);
            
            // update views for the given range
            NSArray *slice = [self sliceFromData:_data withRange:range];
            [self updatePageViews:_pageViews withData:slice];
            
            // recenter
            _realPageIndex = 1;
            [self scroll:scrollView toPage:_realPageIndex];
            
        } else {
            _realPageIndex = newPage;
        }
    }
}


- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self recenterIfNeeded:scrollView];
}
    

#pragma mark - GUI setup


// Create and return a scroll view filling the screen, with margin 20, and content size = pages*screenWidth.
-(UIScrollView*) createScrollViewForPages:(NSUInteger)numberOfPages
{
    const CGFloat statusBar = 20.f;
    const CGFloat margin = 20.f;
    const CGSize screen = [[UIScreen mainScreen] bounds].size;
    const CGRect rect = CGRectMake(margin, margin, screen.width-2*margin, screen.height-2*margin-statusBar);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:rect];
    scrollView.contentSize = CGSizeMake(rect.size.width * numberOfPages, rect.size.height);
    scrollView.directionalLockEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = YES;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.panGestureRecognizer.cancelsTouchesInView = YES;
    
    return scrollView;
}


-(void) setupGUIForNumberOfPages:(NSUInteger)numberOfPages
{
    // setup scroll view
    UIScrollView *scrollView = [self createScrollViewForPages:numberOfPages];
    scrollView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:scrollView];
    
    // setup page views
    NSMutableArray *pageViews = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
    for (NSUInteger i = 0; i <numberOfPages; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:300];
        [pageViews addObject:label];
    }
    
    // add the page views to the scroll view
    NSArray *colors = @[ [UIColor redColor], [UIColor greenColor], [UIColor blueColor]];
    for (NSUInteger i=0; i<[pageViews count]; i++) {
        UIView *view = pageViews[i];
        view.frame = CGRectSetX(view.frame, view.frame.size.width*i);
        view.backgroundColor = [colors objectAtIndex: i % [colors count] ];
        [scrollView addSubview:view];
    }
    
    // globals
    _scrollView = scrollView;
    _pageViews = pageViews;
    _fakePageIndex = 0;
    _realPageIndex = 0;
}


#pragma mark - UIViewController

-(void) viewDidLoad
{
    // data to show
    NSArray *data = @[ @"A", @"B", @"C", @"D", @"E", @"F" ];
    NSAssert([data count]>0, @"Called with empty data");
    _data = data;
    
    NSUInteger numberOfPages = MIN([data count], 3);
    [self setupGUIForNumberOfPages:numberOfPages];
    [self updatePageViews];
}


@end

