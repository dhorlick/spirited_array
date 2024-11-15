//
//  SAAppDelegate.m
//  spiritedarray
//
//  Created by Dave Horlick on 10/19/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SAAppDelegate.h"
#import "SpiritedArray.h"
#import "SALayer.h"
#import "GifEncoder.h"

#import "SATileDrawingStrategy.h"
#import "SALightEmittingDiodeTileDrawingStrategy.h"
#import "SAFatBitsTileDrawingStrategy.h"
#import "SAGraphPaperTileDrawingStrategy.h"
#import "SAH264AvEncoder.h"
#import "SAMacroblockedBounded.h"
@implementation SAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    inaugural = YES;
}

-(IBAction) doOpenFile:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
	[openDlg setAllowedFileTypes:[NSImage imageTypes]];
    
    [openDlg beginSheetModalForWindow: _window completionHandler: ^(NSInteger returnCode)
        {
            if (returnCode == NSOKButton)
            {
                NSURL* toOpen = [openDlg URL];
                NSString* fileName = [toOpen path];
                
                NSLog(@"got file %@", fileName);
                
				[self->_view setPostsBoundsChangedNotifications: YES];
                
                NSString* fileExtension = [fileName pathExtension];
                
                if ([fileExtension isCaseInsensitiveLike:@"gif"] || [fileExtension isCaseInsensitiveLike:@"png"])
                {
                    SATileDrawingStrategy* oldTileDrawingStrategy = nil;
                    if (self.viewHelper!=nil)
                        oldTileDrawingStrategy = [self.viewHelper tileDrawingStrategy];
                    
					self.viewHelper = [[SAViewHelper alloc] initWith:self->_view Path: fileName];
					if (self->inaugural)
                    {
                        [self doGraphPaper:nil];
						self->inaugural = NO;
                    }
                    else
                        [self.viewHelper setTileDrawingStrategy:oldTileDrawingStrategy];
                    
                    SALayer* layer = [[SALayer alloc] initWithViewHelper:self.viewHelper];
					self->_view.layer = layer;
                    
					layer.bounds = [self->_view bounds];
                    layer.timeValue = 0;
					if (@available(macOS 11, *))
					{
						layer.position = NSMakePoint(0, 0);
					}
					else
					{
						layer.position = NSMakePoint(CGRectGetMidX([self->_view bounds]), CGRectGetMidY([self->_view bounds]));
					}
					// NSLog(@"layer.position: %f, %f", layer.position.x, layer.position.y);
                    layer.delegate = self.viewHelper;
                    
                    CAMediaTimingFunction *timingfn = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                    
                    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"timeValue"];
                    anim.fromValue = 0;
                    NSLog(@"Mark! [self.viewHelper frames]=%u", [self.viewHelper frames]);
                    anim.toValue = [NSNumber numberWithDouble:(double)[self.viewHelper frames]-0.01];
                    anim.timingFunction = timingfn;
                    
                    uint average = [[self.viewHelper content] averageDelayInCentisBetweenFrames];
                    NSLog(@"average delay between frames in centis = %u", average);
                    
                    anim.duration = average * (double)[self.viewHelper frames] / 100.0;
                    NSLog(@"anim.duration = %f", anim.duration);
                    anim.repeatCount = INFINITY;
                    anim.fillMode = kCAFillModeForwards;
                    anim.removedOnCompletion = NO;
                
                    // TODO figure out how to get this from repeating integer timeValues
                    
                    [CATransaction begin];
                    [layer addAnimation:anim forKey:@"timeValue"];
					[self->_view setWantsLayer:YES];
                    [CATransaction commit];
                    
					[self->_exportAsGif setEnabled:YES];
					[self->_exportAsH264EncodedMp4Video setEnabled:YES];
					[self->_exportAsH264EncodedQuickTimeMovie setEnabled:YES];
                    
					[self->_lightEmittingDiodes setEnabled:YES];
					[self->_fatBits setEnabled:YES];
					[self->_solidColors setEnabled:YES];
					[self->_meta setEnabled: YES];
					[self->_graphPaper setEnabled:YES];
					
                    [self.tileWidthSlider setHidden:NO];
                    [self.tileHeightSlider setHidden:NO];
                    [self.lockIcon setHidden:NO];
                    
                    NSString* title = [[toOpen pathComponents] lastObject];
                    
                    if (title!=nil)
                        [[self.view window] setTitle:title]; // TODO concatenate with MIDI if loaded?
                }
                /* else if ([fileExtension isCaseInsensitiveLike:@"mid"]
                         || [fileExtension isCaseInsensitiveLike:@"midi"])
                {
                    CFURLRef midiFileURL = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, (const UInt8*)[fileName UTF8String], [fileName length]+1, false); // Why is +1 necessary here?
                    
                    MusicPlayer musicPlayer;
                    NewMusicPlayer(&musicPlayer);
                    
                    OSStatus result = noErr;
                    
                    MusicSequence musicSequence;
                    
                    result = NewMusicSequence(&musicSequence);
                    
                    if (result!=noErr)
                    {
                        [NSException raise:@"play" format:@"Can't create MusicSequence. Error code %d", (int)result];
                    }
                    
                    CFErrorRef thisErr;
                    if (!CFURLResourceIsReachable(midiFileURL, &thisErr))
                    {
                        CFStringRef pErrDesc = CFErrorCopyDescription( thisErr );
                        
                        if( pErrDesc != NULL )
                        {
                            [NSException raise:@"Can't resolve URL" format:@">> %@", pErrDesc];
                        }
                    }
                    
                    result = MusicSequenceFileLoad(musicSequence, midiFileURL, 0, 0);
                    
                    if (result!=noErr)
                    {
                        [NSException raise:@"play" format:@"Can't load MusicSequence. Error code %d", (int)result];
                    }
                    
                    MusicPlayerSetSequence(musicPlayer, musicSequence);
                    MusicPlayerPreroll(musicPlayer);
                    MusicPlayerStart(musicPlayer);
                } */
                else
                {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:@"Unrecognized File type"];
                    [alert setInformativeText:@"Sorry, but you can only open GIF and PNG files."];
                    [alert setAlertStyle:NSWarningAlertStyle];
                    
					[alert beginSheetModalForWindow:self->_window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
                }
            }
        }
     ];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode
        contextInfo:(void *)contextInfo
{
}

