//
//  JHEncyptedObjects.m
//  LongosApp
//
//  Created by justin howlett on 2013-06-20.
//  Copyright (c) 2013 Longos. All rights reserved.
//

#import "JHEncyptedObjects.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"

#define SECURE_PASSWORD @"Your_Password"

@implementation JHEncyptedObjects

#pragma mark -
#pragma mark - utility methods

+(NSData*)encryptedDataForData:(NSData*)input{
    
    NSData* encryptedData   = [RNEncryptor encryptData:input withSettings:kRNCryptorAES256Settings password:SECURE_PASSWORD error:nil];
    
    return encryptedData;
}

+(NSData*)decryptedDataForData:(NSData*)input{
    NSData* decryptedData = [RNDecryptor decryptData:input withPassword:SECURE_PASSWORD error:nil];
    
    return decryptedData;
}

+(NSData*)encryptedDataForString:(NSString*)string{
    NSData* data            = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData* encryptedData   = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:SECURE_PASSWORD error:nil];
    
    return encryptedData;
}

+(NSString*)decryptedStringForData:(NSData*)data{
    
    NSData* decryptedData = [RNDecryptor decryptData:data withPassword:SECURE_PASSWORD error:nil];
    NSString* decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}

@end

#pragma mark -
#pragma mark - NSValueTransformer implementations

@implementation JHStringToEncryptedDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
    
    NSData *data = [JHEncyptedObjects encryptedDataForString:value];
	return data;
}


- (id)reverseTransformedValue:(id)value {
    
    NSString* string = [JHEncyptedObjects decryptedStringForData:value];
	return string;
}

@end

@implementation dictionaryToEncryptedDataTransformer

const NSString* archivedDictKey = @"userCardArchive";

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
    
    NSMutableData *nsKeyedArchiverData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:nsKeyedArchiverData];
    [archiver encodeObject:value forKey:(NSString*)archivedDictKey];
    [archiver finishEncoding];
    
    NSData *data = [JHEncyptedObjects encryptedDataForData:nsKeyedArchiverData];
    
	return data;
}

- (id)reverseTransformedValue:(id)value {
    
    NSData *decryptedData = [JHEncyptedObjects decryptedDataForData:value];
    
    NSMutableData* data = [[NSMutableData alloc] initWithData:decryptedData];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary* reformedDictionary = [unarchiver decodeObjectForKey:(NSString*)archivedDictKey];
    [unarchiver finishDecoding];
    
	return reformedDictionary;
}


@end
