//
//  YYTextAsyncExample.m
//  YYKitExample
//
//  Created by ibireme on 15/9/3.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYTextAsyncExample.h"
#import "YYText.h"
#import "YYImage.h"
#import "UIImage+YYWebImage.h"
#import "UIView+YYAdd.h"
#import "NSBundle+YYAdd.h"
#import "NSString+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "UIControl+YYAdd.h"
#import "YYTextExampleHelper.h"
#import "YYFPSLabel.h"

#define kCellHeight 34

@interface YYTextAsyncExampleCell : UITableViewCell
@property (nonatomic, assign) BOOL async;
- (void)setAyncText:(id)text;
@end


@implementation YYTextAsyncExampleCell {
    UILabel *_uiLabel;
    YYLabel *_yyLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _uiLabel = [UILabel new];
    _uiLabel.font = [UIFont systemFontOfSize:8];
    _uiLabel.numberOfLines = 0;
    
    _yyLabel = [YYLabel new];
    _yyLabel.font = _uiLabel.font;
    _yyLabel.numberOfLines = _uiLabel.numberOfLines;
    _yyLabel.displaysAsynchronously = YES; /// enable async display
    _yyLabel.ignoreCommonProperties = YES;
    _yyLabel.hidden = YES;
    
    [self.contentView addSubview:_uiLabel];
    [self.contentView addSubview:_yyLabel];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _uiLabel.frame = self.contentView.bounds;
    _yyLabel.frame = self.contentView.bounds;
}

- (void)setAsync:(BOOL)async {
    if (_async == async) return;
    _async = async;
    _uiLabel.hidden = async;
    _yyLabel.hidden = !async;
}

- (void)setAyncText:(id)text {
    if (_async) {
        _yyLabel.layer.contents = nil;
        _yyLabel.textLayout = text;
    } else {
        _uiLabel.attributedText = text;
    }
}

@end


@interface YYTextAsyncExample () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) BOOL async;
@property (nonatomic, strong) NSArray *strings;
@property (nonatomic, strong) NSArray *layouts;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat layoutWidth;
@end

@implementation YYTextAsyncExample

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [UITableView new];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[YYTextAsyncExampleCell class] forCellReuseIdentifier:@"id"];
    [self.view addSubview:self.tableView];
    
    
    
    NSMutableArray *strings = [NSMutableArray new];
    for (int i = 0; i < 300; i++) {
        NSString *str = [NSString stringWithFormat:@"%d Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫 Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫",i];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
        text.yy_font = [UIFont systemFontOfSize:10];
        text.yy_lineSpacing = 0;
        text.yy_strokeWidth = @(-3);
        text.yy_strokeColor = [UIColor redColor];
        text.yy_lineHeightMultiple = 1;
        text.yy_maximumLineHeight = 12;
        text.yy_minimumLineHeight = 12;
        
        NSShadow *shadow = [NSShadow new];
        shadow.shadowBlurRadius = 1;
        shadow.shadowColor = [UIColor redColor];
        shadow.shadowOffset = CGSizeMake(0, 1);
        [strings addObject:text];
        
    }
    self.strings = strings;
    
    
    
    UIVisualEffectView *toolbar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toolbar];
    [NSLayoutConstraint activateConstraints:@[
        [toolbar.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [toolbar.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [toolbar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [toolbar.heightAnchor constraintEqualToConstant:40],
        [self.tableView.topAnchor constraintEqualToAnchor:toolbar.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    
    
    YYFPSLabel *fps = [YYFPSLabel new];
    fps.centerY = 20;
    fps.left = 5;
    [toolbar.contentView addSubview:fps];
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"UILabel/YYLabel(Async): ";
    label.font = [UIFont systemFontOfSize:14];
    [label sizeToFit];
    label.centerY = 20;
    label.left = fps.right + 10;
    [toolbar.contentView addSubview:label];
    
    UISwitch *switcher = [UISwitch new];
    [switcher sizeToFit];
    switcher.centerY = 20;
    switcher.left = label.right + 10;
    switcher.layer.transformScale = 0.7;
    __weak typeof(self) _self = self;
    [switcher addBlockForControlEvents:UIControlEventValueChanged block:^(UISwitch *switcher) {
        typeof(_self) self = _self;
        if (!self) return;
        [self setAsync:switcher.isOn];
    }];
    [toolbar.contentView addSubview:switcher];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView layoutIfNeeded];
    CGFloat width = self.tableView.visibleCells.firstObject.contentView.bounds.size.width;
    if (width > 0 && width != self.layoutWidth) {
        self.layoutWidth = width;
        NSMutableArray *layouts = [NSMutableArray arrayWithCapacity:self.strings.count];
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(width, kCellHeight)];
        for (NSAttributedString *text in self.strings) {
            [layouts addObject:[YYTextLayout layoutWithContainer:container text:text]];
        }
        self.layouts = layouts;
        [self.tableView reloadData];
    }
}

- (void)setAsync:(BOOL)async {
    _async = async;
    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(YYTextAsyncExampleCell *cell, NSUInteger idx, BOOL *stop) {
        cell.async = async;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (_async) {
            [cell setAyncText:_layouts[indexPath.row]];
        } else {
            [cell setAyncText:_strings[indexPath.row]];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _strings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTextAsyncExampleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id" forIndexPath:indexPath];
    
    cell.async = _async;
    if (_async) {
        [cell setAyncText:_layouts[indexPath.row]];
    } else {
        [cell setAyncText:_strings[indexPath.row]];
    }
    
    return cell;
}

@end
