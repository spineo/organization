//
//  DepartmentTableViewController.m
//  
//
//  Created by Stuart Pineo on 12/17/15.
//
//
#import "DepartmentTableViewController.h"
#import "AppDelegate.h"
#import "Department.h"
#import "DepEmployee.h"
#import "Employee.h"
#import "EmpDepTableViewController.h"
#import "ManagedObjectUtils.h"

@interface DepartmentTableViewController ()

// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *depEmpArray;
@property (nonatomic, strong) NSArray *empObjArray;
@property (nonatomic, strong) NSString *selEmpName;
@property (nonatomic) int init;

@end

@implementation DepartmentTableViewController

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Init
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Initialize NSManagedObject
    //
    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    [self initializeFetchedResultsController];
    [self insertData];
 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    //self.fetchedResultsController = nil;
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSLog(@"Unwind");
    [self initializeFetchedResultsController];
}

- (void)initializeFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DepEmployee"];
    
    NSSortDescriptor *depSort = [NSSortDescriptor sortDescriptorWithKey:@"de_department.name" ascending:YES];
    NSSortDescriptor *empSort = [NSSortDescriptor sortDescriptorWithKey:@"de_employee.name" ascending:YES];
    
    [request setSortDescriptors:@[depSort, empSort]];
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:@"de_department.name" cacheName:nil]];
    
    
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    
    @try {
        [[self fetchedResultsController] performFetch:&error];
    } @catch (NSException *exception) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (Employee *)queryEmployee:(NSString *)empName {

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate: [NSPredicate predicateWithFormat:@"name == %@", empName]];
    
    NSError *error      = nil;
    NSArray *results    = [self.context executeFetchRequest:fetch error:&error];
    
    return [results objectAtIndex:0];
}

- (void)insertData {
    // Execute if needed
    //
    [self deleteEntity:@"Employee"];
    [self deleteEntity:@"Department"];
    [self insertSample];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TableView
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    DepEmployee *depEmployee = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    NSString *emp_name = [depEmployee valueForKeyPath:@"de_employee.name"];

    cell.textLabel.text = emp_name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numSections = [[[self fetchedResultsController] sections] count];
    
    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];

    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrganizationCell"];
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //NSInteger row_num = [tableView numberOfRowsInSection:indexPath.section];
//    NSLog(@"ROW NUM=%i", (int)indexPath.row);
////    if ((indexPath.row > 0) && (indexPath.row == row_num) && (tableView.editing == FALSE)) {
////        return 0.0;
////    } else {
////        return 44.0;
////    }
//    return 44.0;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DepEmployee *depEmp = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        Department *dep = depEmp.de_department;
        NSString *depName = dep.name;
        
        int depCount = [ManagedObjectUtils checkDepCount:depName context:self.context];
        if (![depName isEqualToString:UNASSIGNED] && (depCount > 1)) {
            
            // Check the association count for this employee (if it dropped to zero, create an 'Unassigned' entry)
            //
            Employee *emp = depEmp.de_employee;
            NSString *empName = emp.name;
            int empCount = [ManagedObjectUtils checkEmpCount:empName context:self.context];
            
            NSError *error;
            if (empCount > 1) {
                [self.context deleteObject:depEmp];
                
            } else {
                [dep removeDepartment_deObject:depEmp];
                
                error = nil;
                if (![self.context save:&error]) {
                    NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                    return;
                }
                
                Department *uaDep = [ManagedObjectUtils queryDepartment:UNASSIGNED context:self.context];
                [uaDep addDepartment_deObject:depEmp];
            }
            
            error = nil;
            if (![self.context save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                return;
            }
            

        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        NSLog(@"Add...");
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    DepEmployee *depEmployee = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
   _selEmpName = [depEmployee valueForKeyPath:@"de_employee.name"];

    
//    if (indexPath.section == 1) {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        
//        Department *dep = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row]];
//        NSString *dep_name = [dep valueForKeyPath:@"name"];
//        
//        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            
//            [_departments removeObjectForKey:dep_name];
//        } else {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            
//            [_departments setObject:dep forKey:dep_name];
//        }
//        
//        [tableView reloadData];
//    }
//    if (cell.isSelected) {
        [self performSegueWithIdentifier:@"empDepSegue" sender:nil];
//    }
}

#pragma mark - TableView Header

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5.0, 5.0, tableView.bounds.size.width, 40.0)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, tableView.bounds.size.width, 38.0)];
    [headerView setBackgroundColor: [UIColor yellowColor]];
    
    [headerView addSubview:headerLabel];
    
    DepEmployee *depEmployee = [[self fetchedResultsController] objectAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:section]];

    [headerLabel setText:[[NSString alloc] initWithFormat: @"Department: %@", depEmployee.de_department.name]];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"empDepSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        EmpDepTableViewController *empDepController = (EmpDepTableViewController *)([navigationViewController viewControllers][0]);
        
        Employee *empObj = [self queryEmployee:_selEmpName];
        
        [empDepController setEmpObj:empObj];
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Core Data
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Query
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)deleteEntity:(NSString *)entity {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self.context]];
    
    [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID

    NSError *error = nil;
    NSArray *objects = [self.context executeFetchRequest:request error:&error];

    for (NSManagedObject *obj in objects) {
        [self.context deleteObject:obj];
    }

    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Save successful");
    }
}

