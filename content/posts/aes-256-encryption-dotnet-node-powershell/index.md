+++
date = '2024-10-13T12:00:00-07:00'
draft = false
title = 'Cross Platform Encryption using AES-256 (NodeJS, PowerShell, C#)'
aliases = ['/security/aes-256-encryption-dotnet-node-powershell/']
description = "Cross-platform encryption is a pain - different languages, same algorithm, different implementations. Here's working AES-256 code for C#, Node.js, and PowerShell that actually interoperates correctly, so you don't have to debug crypto edge cases."
categories = ['Security', 'Development']
tags = ['cryptography', 'encryption', 'security', 'AES-256', 'Advanced Encryption Standard', 'symmetric-key block cipher', 'data security', 'c-sharp', 'nodejs', 'powershell']
[params]
  author = 'Matt Goodrich'
+++

**Cross-platform encryption is a nightmare.** Same algorithm, different languages, endless edge cases where encrypt-in-NodeJS-decrypt-in-C# fails spectacularly.

**I've been there.** Multiple services, different tech stacks, all needing to speak the same encrypted language. **Hours wasted debugging why perfectly valid AES-256 implementations can't talk to each other.**

**Here's the working code I wish I'd found earlier.** Encrypt in one language, decrypt in another - actually works.

## **AES-256: The Gold Standard**

**AES-256 = Advanced Encryption Standard with 256-bit keys.** NIST developed it to replace the aging DES standard. **256-bit key space means 2^256 possible keys** - computationally impossible to brute force.

**Why AES-256?**
- **Security**: That massive key space makes brute force impractical
- **Performance**: Fast enough for real-time use  
- **Compatibility**: Supported everywhere
- **Compliance**: Required/recommended for regulated industries

**Perfect for data at rest, data in transit, and secure communications.**

## **The Cross-Platform Problem**

**Third-party crypto libraries exist everywhere, but they add risk** - licensing issues, security vulnerabilities, unnecessary dependencies. **Most languages have built-in AES-256 support that's perfectly adequate.**

**Two critical notes before we dive in:**
- **All code below interoperates** - encrypt in Node.js, decrypt in C#, no problem
- **Never hardcode keys in production** - use environment variables, key vaults, or secure configuration

### C# / .NET Core

#### External Libraries Used
- None

#### Example Output
```
Unencrypted String: 
This is the secret data to be encrypted

Encrypted String: 
57nxW6FY5zgbipmx6KXH0EosFQDDp/4hIYhbGhVzCqxyI/B6Z4qWhvo3gzrznhlr0ML35O++t7il974PQpfWuw==

Decrypted String: 
This is the secret data to be encrypted
```
#### Code
```csharp
using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace dotnet_core
{
    class Program
    {
        static void Main(string[] args)
        {
            var encryptionKey = "ff18ae35effbbd253a159abc32f11777863b7dc58004ae5994f5ded7518aadb2";
            
            var clearText = "This is the secret data to be encrypted";
            Console.WriteLine($"Unencrypted String: \r\n{clearText}\r\n");

            var aesManaged = new AesManaged
            {
                Mode = CipherMode.CBC, 
                Padding = PaddingMode.PKCS7, 
                BlockSize = 128, 
                KeySize = 256,
                Key = StringToByteArray(encryptionKey)
            };
            var bytes = Encoding.UTF8.GetBytes(clearText);
            var encryptor = aesManaged.CreateEncryptor();
            var encryptedData = encryptor.TransformFinalBlock(bytes, 0, bytes.Length);
            var fullData = aesManaged.IV.Concat(encryptedData).ToArray();
            var encryptedString = Convert.ToBase64String(fullData);
            Console.WriteLine($"Encrypted String: \r\n{encryptedString}\r\n");

            // In a normal scenario, you would have to create a new aesManaged object here, pull off the first 16 bytes
            // and provide it as the IV to the aesManaged object.
            var decryptedBytes = Convert.FromBase64String(encryptedString);
            var decryptor = aesManaged.CreateDecryptor();
            var unencryptedData = decryptor.TransformFinalBlock(decryptedBytes, 16, decryptedBytes.Length - 16);
            var decryptedString = Encoding.UTF8.GetString(unencryptedData);
            Console.WriteLine($"Decrypted String: \r\n{decryptedString}");
        }
        
        static byte[] StringToByteArray(String hex)
        {
            var numberChars = hex.Length;
            var bytes = new byte[numberChars / 2];
            for (var i = 0; i < numberChars; i += 2)
                bytes[i / 2] = Convert.ToByte(hex.Substring(i, 2), 16);
            return bytes;
        }
    }
}

```

