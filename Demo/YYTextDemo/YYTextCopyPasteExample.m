//
//  YYTextCopyPasteExample.m
//  YYKitExample
//
//  Created by ibireme on 15/9/12.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYTextCopyPasteExample.h"
#import "YYText.h"
#import "YYImage.h"
#import "UIImage+YYWebImage.h"
#import "UIView+YYAdd.h"
#import "NSBundle+YYAdd.h"
#import "NSString+YYAdd.h"
#import "YYTextExampleHelper.h"

@interface YYTextCopyPasteExample ()<YYTextViewDelegate>
@property (nonatomic, assign) YYTextView *textView;
@end

@implementation YYTextCopyPasteExample

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSString *text = @"You can copy image from browser or photo album and paste it to here. It support animated GIF and APNG. \n\nYou can also copy attributed string from other YYTextView.\n";
    
    YYTextSimpleMarkdownParser *parser = [YYTextSimpleMarkdownParser new];
    [parser setColorWithDarkTheme];
    
    YYTextView *textView = [YYTextView new];
    textView.text = text;
    textView.font = [UIFont systemFontOfSize:17];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    textView.delegate = self;
    textView.allowsPasteImage = YES; /// Pasts image
    textView.allowsPasteAttributedString = YES; /// Paste attributed string
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    textView.scrollIndicatorInsets = textView.contentInset;
    [self.view addSubview:textView];
    [NSLayoutConstraint activateConstraints:@[
        [textView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [textView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [textView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [textView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    self.textView = textView;
    
    textView.selectedRange = NSMakeRange(text.length, 0);
    [textView becomeFirstResponder];
}

- (void)edit:(UIBarButtonItem *)item {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    } else {
        [_textView becomeFirstResponder];
    }
}

- (void)textViewDidBeginEditing:(YYTextView *)textView {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)textViewDidEndEditing:(YYTextView *)textView {
    self.navigationItem.rightBarButtonItem = nil;
}

@end