- (void)insertSample {
    NSLog(@"Inserting Department, Employee, ...");
    
    // Create the Department entities and instances
    //
    NSEntityDescription *depEntity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.context];
    Department *dep1 = [[Department alloc] initWithEntity:depEntity insertIntoManagedObjectContext:self.context];
    [dep1 setName:@"Technology"];
    Department *dep2 = [[Department alloc] initWithEntity:depEntity insertIntoManagedObjectContext:self.context];
    [dep2 setName:@"Business"];
    Department *dep3 = [[Department alloc] initWithEntity:depEntity insertIntoManagedObjectContext:self.context];
    [dep3 setName:UNASSIGNED];
    
    
    // Create the Employee entities and instances
    //
    NSEntityDescription *empEntity = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.context];
    Employee *emp1 = [[Employee alloc] initWithEntity:empEntity insertIntoManagedObjectContext:self.context];
    [emp1 setName: @"Stuart"];
    Employee *emp2 = [[Employee alloc] initWithEntity: empEntity insertIntoManagedObjectContext:self.context];
    [emp2 setName: @"Linda"];
    Employee *emp3 = [[Employee alloc] initWithEntity: empEntity insertIntoManagedObjectContext:self.context];
    [emp3 setName: @"Isabel"];
    Employee *emp4 = [[Employee alloc] initWithEntity: empEntity insertIntoManagedObjectContext:self.context];
    [emp4 setName: @"Jiji"];
    Employee *emp5 = [[Employee alloc] initWithEntity: empEntity insertIntoManagedObjectContext:self.context];
    [emp5 setName: @"Robert"];
    Employee *emp6 = [[Employee alloc] initWithEntity: empEntity insertIntoManagedObjectContext:self.context];
    [emp6 setName: @"Julie"];

    // Create the DepEmployee entities and instances
    //
    NSEntityDescription *depEmpEntity = [NSEntityDescription entityForName:@"DepEmployee" inManagedObjectContext:self.context];
    DepEmployee *de1 = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
    [dep1 addDepartment_deObject:de1];
    [emp1 addEmployee_deObject:de1];

    DepEmployee *de2 = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
    [dep1 addDepartment_deObject:de2];
    [emp2 addEmployee_deObject:de2];

    DepEmployee *de3 = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
    [dep1 addDepartment_deObject:de3];
    [emp3 addEmployee_deObject:de3];

    DepEmployee *de4 = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
    [dep1 addDepartment_deObject:de4];
    [emp4 addEmployee_deObject:de4];

//    DepEmployee *de5 = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
//    [dep2 addDepartment_deObject:de5];
//    [emp1 addEmployee_deObject:de5];

    DepEmployee *de6 = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
    [dep2 addDepartment_deObject:de6];
    [emp5 addEmployee_deObject:de6];

    DepEmployee *de7 = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
    [dep2 addDepartment_deObject:de7];
    [emp6 addEmployee_deObject:de7];

    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Save successful");
    }
}


@end
