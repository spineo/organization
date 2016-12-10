//
//  EmpDepTableViewController.m
//  Organization
//
//  Created by Stuart Pineo on 1/8/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import "EmpDepTableViewController.h"
#import "AppDelegate.h"
#import "Department.h"
#import "DepEmployee.h"
#import "ManagedObjectUtils.h"

@interface EmpDepTableViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSString *empName;
@property (nonatomic, strong) NSArray *departments;
@property (nonatomic, strong) NSSet *empDeps;
@property (nonatomic, strong) NSMutableDictionary *empDepsDict, *empDepsDictFlag;
@property (nonatomic) BOOL save;

@end

@implementation EmpDepTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _empName = _empObj.name;
    [self setTitle:[[NSString alloc] initWithFormat:@"Employee '%@' Detail", _empName]];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    _departments = [self queryDepartments];
    
    _empDeps = _empObj.employee_de;
    _empDepsDict = [[NSMutableDictionary alloc] init];
    for (DepEmployee *depEmp in _empDeps) {
        NSString *dep_name = [depEmp valueForKeyPath:@"de_department.name"];
        NSLog(@"EMP Dep: %@", dep_name);
        [_empDepsDict setObject:depEmp forKey:dep_name];
    }
    
    _empDepsDictFlag = [[NSMutableDictionary alloc] init];
    
    _save = FALSE;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSArray *)queryDepartments {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != %@", UNASSIGNED];
    [fetch setPredicate:predicate];
    
    NSError *error      = nil;
    NSArray *results    = [self.context executeFetchRequest:fetch error:&error];
    
    return results;
}