-(IBAction) doExportAsGif:(id)sender
{
    NSSavePanel* saveDialog = [NSSavePanel savePanel];
    [saveDialog setAllowedFileTypes: [[NSArray alloc] initWithObjects:@"gif", nil]];
    [saveDialog beginSheetModalForWindow: _window completionHandler: ^(NSInteger returnCode)
    {
        if (returnCode == NSOKButton)
        {
            NSURL* fileUrl = [saveDialog URL];
            NSString* fileName = [fileUrl path];
            
            NSLog(@"got file %@", fileName);
            
            GifEncoder* encoder = [GifEncoder new];
            unsigned long colorsCount = [encoder encode:[self.viewHelper freeze] FilePath:fileName]; // TODO find a way to do this without memorization
            if (colorsCount > 256U)
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"Too Many Output Colors"];
                [alert setInformativeText:[NSString stringWithFormat:@"Sorry, GIF's only support palettes of 256 colors. Yours has %lu, and automatic palette reduction isn't supported yet. Try manually reducing your palette by reducing your frame size, or switching to a simpler tiling strategy.", colorsCount]];
                [alert setAlertStyle:NSWarningAlertStyle];
				
                [alert beginSheetModalForWindow:self->_window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
            }
        }
    }];
}


-(IBAction) doSolidColors:(id)sender
{
    if (self.viewHelper != nil)
    {
        [self.viewHelper setTileDrawingStrategy: [SATileDrawingStrategy new]];
        [SAAppDelegate uncheckAllBut:_solidColors In:_tiling];
    }
}

-(IBAction) doLightEmittingDiodes:(id)sender
{
    if (self.viewHelper != nil)
    {
        [self.viewHelper setTileDrawingStrategy: [SALightEmittingDiodeTileDrawingStrategy new]];
        [SAAppDelegate uncheckAllBut:_lightEmittingDiodes In:_tiling];
    }
}

-(IBAction) doFatBits:(id)sender
{
    if (self.viewHelper != nil)
    {
        [self.viewHelper setTileDrawingStrategy: [SAFatBitsTileDrawingStrategy new]];
        [SAAppDelegate uncheckAllBut:_fatBits In:_tiling];
    }
}

- (IBAction)doGraphPaper:(id)sender
{
    if (self.viewHelper!=nil)
    {
        [self.viewHelper setTileDrawingStrategy: [SAGraphPaperTileDrawingStrategy new]];
        [SAAppDelegate uncheckAllBut:_graphPaper In:_tiling];
    }
}

-(void) setMenu:(NSMenu*)menu ItemsEnabled:(BOOL) enabled
{
    NSArray* menuItems = [menu itemArray];
    
    for (uint i=0U; i<[menuItems count]; i++)
    {
        NSMenuItem* menuItem = [menuItems objectAtIndex:i];
        [menuItem setEnabled:enabled];
    }
}

+(void) uncheckAllBut:(NSMenuItem*)selection In:(NSMenu*)menu
{
    NSArray* menuItems = [menu itemArray];
    
    for (uint i=0U; i<[menuItems count]; i++)
    {
        NSMenuItem* menuItem = [menuItems objectAtIndex:i];
        if (menuItem==selection)
            [menuItem setState:NSOnState];
        else
            [menuItem setState:NSOffState];
        
        if ([menuItem hasSubmenu])
        {
            [SAAppDelegate uncheckAllBut:selection In:[menuItem submenu]];
        }
    }
}

