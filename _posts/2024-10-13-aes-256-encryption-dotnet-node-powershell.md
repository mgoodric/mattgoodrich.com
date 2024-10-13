---
title:  "AES-256 Encryption in C# (.NET), NodeJS and Powershell"
categories: 
  - Security
tags:
  - cryptography
  - dotnet
  - nodejs
  - powershell
---

In the realm of cybersecurity, few areas are as intricate and nuanced as cryptography. For those new to the field, the sheer breadth of concepts, techniques, and terminology can be overwhelming. Despite its importance, cryptography remains a complex domain that often intimidates even seasoned security professionals.

At its core, encryption is a fundamental component of many cybersecurity controls. It serves as a crucial layer of protection for sensitive data, ensuring it remains confidential in the event of unauthorized access or data breaches.

In some cases, implementing encryption within code is not only necessary but also crucial for protecting sensitive information. This can involve encrypting data at rest, such as files or database entries, or encrypting communications between systems, like API keys or confidential messages. 

Selecting the right encryption algorithm for a given task can be daunting, as each has its strengths and weaknesses in terms of security, performance, and compatibility. Among the various encryption algorithms available, one stands out for its exceptional strength and versatility: Advanced Encryption Standard (AES) with 256-bit key length, commonly referred to as AES-256.

## What is AES-256?

AES-256 is a symmetric-key block cipher that encrypts data in blocks of 128 bits. It was developed by the National Institute of Standards and Technology (NIST) to replace the Data Encryption Standard (DES), which had become vulnerable due to advancements in computing power and cryptanalysis techniques.

The "256" in AES-256 refers to the key size used for encryption, where each key is 32 bytes long. This is much larger than the 56-bit keys of DES, making AES significantly more secure against brute-force attacks. The algorithm itself operates on blocks of data, ensuring that even if a portion of the encrypted text is compromised, the entire dataset remains safe.

## Why Choose AES-256?

AES-256 is widely regarded as one of the most secure encryption algorithms in use today for several reasons:

* **Strength Against Brute Force Attacks**: The sheer size of the key space (2^256 possible keys) makes it computationally impractical to decrypt data using brute force methods, even with the most powerful computers available.
* **High Performance**: Despite its strength, AES-256 has a relatively high performance compared to other encryption algorithms, making it suitable for both encrypting large volumes of data and securing real-time communications.
* **Widespread Adoption**: AES-256 is supported by virtually all modern operating systems, devices, and software applications that require encryption, ensuring seamless integration into existing infrastructure.
* **Regulatory Compliance**: In many jurisdictions, the use of AES-256 is mandated or strongly recommended for protecting sensitive data, especially in fields like finance, healthcare, and government services.

## Use Cases for AES-256

Given its broad acceptance and high security standards, AES-256 can be used in a variety of contexts:

* **Data Storage**: Use AES-256 to securely store data on devices, servers, or the cloud, ensuring that even if data is stolen, it remains encrypted.
* **Communication Security**: Encrypt communications between users using AES-256 for privacy and security.
* **Secure Key Exchange**: Utilize AES-256 as part of key exchange protocols like SSL/TLS to securely transmit keys between parties.

## Encryption in Code

You do not have to look far to find a library in your language of choice that does encryption, but adding a third-party libraries to your code base just for the purposes of doing encryption may not be worth the risk (license violations, other functionality that could be vulnerable, etc). Performing encryption in many languages is relatively short. Before digging into the examples below, a couple of notes:

* The encryption/decryption code below works across language examples below (ex. encrypt in NodeJS, decrypt in C#)
* The encryption key should never be hard coded in a production application

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

AES-256 represents the current gold standard in encryption technology, providing unparalleled strength against potential threats while also offering excellent performance. Its widespread adoption across all major platforms makes it a practical choice for organizations and individuals alike seeking to protect sensitive information from unauthorized access. As data security continues to evolve, AES-256 remains at the forefront of encryption technologies, ensuring that secure communication and storage practices remain up-to-date with the latest advancements in cryptography.