- (DepEmployee *)queryDepEmp:(NSString *)empName {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepEmployee" inManagedObjectContext:self.context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate: [NSPredicate predicateWithFormat:@"de_employee.name == %@", empName]];
    
    NSError *error      = nil;
    NSArray *results    = [self.context executeFetchRequest:fetch error:&error];
    
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_departments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmpDepCell" forIndexPath:indexPath];
    
    Department *depObj = [_departments objectAtIndex:indexPath.row];
    NSString *depName = depObj.name;
    cell.textLabel.text = depName;
    
    if (_empDepsDict[depName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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

- (IBAction)save:(id)sender {

    _save = TRUE;
    
    NSArray *cells = [self.tableView visibleCells];
    
    for (UITableViewCell *cell in cells) {
        NSString *depName = cell.textLabel.text;
        
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [_empDepsDictFlag setValue:[NSNumber numberWithInt:0] forKey:depName];

        } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [_empDepsDictFlag setValue:[NSNumber numberWithInt:1] forKey:depName];
        }
    }
}

- (IBAction)fire:(id)sender {
    
    // Make sure that at least one department association remains
    //
    for (Department *dep in _departments) {
        NSString *depName = dep.name;
        DepEmployee *dep_emp_obj = [ManagedObjectUtils getDepEmpObject:depName employee:_empName context:self.context];
        int dep_ct = [ManagedObjectUtils checkDepCount:depName context:self.context];
        if ((dep_emp_obj != nil) && (dep_ct == 1)) {
            [self showOkAlert:@"Can't Fire!" message:[[NSString alloc] initWithFormat:@"Need at least one employee associated with %@", depName]];
            return;
        }
    }
    
    //int dep_ct = [ManagedObjectUtils checkDepCount:depName context:self.context];

    
    // Remove department associations
    //
    for (Department *dep in _departments) {
        NSString *depName = dep.name;

        Department *depObj = [ManagedObjectUtils queryDepartment:depName context:self.context];
        DepEmployee *dep_emp_obj = [ManagedObjectUtils getDepEmpObject:depName employee:_empName context:self.context];

        if (dep_emp_obj != nil) {
            [depObj removeDepartment_deObject:dep_emp_obj];
        }
    }
    
    // Delete the employee object (this should cascade delete the Employee to EmpDepartment associatioins
    //
    [self.context deleteObject:_empObj];
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    
    [self showOkAlert:@"Employee Fired!" message:[[NSString alloc] initWithFormat:@"Employee %@ has been fired.", _empName]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    if (_save == 1) {
        
        BOOL deps = FALSE;
        NSEntityDescription *depEmpEntity = [NSEntityDescription entityForName:@"DepEmployee" inManagedObjectContext:self.context];
        NSError *error;

        for (NSString *depName in _empDepsDictFlag) {
            
            Department *depObj = [ManagedObjectUtils queryDepartment:depName context:self.context];
            DepEmployee *dep_emp_obj = [ManagedObjectUtils getDepEmpObject:depName employee:_empName context:self.context];
            int dep_ct = [ManagedObjectUtils checkDepCount:depName context:self.context];

            int value = [[_empDepsDictFlag valueForKey:depName] intValue];
            
            if (value == 1) {
                deps = TRUE;
                if (dep_emp_obj == nil) {
                    NSLog(@"Adding dep %@ association", depName);
                    
                    DepEmployee *depEmpObj = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
                    [depObj addDepartment_deObject:depEmpObj];
                    [_empObj addEmployee_deObject:depEmpObj];

                    error = nil;
                    if (![self.context save:&error]) {
                        NSLog(@"Can't Add %@ for employee %@! %@ %@", depName, _empName, error, [error localizedDescription]);
                        return;
                    }
                }
            
            } else {

                if (dep_emp_obj != nil) {
                    
                    if (dep_ct > 1) {
                        NSLog(@"Deleting dep %@ association", depName);
                        
                        [depObj removeDepartment_deObject:dep_emp_obj];
                        [_empObj removeEmployee_deObject:dep_emp_obj];
                        [self.context deleteObject:dep_emp_obj];
                        
                        error = nil;
                        if (![self.context save:&error]) {
                            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                            return;
                        }
                    
                    } else {
                        [self showOkAlert:@"Department Size" message:[[NSString alloc] initWithFormat:@"Need at least one employee associated with %@", depName]];
                    }
                }
            }
        }
        
        // Handle "Unassigned" if needed
        //
        Department *uaDepObj = [ManagedObjectUtils queryDepartment:UNASSIGNED context:self.context];
        DepEmployee *ua_dep_emp_obj = [ManagedObjectUtils getDepEmpObject:UNASSIGNED employee:_empName context:self.context];
        if (deps == 1) {
            if (ua_dep_emp_obj != nil) {
                NSLog(@"Deleting %@ association", UNASSIGNED);
                
                [uaDepObj removeDepartment_deObject:ua_dep_emp_obj];
                [_empObj removeEmployee_deObject:ua_dep_emp_obj];
                [self.context deleteObject:ua_dep_emp_obj];
                
                error = nil;
                if (![self.context save:&error]) {
                    NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                    return;
                }
            }
        } else {
            if (ua_dep_emp_obj == nil) {
                NSLog(@"Adding %@ association", UNASSIGNED);
                
                DepEmployee *uaDepEmpObj = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
                [uaDepObj addDepartment_deObject:uaDepEmpObj];
                [_empObj addEmployee_deObject:uaDepEmpObj];
                
                error = nil;
                if (![self.context save:&error]) {
                    NSLog(@"Can't Add %@ for employee %@! %@ %@", UNASSIGNED, _empName, error, [error localizedDescription]);
                    return;
                }
            }
        }
    }

//        NSArray *cells = [self.tableView visibleCells];
//        NSError *error;
//        
//        for (UITableViewCell *cell in cells) {
//            NSString *depName = cell.textLabel.text;
//            Department *depObj = [ManagedObjectUtils queryDepartment:depName context:self.context];
//            
//            if ((cell.accessoryType == UITableViewCellAccessoryNone) && _empDepsDict[depName]) {
//                NSLog(@"Remove Dep %@", cell.textLabel.text);
//                
//                int dep_ct = [ManagedObjectUtils checkDepCount:depName context:self.context];
//                
//                if (dep_ct > 1) {
//                    NSLog(@"DEL OBJ");
//                    DepEmployee *depEmpObj = [_empDepsDict objectForKey:depName];
//                    [depObj removeDepartment_deObject:depEmpObj];
//                    [_empObj removeEmployee_deObject:depEmpObj];
//                    [self.context deleteObject:depEmpObj];
//                    
//                    error = nil;
//                    if (![self.context save:&error]) {
//                        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
//                        return;
//                    }
//                    
//                    [_empDepsDict removeObjectForKey:depName];
//                    NSLog(@"EmpDeps dict count=%i", (int)[_empDepsDict count]);
//                    
//                } else {
//                    [self showOkAlert:@"Department Size" message:[[NSString alloc] initWithFormat:@"Need at least one employee associated with %@", depName]];
//                }
//                
//            } else if ((cell.accessoryType == UITableViewCellAccessoryCheckmark) && ! _empDepsDict[depName]) {
//                // Check if this employee is 'Unassigned' and, if so, remove
//                //
//                DepEmployee *uaDepEmpObj = [_empDepsDict objectForKey:UNASSIGNED];
//                if (uaDepEmpObj) {
//                    NSLog(@"Removing 'Unassigned' association");
//                    [depObj removeDepartment_deObject:uaDepEmpObj];
//                    [_empObj removeEmployee_deObject:uaDepEmpObj];
//                    [self.context deleteObject:uaDepEmpObj];
//                    
//                    error = nil;
//                    if (![self.context save:&error]) {
//                        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
//                        return;
//                    }
//                    
//                    [_empDepsDict removeObjectForKey:UNASSIGNED];
//                }
//                
//                NSLog(@"Add Dep %@", cell.textLabel.text);
//                
//                DepEmployee *depEmpObj = [self queryDepEmp:_empName];
//                
//                if (depEmpObj == nil) {
//                    NSEntityDescription *depEmpEntity = [NSEntityDescription entityForName:@"DepEmployee" inManagedObjectContext:self.context];
//                    depEmpObj = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
//                }
//                
//                [depObj addDepartment_deObject:depEmpObj];
//                [_empObj addEmployee_deObject:depEmpObj];
//                
//                error = nil;
//                if (![self.context save:&error]) {
//                    NSLog(@"Can't Add %@ for employee %@! %@ %@", depName, _empName, error, [error localizedDescription]);
//                    return;
//                }
//                
//                [_empDepsDict setObject:depEmpObj forKey:depName];
//                NSLog(@"EmpDeps dict count=%i", (int)[_empDepsDict count]);
//                
//            }
//        }
//        
//        // Make sure that, if employee/department association is zero to make the employee 'Unassigned'
//        //
//        int emp_ct = [ManagedObjectUtils checkEmpCount:_empName context:self.context];
//        if (emp_ct == 0) {
//            NSLog(@"No deps for this employee, adding 'Unassigned' association");
//            NSEntityDescription *depEmpEntity = [NSEntityDescription entityForName:@"DepEmployee" inManagedObjectContext:self.context];
//            DepEmployee *uaDepEmpObj = [[DepEmployee alloc] initWithEntity:depEmpEntity insertIntoManagedObjectContext:self.context];
//            Department *depObj = [ManagedObjectUtils queryDepartment:UNASSIGNED context:self.context];
//            
//            if (! uaDepEmpObj) {
//                NSLog(@"DepEmployee object is nil!");
//            }
//            NSLog(@"Deparment is %@", depObj.name);
//            NSLog(@"Employee is %@", _empObj.name);
//            
//            [depObj addDepartment_deObject:uaDepEmpObj];
//            [_empObj addEmployee_deObject:uaDepEmpObj];
//            
//            error = nil;
//            if (![self.context save:&error]) {
//                NSLog(@"Can't Add %@ for employee %@! %@ %@", UNASSIGNED, _empName, error, [error localizedDescription]);
//                return;
//            }
//            
//            [_empDepsDict setObject:uaDepEmpObj forKey:UNASSIGNED];
//        }

    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
