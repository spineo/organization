//
//  EmployeeAddTableViewController.m
//  Organization
//
//  Created by Stuart Pineo on 1/5/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//
#import "EmployeeAddTableViewController.h"
#import "AppDelegate.h"
#import "Department.h"
#import "DepEmployee.h"
#import "Employee.h"
#import "ManagedObjectUtils.h"

@interface EmployeeAddTableViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableDictionary *departments;
@property (nonatomic, strong) NSString *empName;

@end

@implementation EmployeeAddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    [self initializeFetchedResultsController];
    
    _departments = [[NSMutableDictionary alloc] init];
    _empName     = @"";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)initializeFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Department"];
    
    NSSortDescriptor *depSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    [request setSortDescriptors:@[depSort]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != %@", UNASSIGNED];
    [request setPredicate:predicate];
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:@"name" cacheName:nil]];
    
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    
    @try {
        [[self fetchedResultsController] performFetch:&error];
    } @catch (NSException *exception) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSInteger numSections = [[[self fetchedResultsController] sections] count];
//    
//    return numSections;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
//    
//    return [sectionInfo numberOfObjects];
    if (section == 0) {
        return 1;
    } else {
        return self.fetchedResultsController.fetchedObjects.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmployeeCell" forIndexPath:indexPath];
    

    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    if (indexPath.section == 0) {
        [cell setAccessoryType: UITableViewCellAccessoryNone];
        
        UITextField *textField = [self createTextField:@"Employee Name" tag:1];
        [textField setFrame:CGRectMake(15.0, 7.0, self.tableView.bounds.size.width - 20.0, 30.0)];
        [textField setDelegate: self];
        [cell.contentView addSubview:textField];
        [textField setText:_empName];

        cell.textLabel.text = @"";

    } else {
        Department *dep = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row]];
        NSString *dep_name = [dep valueForKeyPath:@"name"];

        cell.textLabel.text = dep_name;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        Department *dep = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row]];
        NSString *dep_name = [dep valueForKeyPath:@"name"];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            [_departments removeObjectForKey:dep_name];
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            [_departments setObject:dep forKey:dep_name];
        }
        
        [tableView reloadData];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITextField *)createTextField:(NSString *)name tag:(NSInteger)tag {
    
    UITextField *textField = [[UITextField alloc] init];
    [textField setBackgroundColor: [UIColor whiteColor]];
    [textField setTextColor: [UIColor blackColor]];
    [textField.layer setCornerRadius: 5.0];
    [textField.layer setBorderWidth: 1.0];
    [textField setTag: tag];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setClearButtonMode: UITextFieldViewModeWhileEditing];
    [textField setPlaceholder:name];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 30.0)];
    [textField      setLeftView: paddingView];
    [textField      setLeftViewMode: UITextFieldViewModeAlways];
    
    // Allow for rotation
    //
    [textField setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    return textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _empName = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)save:(id)sender {

    if ([_empName isEqualToString:@""] || ! _empName) {
        [self showOkAlert:@"Employee Name" message:@"Employee name must have a value."];
        
    } else {
        if ([_departments count] == 0) {
            NSLog(@"Saving employee without department(s) association.");

            Department *dep = [ManagedObjectUtils queryDepartment:UNASSIGNED context:self.context];

            NSString *dep_name = [dep valueForKeyPath:@"name"];
            [_departments setObject:dep forKey:dep_name];

        } else {
            NSLog(@"Saving employee department(s) association.");
        }
            
        NSEntityDescription *empEntity = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.context];
        Employee *emp = [[Employee alloc] initWithEntity:empEntity insertIntoManagedObjectContext:self.context];
        [emp setName: _empName];

        NSEntityDescription *depEmpEntity = [NSEntityDescription entityForName:@"DepEmployee" inManagedObjectContext:self.context];
        for (NSString *dep_name in _departments) {
            Department *dep = [_departments objectForKey:dep_name];
            DepEmployee *de = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
            [dep addDepartment_deObject:de];
            [emp addEmployee_deObject:de];
        }
        
        NSError *error = nil;
        if (![self.context save:&error]) {
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        } else {
            NSLog(@"Save successful");
        }
    }
}

- (void)showOkAlert:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles: nil];
    [alert setTintColor: [UIColor blackColor]];
    
    [alert show];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
