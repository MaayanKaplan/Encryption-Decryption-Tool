function Encryption {
  Start-Sleep -Seconds 1
  Write-Host "This tool will encrypt your text file with certificate." -ForegroundColor Gray
  Write-Host "WARNING: USE THIS TOOL ON VM ONLY !!! " -BackgroundColor Red

  $certificate = Read-Host -Prompt "Do you already have a certificate? Y/N." 
  if ($certificate -eq 'Y')   #If you already have a certificate
  {
    $certPath = "Cert:\CurrentUser\My" 
    Write-Host "Please choose the certificate you want to use." -ForegroundColor Green
    #A list of choices will appear on the screen and the user will ll have to choose a certificate from the list. 
    Start-Sleep -Seconds 3
    $myCert = Get-ChildItem -Path $certPath 
    $choicec=$myCert | Where-Object hasprivatekey -eq 'true' | Select-Object -Property Issuer,Subject,HasPrivateKey | Out-GridView -Title 'Select Certificate' -PassThru

    $filePath = Read-Host -Prompt "Enter the path of the files you want to encrypt:" 
    Write-Host "Encryption in process... Once complited notepad will open your encrypted file." -ForegroundColor Gray
    Start-Sleep -Seconds 2
    Get-Content $filePath | Protect-CmsMessage -To $choicec.Subject -OutFile $filePath
    Write-Host "Your file is encrypted now!" -ForegroundColor Green
    Start-Sleep -Seconds 2

    notepad $filePath
    Break   #Once the encryption is done the script will stop.
  }

  else  #If you don't have a certificate
  {
    Write-Host "Let's create a certificate!" -ForegroundColor Gray
    $cert_name = Read-Host -Prompt "Enter a name for your certificate:" 
    $cert_path = "Cert:\CurrentUser\My"

    #Create a self-signed certificate
    New-SelfSignedCertificate -DnsName $cert_name -CertStoreLocation $cert_path -KeyUsage KeyEncipherment,DataEncipherment, KeyAgreement -Type DocumentEncryptionCert

    $cert = Get-ChildItem -Path $cert_path | Where-Object subject -like "*$cert_name*"
    $thumb = $cert.thumbprint
    Write-Host "Your certificate was created successfuly!" -ForegroundColor Green
    Write-Host "It is saved at $cert_path" -ForegroundColor Green

    #Protect your certificate with a password. 
    $passcert = ConvertTo-SecureString -String (Read-Host -Prompt 'Enter password for your certificate:') -Force -AsPlainText
    Export-PfxCertificate -Cert $cert_path\$thumb -FilePath $home\"cert_"$env:username".pfx" -Password $passcert 
  
    #Move to the folder you want to encrypt.
    $path = Read-Host -Prompt "Enter the path of the file you want to encrypt."
    Write-Host "Encryption in process... Once complited notepad will open your encrypted file." -ForegroundColor Gray
    Start-Sleep -Seconds 2
    Get-Content $path | Protect-CmsMessage -To $cert.Subject -OutFile $path
    Write-Host "Your file is encrypted now!" -ForegroundColor Green
    Start-Sleep -Seconds 2

    notepad $path
    Break
  }
}

function Decryption {
  Start-Sleep -Seconds 1
  Write-Host "This tool will decrypt an encrypted file." -ForegroundColor Green
  #Write-Host "Let's decrypt your file!" -ForegroundColor Green
  $encPath = Read-Host -Prompt "Enter the path of the encrypted file:"
  $newName = Read-Host -Prompt "How whould you like to name your new file?"
  $newPath = Read-Host -Prompt "Where do you want to save the decrypted file?"
  
  $decryption = "$newPath\$newName"
  
  Unprotect-CmsMessage -Path $encPath | New-Item -Path $newPath -Name $newName
  
  Start-Sleep -Seconds 5
  
  notepad $decryption
  Break
}

do    
{
  Write-Host "What would you like to perform? Encryption/Decryption"
  Start-Sleep -Seconds 2
  $answer = Read-Host -Prompt "Choose 'E' for encryption or 'D' for decryption"

  if ($answer -eq 'E')
  {
    Encryption
  }
  elseif ($answer -eq 'D') 
  {
    Decryption
  }
  else 
  {
    Write-Host "Your choice is invalid, please choose again." -ForegroundColor Red
    Start-Sleep -Seconds 2
  }
}
while (($answer -ne 'E') -or ($answer -ne 'D'))   #If the choice isn't valid, the question will repeat itself until the user will enter a valid answer. 


  