+(void) uncheckAllButName:(NSString*)name In:(NSMenu*)menu
{
    NSArray* menuItems = [menu itemArray];
    
    for (uint i=0U; i<[menuItems count]; i++)
    {
        NSMenuItem* menuItem = [menuItems objectAtIndex:i];
        if ([[menuItem title] isEqual: name])
            [menuItem setState:NSOnState];
        else
            [menuItem setState:NSOffState];

        if ([menuItem hasSubmenu])
        {
            [SAAppDelegate uncheckAllButName:name In:[menuItem submenu]];
        }
    }
}

-(void)setupVideoExportSettingsView
{
    SAMacroblockedBounded* macroblocked = [[SAMacroblockedBounded alloc] initWithBounded:self.view AndMacroblockOfWidth:8U AndHeight:8U];
    
    self.videoExportSettingsController.initialWidthInPixels = macroblocked.bounds.size.width;
    self.videoExportSettingsController.initialHeightInPixels = macroblocked.bounds.size.height;
    self.videoExportSettingsController.videoExportSettings.widthInPixels = [NSNumber numberWithFloat: macroblocked.bounds.size.width];
    self.videoExportSettingsController.videoExportSettings.heightInPixels = [NSNumber numberWithFloat: macroblocked.bounds.size.height];
    
    [self.videoExportSettingsController.dimensionsRadioButtonMatrix selectCellWithTag:0];
}

-(IBAction)doExportAsH264EncodedMp4Video:(id)sender
{
    NSSavePanel* panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes: [[NSArray alloc] initWithObjects:@"mp4", nil]];
    
    [panel setAccessoryView: self.exportSettingsView];
    [self setupVideoExportSettingsView];
    
    [panel beginSheetModalForWindow: _window completionHandler: ^(NSInteger returnCode)
     {
         if (returnCode == NSOKButton)
         {
             float tileFootprintCorrectionFactor = [self leastUpheavalTileFootprintCorrectionFactor];
             
             SAH264AvEncoder* encoder = [SAH264AvEncoder new];
             [encoder encode:[self.viewHelper spiritedArraySourceFilePath] TileDrawingStrategy:[self.viewHelper tileDrawingStrategy] WidthInPixels:[self.videoExportSettingsController.videoExportSettings.widthInPixels unsignedIntValue] HeightInPixels:[self.videoExportSettingsController.videoExportSettings.heightInPixels unsignedIntValue] TileWidthInPixels:tileFootprintCorrectionFactor*self.viewHelper.desiredTileWidth TileHeightInPixels:tileFootprintCorrectionFactor*self.viewHelper.desiredTileHeight Url:[panel URL] QuicktimeContainer:NO];
         }
     }
     ];
}

-(IBAction)doExportAsH264EncodedQuickTimeMovie:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes: [[NSArray alloc] initWithObjects:@"mov", nil]];
    [panel setAccessoryView: self.exportSettingsView];

    [self setupVideoExportSettingsView];
    [panel setAccessoryView: self.exportSettingsView];
    
    [panel beginSheetModalForWindow: _window completionHandler: ^(NSInteger returnCode)
     {
         if (returnCode == NSOKButton)
         {
             float tileFootprintCorrectionFactor = [self leastUpheavalTileFootprintCorrectionFactor];
             
             SAH264AvEncoder* encoder = [SAH264AvEncoder new];
             [encoder encode:[self.viewHelper spiritedArraySourceFilePath] TileDrawingStrategy:[self.viewHelper tileDrawingStrategy] WidthInPixels:[self.videoExportSettingsController.videoExportSettings.widthInPixels unsignedIntValue] HeightInPixels:[self.videoExportSettingsController.videoExportSettings.heightInPixels unsignedIntValue] TileWidthInPixels:tileFootprintCorrectionFactor*self.viewHelper.desiredTileWidth TileHeightInPixels:tileFootprintCorrectionFactor*self.viewHelper.desiredTileHeight Url:[panel URL] QuicktimeContainer:YES];
         }
     }
     ];
}

-(float) leastUpheavalTileFootprintCorrectionFactor
{
    float a = [self.videoExportSettingsController.videoExportSettings.widthInPixels floatValue] / (float)self.videoExportSettingsController.initialWidthInPixels;
    float b = [self.videoExportSettingsController.videoExportSettings.heightInPixels floatValue] / (float)self.videoExportSettingsController.initialHeightInPixels;
    
    float c;
    
    if (a>1 && b>1)
    {
        if (a>b)
            c = b;
        else
            c = a;
    }
    else if (a<1 && b<1)
    {
        if (a>b)
            c = a;
        else
            c = b;
    }
    else
    {
        c = 1.0f;
    }
    
    NSLog(@"tileFootprintCorrectionFactor=%f", c);
    
    return c;
}

- (IBAction)toggleResizeTileWidthAndHeightTogether:(id)sender
{
    if (!self.viewHelper.resizeTileWidthAndHeightTogether)
    {
        [self.lockIcon setTitle:@"🔒"];
        self.viewHelper.resizeTileWidthAndHeightTogether = true;
    }
    else
    {
        [self.lockIcon setTitle:@"🔓"];
        self.viewHelper.resizeTileWidthAndHeightTogether = false;
    }
}

@end
