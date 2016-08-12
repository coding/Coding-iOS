//
//  NSObject+ObjectMap.m
//  CSBase
//
//  Created by Mr Right on 13-11-13.
//  Copyright (c) 2013年 csair. All rights reserved.
//

#import "NSObject+ObjectMap.h"

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const __unused short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};


@implementation NSObject (ObjectMap)

#pragma mark - XML to Object
+(id)objectOfClass:(NSString *)object fromXML:(NSString *)xml {
    id newObject = [[NSClassFromString(object) alloc] init];
    
    NSDictionary *mapDictionary = [newObject propertyDictionary];
    
    for (NSString *key in [mapDictionary allKeys]) {
        objc_property_t property = class_getProperty([newObject class], [key UTF8String]);
        NSString *propertyStr = [newObject typeFromProperty:property];
        if (propertyStr == nil || propertyStr.length <= 4) {
            continue;
        }
        NSString *className = [propertyStr substringWithRange:NSMakeRange(3, propertyStr.length - 4)];
        id objForKey;
        
        // Check Types
        if (className == nil) {
            continue;
        }
        else if ([className isEqualToString:@"NSString"]) {
            objForKey = [[NSString alloc] init];
        }
        else if ([className isEqualToString:@"NSDate"]) {
            objForKey = [NSDate date];
        }
        else if ([className isEqualToString:@"NSNumber"]) {
            objForKey = [[NSNumber alloc] initWithFloat:0.00];
        }
        else if ([className isEqualToString:@"NSArray"]) {
            objForKey = [[NSArray alloc] init];
        }
        else if ([className isEqualToString:@"NSDictionary"]) {
            objForKey = [[NSDictionary alloc] init];
        }
        else if ([className isEqualToString:@"NSData"]){
            objForKey = [[NSData alloc] init];
        }
        else {
            continue;
//            objForKey = [[NSClassFromString(className) alloc] init];
        }
        
        // Create
        if ([objForKey getNodeValue:key fromXML:xml] != nil) {
            [newObject setValue:[objForKey getNodeValue:key fromXML:xml] forKey:key];
        }
    }
    
    return newObject;
}

