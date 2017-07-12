//
//  HClassDocument.m
//
//  Created by 朱子豪 on 16/3/24.
//  Copyright © 2016年 Space. All rights reserved.
//

#import "HClassDocument.h"

@implementation HClassDocument

+(void)scanProperty:(Class)clazz _super:(BOOL)hasSuper{
    NSMutableArray *array = [NSMutableArray array];
    [HClassDocument scanProperty:clazz _super:hasSuper option:^(NSDictionary<NSString *,NSArray<NSString *> *> *dictionary) {
        [array addObject:dictionary];
    }];
    NSLog(@"%@",array);
}
+(void)scanProperty:(Class)clazz _super:(BOOL)hasSuper option:(void(^)(NSDictionary<NSString *,NSArray<NSString *>*>* dictionary))option{
    if (hasSuper) {
        Class _super = [clazz superclass];
        if (_super != [NSObject class]) {
            [HClassDocument scanProperty:_super _super:hasSuper option:^(NSDictionary<NSString *,NSArray<NSString *> *> *dictionary) {
                option(dictionary);
            }];
        }
    }
    NSString *name = NSStringFromClass(clazz);
    unsigned int num;
    objc_property_t *pros = class_copyPropertyList(clazz, &num);
    NSMutableArray * proName = [NSMutableArray array];
    for (int i=0; i<num; i++) {
        NSString *na = [NSString stringWithUTF8String:property_getName(pros[i])];
        NSString *one = [HClassDocument getPropertyDescription:pros[i]];
        [proName addObject:@[na,one]];
    }
    option(@{name:proName});
}



/**实例方法*/
+(void)scanInstanceMethod:(Class)clazz _super:(BOOL)hasSuper{
    NSMutableArray *array = [NSMutableArray array];
    [HClassDocument scanInstanceMethod:clazz _super:hasSuper option:^(NSDictionary<NSString *,NSArray<NSString *> *> *dictionary) {
        [array addObject:dictionary];
    }];
    NSLog(@"%@",array);
}
+(void)scanInstanceMethod:(Class)clazz _super:(BOOL)hasSuper option:(void(^)(NSDictionary<NSString *,NSArray<NSString *>*>*dictionary))option{
    if (hasSuper) {
        Class obj = [clazz superclass];
        if (obj != [NSObject class]) {
            [HClassDocument scanInstanceMethod:obj _super:hasSuper option:^(NSDictionary<NSString *,NSArray<NSString *> *> *dictionary) {
                option(dictionary);
            }];
        }
    }
    //.cxx_destruct
    NSString *name = NSStringFromClass(clazz);
    unsigned int num;
    Method *methods = class_copyMethodList(clazz, &num);
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<num; i++) {
        if (![HClassDocument containProperty:method_getName(methods[i]) clazz:clazz]) {
            NSMutableString *content = [NSMutableString stringWithString:@" - ("];
            SEL aSele = method_getName(methods[i]);
            NSString * aSelName = NSStringFromSelector(aSele);
            const char *type = method_getTypeEncoding(class_getInstanceMethod(clazz, aSele));
            NSString *typeEncode = [NSString stringWithUTF8String:type];
            NSMutableString *typeStr= [NSMutableString string];
            for (int j=0; j<typeEncode.length; j++) {
                NSString *one = [typeEncode substringWithRange:NSMakeRange(j, 1)];
                const char *oneChar = [one cStringUsingEncoding:4];
                if (*oneChar<48||*oneChar>57) {
                    [typeStr appendString:[NSString stringWithUTF8String:oneChar]];
                }
            }
            for (int j=0; j<2; j++) {
                [typeStr replaceCharactersInRange:NSMakeRange(1, 1) withString:@""];
            }
            NSString *returnType = [self getReturnType:[typeStr substringWithRange:NSMakeRange(0, 1)]];
            [content appendFormat:@"%@)",returnType];
            
            
            
            if ([aSelName containsString:@":"]) {
                NSMutableArray *temp  = [aSelName componentsSeparatedByString:@":"].mutableCopy;
                [temp removeLastObject];
                [temp enumerateObjectsUsingBlock:^(NSString *onePart, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *tempStr = [self getTypeName:[typeStr substringWithRange:NSMakeRange(idx+1, 1)]];
                    
                    
                    [content appendFormat:@"%@:(%@) propertyName ",onePart,tempStr];
                }];
            }else{
                [content appendFormat:@"%@",aSelName];
            }
            
            [array addObject:content];
        }
    }
    option(@{name:array});
}


/**打印所有子视图*/
static NSMutableString *content;
+(NSString *)scanSubView:(UIView *)_superView frame:(BOOL)frame{
    content = [NSMutableString stringWithString:@"\n"];
    [HClassDocument scanSubView:_superView frame:frame count:0];
    NSLog(@"%@",content);
    NSString *temp = content.copy;
    content = @"".mutableCopy;
    return temp;
}
+(void)scanSubView:(UIView *)_superView frame:(BOOL)frame count:(int)count{
    NSString * className = NSStringFromClass([_superView class]);
    NSArray *subViews = _superView.subviews;
    NSMutableString *tt = [NSMutableString string];
    for (int i=0; i<count; i++) {
        [tt appendFormat:@"\t"];
    }
    if (frame) {
        [tt appendFormat:@"%@(%@)",className,NSStringFromCGRect(_superView.frame)];
    }else{
        [tt appendFormat:@"%@",className];
    }
    [content appendFormat:@"%@\n",tt];
    [subViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([HClassDocument contain:obj]) {
            [HClassDocument scanSubView:obj frame:frame count:count+1];
        }
        
    }];
    
}
/**去除属性的set  get 方法*/
+(BOOL)containProperty:(SEL)aSelector clazz:(Class)clazz{
    NSMutableArray *array = objc_getAssociatedObject([UIApplication sharedApplication], "property");
    if (!array) {
        unsigned int num;
        objc_property_t *pros = class_copyPropertyList(clazz, &num);
        NSMutableArray * proName = [NSMutableArray array];
        for (int i=0; i<num; i++) {
            NSString *one = [NSString stringWithUTF8String:property_getName(pros[i])];
            NSString *two  = [[@"set" stringByAppendingString:one] stringByAppendingString:@":"];
            [proName addObject:one];
            [proName addObject:[two lowercaseString]];
        }
        [proName addObject:@".cxx_destruct"];
        objc_setAssociatedObject([UIApplication sharedApplication], "property",proName, OBJC_ASSOCIATION_RETAIN);
        array = proName;
    }
    NSString *one = [NSStringFromSelector(aSelector) lowercaseString];
    BOOL flag = [array containsObject:one];
    return flag;
}

