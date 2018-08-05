//
//  SAAppDelegate.h
//  spiritedarray
//
//  Created by Dave Horlick on 10/19/12.
//  Copyleft 2012 River Porpoise Software
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/MusicPlayer.h>

#import "SAMacView.h"
#import "SpiritedArray.h"
#import "SAVideoExportSettings.h"
#import "SAVideoExportSettingsController.h"

@interface SAAppDelegate : NSObject <NSApplicationDelegate>
{
    BOOL inaugural;
}
@property IBOutlet SAViewHelper* viewHelper; // TODO make this readonly?
@property (getter=desiredTileWidth, setter=setDesiredTileWidth:) IBOutlet NSNumber* desiredTileWidth;
@property (getter=desiredTileHeight, setter=setDesiredTileHeight:) IBOutlet NSNumber* desiredTileHeight;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet SAMacView *view;
@property (weak) IBOutlet NSView *exportSettingsView;
@property (weak) IBOutlet NSMenuItem *exportAsGif;
@property (weak) IBOutlet NSMenuItem *exportAsH264EncodedMp4Video;
@property (weak) IBOutlet NSMenuItem *exportAsH264EncodedQuickTimeMovie;
@property (weak) IBOutlet NSMenuItem* solidColors;
@property (weak) IBOutlet NSMenuItem* lightEmittingDiodes;
@property (weak) IBOutlet NSMenuItem* meta;
@property (weak) IBOutlet NSMenuItem* fatBits;
@property (weak) IBOutlet NSMenuItem* graphPaper;
@property (weak) IBOutlet NSMenuItem* crossStitch;
@property (weak) IBOutlet NSMenu* linePrinter;
@property (weak) IBOutlet NSMenu* tiling;
@property (weak) IBOutlet SAVideoExportSettingsController* videoExportSettingsController;
@property (weak) IBOutlet NSButton *lockIcon;
@property (weak) IBOutlet NSSlider *tileWidthSlider;
@property (weak) IBOutlet NSSlider *tileHeightSlider;

+(void) uncheckAllBut:(NSMenuItem*)selection In:(NSMenu*)menu;
+(void) uncheckAllButName:(NSString*)name In:(NSMenu*)menu;

-(IBAction) doOpenFile:(id)sender;
-(IBAction) doExportAsGif:(id)sender;

-(IBAction)doSolidColors:(id)sender;
-(IBAction)doLightEmittingDiodes:(id)sender;
-(IBAction)doFatBits:(id)sender;
-(IBAction)doGraphPaper:(id)sender;

-(IBAction)doExportAsH264EncodedMp4Video:(id)sender;
-(IBAction)doExportAsH264EncodedQuickTimeMovie:(id)sender;

- (IBAction)toggleResizeTileWidthAndHeightTogether:(id)sender;

@end