-(id)getNodeValue:(NSString *)node fromXML:(NSString *)xml {
    NSString *trash = @"";
    NSString *value = @"";
    NSScanner *xmlScanner = [NSScanner scannerWithString:xml];
    [xmlScanner scanUpToString:[NSString stringWithFormat:@"<%@", node] intoString:&trash];
    [xmlScanner scanUpToString:@">" intoString:&trash];
    [xmlScanner scanString:@">" intoString:&trash];
    
    // Check property type
    if ([self isKindOfClass:[NSArray class]]) {
        // Set up a new scanner for xml substring
        [xmlScanner scanUpToString:[NSString stringWithFormat:@"</%@", node] intoString:&value];
        NSString *filteredArrayObj = @"";
        NSScanner *checkTypeScanner = [NSScanner scannerWithString:value];
        [checkTypeScanner scanString:@"<" intoString:&trash];
        [checkTypeScanner scanUpToString:@">" intoString:&filteredArrayObj];
        NSScanner *insideArrayScanner = [NSScanner scannerWithString:value];
        NSString *newValue = @"";
        NSMutableArray *objArray = [@[] mutableCopy];
        
        // Scan and create objects until you can't no mo'
        while (![insideArrayScanner isAtEnd]) {
            [insideArrayScanner scanUpToString:[NSString stringWithFormat:@"<%@", filteredArrayObj] intoString:&trash];
            [insideArrayScanner scanUpToString:@">" intoString:&trash];
            [insideArrayScanner scanString:@">" intoString:&trash];
            [insideArrayScanner scanUpToString:[NSString stringWithFormat:@"</%@", filteredArrayObj] intoString:&newValue];
            
            // Create Object
            //id objForKey = [[NSClassFromString(filteredArrayObj) alloc] init];
            if ([filteredArrayObj isEqualToString:@"string"]) {
                [objArray addObject:(NSString *)newValue];
            }
            else {
                id object = [NSObject objectOfClass:filteredArrayObj fromXML:newValue];
                if (object){
                    [objArray addObject:object];
                }
            }
            
            // Scan until nextNode
            [insideArrayScanner scanString:[NSString stringWithFormat:@"</%@", filteredArrayObj] intoString:&trash];
            [insideArrayScanner scanUpToString:@">" intoString:&trash];
            [insideArrayScanner scanString:@">" intoString:&trash];
        }
        
        // Return the array
        return objArray;
    }
    
    else if ([self isKindOfClass:[NSNumber class]]) {
        [xmlScanner scanUpToString:@"</" intoString:&value];
        if ([value isEqualToString:@"true"]) {
            return [NSNumber numberWithBool:YES];
        }
        else if ([value isEqualToString:@"false"]){
            return [NSNumber numberWithBool:NO];
        }
        
        return [NSNumber numberWithFloat:[value floatValue]];
    }
    
    else if ([self isKindOfClass:[NSString class]])
    {
        [xmlScanner scanUpToString:@"</" intoString:&value];
        NSString *str =@"<";
        NSString *strN =@">";
        NSRange range = [value rangeOfString:str];
        NSRange range2 = [value rangeOfString:strN];
        if (range.location ==NSNotFound && range2.location ==NSNotFound)
        {
            return value;
        }else
        {
        return @"";
        }
    }
    
    else if ([self isKindOfClass:[NSDate class]]) {
        [xmlScanner scanUpToString:@"</" intoString:&value];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:OMDateFormat];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:OMTimeZone]];
        return [formatter dateFromString:value];
    }
    else if ([self isKindOfClass:[NSData class]]){
        [xmlScanner scanUpToString:@"</" intoString:&value];
        return [NSObject base64DataFromString:value];
    }
    
    // Custom NSObject
    //If it has the same name as the object type
    else if ([self isKindOfClass:[NSClassFromString(node) class]]) {
        [xmlScanner scanUpToString:[NSString stringWithFormat:@"</%@", node] intoString:&value];
        return [NSObject objectOfClass:node fromXML:value];
    }
    //If the type name is different from the object name
    else {
        [xmlScanner scanUpToString:[NSString stringWithFormat:@"</%@", node] intoString:&value];
        return [NSObject objectOfClass:NSStringFromClass([self class]) fromXML:value];
    }
    
    return nil;
}

#pragma mark - Dictionary to Object
+(id)objectOfClass:(NSString *)object fromJSON:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    id newObject = [[NSClassFromString(object) alloc] init];
    
    NSDictionary *mapDictionary = [newObject propertyDictionary];
    
    for (NSString *key in [dict allKeys]) {
        NSString *tempKey;
        if ([key isEqualToString:@"description"] || [key isEqualToString:@"hash"]) {
            tempKey = [key stringByAppendingString:@"_mine"];
        }else{
            tempKey = key;
        }
        NSString *propertyName = [mapDictionary objectForKey:tempKey];
        if (!propertyName) {
            continue;
        }
        // If it's a Dictionary, make into object
        if ([[dict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
            //id newObjectProperty = [newObject valueForKey:propertyName];
            NSString *propertyType = [newObject classOfPropertyNamed:propertyName];
            id nestedObj = [NSObject objectOfClass:propertyType fromJSON:[dict objectForKey:key]];
            [newObject setValue:nestedObj forKey:propertyName];
        }
        
        // If it's an array, check for each object in array -> make into object/id
        else if ([[dict objectForKey:key] isKindOfClass:[NSArray class]]) {
            NSArray *nestedArray = [dict objectForKey:key];
            NSString *propertyType = [newObject valueForKeyPath:[NSString stringWithFormat:@"propertyArrayMap.%@", key]];
            [newObject setValue:[NSObject arrayMapFromArray:nestedArray forPropertyName:propertyType] forKey:propertyName];
        }
        
        // Add to property name, because it is a type already
        else {
            objc_property_t property = class_getProperty([newObject class], [propertyName UTF8String]);
            if (!property) {
                continue;
            }
            NSString *classType = [newObject typeFromProperty:property];
            
            // check if NSDate or not
            if ([classType isEqualToString:@"T@\"NSDate\""]) {
//                1970年的long型数字
                NSObject *obj = [dict objectForKey:key];
                if ([obj isKindOfClass:[NSNumber class]]) {
                    NSNumber *timeSince1970 = (NSNumber *)obj;
                    NSTimeInterval timeSince1970TimeInterval = timeSince1970.doubleValue/1000;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeSince1970TimeInterval];
                    [newObject setValue:date forKey:propertyName];
                }else{
//                            日期字符串
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:OMDateFormat];
                    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:OMTimeZone]];
                    NSString *dateString = [[dict objectForKey:key] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                    [newObject setValue:[formatter dateFromString:dateString] forKey:propertyName];
                }
            }
            else {
                if ([dict objectForKey:key] != [NSNull null]) {
                    [newObject setValue:[dict objectForKey:key] forKey:propertyName];
                }
                else {
                    [newObject setValue:nil forKey:propertyName];
                }
            }
        }
    }
    
    return newObject;
}

