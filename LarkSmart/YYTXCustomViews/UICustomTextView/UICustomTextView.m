//
//  UICustomTextView.m
//  CloudBox
//
//  Created by TTS on 15/8/31.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTextView.h"

@interface UICustomTextView ()
@property (nonatomic, retain) UILabel *labelPlaceholder;
//@property (nonatomic, retain) UIColor *placeHolderColor;
@property (nonatomic, retain) UIFont *fontPlaceholder;

@end

@implementation UICustomTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (nil != self) {
        [self awakeFromNib];
        
        NSLog(@"%s", __func__);
        
        
//        _placeHolderColor = [UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:192.0f/255.0f alpha:1.0f];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self addObserver];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
}

- (void)textDidBeginEditing:(NSNotification *)notification {
    NSLog(@"%s", __func__);
//    if ([super.text isEqualToString:_placeHolder]) {
//        super.text = @"";
//        [super setTextColor:_customTextColor];
//    }
    [_labelPlaceholder removeFromSuperview];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    NSLog(@"%s textColor:%@", __func__, super.textColor);
    if (super.text.length <= 0) {
//        super.text = _placeHolder;
//        [super setTextColor:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:192.0f/255.0f alpha:1.0f]];
        [self addSubview:_labelPlaceholder];
    } else {
//        if ([super.text isEqualToString:_placeHolder]) {
//            [super setTextColor:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:192.0f/255.0f alpha:1.0f]];
//        } else {
//            [super setTextColor:_customTextColor];
//        }
        [_labelPlaceholder removeFromSuperview];
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    
    NSLog(@"%s", __func__);
    
    if (nil == placeHolder || placeHolder.length <= 0) {
        return;
    }
    
    _placeHolder = placeHolder;
    
    if (nil == _labelPlaceholder) {
//        _fontPlaceholder = [UIFont systemFontOfSize:16.0f];
        
        _labelPlaceholder = [[UILabel alloc] init];
        [_labelPlaceholder setNumberOfLines:0];
        [_labelPlaceholder setLineBreakMode:NSLineBreakByTruncatingTail];
        [_labelPlaceholder setFont:self.font];
        [_labelPlaceholder setTextColor:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:192.0f/255.0f alpha:1.0f]];
        [_labelPlaceholder setUserInteractionEnabled:NO];
    }
    
//    CGRect placeholderRect = [_placeHolder boundingRectWithSize:self.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
//    NSLog(@"%s textviewFrame:%@ placeholderRect:%@", __func__, NSStringFromCGRect(self.frame), NSStringFromCGRect(placeholderRect));
    CGRect placeholderRect = self.frame;
    placeholderRect.origin = (CGPoint){0, 0};
    [_labelPlaceholder setFrame:placeholderRect];
    [_labelPlaceholder setText:_placeHolder];
    
//    [self textDidEndEditing:nil];
}

- (NSString *)text {
    NSLog(@"%s text:%@", __func__, [super text]);
    NSString *text = [super text];
//    if ([text isEqualToString:_placeHolder]) {
//        return @"";
//    }
    
    return text;
}

- (void)setText:(NSString *)text {
    NSLog(@"%s text:%@", __func__, text);
    if (nil == text || text.length <= 0) {
        [super setText:@""];
        
        NSLog(@"%s text is empty", __func__);
        
//        [self textDidEndEditing:nil];
//        if ((_labelPlaceholder.text.length > 0) && (nil == _labelPlaceholder.superview)) {
//        NSLog(@"%s _labelPlaceholder:%@ _labelPlaceholder.text:%@", __func__, _labelPlaceholder, _labelPlaceholder.text);
//        dispatch_async(dispatch_get_main_queue(), ^{
        
        if (![self isFirstResponder]) {
            [self addSubview:_labelPlaceholder];
        }
        
//            [self bringSubviewToFront:_labelPlaceholder];
//        });
        
//        }
    } else {
//        [super setTextColor:_customTextColor];
        [super setText:text];
//        if (nil != _labelPlaceholder.superview) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            [_labelPlaceholder removeFromSuperview];
//        });
//        }
    }
}

@end
