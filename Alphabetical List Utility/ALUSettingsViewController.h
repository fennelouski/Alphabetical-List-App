//
//  ALUSettingsViewController.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/24/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALUSettingsViewDelegate <NSObject>

- (void)useWebIcon;
- (void)removeListModeNumbersCurrentSelectedTextRange:(NSRange)range replacementText:(NSString *)text;
- (void)listModeChanged;
- (void)showListIconChanged;
- (void)listRenameSelected;
- (void)alphabetize;
- (void)sendEmail;
- (void)selectLocation;
- (void)editIcon;
- (void)cardStyleChanged;
- (void)insertPhotoInNote;

@end

// The note's settings, as a sheet of inset-grouped rows with SF Symbols. Anything with
// options of its own (the icon, the card style, the location reminder) is a sub-page
// pushed onto the sheet's own navigation stack rather than another row in the same list.
@interface ALUSettingsViewController : UITableViewController

// Presents the settings sheet for a note. `hasNoteText` gates the rows that only make
// sense with something written down, e.g. emailing the note.
+ (void)presentForListName:(NSString *)listName
                     color:(UIColor *)color
               hasNoteText:(BOOL)hasNoteText
                  delegate:(id <ALUSettingsViewDelegate>)delegate
                      from:(UIViewController *)presenter;

@end