-(NSString *)classOfPropertyNamed:(NSString *)propName {
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int xx = 0; xx < count; xx++) {
        NSString *curProperty = [NSString stringWithUTF8String:property_getName(properties[xx])];
        if ([curProperty isEqualToString:propName]) {
            NSString *className = [NSString stringWithFormat:@"%s", getPropertyType(properties[xx])];
            free(properties);
            return className;
        }
    }
    
    return nil;
}


static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
//    printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}

+(NSMutableArray *)arrayFromJSON:(NSArray *)jsonArray ofObjects:(NSString *)obj {
    //NSString *filteredObject = [NSString stringWithFormat:@"%@s",obj];
    return [NSObject arrayMapFromArray:jsonArray forPropertyName:obj];
}

-(NSString *)nameOfClass {
    return [NSString stringWithUTF8String:class_getName([self class])];
}

+(NSMutableArray *)arrayMapFromArray:(NSArray *)nestedArray forPropertyName:(NSString *)propertyName {
    // Set Up
    NSMutableArray *objectsArray = [@[] mutableCopy];
    
    // Removes "ArrayOf(PropertyName)s" to get to the meat
    //NSString *filteredProperty = [propertyName substringWithRange:NSMakeRange(0, propertyName.length - 1)]; /* TenEight */
    //NSString *filteredProperty = [propertyName substringWithRange:NSMakeRange(7, propertyName.length - 8)]; /* AlaCop */
    
    // Create objects
    for (int xx = 0; xx < nestedArray.count; xx++) {
        // If it's an NSDictionary
        if ([nestedArray[xx] isKindOfClass:[NSDictionary class]]) {
            // Create object of filteredProperty type
            id nestedObj = [[NSClassFromString(propertyName) alloc] init];
            
            // Iterate through each key, create objects for each
            for (NSString *newKey in [nestedArray[xx] allKeys]) {
                // If it's an Array, recur
                if ([[nestedArray[xx] objectForKey:newKey] isKindOfClass:[NSArray class]]) {
                    //添加属性判断，防止运行时崩溃
                    objc_property_t property = class_getProperty([NSClassFromString(propertyName) class], [@"propertyArrayMap" UTF8String]);
                    if (!property) {
                        continue;
                    }
                    NSString *propertyType = [nestedObj valueForKeyPath:[NSString stringWithFormat:@"propertyArrayMap.%@", newKey]];
                    if (!propertyType) {
                        continue;
                    }
                    [nestedObj setValue:[NSObject arrayMapFromArray:[nestedArray[xx] objectForKey:newKey]  forPropertyName:propertyType] forKey:newKey];
                }
                // If it's a Dictionary, create an object, and send to [self objectFromJSON]
                else if ([[nestedArray[xx] objectForKey:newKey] isKindOfClass:[NSDictionary class]]) {
                    NSString *type = [nestedObj classOfPropertyNamed:newKey];
                    if (!type) {
                        continue;
                    }
                    
                    id nestedDictObj = [NSObject objectOfClass:type fromJSON:[nestedArray[xx] objectForKey:newKey]];
                    [nestedObj setValue:nestedDictObj forKey:newKey];
                }
                // Else, it is an object
                else {
                    NSString *tempNewKey;
                    if ([newKey isEqualToString:@"description"] || [newKey isEqualToString:@"hash"]) {
                        tempNewKey = [newKey stringByAppendingString:@"_mine"];
                    }else{
                        tempNewKey = newKey;
                    }
                    objc_property_t property = class_getProperty([NSClassFromString(propertyName) class], [tempNewKey UTF8String]);
                    if (!property) {
                        continue;
                    }
                    NSString *classType = [self typeFromProperty:property];
                    // check if NSDate or not
                    if ([classType isEqualToString:@"T@\"NSDate\""]) {
//                        1970年的long型数字
                        NSObject *obj = [nestedArray[xx] objectForKey:newKey];
                        if ([obj isKindOfClass:[NSNumber class]]) {
                            NSNumber *timeSince1970 = (NSNumber *)obj;
                            NSTimeInterval timeSince1970TimeInterval = timeSince1970.doubleValue/1000;
                            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeSince1970TimeInterval];
                            [nestedObj setValue:date forKey:tempNewKey];
                        }else{
//                            日期字符串
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat:OMDateFormat];
                            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:OMTimeZone]];
                            
                            NSString *dateString = [[nestedArray[xx] objectForKey:newKey] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                            [nestedObj setValue:[formatter dateFromString:dateString] forKey:tempNewKey];
                        }
                    }
                    else {
                        [nestedObj setValue:[nestedArray[xx] objectForKey:newKey] forKey:tempNewKey];
                    }
                }
            }
            
            // Finally add that object
            [objectsArray addObject:nestedObj];
        }
        
        // If it's an NSArray, recur
        else if ([nestedArray[xx] isKindOfClass:[NSArray class]]) {
            [objectsArray addObject:[NSObject arrayMapFromArray:nestedArray[xx] forPropertyName:propertyName]];
        }
        
        // Else, add object directly
        else {
            [objectsArray addObject:nestedArray[xx]];
        }
    }
    
    // This is now an Array of objects
    return objectsArray;
}