+(BOOL)contain:(UIView *)one{
    NSMutableArray *temp = objc_getAssociatedObject([UIApplication sharedApplication], "array");
    if (!temp){
        NSMutableArray *all = @[@"UIlabel",@"UIView",@"UISegmentedControl",@"UITextField",@"uislider",@"UIswitch",@"uiactivityindicatorview",@"UIProgressView",@"UIStackView",@"UIimageView",@"UITableView",@"uitableviewcell",@"uicollectionviewcell",@"uicollectionview",@"uitextView",@"uiscrollview",@"uipickView",@"uiwebview",@"uistepper"].mutableCopy;
        NSMutableArray *array = [NSMutableArray array];
        [all enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:[obj lowercaseString]];
        }];
        objc_setAssociatedObject([UIApplication sharedApplication], "array",array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        temp = array;
    }
    return [temp containsObject:NSStringFromClass([one class]).lowercaseString];
}
+(NSString *)getPropertyDescription:(objc_property_t)pro{
    
    NSMutableString *string = [NSMutableString stringWithString:@"@property"];
    
    NSString *name = [[NSString alloc]initWithUTF8String:property_getName(pro)];
    NSString *allPro =[[NSString alloc]initWithUTF8String:property_getAttributes(pro)];
    //    NSLog(@"%@",allPro);
    NSArray * a = [allPro componentsSeparatedByString:@","];
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    if ([a containsObject:@"N"]) {
        [array addObject:@"nonatomic"];
    }else{
        [array addObject:@"atomic"];
    }
    
    if ([a containsObject:@"&"]) {
        [array addObject:@"strong"];
    }else if([a containsObject:@"C"]){
        [array addObject:@"copy"];
    }else if ([a containsObject:@"W"]){
        [array addObject:@"weak"];
    }else{
        [array addObject:@"assign"];
    }
    
    if ([a containsObject:@"R"]) {
        [array addObject:@"readonly"];
    }
    NSString *par = [@" (" stringByAppendingFormat:@"%@) ",[array componentsJoinedByString:@","]];
    [string appendString:par];
    
    /**类型*/
    NSString *temp = [a firstObject];
    NSString *type = [HClassDocument getTypeName:temp];
    [string appendString:type];
    [string appendFormat:@" %@",name];
    return  string;
}
//得到类型 UITableView   NSString
+(NSString *)getTypeName:(NSString *)oneChar{
    NSString *str;
    if ([oneChar containsString:@"@\""]) {
        NSString *type  = [oneChar stringByReplacingOccurrencesOfString:@"T@\"" withString:@""];
        type = [type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if ([type containsString:@"<"]) {
            str = [[NSString alloc]initWithFormat:@"id%@",type];
        }else{
            str =  [type stringByAppendingString:@" *"];
        }
    }else if([oneChar containsString:@"{"]){
        NSString *type  = [oneChar stringByReplacingOccurrencesOfString:@"T{" withString:@""];
        type = [type stringByReplacingOccurrencesOfString:@"}" withString:@""];
        str = [[type componentsSeparatedByString:@"="] firstObject];
    }else{
        if ([oneChar containsString:@"B"]) {
            str =@"BOOL";
        }else if([oneChar containsString:@"q"]){
            str = @"long";
        }else if ([oneChar containsString:@"f"]){
            str = @"float";
        }else if ([oneChar containsString:@"i"]){
            str = @"int";
        }else if([oneChar containsString:@"d"]){
            str = @"double";
        }else if([oneChar containsString:@"Q"]){
            str = @"NSUInteger";
        }else if([oneChar containsString:@"#"]){
            str = @"Class";
        }else if([oneChar containsString:@":"]){
            str = @"SEL";
        }else{
            str = @"id";
        }
    }
    return str;
}
+(NSString *)getReturnType:(NSString *)oneChar{
    NSString *str;
    if ([oneChar containsString:@"B"]) {
        str =@"BOOL";
    }else if([oneChar containsString:@"q"]){
        str = @"long";
    }else if ([oneChar containsString:@"f"]){
        str = @"float";
    }else if ([oneChar containsString:@"i"]){
        str = @"int";
    }else if([oneChar containsString:@"d"]){
        str = @"double";
    }else if([oneChar containsString:@"Q"]){
        str = @"NSUInteger";
    }else if([oneChar containsString:@"#"]){
        str = @"Class";
    }else if([oneChar containsString:@":"]){
        str = @"SEL";
    }else if([oneChar containsString:@"v"]){
        str = @"void";
    }else{
        str = @"id";
    }
    return  str;
}
@end

