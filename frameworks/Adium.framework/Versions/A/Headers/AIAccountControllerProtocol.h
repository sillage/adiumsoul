/*
 *  AIAccountControllerProtocol.h
 *  Adium
 *
 *  Created by Evan Schoenberg on 7/30/06.
 *
 */

#import <Adium/AIControllerProtocol.h>

@class AIService, AIAccount, AIListContact;

#define Account_ListChanged 					@"Account_ListChanged"
#define Adium_RequestSetManualIdleTime			@"Adium_RequestSetManualIdleTime"

@protocol AIAccountController <AIController>

//Services
- (void)registerService:(AIService *)inService;
- (NSArray *)services;
- (NSSet *)activeServicesIncludingCompatibleServices:(BOOL)includeCompatible;
- (AIService *)serviceWithUniqueID:(NSString *)uniqueID;
- (AIService *)firstServiceWithServiceID:(NSString *)serviceID;

//Passwords
- (void)setPassword:(NSString *)inPassword forAccount:(AIAccount *)inAccount;
- (void)forgetPasswordForAccount:(AIAccount *)inAccount;
- (NSString *)passwordForAccount:(AIAccount *)inAccount;
- (void)passwordForAccount:(AIAccount *)inAccount notifyingTarget:(id)inTarget selector:(SEL)inSelector context:(id)inContext;
- (void)setPassword:(NSString *)inPassword forProxyServer:(NSString *)server userName:(NSString *)userName;
- (NSString *)passwordForProxyServer:(NSString *)server userName:(NSString *)userName;
- (void)passwordForProxyServer:(NSString *)server userName:(NSString *)userName notifyingTarget:(id)inTarget selector:(SEL)inSelector context:(id)inContext;

//Accounts
- (NSArray *)accounts;
- (NSArray *)accountsCompatibleWithService:(AIService *)service;
- (AIAccount *)accountWithInternalObjectID:(NSString *)objectID;
- (AIAccount *)createAccountWithService:(AIService *)service UID:(NSString *)inUID;
- (void)addAccount:(AIAccount *)inAccount;
- (void)deleteAccount:(AIAccount *)inAccount;
- (int)moveAccount:(AIAccount *)account toIndex:(int)destIndex;
- (void)accountDidChangeUID:(AIAccount *)inAccount;

//Preferred Accounts
- (AIAccount *)preferredAccountForSendingContentType:(NSString *)inType toContact:(AIListContact *)inContact;
- (AIAccount *)preferredAccountForSendingContentType:(NSString *)inType toContact:(AIListContact *)inContact includeOffline:(BOOL)includeOffline;
- (AIAccount *)firstAccountAvailableForSendingContentType:(NSString *)inType toContact:(AIListContact *)inContact includeOffline:(BOOL)includeOffline;

//Connection convenience methods
- (void)disconnectAllAccounts;
- (BOOL)oneOrMoreConnectedAccounts;
- (BOOL)oneOrMoreConnectedOrConnectingAccounts;

@end
