//
//  spiritedarrayTests.m
//  spiritedarrayTests
//
//  Created by Dave Horlick on 10/19/12.
//  Copyleft 2012 River Porpoise Software
//

#import "spiritedarrayTests.h"
#import "MemorizedSpiritedArray.h"
#import "UnUpSampler.h"
#import "SpiritedArray.h"
#import "OptimizedSpiritedArray.h"
#import "StreamedGifDecoder.h"
#import "GifEncoder.h"
#import "SpiritedArrayFactory.h"
#import "AppKitAwareSpiritedArrayFactory.h"

@implementation spiritedarrayTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testStuff
{
    // STFail(@"Unit tests are not implemented yet in spiritedarrayTests");
    MemorizedSpiritedArray* msa = [[MemorizedSpiritedArray alloc] initWith:1 Width:9 Height:6];
    
    SAColorType red;
    red.Red = 100;
    red.Green = 0;
    red.Blue = 0;
    
    SAColorType green;
    green.Red = 0;
    green.Green = 100;
    green.Blue = 0;
    
    SAColorType blue;
    green.Red = 0;
    green.Green = 0;
    green.Blue = 100;
    
    [msa writePixelColorAtFrame:0 X:0 Y:0 Color:red];
    [msa writePixelColorAtFrame:0 X:1 Y:0 Color:red];
    [msa writePixelColorAtFrame:0 X:2 Y:0 Color:red];
    [msa writePixelColorAtFrame:0 X:3 Y:0 Color:green];
    [msa writePixelColorAtFrame:0 X:4 Y:0 Color:green];
    [msa writePixelColorAtFrame:0 X:5 Y:0 Color:green];
    [msa writePixelColorAtFrame:0 X:6 Y:0 Color:blue];
    [msa writePixelColorAtFrame:0 X:7 Y:0 Color:blue];
    [msa writePixelColorAtFrame:0 X:8 Y:0 Color:blue];
    
    [msa writePixelColorAtFrame:0 X:0 Y:1 Color:red];
    [msa writePixelColorAtFrame:0 X:1 Y:1 Color:red];
    [msa writePixelColorAtFrame:0 X:2 Y:1 Color:red];
    [msa writePixelColorAtFrame:0 X:3 Y:1 Color:green];
    [msa writePixelColorAtFrame:0 X:4 Y:1 Color:green];
    [msa writePixelColorAtFrame:0 X:5 Y:1 Color:green];
    [msa writePixelColorAtFrame:0 X:6 Y:1 Color:blue];
    [msa writePixelColorAtFrame:0 X:7 Y:1 Color:blue];
    [msa writePixelColorAtFrame:0 X:8 Y:1 Color:blue];
    
    [msa writePixelColorAtFrame:0 X:0 Y:2 Color:red];
    [msa writePixelColorAtFrame:0 X:1 Y:2 Color:red];
    [msa writePixelColorAtFrame:0 X:2 Y:2 Color:red];
    [msa writePixelColorAtFrame:0 X:3 Y:2 Color:green];
    [msa writePixelColorAtFrame:0 X:4 Y:2 Color:green];
    [msa writePixelColorAtFrame:0 X:5 Y:2 Color:green];
    [msa writePixelColorAtFrame:0 X:6 Y:2 Color:blue];
    [msa writePixelColorAtFrame:0 X:7 Y:2 Color:blue];
    [msa writePixelColorAtFrame:0 X:8 Y:2 Color:blue];
    
    [msa writePixelColorAtFrame:0 X:0 Y:3 Color:green];
    [msa writePixelColorAtFrame:0 X:1 Y:3 Color:green];
    [msa writePixelColorAtFrame:0 X:2 Y:3 Color:green];
    [msa writePixelColorAtFrame:0 X:3 Y:3 Color:red];
    [msa writePixelColorAtFrame:0 X:4 Y:3 Color:red];
    [msa writePixelColorAtFrame:0 X:5 Y:3 Color:red];
    [msa writePixelColorAtFrame:0 X:6 Y:3 Color:blue];
    [msa writePixelColorAtFrame:0 X:7 Y:3 Color:blue];
    [msa writePixelColorAtFrame:0 X:8 Y:3 Color:blue];
    
    [msa writePixelColorAtFrame:0 X:0 Y:4 Color:green];
    [msa writePixelColorAtFrame:0 X:1 Y:4 Color:green];
    [msa writePixelColorAtFrame:0 X:2 Y:4 Color:green];
    [msa writePixelColorAtFrame:0 X:3 Y:4 Color:red];
    [msa writePixelColorAtFrame:0 X:4 Y:4 Color:red];
    [msa writePixelColorAtFrame:0 X:5 Y:4 Color:red];
    [msa writePixelColorAtFrame:0 X:6 Y:4 Color:blue];
    [msa writePixelColorAtFrame:0 X:7 Y:4 Color:blue];
    [msa writePixelColorAtFrame:0 X:8 Y:4 Color:blue];
    
    [msa writePixelColorAtFrame:0 X:0 Y:5 Color:green];
    [msa writePixelColorAtFrame:0 X:1 Y:5 Color:green];
    [msa writePixelColorAtFrame:0 X:2 Y:5 Color:green];
    [msa writePixelColorAtFrame:0 X:3 Y:5 Color:red];
    [msa writePixelColorAtFrame:0 X:4 Y:5 Color:red];
    [msa writePixelColorAtFrame:0 X:5 Y:5 Color:red];
    [msa writePixelColorAtFrame:0 X:6 Y:5 Color:blue];
    [msa writePixelColorAtFrame:0 X:7 Y:5 Color:blue];
    [msa writePixelColorAtFrame:0 X:8 Y:5 Color:blue];
    XCTAssertEqual(1U, [msa frames], @"msa reports incorrect number of frames.");
    [self makeSureArrayLooksRight: msa Red:red Green:green Blue:blue];
    [self makeSureArrayLooksRight: msa Red:red Green:green Blue:blue];
    
    UnUpSampler* uus = [[UnUpSampler alloc] initWith:msa TargetWidth:100 TargetHeight:100 TileWidth:1 TileHeight:1];
    XCTAssertEqual(UN_UP, [uus samplingType], @"wrong sampling type");
    SpiritedArray* content = [uus content];
    XCTAssertEqual(3U, [content width]);  // [NSString localizedStringWithFormat: @"wrong width %u", [content width]]
    XCTAssertEqual(2U, [content height]);  // [NSString localizedStringWithFormat: @"wrong height %u", [content height]]
    
    XCTAssertTrue(SAEqualColorTypes(red, [content pixelColorAtFrame:0 X:0 Y:0]));  // @"pixel #1 isn't red"
    XCTAssertTrue(SAEqualColorTypes(green, [content pixelColorAtFrame:0 X:1 Y:0]));  // @"pixel #2 isn't green"
    XCTAssertTrue(SAEqualColorTypes(blue, [content pixelColorAtFrame:0 X:2 Y:0]));  // @"pixel #3 isn't blue"
    
    SAColorType pixel = [content pixelColorAtFrame:0 X:0 Y:1];
	XCTAssertTrue(SAEqualColorTypes(green, pixel)); // @"pixel #4 isn't green, it's %@", SADescribeColorType(pixel)
    pixel = [content pixelColorAtFrame:0 X:1 Y:1];
    XCTAssertTrue(SAEqualColorTypes(red, pixel));  // @"pixel #5 isn't red, it's %@", SADescribeColorType(pixel)
    pixel = [content pixelColorAtFrame:0 X:2 Y:1];
    XCTAssertTrue(SAEqualColorTypes(blue, pixel));  // @"pixel #6 isn't blue, it's %@" SADescribeColorType(pixel)
    
    SpiritedArrayIterator* sai =[[SpiritedArrayIterator alloc] initWithSpiritedArray:content];
    XCTAssertEqual(1U, [sai frames]);
    XCTAssertEqual([sai width], [content width]);  // @"iterator and iterator source report different widths"
    XCTAssertEqual([sai height], [content height]);  // @"iterator and iterator source report different heights"
    XCTAssertTrue([sai arrayHasAnotherFrame]);  //  @"sai claims not to have any frames."
    
    uint x=0U,y=0U,frame=0U;
    
    while ([sai arrayHasAnotherFrame])
    {
        x = -1;
        y = -1;
        [sai nextFrame];
        
        while ([sai imageHasAnotherRow])
        {
            x = -1;
            [sai nextRow];
            
            while ([sai rowHasAnotherPixel])
            {
                [sai nextPixel];
                x++;
            }
            
            y++;
        }
        
        frame++;
    }
    
    XCTAssertEqual(y, [content height]-1, @"iterator iterated over all rows");
    XCTAssertEqual(x, [content width]-1, @"iterator iterated over all column");
    
    [sai close];
    
    OptimizedSpiritedArray* osa = [[OptimizedSpiritedArray alloc] initWith:msa];
    [self makeSureArrayLooksRight:osa Red:red Green:green Blue:blue];
    
    SAColorType filtered1 = filterPixel(red, red);
    XCTAssertTrue(SAEqualColorTypes(filtered1, red), @"Red filtered against Red != Red; it's %@", SADescribeColorType(filtered1));
    
    SAColorType white = {100, 100, 100};
    
    SAColorType filtered2 = filterPixel(white, red);
    XCTAssertTrue(SAEqualColorTypes(filtered2, red), @"White filtered against Red != Red; it's %@", SADescribeColorType(filtered2));
    
    SAColorType black = {0, 0, 0};
    
    SAColorType filtered3 = filterPixel(blue, red);
    XCTAssertTrue(SAEqualColorTypes(filtered3, black), @"Blue filtered against Red != Black; it's %@", SADescribeColorType(filtered3));
    
    SAColorType purple = {50, 0, 50};
    SAColorType darkRed = {50, 0, 0};
    
    SAColorType filtered4 = filterPixel(purple, red);
    XCTAssertTrue(SAEqualColorTypes(filtered4, darkRed), @"Purple filtered against Red != Dark Red; it's %@", SADescribeColorType(filtered4));
    
    /* SAColorType filtered5 = filterPixel(red, purple);
    XCTAssertTrue(SAEqualColorTypes(filtered5, purple), @"Red filtered against Purple != Purple; it's %@", SADescribeColorType(filtered5)); */
    
    unsigned long anotherResult = [GifEncoder lowestPowerOfTwoThatIsNotLessThan: 61lu];
    XCTAssertEqual(64lu, anotherResult, @"%u != 64", anotherResult);
    
    unsigned long anotherOtherResult = [GifEncoder lowestPowerOfTwoThatIsNotLessThan:188lu];
    XCTAssertEqual(256lu, anotherOtherResult, @"%u != 256", anotherResult);
}

