//
//  SuspensionView.m
//  Latin2.0
//
//  Created by ripper on 16-02-25.
//  Copyright (c) 2016年 ripper. All rights reserved.
//

#import "SuspensionView.h"
#import "NSObject+Key.h"

#define kTouchWidth self.frame.size.width
#define kTouchHeight self.frame.size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@implementation SuspensionView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color
{
    if(self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = color;
        self.alpha = .7;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        
        //拖动
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(changeLocation:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        //点击
        [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - event response
- (void)changeLocation:(UIPanGestureRecognizer*)p
{
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [p locationInView:appWindow];
    
    
    if(p.state == UIGestureRecognizerStateBegan)
    {
        self.alpha = 1;
    }
    else if (p.state == UIGestureRecognizerStateEnded)
    {
        self.alpha = .7;
    }
    
    if(p.state == UIGestureRecognizerStateChanged)
    {
        [[SuspensionManager shared] windowForKey:self.md5Key].center = CGPointMake(panPoint.x, panPoint.y);
    }
    else if(p.state == UIGestureRecognizerStateEnded)
    {
        CGFloat left = fabs(panPoint.x);
        CGFloat right = fabs(kScreenWidth - left);
        //ripper:只停留在左右，需要在上下，将注释打开
//        CGFloat top = fabs(panPoint.y);
//        CGFloat bottom = fabs(kScreenHeight - top);
        
        CGFloat minSpace = MIN(left, right);
//        CGFloat minSpace = MIN(MIN(MIN(top, left), bottom), right);
        CGPoint newCenter;
        CGFloat targetY = 0;
        
        //校正Y
        if (panPoint.y < 15 + kTouchHeight/2.0) {
            targetY = 15 + kTouchHeight/2.0;
        }else if (panPoint.y > (kScreenHeight - kTouchHeight/2.0 - 15)) {
            targetY = kScreenHeight - kTouchHeight/2.0 - 15;
        }else{
            targetY = panPoint.y;
        }
        
        if (minSpace == left) {
            newCenter = CGPointMake(kTouchHeight/3, targetY);
        }else if (minSpace == right) {
            newCenter = CGPointMake(kScreenWidth-kTouchHeight/3, targetY);
        }
//        else if (minSpace == top) {
//            newCenter = CGPointMake(panPoint.x, kTouchWidth/3);
//        }else if (minSpace == bottom) {
//            newCenter = CGPointMake(panPoint.x, kScreenHeight-kTouchWidth/3);
//        }
        
        [UIView animateWithDuration:.25 animations:^{
            [[SuspensionManager shared] windowForKey:self.md5Key].center = newCenter;
        }];
    }
}

- (void)click
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(suspensionViewClick:)])
    {
        [self.delegate suspensionViewClick:self];
    }
}

#pragma mark - public methods
- (void)show
{
    UIWindow *backWindow = [[UIWindow alloc] initWithFrame:self.frame];
    backWindow.windowLevel = UIWindowLevelAlert * 2;
    backWindow.rootViewController = [[UIViewController alloc] init];
    backWindow.layer.cornerRadius = backWindow.frame.size.width / 2.0;
    backWindow.layer.borderColor = [UIColor whiteColor].CGColor;
    backWindow.layer.borderWidth = 1.0;
    backWindow.clipsToBounds = YES;
    [backWindow makeKeyAndVisible];
    [[SuspensionManager shared] saveWindow:backWindow forKey:self.md5Key];

    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [backWindow addSubview:self];
}

- (void)removeFromScreen
{
    [[SuspensionManager shared] destroyWindowForKey:self.md5Key replaceWith:nil];
}

@end
