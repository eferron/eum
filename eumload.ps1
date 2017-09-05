

$base = "http://localhost:8089"
$urlList = "/default", "/about", "/contact"
do
{
    $index = Get-Random -Minimum 0 -Maximum 2
    $sleepinterval = Get-Random -Minimum 3 -Maximum 10 
    $destination = $base + $urlList[$index]
    Write-Output "------------------------------------"
    Write-Output $destination
    Write-Output "************************************"
    Write-Output "Waiting [ $sleepinterval ] seconds"
    Write-Output "************************************"
    Write-Output ""
    Invoke-WebRequest -UseBasicParsing $destination
    Start-Sleep -s $sleepinterval
} while(1)
