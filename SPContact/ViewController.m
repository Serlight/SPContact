//
//  ViewController.m
//  SPContact
//
//  Created by 何长春 on 15/7/3.
//  Copyright (c) 2015年 nuoqing. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import "Contact.h"
#import "ChineseContact.h"

@interface ViewController ()
@property (nonatomic, retain) NSMutableArray *contacts;
@property (retain, nonatomic) NSMutableArray *sortIndexs;
@property (retain, nonatomic) NSMutableDictionary *groupContact;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _contacts = [NSMutableArray array];
    [self setupAddressBook];
}

- (void)setupAddressBook {
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle:@"不能访问通讯录"
                                                                              message:@"你必须授权app访问通讯录的权限。"
                                                                             delegate:self
                                                                    cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                [cantAddContactAlert show];
                return ;
            }
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            CFIndex nPeople = ABAddressBookGetPersonCount(addressBookRef);
            for (int i = 0; i < nPeople; i ++) {
                Contact *contact = [[Contact alloc] init];
                ABRecordRef recordRef = CFArrayGetValueAtIndex(allPeople, i);
                NSString *firstName = CFBridgingRelease(ABRecordCopyValue(recordRef, kABPersonFirstNameProperty));
                contact.firstName = firstName;
                NSString *lastName = CFBridgingRelease(ABRecordCopyValue(recordRef, kABPersonLastNameProperty));
                contact.lastName = lastName;
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
                NSMutableArray *phones = [NSMutableArray array];
                CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
                for (CFIndex phoneIndex; phoneIndex < numberOfPhoneNumbers; phoneIndex ++ ) {
                    NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, phoneIndex));
                    [phones addObject:phoneNumber];
                    NSLog(@" phone:%@", phoneNumber);
                }
                contact.phoneNumbers = phones;
                [_contacts addObject:contact];
            }
            NSMutableArray *sortedContact = [ChineseContact returnSortedChineseArray:_contacts];
            _sortIndexs = [ChineseContact indexArrayWithSortContact:sortedContact];
            _groupContact = [ChineseContact leterSortArrayWithSortContact:sortedContact];
            NSLog(@"%lu", (unsigned long)sortedContact.count);
            
        });
    });
}

@end