-(void) dontTestGif
{
    StreamedGifDecoder *spiritedArrayFromFile = (StreamedGifDecoder*) [SpiritedArrayFactory build:@"spiritedarrayTests2/nyan.gif"];  // TODO unbreak this resource
    
    [spiritedArrayFromFile setRespoolHandler: ^()
    {
        XCTFail(@"respooled, but shouldn't have");
    }];
    
    SpiritedArray* result = [[OptimizedSpiritedArray alloc] initWith:spiritedArrayFromFile];
    XCTAssertEqual([result frames], 6U, @"nyan.gif has wrong number of frames: %u", [result frames]);
    XCTAssertEqual([result width], 258U, @"nyan.gif has wrong width: %u", [result width]);
    XCTAssertEqual([result height], 181U, @"nyan.gif has wrong height: %u", [result height]);
    
    GifEncoder* encoder = [GifEncoder new];
    [encoder encode:result FilePath:[self pathForTemporaryFileWithPrefix:@"lalala"]];
}

-(void) dontTestPng
{
    SpiritedArray *spiritedArrayFromFile = [AppKitAwareSpiritedArrayFactory build:@"spiritedarrayTests2/nyan_frame_1.png"];  // TODO unbreak this resource
    
    XCTAssertEqual([spiritedArrayFromFile frames], 1U, @"nyan_frame_1 has wrong number of frames: %u", [spiritedArrayFromFile frames]);
    XCTAssertEqual([spiritedArrayFromFile width], 258U, @"nyan_frame_1 has wrong width: %u", [spiritedArrayFromFile width]);
    XCTAssertEqual([spiritedArrayFromFile height], 181U, @"nyan_frame_1 has wrong height: %u", [spiritedArrayFromFile height]);
    
    SpiritedArray* result = [[OptimizedSpiritedArray alloc] initWith:spiritedArrayFromFile];
    XCTAssertEqual([result frames], 1U, @"optimized view of nyan_frame_1 has wrong number of frames: %u", [result frames]);
    XCTAssertEqual([result width], 258U, @"optimized view of nyan_frame_1 has wrong width: %u", [result width]);
    XCTAssertEqual([result height], 181U, @"optimized view of nyan_frame_1 has wrong height: %u", [result height]);
    
    @try {
        [AppKitAwareSpiritedArrayFactory build:@"spiritedarrayTests/i_dont_exist.png"];
        XCTFail(@"Attempt to open nonexistent PNG file didn't result in an exception.");
    }
    @catch (NSException * e) {
        // good
    }
}

