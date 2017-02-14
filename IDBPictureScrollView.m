//
//  IDBPictureScrollView.m
//
//  Created by Han Yahui on 15/12/23.
//  Copyright © 2015年 Han Yahui. All rights reserved.
//

#import "IDBPictureScrollView.h"
#import "NSTimer+Addition.h"
#import "IDBPageControl.h"

@interface IDBPictureScrollView () <UIScrollViewDelegate>
{
    CGFloat scrollViewStartContentOffsetX;
}
@property (nonatomic , assign) NSInteger currentPageIndex;
@property (nonatomic , assign) NSInteger totalPageCount;
@property (nonatomic , strong) NSMutableArray *contentViews;
@property (nonatomic , strong) UIScrollView *scrollView;

@property (nonatomic , strong) NSTimer *animationTimer;
@property (nonatomic , assign) NSTimeInterval animationDuration;

@property (nonatomic , strong) IDBPageControl *pageControl;

@end

@implementation IDBPictureScrollView

- (IDBPageControl *)pageControl
{
    //少于或者等于一页的话，没有必要显示pageControl
    if (self.totalPageCount > 1) {
        if (!_pageControl) {
            NSInteger pageCount = self.totalPageCount;
            CGFloat dotGapWidth = 8.0;
            UIImage *normalImage = [UIImage imageNamed:@"page_state_normal"];
            UIImage *highlightImage = [UIImage imageNamed:@"page_state_highlight"];
          
            CGFloat pageControlWidth = pageCount * normalImage.size.width + (pageCount - 1) * dotGapWidth;
          
            CGRect frame = CGRectMake(CGRectGetMidX(self.scrollView.frame) - 0.5 * pageControlWidth , 0.9 * CGRectGetHeight(self.scrollView.frame), pageControlWidth, normalImage.size.height);
            
            _pageControl = [[IDBPageControl alloc] initWithFrame:frame
                                                     normalImage:normalImage
                                                highlightedImage:highlightImage
                                                      dotsNumber:pageCount
                                                      sideLength:dotGapWidth
                                                         dotsGap:dotGapWidth];
            _pageControl.hidden = NO;
        }
    }
    return _pageControl;
}

-(void)setDelegate:(id<IDBPictureScrollViewDelegate>)delegate
{
  _delegate = delegate;
  
  self.totalPageCount = [self numberOfPages];
  
  if (self.totalPageCount > 0) {
    if (self.totalPageCount > 1) {
      self.scrollView.scrollEnabled = YES;
      self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
      [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
    } else {
      self.scrollView.scrollEnabled = NO;
    }
    [self configContentViews];
    [self addSubview:self.pageControl];
  }
  
  [self configContentViews];
  
}


- (void)reloadData
{
  
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
    [self.pageControl setCurrentPage:_currentPageIndex];
}

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    self = [self initWithFrame:frame];
    if (animationDuration > 0.0) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration = animationDuration)
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [self.animationTimer pauseTimer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.autoresizesSubviews = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.currentPageIndex = 0;
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration = 3)
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [self.animationTimer pauseTimer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        self.currentPageIndex = 0;
    }
    return self;
}

#pragma mark -
#pragma mark - 私有函数

- (void)configContentViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
      
      [self.scrollView addSubview:contentView];
        contentView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(longTapGestureAction:)];
        [contentView addGestureRecognizer:longTapGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
      
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        
        contentView.frame = rightRect;
    }
    if (self.totalPageCount > 1) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }
    [self.contentViews removeAllObjects];
    
  id set = (self.totalPageCount == 1)?[NSSet setWithObjects:@(previousPageIndex),@(_currentPageIndex),@(rearPageIndex), nil]:@[@(previousPageIndex),@(_currentPageIndex),@(rearPageIndex)];
  
  for (NSNumber *tempNumber in set) {
    NSInteger tempIndex = [tempNumber integerValue];
    if ([self isValidArrayIndex:tempIndex]) {
      [self.contentViews addObject:[self contentForPageAtIndex:tempIndex]];
    }
  }
  
}

- (BOOL)isValidArrayIndex:(NSInteger)index
{
    if (index >= 0 && index <= self.totalPageCount - 1) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalPageCount - 1;
    } else if (currentPageIndex == self.totalPageCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollViewStartContentOffsetX = scrollView.contentOffset.x;
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    if (self.totalPageCount == 2) {
        if (scrollViewStartContentOffsetX < contentOffsetX) {
            UIView *tempView = (UIView *)[self.contentViews lastObject];
            tempView.frame = (CGRect){{2 * CGRectGetWidth(scrollView.frame),0},tempView.frame.size};
        } else if (scrollViewStartContentOffsetX > contentOffsetX) {
            UIView *tempView = (UIView *)[self.contentViews firstObject];
            tempView.frame = (CGRect){{0,0},tempView.frame.size};
        }
    }
    
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
        //        NSLog(@"next，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
    if(contentOffsetX <= 0) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
        //        NSLog(@"previous，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

#pragma mark -
#pragma mark - 响应事件

- (void)longTapGestureAction:(UILongPressGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateBegan) {
        [self.animationTimer pauseTimer];
    }
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self.animationTimer resumeTimer];
    }
}

- (void)animationTimerDidFired:(NSTimer *)timer
{
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
}



- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
  if ([_delegate respondsToSelector:@selector(pictureScollView:didSelectedAtIndex:)]) {
    [_delegate pictureScollView:self didSelectedAtIndex:self.currentPageIndex];
  }
  
}

- (UIView *)contentForPageAtIndex:(NSInteger)index
{
  if ([_delegate respondsToSelector:@selector(pictureScrollView:contentForPageAtIndex:)]) {
  return  [_delegate pictureScrollView:self contentForPageAtIndex:index];
  }
  return [[UIView alloc] init];
}

- (NSInteger)numberOfPages
{
  if ([_delegate respondsToSelector:@selector(numberOfPagesPictueScrollView:)]) {
    return  [_delegate numberOfPagesPictueScrollView:self];
  }
  return 0;
}

@end
