//
//  ViewController.m
//  LifeTool
//
//  Created by Zzy on 9/2/14.
//  Copyright (c) 2014 Chihya Tsang. All rights reserved.
//

#import "PhoneViewController.h"
#import "Person.h"
#import <AddressBook/AddressBook.h>

typedef void (^RequestAddressBookBlock)(BOOL success);

@interface PhoneViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) NSMutableArray *addressBook;
@property (strong, nonatomic) NSMutableArray *matchAddressBook;
@property (nonatomic, getter = isMatching) BOOL matching;
@end

@implementation PhoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addressBook = [[NSMutableArray alloc] init];
    self.matchAddressBook = [[NSMutableArray alloc] init];
    
    [self.inputTextField becomeFirstResponder];
    [self requestAddressBookAccessWithBlock:^(BOOL success) {
        if (success) {
            [self.tableView reloadData];
        } else {
            
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isMatching) {
        return self.matchAddressBook.count;
    }
    return self.addressBook.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Phone"];
    Person *person;
    if (self.isMatching) {
        person = [self.matchAddressBook objectAtIndex:indexPath.row];
    } else {
        person = [self.addressBook objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", (person.lastName ? person.lastName : @""), (person.firstName ? person.firstName : @"")];
    cell.detailTextLabel.text = person.phoneNumber;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Person *person;
    if (self.isMatching) {
        person = [self.matchAddressBook objectAtIndex:indexPath.row];
    } else {
        person = [self.addressBook objectAtIndex:indexPath.row];
    }
    [self callWithPhoneNumber:person.phoneNumber];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *inputNumber = @"";
    if ([string isEqualToString:@""]) {
        NSInteger index = textField.text.length - 1;
        if (index < 0) {
            index = 0;
        }
        inputNumber = [textField.text substringToIndex:index];
    } else {
        inputNumber = [textField.text stringByAppendingString:string];
    }
    if (inputNumber.length > 0) {
        self.matching = YES;
        [self.matchAddressBook removeAllObjects];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (Person *item in self.addressBook) {
            NSString *phoneNumer = [item.phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phoneNumer = [phoneNumer stringByReplacingOccurrencesOfString:@"+" withString:@""];
            if ([phoneNumer hasPrefix:inputNumber]) {
                [self.matchAddressBook addObject:item];
            } else if ([phoneNumer rangeOfString:inputNumber].length > 0) {
                [tempArray addObject:item];
            }
        }
        [self.matchAddressBook addObjectsFromArray:tempArray];
    } else {
        self.matching = NO;
    }
    [self.tableView reloadData];
    return YES;
}

- (void)requestAddressBookAccessWithBlock:(RequestAddressBookBlock)block
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            [self getAddressBookWithRef:addressBookRef];
            if (block) {
                block(YES);
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self getAddressBookWithRef:addressBookRef];
        if (block) {
            block(YES);
        }
    } else {
        if (block) {
            block(NO);
        }
    }
}

- (void)getAddressBookWithRef:(ABAddressBookRef)addressBookRef
{
    CFArrayRef addressArr = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    for (NSInteger i = 0; i < CFArrayGetCount(addressArr); i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(addressArr, i);
        NSString *firstName = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int j = 0; j < ABMultiValueGetCount(phone); j++) {
            NSString *phoneNumber = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, j));
            Person *person = [[Person alloc] initWithFirstName:firstName lastName:lastName phoneNumber:phoneNumber];
            [self.addressBook addObject:person];
        }
        CFRelease(phone);
        CFRelease(person);
    }
    CFRelease(addressArr);
}

- (void)callWithPhoneNumber:(NSString *)phoneNumber
{
    NSString *tel = [[NSString alloc] initWithFormat:@"telprompt://%@", phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
}

- (IBAction)onClickSendMessage:(id)sender
{
    if (self.inputTextField.text.length > 0) {
        [self callWithPhoneNumber:self.inputTextField.text];
    }
}

- (IBAction)onClickCallNumber:(id)sender
{
    if (self.inputTextField.text.length > 0) {
        [self callWithPhoneNumber:self.inputTextField.text];
    }
}
@end
