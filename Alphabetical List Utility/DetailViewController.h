//
//  DetailViewController.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <CoreLocation/CoreLocation.h>

@protocol DetailViewControllerDelegate <NSObject>

- (void)reloadList;

@optional
// The open note was deleted from the editor's overflow menu; the presenter should
// tear the editor down without saving.
- (void)noteWasDeleted;

@end

@interface DetailViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, CNContactPickerDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UITextView *detailDescriptionLabel;

@property (nonatomic, strong) UITextView *listItemTextView;

@property (weak) id <DetailViewControllerDelegate> delegate;

// Persists the note text immediately. Called by the card UI before it reads the note
// back for the collapsed-card preview.
- (void)saveList;

@end

