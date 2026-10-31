//
//  YYTextEditExample.m
//  YYKitExample
//
//  Created by ibireme on 15/9/3.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYTextEditExample.h"
#import "YYText.h"
#import "YYImage.h"
#import "UIImage+YYWebImage.h"
#import "UIView+YYAdd.h"
#import "NSBundle+YYAdd.h"
#import "NSString+YYAdd.h"
#import "UIControl+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "NSData+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "YYTextExampleHelper.h"

@interface YYTextEditExample () <YYTextViewDelegate, YYTextKeyboardObserver>
@property (nonatomic, strong) YYTextView *textView;
@property (nonatomic, strong) UIVisualEffectView *toolbar;
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) BOOL keyboardVisible;
@property (nonatomic, assign) BOOL imagePositioned;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UISwitch *verticalSwitch;
@property (nonatomic, strong) UISwitch *debugSwitch;
@property (nonatomic, strong) UISwitch *exclusionSwitch;
@end

@implementation YYTextEditExample

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initImageView];
    __weak typeof(self) _self = self;
    
    UIVisualEffectView *toolbar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
    [NSLayoutConstraint activateConstraints:@[
        [toolbar.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [toolbar.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [toolbar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [toolbar.heightAnchor constraintEqualToConstant:40]
    ]];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the season of light, it was the season of darkness, it was the spring of hope, it was the winter of despair, we had everything before us, we had nothing before us. We were all going direct to heaven, we were all going direct the other way.\n\n这是最好的时代，这是最坏的时代；这是智慧的时代，这是愚蠢的时代；这是信仰的时期，这是怀疑的时期；这是光明的季节，这是黑暗的季节；这是希望之春，这是失望之冬；人们面前有着各样事物，人们面前一无所有；人们正在直登天堂，人们正在直下地狱。"];
    text.yy_font = [UIFont fontWithName:@"Times New Roman" size:20];
    text.yy_lineSpacing = 4;
    text.yy_firstLineHeadIndent = 20;
    
    YYTextView *textView = [YYTextView new];
    textView.attributedText = text;
    textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    textView.delegate = self;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    textView.selectedRange = NSMakeRange(text.length, 0);
    [self.view insertSubview:textView belowSubview:toolbar];
    self.textView = textView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [textView becomeFirstResponder];
    });
    
    
    
    /*------------------------------ Toolbar ---------------------------------*/
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    label.text = @"Vertical:";
    UILabel *verticalLabel = label;
    
    _verticalSwitch = [UISwitch new];
    [_verticalSwitch sizeToFit];
    _verticalSwitch.layer.transformScale = 0.8;
    [_verticalSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(UISwitch *switcher) {
        [_self.textView endEditing:YES];
        if (switcher.isOn) {
            [_self setExclusionPathEnabled:NO];
            _self.exclusionSwitch.on = NO;
        }
        _self.exclusionSwitch.enabled = !switcher.isOn;
        _self.textView.verticalForm = switcher.isOn; /// Set vertical form
        [_self.view setNeedsLayout];
    }];
    
    label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    label.text = @"Debug:";
    UILabel *debugLabel = label;
    
    _debugSwitch = [UISwitch new];
    [_debugSwitch sizeToFit];
    _debugSwitch.on = [YYTextExampleHelper isDebug];
    _debugSwitch.layer.transformScale = 0.8;
    [_debugSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(UISwitch *switcher) {
        [YYTextExampleHelper setDebug:switcher.isOn];
    }];
    
    label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    label.text = @"Exclusion:";
    UILabel *exclusionLabel = label;
    
    _exclusionSwitch = [UISwitch new];
    [_exclusionSwitch sizeToFit];
    _exclusionSwitch.layer.transformScale = 0.8;
    [_exclusionSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(UISwitch *switcher) {
        [_self setExclusionPathEnabled:switcher.isOn];
    }];
    UIStackView *controls = [[UIStackView alloc] initWithArrangedSubviews:@[verticalLabel, _verticalSwitch, debugLabel, _debugSwitch, exclusionLabel, _exclusionSwitch]];
    controls.translatesAutoresizingMaskIntoConstraints = NO;
    controls.alignment = UIStackViewAlignmentCenter;
    controls.distribution = UIStackViewDistributionEqualSpacing;
    [toolbar.contentView addSubview:controls];
    [NSLayoutConstraint activateConstraints:@[
        [controls.leadingAnchor constraintEqualToAnchor:toolbar.contentView.leadingAnchor constant:10],
        [controls.trailingAnchor constraintEqualToAnchor:toolbar.contentView.trailingAnchor constant:-10],
        [controls.topAnchor constraintEqualToAnchor:toolbar.contentView.topAnchor],
        [controls.bottomAnchor constraintEqualToAnchor:toolbar.contentView.bottomAnchor]
    ]];

    YYTextKeyboardManager *manager = [YYTextKeyboardManager defaultManager];
    self.keyboardFrame = manager.keyboardFrame;
    self.keyboardVisible = manager.keyboardVisible;
    [manager addObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect frame = self.view.safeAreaLayoutGuide.layoutFrame;
    CGFloat bottom = CGRectGetMaxY(frame);
    frame.origin.y = CGRectGetMaxY(self.toolbar.frame);
    frame.size.height = MAX(0, bottom - frame.origin.y);
    if (self.textView.verticalForm && self.keyboardVisible) {
        CGRect keyboard = [[YYTextKeyboardManager defaultManager] convertRect:self.keyboardFrame toView:self.view];
        CGRect overlap = CGRectIntersection(frame, keyboard);
        CGFloat tolerance = 1.0 / self.traitCollection.displayScale;
        // Only a full-width, bottom-docked keyboard shortens the vertical viewport.
        if (!CGRectIsNull(overlap) && CGRectGetMaxY(keyboard) >= CGRectGetMaxY(self.view.bounds) - tolerance &&
            CGRectGetMinX(keyboard) <= CGRectGetMinX(frame) + tolerance &&
            CGRectGetMaxX(keyboard) >= CGRectGetMaxX(frame) - tolerance) {
            frame.size.height = MAX(0, CGRectGetMinY(overlap) - frame.origin.y);
        }
    }
    self.textView.frame = frame;
    if (!self.imagePositioned && frame.size.width > 0 && frame.size.height > 0) {
        self.imagePositioned = YES;
        self.imageView.center = CGPointMake(CGRectGetMidX(self.textView.bounds), CGRectGetMidY(self.textView.bounds));
    }
}

- (void)dealloc {
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

- (void)setExclusionPathEnabled:(BOOL)enabled {
    if (enabled) {
        [self.textView addSubview:self.imageView];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.imageView.frame
                                                        cornerRadius:self.imageView.layer.cornerRadius];
        self.textView.exclusionPaths = @[path]; /// Set exclusion paths
    } else {
        [self.imageView removeFromSuperview];
        self.textView.exclusionPaths = nil;
    }
}

- (void)initImageView {
    NSData *data = [NSData dataNamed:@"dribbble256_imageio.png"];
    UIImage *image = [[YYImage alloc] initWithData:data scale:2];
    UIImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    imageView.layer.cornerRadius = imageView.height / 2;
    self.imageView = imageView;

    
    __weak typeof(self) _self = self;
    UIPanGestureRecognizer *g = [[UIPanGestureRecognizer alloc] initWithActionBlock:^(UIPanGestureRecognizer *g) {
        __strong typeof(_self) self = _self;
        if (!self) return;
        CGPoint p = [g locationInView:self.textView];
        self.imageView.center = p;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.imageView.frame
                                                        cornerRadius:self.imageView.layer.cornerRadius];
        self.textView.exclusionPaths = @[path];
    }];
    [imageView addGestureRecognizer:g];
}

- (void)edit:(UIBarButtonItem *)item {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    } else {
        [_textView becomeFirstResponder];
    }
}

#pragma mark text view

- (void)textViewDidBeginEditing:(YYTextView *)textView {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)textViewDidEndEditing:(YYTextView *)textView {
    self.navigationItem.rightBarButtonItem = nil;
}


#pragma mark - keyboard

- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition {
    self.keyboardFrame = transition.toFrame;
    self.keyboardVisible = transition.toVisible;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:transition.animationDuration delay:0
                       options:transition.animationOption | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{ [self.view layoutIfNeeded]; } completion:nil];
}

@end
