//
//  SureCommCrypto.swift
//  
//
//  Created by u0764757 on 12/8/15.
//
//

import Foundation
import BigInteger
import CryptoSwift

public class SureCommCrypto {

    public static let g:BigInteger = BigInteger("2")!
    //p and g from: http://tools.ietf.org/html/rfc3526#section-7
    public static let p:BigInteger = BigInteger(valueAsString:"FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B33A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF6955817183995497CEA956AE515D2261898FA051015728E5A8AAAC42DAD33170D04507A33A85521ABDF1CBA64ECFB850458DBEF0A8AEA71575D060C7DB3970F85A6E1E4C7ABF5AE8CDB0933D71E8C94E04A25619DCEE3D2261AD2EE6BF12FFA06D98A0864D87602733EC86A64521F2B18177B200CBBE117577A615D6C770988C0BAD946E208E24FA074E5AB3143DB5BFCE0FD108E4B82D120A92108011A723C12A787E6D788719A10BDBA5B2699C327186AF4E23C1A946834B6150BDA2583E9CA2AD44CE8DBBBC2DB04DE8EF92E8EFC141FBECAA6287C59474E6BC05D99B2964FA090C3A2233BA186515BE7ED1F612970CEE2D7AFB81BDD762170481CD0069127D5B05AA993B4EA988D8FDDC186FFB7DC90A6C08F4DF435C934063199FFFFFFFFFFFFFFFF",radix:16)!
    
    //from stackoverflow.com/questions/30762414/swift-convert-decimal-string-to-uint8-array
    public static func decimalStringToUInt8Array(decimalString:String) -> [UInt8] {
        let hex = BigInteger(decimalString)!.asString(radix:16)
        var temp = hex
        if temp.characters.count % 2 == 1{
            temp = "0" + temp
        }
        var arr = [UInt8](count:temp.characters.count/2,repeatedValue:0)
        for var i = 0; i < temp.characters.count; i+=2{
            let leftIndex = temp.startIndex.advancedBy(i)
            let rightIndex = temp.startIndex.advancedBy(i+1)

            let leftDigit = temp[leftIndex]
            let rightDigit = temp[rightIndex]
            arr[i/2] = UInt8(String(leftDigit),radix:16)!*16 + UInt8(String(rightDigit),radix:16)!
        }
        return arr
    }

    public static func getsharedsecret(publickey:String,privatekey:String) ->String{
        let num = expo(BigInteger(publickey)!,d: BigInteger(privatekey)!,n: p)
        return num.asString
    }
    
    public static func generateprivatekey() -> String{
        // Random byte generation from http://jamescarroll.xyz/2015/09/09/safely-generating-cryptographically-secure-random-numbers-with-swift/
        
        let bytesCount = 32 // number of bytes
        var randomNum = "" // hexadecimal version of randomBytes
        var randomBytes = [UInt8](count: bytesCount, repeatedValue: 0) // array to hold randoms bytes
        
        // Gen random bytes
        SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
        
        // Turn randomBytes into array of hexadecimal strings
        // Join array of strings into single string
        randomNum = (randomBytes.map({String(format: "%02hhx", $0)})).joinWithSeparator("").uppercaseString
        let num = BigInteger(valueAsString:randomNum,radix:16)
        return num!.asString
    }
    
    public static func generatepublickey(a:String) -> String{
        
        return expo(g,d: BigInteger(a)!,n: p).asString
    }
    
    public static func expo(m:BigInteger, d:BigInteger, n:BigInteger) -> BigInteger {
        let bitCount = bitcount(d)
        var x =  m.remainder(n)!
        for var i:Int32 = bitCount - 2; i >= 0;--i {
            let power = d.shiftRight(i)
            x = x.pow(2).remainder(n)!
            let currentbit = power.bitwiseAnd(BigInteger("1")!)
            if(currentbit == BigInteger("1")!){
                x = x.multiplyBy(m).remainder(n)!
            }
        }
        return x
    }
    
    public static func xor(a:String,b:String) -> String {
        return BigInteger(a)!.bitwiseXor(BigInteger(b)!).asString
    }
    
    public static func bitcount(i:BigInteger) -> Int32{
        var count:Int32 = 0
        var temp = i
        while temp > BigInteger("0")!{
            temp = temp.shiftRight(1)
            count+=1
        }
        return count
    }

    public static func encrypt(text:String, encryptKey:[UInt8], iv:[UInt8],integrityKey:[UInt8]) -> String{
        let textBytes = [UInt8](text.utf8)
        let mac: [UInt8] = try! Authenticator.Poly1305(key: integrityKey).authenticate(textBytes)
        let textWithMac = NSData(bytes: textBytes).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength) + "\u{001b}" + NSData(bytes: mac).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        let bytesWithMac = [UInt8](textWithMac.utf8)
        var encrypted:[UInt8] = []
        do{
            encrypted = try AES(key: encryptKey, iv: iv, blockMode: .CBC).encrypt(bytesWithMac, padding: PKCS7())
        }
        catch {
            // some error
        }
        return NSData(bytes: encrypted).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    
}