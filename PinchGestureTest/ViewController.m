//
//  ViewController.m
//  PinchGestureTest
//
//  Created by Jie on 16/10/20.
//  Copyright © 2016年 com.HuXiaoQian. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "PinchScaleImageView.h"

@interface ViewController (){
    UIScrollView *topScrollView;
    UIImageView *topImageV;
}
@end

@implementation ViewController


#pragma mark - viewControllerLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - createView
- (void)createView {
    //上半部分捏合放大
    topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 30, SCREEN_WIDTH-20, (SCREEN_HEIGHT-60)/2)];
    topScrollView.backgroundColor = [UIColor lightGrayColor];
    topScrollView.bounces = NO;
    topScrollView.showsVerticalScrollIndicator = NO;
    topScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:topScrollView];
    topImageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    NSLog(@"%f",topImageV.frame.size.width);
    [topImageV setImage:[UIImage imageNamed:@"test1.jpg"]];
    topImageV.contentMode = UIViewContentModeScaleAspectFit;
    topImageV.userInteractionEnabled = YES;
    topImageV.multipleTouchEnabled = YES;
    topImageV.backgroundColor = [UIColor yellowColor];
    [topScrollView addSubview:topImageV];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchScaleImage:)];
    [topImageV addGestureRecognizer:pinchGesture];
    UIButton *topResetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    topResetBtn.frame = CGRectMake(SCREEN_WIDTH-70, 30, 40, 20);
    topResetBtn.backgroundColor = [UIColor clearColor];
    [topResetBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [topResetBtn setTitle:@"还原" forState:UIControlStateNormal];
    [topResetBtn addTarget:self action:@selector(resetImageV:) forControlEvents:UIControlEventTouchUpInside];
    topResetBtn.tag = 1000;
    [self.view addSubview:topResetBtn];
    //下半部分点击放大
    UIImageView *bottomImageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, (SCREEN_HEIGHT-60)/2+50, 100, 100)];
    [bottomImageV setImage:[UIImage imageNamed:@"test1.jpg"]];
    bottomImageV.userInteractionEnabled = YES;
    [self.view addSubview:bottomImageV];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [bottomImageV addGestureRecognizer:tapGesture];
}

#pragma mark - btnMethod
- (void)resetImageV:(UIButton *)btn {
    switch (btn.tag) {
        case 1000:
            //topImageV reset
            topScrollView.contentSize = CGSizeMake(SCREEN_WIDTH - 20, (SCREEN_HEIGHT-60)/2);
            [topImageV setFrame:CGRectMake(10, 10, 100, 100)];
            
            break;

        default:
            break;
    }
}

#pragma mark - privateMethod
//点击放大
- (void)tapHandle:(UITapGestureRecognizer *)tapGesture {
    PinchScaleImageView *pinchView = [[PinchScaleImageView alloc] initWithImage:[UIImage imageNamed:@"test1.jpg"]];
    [self.view addSubview:pinchView];
}

//捏合缩放
static float lastGesture = 1;
- (void)pinchScaleImage:(UIPinchGestureRecognizer *)gesture {
    //3这个比例 如果感觉小，捏合比较费劲的话 可以调大一点
    CGFloat gestureScale = 1+ (gesture.scale - lastGesture) /3;
    //记录下当前捏合比例
    lastGesture = gesture.scale;
    CGFloat imageVWidth = topImageV.frame.size.width;
    NSLog(@"%f",gestureScale);
    //最大放大判断 现在是三倍
    if ((imageVWidth > 3*(SCREEN_WIDTH-20)) && (gestureScale>1)) {
        return;
    }
    CGFloat imageVHeight = topImageV.frame.size.height;
    //当捏合手势状态变化的时候 走的方法 调节scrollView的大小 调节imageV的大小 并设定初始值
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if ((imageVWidth * gestureScale > (SCREEN_WIDTH - 20)) || (imageVHeight * gestureScale) > (SCREEN_HEIGHT-60)/2) {
            topScrollView.contentSize = CGSizeMake(imageVWidth * gestureScale + 20, imageVHeight * gestureScale + 20);
        } else {
            topScrollView.contentSize = CGSizeMake(SCREEN_WIDTH - 20, (SCREEN_HEIGHT-60)/2);
        }
        NSLog(@"%f--%f",imageVWidth * gestureScale, imageVHeight * gestureScale);
        if (imageVWidth * gestureScale < 100 || imageVHeight * gestureScale < 100) {
            [topImageV setFrame:CGRectMake(10, 10, 100, 100)];
        } else {
        [topImageV setFrame:CGRectMake(10, 10, imageVWidth * gestureScale, imageVHeight * gestureScale)];
        }
    }
}

#pragma mark - delegate

#pragma mark - getData

@end
