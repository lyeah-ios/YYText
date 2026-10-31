//
//  YYTextMarkdownExample.m
//  YYKitExample
//
//  Created by ibireme on 15/9/3.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYTextMarkdownExample.h"
#import "YYText.h"
#import "YYImage.h"
#import "UIImage+YYWebImage.h"
#import "UIView+YYAdd.h"
#import "NSBundle+YYAdd.h"
#import "NSString+YYAdd.h"
#import "YYTextExampleHelper.h"

@interface YYTextMarkdownExample () <YYTextViewDelegate>
@property (nonatomic, assign) YYTextView *textView;
@end

@implementation YYTextMarkdownExample

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSString *text = @"#Markdown Editor\nThis is a simple markdown editor based on `YYTextView`.\n\n*********************************************\nIt\'s *italic* style.\n\nIt\'s also _italic_ style.\n\nIt\'s **bold** style.\n\nIt\'s ***italic and bold*** style.\n\nIt\'s __underline__ style.\n\nIt\'s ~~deleteline~~ style.\n\n\nHere is a link: [YYKit](https://github.com/ibireme/YYKit)\n\nHere is some code:\n\n\tif(a){\n\t\tif(b){\n\t\t\tif(c){\n\t\t\t\tprintf(\"haha\");\n\t\t\t}\n\t\t}\n\t}\n";
    
    YYTextSimpleMarkdownParser *parser = [YYTextSimpleMarkdownParser new];
    [parser setColorWithDarkTheme];
    
    YYTextView *textView = [YYTextView new];
    textView.text = text;
    textView.font = [UIFont systemFontOfSize:14];
    textView.textParser = parser;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    textView.delegate = self;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    textView.backgroundColor = [UIColor colorWithWhite:0.134 alpha:1.000];
    textView.scrollIndicatorInsets = textView.contentInset;
    textView.selectedRange = NSMakeRange(text.length, 0);
    [self.view addSubview:textView];
    [NSLayoutConstraint activateConstraints:@[
        [textView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [textView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [textView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [textView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    self.textView = textView;
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
