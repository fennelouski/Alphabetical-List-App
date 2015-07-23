//
//  MasterViewController.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ALUDataManager.h"
#import "UIFont+AppFonts.h"
#import "NKFColor.h"
#import "NKFColor+Companies.h"
#import "NKFColor+Dates.h"
#import "NKFColor+WikipediaColors.h"
#import "NKFColor+AppColors.h"


#define kScreenWidth (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define DEFAULT_FONT_SIZE ((((kScreenHeight + kScreenWidth) * 0.02f) < 18.0f) ? 18.0f : (((kScreenHeight + kScreenWidth) * 0.02f) > 25.0f) ? 25.0f : ((kScreenHeight + kScreenWidth) * 0.02f))

@interface MasterViewController () <DetailViewControllerDelegate>

@property NSArray *objects;
@end

@implementation MasterViewController {
	UITextField *_alertTextField;
	NSDate *_lastReloadDate;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	self.objects = [[ALUDataManager sharedDataManager] lists];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewListButtonTouched:)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	self.navigationItem.title = @"";
	self.view.backgroundColor = [NKFColor white];
	self.navigationController.navigationBar.tintColor = [NKFColor appColor];
	
	if (self.objects.count > 0) {
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	self.navigationController.navigationBar.translucent = YES;
	self.navigationController.navigationBar.barTintColor = nil;
	self.navigationController.navigationBar.tintColor = [NKFColor appColor];
	[ALUDataManager sharedDataManager].currentColorIsDark = NO;
	[self.splitViewController setNeedsStatusBarAppearanceUpdate];
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)createNewListButtonTouched:(id)sender {
	UIAlertController *titleController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Note", nil)
																			 message:NSLocalizedString(@"Please give your Note a title", nil)
																	  preferredStyle:UIAlertControllerStyleAlert];
	[titleController addTextFieldWithConfigurationHandler:^(UITextField * __nonnull textField) {
		textField.placeholder = NSLocalizedString(@"Note Title", nil);
		textField.keyboardAppearance = UIKeyboardAppearanceLight;
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		textField.autocorrectionType = UITextAutocorrectionTypeYes;
		_alertTextField = textField;
	}];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * __nonnull action) {
															 
														 }];
	[titleController addAction:cancelAction];
	
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction * __nonnull action) {
														 if (_alertTextField.text.length > 0) {
															 [self insertNewList:_alertTextField.text];
														 }
													 }];
	[titleController addAction:okAction];
	
	[self presentViewController:titleController animated:YES completion:^{
		
	}];
}

- (void)insertNewObject:(id)sender {
	if (!self.objects) {
	    self.objects = [[ALUDataManager sharedDataManager] lists];
	}
	[[ALUDataManager sharedDataManager] addList:[[NSDate date] description]];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertNewList:(NSString *)listTitle {
	if (!self.objects) {
		self.objects = [[ALUDataManager sharedDataManager] lists];
	}
	[[ALUDataManager sharedDataManager] addList:listTitle];
	[self reloadList];
}

- (void)reloadList {
	self.objects = [[ALUDataManager sharedDataManager] lists];
	[self.tableView reloadData];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
	    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	    NSString *object = self.objects[indexPath.row];
	    DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
		[controller setDelegate:self];
	    [controller setDetailItem:object];
	    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
	    controller.navigationItem.leftItemsSupplementBackButton = YES;
		self.navigationController.navigationBar.barTintColor = [NKFColor colorForCompanyName:object];
		self.navigationController.navigationBar.tintColor = [(NKFColor *)self.navigationController.navigationBar.barTintColor oppositeBlackOrWhite];
		controller.navigationController.navigationBar.barTintColor = [NKFColor colorForCompanyName:object];
		controller.navigationController.navigationBar.tintColor = [(NKFColor *)self.navigationController.navigationBar.barTintColor oppositeBlackOrWhite];
		[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.navigationController.navigationBar.tintColor}];
		if ([(NKFColor *)self.navigationController.navigationBar.barTintColor isDark]) {
			[ALUDataManager sharedDataManager].currentColorIsDark = YES;
		} else {
			[ALUDataManager sharedDataManager].currentColorIsDark = NO;
		}
	} else {
		NSLog(@"Prepare Segue for \"%@\" won't do anything", sender);
	}
}

#pragma mark - Status Bar

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.navigationController.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
	return self.navigationController.visibleViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	if ([(NKFColor *)self.navigationController.navigationBar.barTintColor isDark]) {
		return UIStatusBarStyleLightContent;
	}
	
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	NSString *object = self.objects[indexPath.row];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
	cell.textLabel.attributedText = [NKFColor attributedStringForCompanyName:[object description]];
	UIImage *companyLogoImage = [[ALUDataManager sharedDataManager] imageForCompanyName:cell.textLabel.text];
	
	if (companyLogoImage && [NKFColor strictColorForCompanyName:cell.textLabel.text]) {
        cell.accessoryView.hidden = NO;
		if (cell.accessoryView && [cell.accessoryView respondsToSelector:@selector(setImage:)]) {
			UIImageView *accessoryView = (UIImageView *)cell.accessoryView;
			accessoryView.image = companyLogoImage;
		} else {
			UIImageView *imageView = [[UIImageView alloc] initWithImage:companyLogoImage];
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			CGFloat scale = 0.925f;
			CGRect frame = imageView.frame;
			frame.size.height = cell.frame.size.height * scale;
            frame.size.width = frame.size.height * scale;
            frame.origin.x = cell.frame.size.width - frame.size.width;
			imageView.frame = frame;
			imageView.clipsToBounds = YES;
			imageView.layer.cornerRadius = 2.0f;
			cell.accessoryView = imageView;
		}
	} else {
		cell.accessoryView.hidden = YES;
	}
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	    [[ALUDataManager sharedDataManager] removeList:self.objects[indexPath.row]];
		self.objects = [[ALUDataManager sharedDataManager] lists];
	    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self performSelector:@selector(reloadAfterDeleting) withObject:self afterDelay:0.35f];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
	    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	[self reloadAfterDeleting];
}

- (void)reloadAfterDeleting {
	if (!_lastReloadDate || [_lastReloadDate timeIntervalSinceNow] < -1) {
		self.objects = [[ALUDataManager sharedDataManager] lists];
		[self.tableView reloadData];
		_lastReloadDate = [NSDate date];
	}
}

@end
