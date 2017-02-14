//
//  IDBPictureScrollView.h
//
//  Created by Han Yahui on 15/12/23.
//  Copyright © 2015年 Han Yahui. All rights reserved.
//


#import <UIKit/UIKit.h>


@class IDBPictureScrollView;

@protocol IDBPictureScrollViewDelegate <NSObject>

- (NSInteger)numberOfPagesPictueScrollView:(IDBPictureScrollView *)scrollView;
- (UIView *)pictureScrollView:(IDBPictureScrollView *)scrollView contentForPageAtIndex:(NSInteger)index;
- (void)pictureScollView:(IDBPictureScrollView *)scrollView didSelectedAtIndex:(NSInteger)index;


@end


@interface IDBPictureScrollView : UIView

@property (nonatomic , readonly) UIScrollView *scrollView;

@property (nonatomic,weak) id<IDBPictureScrollViewDelegate> delegate;
/**
 *  初始化
 *
 *  @param frame             frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *
 *  @return instance
 */
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;

- (void)reloadData;


@end




