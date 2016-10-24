//
//  pinchScaleImageView.m
//  PinchGestureTest
//
//  Created by Jie on 16/10/24.
//  Copyright © 2016年 com.HuXiaoQian. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "PinchScaleImageView.h"

@interface PinchScaleImageView (){
    UIScrollView *backgroundScrollView;
    UIImageView *imageV;
}
@property (nonatomic, assign) CGFloat lastGestureScale;
@property (nonatomic, assign) CGFloat defaultScale;
@end


@implementation PinchScaleImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _lastGestureScale = 1;
        _defaultScale = 1;
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        cover.backgroundColor = [UIColor blackColor];
        cover.alpha = 0.8;
        [self addSubview:cover];
        backgroundScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 120, SCREEN_WIDTH, SCREEN_HEIGHT-220)];
        backgroundScrollView.showsVerticalScrollIndicator = NO;
        backgroundScrollView.showsHorizontalScrollIndicator = NO;
        backgroundScrollView.bounces = NO;
        backgroundScrollView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:backgroundScrollView];
        imageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, SCREEN_HEIGHT-240)];
        imageV.userInteractionEnabled = YES;
        [backgroundScrollView addSubview:imageV];
        //添加捏合手势
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchScaleImage:)];
        [imageV addGestureRecognizer:pinchGesture];
        //添加双击手势
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [imageV addGestureRecognizer:doubleTapGesture];
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        resetBtn.frame = CGRectMake(SCREEN_WIDTH-120, 10, 40, 20);
        resetBtn.backgroundColor = [UIColor clearColor];
        [resetBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [resetBtn setTitle:@"还原" forState:UIControlStateNormal];
        [resetBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        resetBtn.tag = 1000;
        [self addSubview:resetBtn];
        UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissBtn.frame = CGRectMake(SCREEN_WIDTH-70, 10, 40, 20);
        dismissBtn.backgroundColor = [UIColor clearColor];
        [dismissBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [dismissBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [dismissBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        dismissBtn.tag = 1001;
        [self addSubview:dismissBtn];
        
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)showImage {
    self = [self initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT-20)];
    if (self) {
        [imageV setImage:showImage];
    }
    return self;
}

#pragma mark - btnMethod
- (void)buttonClicked:(UIButton *)btn {
    switch (btn.tag) {
        case 1000:
            //imageV reset
            backgroundScrollView.frame = CGRectMake(0, 120, SCREEN_WIDTH, SCREEN_HEIGHT-220);
            backgroundScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-220);
            [imageV setFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, SCREEN_HEIGHT-240)];
            break;
        case 1001:
            //dismiss
            [self removeFromSuperview];
            break;
        default:
            break;
    }
}

//双击放大缩小
- (void)tapHandle:(UITapGestureRecognizer *)tapGesture {
    CGFloat imageVWidth = imageV.frame.size.width;
    CGFloat imageVHeight = imageV.frame.size.height;
    if (imageVWidth == (SCREEN_WIDTH-20)) {
        _defaultScale = 2;
    } else {
        _defaultScale = (SCREEN_WIDTH-20)/imageVWidth;
    }
    
    if ((imageVWidth * _defaultScale > (SCREEN_WIDTH - 20)) || (imageVHeight * _defaultScale) > (SCREEN_HEIGHT - 240)) {
        if ((imageVHeight * _defaultScale + 20)>(SCREEN_HEIGHT-20)) {
        [backgroundScrollView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT-40)];
        } else {
            [backgroundScrollView setFrame:CGRectMake(0, (SCREEN_HEIGHT-20-(imageVHeight * _defaultScale + 20))/2, SCREEN_WIDTH, imageVHeight * _defaultScale + 20)];
        }
        backgroundScrollView.contentSize = CGSizeMake(imageVWidth * _defaultScale + 20, imageVHeight * _defaultScale + 20);
    } else {
        [backgroundScrollView setFrame:CGRectMake(0, 120, SCREEN_WIDTH, SCREEN_HEIGHT-220)];
        backgroundScrollView.contentSize = CGSizeMake(SCREEN_WIDTH , SCREEN_HEIGHT- 220);
    }
    NSLog(@"%f--%f",imageVWidth * _defaultScale, imageVHeight * _defaultScale);
    if (imageVWidth * _defaultScale < SCREEN_WIDTH-20 || imageVHeight * _defaultScale < SCREEN_HEIGHT-240) {
        [imageV setFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, SCREEN_HEIGHT-240)];
    } else {
        [imageV setFrame:CGRectMake(10, 10, imageVWidth * _defaultScale, imageVHeight * _defaultScale)];
    }
}

//捏合手势方法
- (void)pinchScaleImage:(UIPinchGestureRecognizer *)gesture {
    //3这个比例 如果感觉小，捏合比较费劲的话 可以调大一点
    CGFloat gestureScale = 1+ (gesture.scale - _lastGestureScale) /3;
    
    //记录下当前捏合比例
    _lastGestureScale = gesture.scale;
    CGFloat imageVWidth = imageV.frame.size.width;
    NSLog(@"%f",gestureScale);
    //最大放大判断 现在是三倍
    if ((imageVWidth > 3*(SCREEN_WIDTH-20)) && (gestureScale >= 1)) {
        return;
    }
    CGFloat imageVHeight = imageV.frame.size.height;
    //当捏合手势状态变化的时候 走的方法 调节scrollView的大小 调节imageV的大小 并设定初始值
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if ((imageVWidth * gestureScale > (SCREEN_WIDTH - 20)) || (imageVHeight * gestureScale) > (SCREEN_HEIGHT - 240)) {
            if ((imageVHeight * gestureScale + 20)>(SCREEN_HEIGHT-20)) {
                
            } else {
                [backgroundScrollView setFrame:CGRectMake(0, (SCREEN_HEIGHT-20-(imageVHeight * gestureScale + 20))/2, SCREEN_WIDTH, imageVHeight * gestureScale + 20)];
            }
            backgroundScrollView.contentSize = CGSizeMake(imageVWidth * gestureScale + 20, imageVHeight * gestureScale + 20);
        } else {
            [backgroundScrollView setFrame:CGRectMake(0, 120, SCREEN_WIDTH, SCREEN_HEIGHT-220)];
            backgroundScrollView.contentSize = CGSizeMake(SCREEN_WIDTH , SCREEN_HEIGHT- 220);
        }
        NSLog(@"%f--%f",imageVWidth * gestureScale, imageVHeight * gestureScale);
        if (imageVWidth * gestureScale < SCREEN_WIDTH-20 || imageVHeight * gestureScale < SCREEN_HEIGHT-240) {
            [imageV setFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, SCREEN_HEIGHT-240)];
        } else {
            [imageV setFrame:CGRectMake(10, 10, imageVWidth * gestureScale, imageVHeight * gestureScale)];
        }
    }
}


@end
