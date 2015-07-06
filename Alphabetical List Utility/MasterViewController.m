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
#import "UIColor+AppColors.h"
#import "UIFont+AppFonts.h"
#import "UIColor+BrandColors.h"

#define kScreenWidth (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define DEFAULT_FONT_SIZE ((((kScreenHeight + kScreenWidth) * 0.02f) < 18.0f) ? 18.0f : (((kScreenHeight + kScreenWidth) * 0.02f) > 25.0f) ? 25.0f : ((kScreenHeight + kScreenWidth) * 0.02f))

@interface MasterViewController ()

@property NSArray *objects;
@end

@implementation MasterViewController {
	UITextField *_alertTextField;
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
	self.view.backgroundColor = [UIColor white];
	self.navigationController.navigationBar.tintColor = [UIColor appColor];
}

- (void)viewWillAppear:(BOOL)animated {
	self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)createNewListButtonTouched:(id)sender {
	UIAlertController *titleController = [UIAlertController alertControllerWithTitle:@"New Note"
																			 message:@"Please give your Note a title"
																	  preferredStyle:UIAlertControllerStyleAlert];
	[titleController addTextFieldWithConfigurationHandler:^(UITextField * __nonnull textField) {
		textField.placeholder = @"Note Title";
		textField.keyboardAppearance = UIKeyboardAppearanceAlert;
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		textField.autocorrectionType = UITextAutocorrectionTypeYes;
		_alertTextField = textField;
	}];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * __nonnull action) {
															 
														 }];
	[titleController addAction:cancelAction];
	
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
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
	self.objects = [[ALUDataManager sharedDataManager] lists];
	[self.tableView reloadData];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
	    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	    NSDate *object = self.objects[indexPath.row];
	    DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
	    [controller setDetailItem:object];
	    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
	    controller.navigationItem.leftItemsSupplementBackButton = YES;
	}
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
	cell.textLabel.text = [object description];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
	cell.textLabel.textColor = [[UIColor black] colorForCompanyName:cell.textLabel.text];
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
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
	    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}
}

@end
