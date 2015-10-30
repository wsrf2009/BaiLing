//
//  QXToast.m
//  QXToastDemo
//
//  Created by TTS on 15/10/19.
//  Copyright © 2015年 yytx. All rights reserved.
//

#import "QXToast.h"

@implementation QXToast

+ (void)showMessage:(NSString *)message {
    
#define leadingSpaceToSuperView 20
#define trailingSpaceToSuperView 20
#define topSpaceToSuperView 20
#define bottomSpaceToSuperView 10
    
    CGFloat maxContentViewWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat maxContentViewHeight = 100.0f;
    UIFont *messageFont = [UIFont systemFontOfSize:15.0f];
    UIColor *messageColor = [UIColor whiteColor];
    CGFloat maxMessageWidth = maxContentViewWidth-leadingSpaceToSuperView-trailingSpaceToSuperView;
    CGFloat maxMessageheight = maxContentViewHeight-topSpaceToSuperView-bottomSpaceToSuperView;
    CGSize maxSize = (CGSize){maxMessageWidth, maxMessageheight};
    
    CGRect messageRect;
    messageRect = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:messageFont} context:nil];
    messageRect.size.height += 1;
    messageRect.origin = (CGPoint){0, 0};
    
    CGRect contentViewRect = messageRect;
    contentViewRect.size.height += (topSpaceToSuperView+bottomSpaceToSuperView);
    contentViewRect.size.width = maxContentViewWidth;
    contentViewRect.origin.y = -contentViewRect.size.height;
    contentViewRect.origin.x = 0;

    UIView *contentView = [[UIView alloc] init];
    [contentView setFrame:contentViewRect];
    [contentView setBackgroundColor:[UIColor colorWithWhite:.0f alpha:0.7]];
    [contentView setAlpha:.0f];
    
    UILabel *labelMessage = [[UILabel alloc] init];
    [labelMessage setFont:messageFont];
    [labelMessage setTextColor:messageColor];
    [labelMessage setNumberOfLines:0];
    [labelMessage setLineBreakMode:NSLineBreakByTruncatingTail];
    [labelMessage setText:message];
    [labelMessage setOpaque:YES];
    labelMessage.translatesAutoresizingMaskIntoConstraints = NO;
    
    [contentView addSubview:labelMessage];
    
    CGFloat labelWidth = messageRect.size.width;
    CGFloat labelHeight= messageRect.size.height;
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:labelMessage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=leadingSpaceToSuperView)-[labelMessage(==labelWidth)]-(>=trailingSpaceToSuperView)-|" options:0 metrics:@{@"leadingSpaceToSuperView":@leadingSpaceToSuperView, @"trailingSpaceToSuperView":@trailingSpaceToSuperView,@"labelWidth":@(labelWidth)} views:NSDictionaryOfVariableBindings(labelMessage)]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==topSpaceToSuperView)-[labelMessage(>=labelHeight)]-(==bottomSpaceToSuperView)-|" options:0 metrics:@{@"topSpaceToSuperView":@topSpaceToSuperView, @"bottomSpaceToSuperView":@bottomSpaceToSuperView, @"labelHeight":@(labelHeight)} views:NSDictionaryOfVariableBindings(labelMessage)]];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window  addSubview:contentView];
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0f, contentViewRect.size.height);

    [UIView animateWithDuration:.5f animations:^{
            
        NSLog(@"%s labelFrame:%@", __func__, NSStringFromCGRect(labelMessage.bounds));
            
        contentView.transform = translate;
        [contentView setAlpha:1.0f];
    } completion:^(BOOL finished) {
            
        [UIView animateWithDuration:.5f delay:3.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
            contentView.transform = CGAffineTransformIdentity;
            [contentView setAlpha:.0f];
        } completion:nil];
    }];
}


@end
