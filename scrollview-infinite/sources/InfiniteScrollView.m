

#import "InfiniteScrollView.h"

@interface InfiniteScrollView () {
    NSMutableArray *visibleLabels;
    UIView         *labelContainerView;
}

- (void)tileLabelsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX;

@end


@implementation InfiniteScrollView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.contentSize = CGSizeMake(5000, self.frame.size.height);
        
        visibleLabels = [[NSMutableArray alloc] init];
        
        labelContainerView = [[UIView alloc] init];
        labelContainerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height/2);
        [self addSubview:labelContainerView];

        [labelContainerView setUserInteractionEnabled:NO];
        
        // hide horizontal scroll indicator so our recentering trick is not revealed
        [self setShowsHorizontalScrollIndicator:NO];
    }
    return self;
}

#pragma mark -
#pragma mark Layout

// recenter content periodically to achieve impression of infinite scrolling
- (void)recenterIfNecessary {
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > (contentWidth / 4.0)) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        // move content by the same amount so it appears to stay still
        for (UILabel *label in visibleLabels) {
            CGPoint center = [labelContainerView convertPoint:label.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            label.center = [self convertPoint:center toView:labelContainerView];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self recenterIfNecessary];
 
    // tile content in visible bounds
    CGRect visibleBounds = [self convertRect:[self bounds] toView:labelContainerView];
    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
    
    [self tileLabelsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}


#pragma mark -
#pragma mark Label Tiling

- (UILabel *)insertLabel {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 80)] autorelease];
    [label setNumberOfLines:3];
    [label setText:@"1024 Block Street\nShaffer, CA\n95014"];
    [labelContainerView addSubview:label];

    return label;
}

- (CGFloat)placeNewLabelOnRight:(CGFloat)rightEdge {
    UILabel *label = [self insertLabel];
    [visibleLabels addObject:label]; // add rightmost label at the end of the array
    
    CGRect frame = [label frame];
    frame.origin.x = rightEdge;
    frame.origin.y = [labelContainerView bounds].size.height - frame.size.height;
    [label setFrame:frame];
        
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewLabelOnLeft:(CGFloat)leftEdge {
    UILabel *label = [self insertLabel];
    [visibleLabels insertObject:label atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [label frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = [labelContainerView bounds].size.height - frame.size.height;
    [label setFrame:frame];
    
    return CGRectGetMinX(frame);
}

- (void)tileLabelsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX {
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([visibleLabels count] == 0) {
        [self placeNewLabelOnRight:minimumVisibleX];
    }
    
    // add labels that are missing on right side
    UILabel *lastLabel = [visibleLabels lastObject];
    CGFloat rightEdge = CGRectGetMaxX([lastLabel frame]);
    while (rightEdge < maximumVisibleX) {
        rightEdge = [self placeNewLabelOnRight:rightEdge];
    }
    
    // add labels that are missing on left side
    UILabel *firstLabel = [visibleLabels objectAtIndex:0];
    CGFloat leftEdge = CGRectGetMinX([firstLabel frame]);
    while (leftEdge > minimumVisibleX) {
        leftEdge = [self placeNewLabelOnLeft:leftEdge];
    }
    
    // remove labels that have fallen off right edge
    lastLabel = [visibleLabels lastObject];
    while ([lastLabel frame].origin.x > maximumVisibleX) {
        [lastLabel removeFromSuperview];
        [visibleLabels removeLastObject];
        lastLabel = [visibleLabels lastObject];
    }
    
    // remove labels that have fallen off left edge
    firstLabel = [visibleLabels objectAtIndex:0];
    while (CGRectGetMaxX([firstLabel frame]) < minimumVisibleX) {
        [firstLabel removeFromSuperview];
        [visibleLabels removeObjectAtIndex:0];
        firstLabel = [visibleLabels objectAtIndex:0];
    }
}

@end
