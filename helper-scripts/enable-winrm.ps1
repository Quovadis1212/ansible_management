# Variables
$Hostname = [System.Net.Dns]::GetHostName()  # Get the hostname explicitly
$CertName = "WinRM Certificate"
$Port = 5986
$CertPath = "Cert:\LocalMachine\My"

# Create a self-signed certificate with the hostname
Write-Host "Creating a self-signed certificate with hostname: $Hostname..."
$Cert = New-SelfSignedCertificate -DnsName $Hostname -CertStoreLocation $CertPath -FriendlyName $CertName -KeyUsage DigitalSignature, KeyEncipherment

# Get the certificate thumbprint
$Thumbprint = $Cert.Thumbprint
Write-Host "Certificate Thumbprint: $Thumbprint"

# Configure WinRM
Write-Host "Configuring WinRM..."
winrm quickconfig -force
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="false"}'

# Remove existing listeners
Write-Host "Removing existing WinRM listeners..."
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
winrm delete winrm/config/Listener?Address=*+Transport=HTTP

# Create a new listener with the certificate
Write-Host "Creating a new WinRM listener with SSL..."
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$Hostname`"; CertificateThumbprint=`"$Thumbprint`"; Port=`"$Port`"}"

# Open firewall for WinRM HTTPS
Write-Host "Configuring firewall for WinRM HTTPS..."
New-NetFirewallRule -DisplayName "Allow WinRM HTTPS"