-(void) makeSureArrayLooksRight: (SpiritedArray*)spiritedArray Red:(SAColorType)red Green:(SAColorType)green Blue:(SAColorType) blue
{
    SpiritedArrayIterator* sai2 =[[SpiritedArrayIterator alloc] initWithSpiritedArray:spiritedArray];
    [sai2 nextFrame];
    [sai2 nextRow];
    
    [self assertNextPixelColor:@"Test 1" SpiritedArrayIterator:sai2 Color:red];
    [self assertNextPixelColor:@"Test 2" SpiritedArrayIterator:sai2 Color:red];
    [self assertNextPixelColor:@"Test 3" SpiritedArrayIterator:sai2 Color:red];
    [self assertNextPixelColor:@"Test 4" SpiritedArrayIterator:sai2 Color:green];
    [self assertNextPixelColor:@"Test 5" SpiritedArrayIterator:sai2 Color:green];
    [self assertNextPixelColor:@"Test 6" SpiritedArrayIterator:sai2 Color:green];
    [self assertNextPixelColor:@"Test 7" SpiritedArrayIterator:sai2 Color:blue];
    [self assertNextPixelColor:@"Test 8" SpiritedArrayIterator:sai2 Color:blue];
    [self assertNextPixelColor:@"Test 9" SpiritedArrayIterator:sai2 Color:blue];
    [sai2 nextRow];
    [self assertNextPixelColor:@"Test 10" SpiritedArrayIterator:sai2 Color:red];
    
    [sai2 close];
}

-(void) assertNextPixelColor:(NSString*)message SpiritedArrayIterator:(SpiritedArrayIterator*)sai Color:(SAColorType) color
{
    SAColorType result = [sai nextPixel];
    XCTAssertTrue(SAEqualColorTypes(result, color), @"%@: %@ != %@", message, SADescribeColorType(color), SADescribeColorType(result));
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

@end