-(NSDictionary *)propertyDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        [dict setObject:key forKey:key];
    }
    
    free(properties);
    
    // Add all superclass properties as well, until it hits NSObject
    NSString *superClassName = [[self superclass] nameOfClass];
    if (![superClassName isEqualToString:@"NSObject"]) {
        for (NSString *property in [[[self superclass] propertyDictionary] allKeys]) {
            [dict setObject:property forKey:property];
        }
    }
    
    return dict;
}

-(NSString *)typeFromProperty:(objc_property_t)property {
    return [[NSString stringWithUTF8String:property_getAttributes(property)] componentsSeparatedByString:@","][0];
}


#pragma mark - Get Property Array Map
// This returns an associated property Dictionary for objects
// You should make an object contain a dictionary in init
// that contains a map for each array and what it contains:
//
// {"arrayPropertyName":"TypeOfObjectYouWantInArray"}
//
// To Set this object in each init method, do something like this:
//
// [myObject setValue:@"TypeOfObjectYouWantInArray" forKeyPath:@"propertyArrayMap.arrayPropertyName"]
//
-(NSMutableDictionary *)getpropertyArrayMap {
    if (objc_getAssociatedObject(self, @"propertyArrayMap")==nil) {
        objc_setAssociatedObject(self,@"propertyArrayMap",[[NSMutableDictionary alloc] init],OBJC_ASSOCIATION_RETAIN);
    }
    return (NSMutableDictionary *)objc_getAssociatedObject(self, @"propertyArrayMap");
}


#pragma mark - Copy NSObject (initWithObject)
-(id)initWithObject:(NSObject *)oldObject error:(NSError **)error {
    self = [self init];
    if (self) {
        NSString *oldClassName = [oldObject nameOfClass];
        NSString *newClassName = [self nameOfClass];
        if ([newClassName isEqualToString:oldClassName]) {
            for (NSString *propertyKey in [[oldObject propertyDictionary] allKeys]) {
                [self setValue:[oldObject valueForKey:propertyKey] forKey:propertyKey];
            }
        }
        else {
            *error = [NSError errorWithDomain:@"MismatchedObjects" code:404 userInfo:@{@"Error":@"Mismatched Object Classes"}];
        }
    }
    return self;
}

