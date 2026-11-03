#import <XCTest/XCTest.h>
#import <YYText/YYText.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface YYTextTests : XCTestCase
@end

@implementation YYTextTests

- (void)testReadsLegacyRootObjectArchive {
    NSString *root = @"legacy archive";
    NSMutableData *data = [NSMutableData data];
    YYTextArchiver *archiver = [[YYTextArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeRootObject:root];
    [archiver finishEncoding];
    XCTAssertEqualObjects([YYTextUnarchiver unarchiveObjectWithData:data], root);
}

- (void)testLegacyAPICanReadNewRootObjectArchive {
    NSString *root = @"new archive";
    NSData *data = [YYTextArchiver archivedDataWithRootObject:root];
    XCTAssertNotNil(data);
    YYTextUnarchiver *unarchiver = [[YYTextUnarchiver alloc] initForReadingWithData:data];
    XCTAssertEqualObjects([unarchiver decodeObject], root);
    [unarchiver finishDecoding];
}

- (void)testAttributedStringArchiveRoundTrip {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"archive"];
    [text addAttribute:(id)kCTForegroundColorAttributeName value:(id)UIColor.redColor.CGColor range:NSMakeRange(0, text.length)];
    NSData *data = [text yy_archiveToData];
    XCTAssertNotNil(data);
    NSAttributedString *decoded = [NSAttributedString yy_unarchiveFromData:data];
    XCTAssertEqualObjects(decoded.string, text.string);
    CGColorRef color = (__bridge CGColorRef)[decoded attribute:(id)kCTForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
    XCTAssertNotEqual(color, NULL);
    if (color) XCTAssertTrue(CGColorEqualToColor(color, UIColor.redColor.CGColor));
}

- (void)testInvalidArchiveReturnsNil {
    XCTAssertNil([NSAttributedString yy_unarchiveFromData:[NSData data]]);
    XCTAssertNil([NSAttributedString yy_unarchiveFromData:[@"invalid" dataUsingEncoding:NSUTF8StringEncoding]]);
}

- (void)testParagraphStyleRoundTrip {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    style.paragraphSpacing = 12;
    style.headIndent = 7;
    style.defaultTabInterval = 36;
    style.tabStops = @[[[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentRight location:42 options:@{}]];
    CTParagraphStyleRef ctStyle = [style yy_CTStyle];
    XCTAssertNotEqual(ctStyle, NULL);
    if (!ctStyle) return;
    NSParagraphStyle *decoded = [NSParagraphStyle yy_styleWithCTStyle:ctStyle];
    CFRelease(ctStyle);
    XCTAssertEqual(decoded.alignment, style.alignment);
    XCTAssertEqualWithAccuracy(decoded.paragraphSpacing, 12, 0.001);
    XCTAssertEqualWithAccuracy(decoded.headIndent, 7, 0.001);
    XCTAssertEqualWithAccuracy(decoded.defaultTabInterval, 36, 0.001);
    XCTAssertEqual(decoded.tabStops.count, 1u);
    XCTAssertEqual(decoded.tabStops.firstObject.alignment, NSTextAlignmentRight);
    XCTAssertEqualWithAccuracy(decoded.tabStops.firstObject.location, 42, 0.001);
}

- (void)testPasteboardTypesAndAttributedString {
    UIPasteboard *board = [UIPasteboard pasteboardWithUniqueName];
    NSData *data = [@"image-data" dataUsingEncoding:NSUTF8StringEncoding];
    board.yy_PNGData = data;
    XCTAssertEqualObjects([board dataForPasteboardType:UTTypePNG.identifier], data);
    board.yy_JPEGData = data;
    XCTAssertEqualObjects([board dataForPasteboardType:UTTypeJPEG.identifier], data);
    board.yy_GIFData = data;
    XCTAssertEqualObjects([board dataForPasteboardType:UTTypeGIF.identifier], data);
    board.yy_WEBPData = data;
    XCTAssertEqualObjects([board dataForPasteboardType:YYTextUTTypeWEBP], data);
    board.yy_ImageData = data;
    XCTAssertEqualObjects([board dataForPasteboardType:UTTypeImage.identifier], data);
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"paste" attributes:@{NSForegroundColorAttributeName: UIColor.redColor}];
    board.yy_AttributedString = text;
    XCTAssertEqualObjects(board.string, text.string);
    XCTAssertEqualObjects(board.yy_AttributedString, text);
    BOOL hasArchivedText = NO;
    for (NSDictionary *item in board.items) {
        if (item[YYTextPasteboardTypeAttributedString]) hasArchivedText = YES;
    }
    XCTAssertTrue(hasArchivedText);
    [UIPasteboard removePasteboardWithName:board.name];
}

@end