### NodeJS

#### External Libraries Used
- None

#### Example Output
```
Unencrypted String: 
This is the secret data to be encrypted

Encrypted String: 
NLaMxjVNIjavBHQuDPqykcKoYxmLZMr/lzmMc0ncFM3APaziKkJ0U6OlzYRJ5YTe6zVcVOdTqTGhQIb/VioxnQ==

Decrypted String: 
This is the secret data to be encrypted
```
#### Code
```javascript
const crypto = require('crypto');

const ALGORITHM = 'aes-256-cbc';
const IV_BYTES = 16;

const ENCRYPTION_KEY = "ff18ae35effbbd253a159abc32f11777863b7dc58004ae5994f5ded7518aadb2";

const clearText = "This is the secret data to be encrypted";
console.log(`Unencrypted String: \r\n${clearText}\r\n`);

 // random initialization vector
 const iv = crypto.randomBytes(IV_BYTES);
 // AES 256 CBC Mode
 const cipher = crypto.createCipheriv(ALGORITHM, Buffer.from(ENCRYPTION_KEY, 'hex'), iv);
 // encrypt the given data
 let encrypted = cipher.update(clearText, 'utf8', 'hex');
 encrypted += cipher.final('hex');
 // generate output in base64
 const encryptedString = Buffer.concat([iv, Buffer.from(encrypted, 'hex')]).toString(
   'base64'
 );
 console.log(`Encrypted String: \r\n${encryptedString}\r\n`);

 // base64 decoding
 const bData = Buffer.from(encryptedString, 'base64');
 // convert data to buffers
 const iv2 = bData.slice(0, IV_BYTES);
 const encrypted2 = bData.slice(IV_BYTES);
 // AES 256 CBC Mode
 const decipher = crypto.createDecipheriv(ALGORITHM, Buffer.from(ENCRYPTION_KEY, 'hex'), iv2);

 // return decrypted data
 const decryptedString = `${decipher.update(encrypted2, 'binary', 'utf8')}${decipher.final(
   'utf8'
 )}`;
 console.log(`Decrypted String: \r\n${decryptedString}`);

```

### Powershell

#### External Libraries Used
- None

#### Example Output
```
Unencrypted String: 
This is the secret data to be encrypted

Encrypted String: 
57nxW6FY5zgbipmx6KXH0EosFQDDp/4hIYhbGhVzCqxyI/B6Z4qWhvo3gzrznhlr0ML35O++t7il974PQpfWuw==

Decrypted String: 
This is the secret data to be encrypted
```
#### Code
```powershell
function Create-AesManagedObject($key, $IV) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7;
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}

function Encrypt-String($key, $unencryptedString) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    if($PSVersion -gt 2) { 
        $aesManaged.Dispose()
    }
    [System.Convert]::ToBase64String($fullData)
}

function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    if($PSVersion -gt 2) {
        $aesManaged.Dispose()
    }
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}

function Convert-HexToByteArray {
    param(
        [parameter(Mandatory=$true)]
        [String]
        $HexString
    )

	$BytesArrayLength = $HexString.Length / 2
    $Bytes =  New-Object Byte[] $BytesArrayLength

    For($i=0; $i -lt $HexString.Length; $i+=2){
        $Bytes[$i/2] = [convert]::ToByte($HexString.Substring($i, 2), 16)
    }
    $Bytes
}

$aesSecret = "ff18ae35effbbd253a159abc32f11777863b7dc58004ae5994f5ded7518aadb2"
$AESEncryptionKey = Convert-HexToByteArray $aesSecret

$clearText = "This is the secret data to be encrypted";
Write-Host "Unencrypted String: "
Write-Host $clearText
Write-Host ""

$EncryptedString = Encrypt-String $AESEncryptionKey $clearText
Write-Host "Encrypted String: "
Write-Host $EncryptedString
Write-Host ""

$DecryptedString = Decrypt-String $AESEncryptionKey $EncryptedString
Write-Host "Decrypted String: "
Write-Host $DecryptedString
```

## **Key Takeaways**

**AES-256 remains the gold standard** - strong enough for government use, fast enough for production systems, supported everywhere that matters.

**The code above solves the cross-platform interoperability problem** that wastes countless hours. Encrypt in one language, decrypt in another, without debugging cryptographic edge cases.

**Remember: these examples work for testing and learning.** Production systems need proper key management, secure key storage, and additional security considerations like authentication and message integrity.

**Save yourself the debugging headaches.** Use these implementations as starting points for your own cross-platform encryption needs.