#pragma mark - Object to Data/String/etc.

-(NSDictionary *)objectDictionary {
    NSMutableDictionary *objectDict = [@{} mutableCopy];
    for (NSString *key in [[self propertyDictionary] allKeys]) {
        [objectDict setValue:[self valueForKey:key] forKey:key];
    }
    return objectDict;
}

-(NSData *)JSONData{
    NSDictionary *dict = [NSObject dictionaryWithPropertiesOfObject:self];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
}

-(NSString *)JSONString{
    NSDictionary *dict = [NSObject dictionaryWithPropertiesOfObject:self];
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
}

+(NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSMutableArray *propertiesArray = [NSObject propertiesArrayFromObject:obj];
    
    for (int i = 0; i < propertiesArray.count; i++) {
        NSString *key = propertiesArray[i];
        
        if ([self isArray:obj key:key]) {
            [dict setObject:[self arrayForObject:[obj valueForKey:key]] forKey:key];
        }
        else if ([self isDate:[obj valueForKey:key]]){
            [dict setObject:[self dateForObject:[obj valueForKey:key]] forKey:key];
        }
        else if ([self isSystemObject:obj key:key]) {
            [dict setObject:[obj valueForKey:key] forKey:key];
        }
        else if ([NSObject isData:[obj valueForKey:key]]){
            [dict setObject:[NSObject encodeBase64WithData:[obj valueForKey:key]] forKey:key];
        }
        else {
            [dict setObject:[self dictionaryWithPropertiesOfObject:[obj valueForKey:key]] forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

+(NSMutableArray *)propertiesArrayFromObject:(id)obj {
    
    NSMutableArray *props = [NSMutableArray array];
    
    if (!obj) {
        return props;
    }
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    for (int i = 0; i < count; i++) {
        [props addObject:[NSString stringWithUTF8String:property_getName(properties[i])]];
    }
    
    free(properties);
    
    NSString *superClassName = [[obj superclass] nameOfClass];
    if (![superClassName isEqualToString:@"NSObject"]) {
        [props addObjectsFromArray:[NSObject propertiesArrayFromObject:[[NSClassFromString(superClassName) alloc] init]]];
    }
    
    return props;
}

-(BOOL)isSystemObject:(id)obj key:(NSString *)key{
    if ([[obj valueForKey:key] isKindOfClass:[NSString class]] || [[obj valueForKey:key] isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isSystemObject:(id)obj{
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isArray:(id)obj key:(NSString *)key{
    if ([[obj valueForKey:key] isKindOfClass:[NSArray class]]) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isArray:(id)obj{
    if ([obj isKindOfClass:[NSArray class]]) {
        return YES;
    }
    
    return NO;
}

+(BOOL)isDate:(id)obj{
    if ([obj isKindOfClass:[NSDate class]]) {
        return YES;
    }
    
    return NO;
}

+(BOOL)isData:(id)obj{
    if ([obj isKindOfClass:[NSData class]]) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isData:(id)obj{
    if ([obj isKindOfClass:[NSData class]]) {
        return YES;
    }
    
    return NO;
}

+(NSArray *)arrayForObject:(id)obj{
    NSArray *ContentArray = (NSArray *)obj;
    NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
    for (int ii = 0; ii < ContentArray.count; ii++) {
        if ([self isArray:ContentArray[ii]]) {
            [objectsArray addObject:[self arrayForObject:[ContentArray objectAtIndex:ii]]];
        }
        else if ([self isDate:ContentArray[ii]]){
            [objectsArray addObject:[self dateForObject:[ContentArray objectAtIndex:ii]]];
        }
        else if ([self isSystemObject:[ContentArray objectAtIndex:ii]]) {
            [objectsArray addObject:[ContentArray objectAtIndex:ii]];
        }
        else {
            [objectsArray addObject:[self dictionaryWithPropertiesOfObject:[ContentArray objectAtIndex:ii]]];
        }
        
    }
    
    return objectsArray;
}


+(NSString *)dateForObject:(id)obj{
    NSDate *date = (NSDate *)obj;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:OMDateFormat];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:OMTimeZone]];
    return [formatter stringFromDate:date];
}

#pragma mark - SOAP/XML Serialization

-(NSData *)SOAPData{
    NSDictionary *dict = [NSObject dictionaryWithPropertiesOfObject:self];
    return [[self soapStringFroDictionary:dict] dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *)XMLData{
    NSDictionary *dict = [NSObject dictionaryWithPropertiesOfObject:self];
    return [[self xmlStringForSelfDictionary:dict] dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)XMLString{
    NSDictionary *dict = [NSObject dictionaryWithPropertiesOfObject:self];
    return [self xmlStringForSelfDictionary:dict];
}

-(NSString *)SOAPString{
     NSDictionary *dict = [NSObject dictionaryWithPropertiesOfObject:self];
    return [self soapStringFroDictionary:dict];
}

-(NSString *)soapStringFroDictionary:(NSDictionary *)dict{
    SOAPObject *soapObject = (SOAPObject *)self;
    
    NSMutableString *soapString = [[NSMutableString alloc] initWithString:@""];
    
    //Open Envelope
    [soapString appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns=\"http://tempuri.org/\">"];
    
    //Request Header
    if ([dict valueForKey:@"Header"]) {
        
        
        
        //Append containing class name
        if (soapObject.Header) {
            [soapString appendString:@"<soap:Header>"];
            [soapString appendFormat:@"<%s>", class_getName([soapObject.Header class])];
        }
        
        
        NSDictionary *headerDict = [dict valueForKey:@"Header"];
        //Append object contents
        for (id key in headerDict) {
            [soapString appendFormat:@"<%@>", (NSString *)key];
            [soapString appendFormat:@"%@", [self xmlStringForDictionary:headerDict key:key]];
            [soapString appendFormat:@"</%@>", (NSString *)key];
        }
        
        //Close containing class name
        if (soapObject.Header) {
            [soapString appendFormat:@"</%s>", class_getName([soapObject.Header class])];
            [soapString appendString:@"</soap:Header>"];
        }
        
        
        
    }
    
    
    if ([dict valueForKey:@"Body"]) {
        [soapString appendString:@"<soap:Body>"];
        
        //Append containing class name
        if (soapObject.Body) {
            [soapString appendFormat:@"<%s>", class_getName([soapObject.Body class])];
        }
        
        NSDictionary *bodyDict = [dict valueForKey:@"Body"];
        //NSLog(@"\n\nSOAP Body: %@\n\n", bodyDict);
        //Append object contents
        for (id key in bodyDict) {
            [soapString appendFormat:@"<%@>", (NSString *)key];
            [soapString appendFormat:@"%@", [self xmlStringForDictionary:bodyDict key:key]];
            [soapString appendFormat:@"</%@>", (NSString *)key];
        }
        
        //Close containing class name
        if (soapObject.Body) {
            [soapString appendFormat:@"</%s>", class_getName([soapObject.Body class])];
        }
        
        [soapString appendString:@"</soap:Body>"];
    }
    
    //Close Envelope
    [soapString appendString:@"</soap:Envelope>"];
    
    return soapString;
}

-(NSString *)xmlStringForSelfDictionary:(NSDictionary *)dict{
    NSMutableString *xmlString = [[NSMutableString alloc] initWithString:@""];
    
    //Document Header
    [xmlString appendString:@"<?xml version=\"1.0\"?>"];
    
    //Append containing class name
    [xmlString appendFormat:@"<%s>", class_getName([self class])];
    
    //Fill in all values
    for (id key in dict) {
        [xmlString appendFormat:@"<%@>", (NSString *)key];
        [xmlString appendFormat:@"%@", [self xmlStringForDictionary:dict key:key]];
        [xmlString appendFormat:@"</%@>", (NSString *)key];
    }
    
    //Close containing class name
    [xmlString appendFormat:@"</%s>", class_getName([self class])];
    
    return xmlString;
}


-(NSString *)xmlStringForDictionary:(NSDictionary *)dict key:(NSString *)key{
    NSMutableString *soapString = [[NSMutableString alloc] initWithString:@""];
    
    if ([[dict valueForKey:key] isKindOfClass:[NSDate class]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:OMDateFormat];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:OMTimeZone]];
        return [formatter stringFromDate:[dict valueForKey:key]];
        
        return [dict valueForKey:key];
    }
    else if ([[dict valueForKey:key] isKindOfClass:[NSData class]]){
        return [NSObject encodeBase64WithData:[dict valueForKey:key]];
    }
    else if ([[dict valueForKey:key] isKindOfClass:[NSArray class]]) {
        NSArray *childArray = [dict valueForKey:key];
        for (int ii = 0; ii < childArray.count; ii++) {
            NSString *className = [key stringByReplacingOccurrencesOfString:@"ArrayOf" withString:@""];

            if ([childArray[ii] isKindOfClass:[NSString class]]) {
                [soapString appendString:@"<string>"];
                [soapString appendFormat:@"%@", childArray[ii]];
                [soapString appendString:@"</string>"];
            }
            else {
                [soapString appendFormat:@"<%@>", className];
                [soapString appendFormat:@"%@", [self xmlStringForDictionary:childArray[ii]]];
                [soapString appendFormat:@"</%@>", className];
            }
            
            
        }
    }
    else if ([[dict valueForKey:key] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *childDictionary = [dict valueForKey:key];
        for (id childKey in [dict valueForKey:key]) {
            [soapString appendFormat:@"<%@>", (NSString *)childKey];
            [soapString appendFormat:@"%@", [self xmlStringForDictionary:childDictionary key:childKey]];
            [soapString appendFormat:@"</%@>", (NSString *)childKey];
        }
    }
    
    else {
        return [dict valueForKey:key];
    }
    
    return soapString;
}

-(NSString *)xmlStringForDictionary:(NSDictionary *)dict{
    NSMutableString *soapString = [[NSMutableString alloc] initWithString:@""];
    
    for (id key in dict) {
        [soapString appendFormat:@"<%@>", (NSString *)key];
        [soapString appendFormat:@"%@", [self xmlStringForDictionary:dict key:key]];
        [soapString appendFormat:@"</%@>", (NSString *)key];
    }
    
    return soapString;
}


#pragma mark - Base64 Binary Encode/Decode

+(NSData *)base64DataFromString:(NSString *)string
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4] = {}, outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil)
    {
        return [NSData data];
    }
    
    ixtext = 0;
    
    tempcstring = (const unsigned char *)[string UTF8String];
    
    lentext = [string length];
    
    theData = [NSMutableData dataWithCapacity: lentext];
    
    ixinbuf = 0;
    
    while (true)
    {
        if (ixtext >= lentext)
        {
            break;
        }
        
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z'))
        {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z'))
        {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9'))
        {
            ch = ch - '0' + 52;
        }
        else if (ch == '+')
        {
            ch = 62;
        }
        else if (ch == '=')
        {
            flendtext = true;
        }
        else if (ch == '/')
        {
            ch = 63;
        }
        else
        {
            flignore = true;
        }
        
        if (!flignore)
        {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext)
            {
                if (ixinbuf == 0)
                {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2))
                {
                    ctcharsinbuf = 1;
                }
                else
                {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4)
            {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++)
                {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak)
            {
                break;
            }
        }
    }
    
    return theData;
}

+ (NSString *)encodeBase64WithData:(NSData *)objData {
    const unsigned char * objRawData = [objData bytes];
    char * objPointer;
    char * strResult;
    
    // Get the Raw Data length and ensure we actually have data
    int intLength = (int)[objData length];
    if (intLength == 0) return nil;
    
    // Setup the String-based Result placeholder and pointer within that placeholder
    strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
    objPointer = strResult;
    
    // Iterate through everything
    while (intLength > 2) { // keep going until we have less than 24 bits
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
        
        // we just handled 3 octets (24 bits) of data
        objRawData += 3;
        intLength -= 3;
    }
    
    // now deal with the tail end of things
    if (intLength != 0) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }
    
    // Terminate the string-based result
    *objPointer = '\0';
    
    NSString *resultStr = [NSString stringWithCString:strResult encoding:NSUTF8StringEncoding];
    
    free(strResult);
    
    // Return the results as an NSString object
    return resultStr;
}



@end


@implementation SOAPObject

@end
