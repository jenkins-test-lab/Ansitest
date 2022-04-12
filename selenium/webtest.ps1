$execution = "TestExec-" + (Get-Date -Format "yyyyMMdd-HHmmss")
$execlog = $PSScriptRoot + "\$($execution)"
New-Item -Path $execlog -ItemType Directory

$report = ""

$iEProcess = Start-Process "C:\apps\jenkins\driver\chromedriver.exe" -PassThru -ArgumentList "/port=5577" #-WindowStyle hidden

$a=[System.Reflection.Assembly]::LoadFrom("C:\apps\jenkins\driver\Selenium.WebDriverBackedSelenium.dll")
$b=[System.Reflection.Assembly]::LoadFrom("C:\apps\jenkins\driver\WebDriver.dll")
$c=[System.Reflection.Assembly]::LoadFrom("C:\apps\jenkins\driver\WebDriver.Support.dll")
$ss = New-Object OpenQA.Selenium.Remote.DesiredCapabilities
[OpenQA.Selenium.ScreenshotImageFormat]$ImageFormat = [OpenQA.Selenium.ScreenshotImageFormat]::jpeg

$dd= New-Object OpenQA.Selenium.Remote.RemoteWebDriver("http://127.0.0.1:5577",$ss)
$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait($dd,[System.TimeSpan]::FromSeconds(50))
$wait.PollingInterval = 100

 $dd.url = "http://20.224.65.81:8080/test/"
try{
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Id("id01")))
}
catch{}

$initlogin = $dd.FindElementByXPath("/html/body/button")
if($initlogin.Text -eq "Login"){
    Write-Output "Homepage loaded successfully"
    $img = $dd.GetScreenshot()
    $report += "<tr><td>$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss'): Homepage loaded successfully</td></tr>"
    $report += "<tr><td><img src=`"data:image/png;base64,$($img.AsBase64EncodedString)`" width=""800"" height=""600""></td></tr>"
    $Screenshot = [OpenQA.Selenium.Support.Extensions.WebDriverExtensions]::TakeScreenshot($dd)
    $Screenshot.SaveAsFile("$($execlog)\Pageload.jpeg", $ImageFormat)
}
$initlogin.Click()

[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::Name("uname")))
$username = $dd.FindElementByName("uname")
#$username.Text
$username.Click()
$username.SendKeys("test")

$psw = $dd.FindElementByName("psw")
$psw.click()
$psw.SendKeys("test")

$finallogin = $dd.FindElementByXPath("/html/body/div/form/div[2]/button")
if($finallogin.Text -eq "Login"){
    Write-Output "Login Form loaded successfully."
    $img = $dd.GetScreenshot()
    $report += "<tr><td>$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss'): Login Form loaded successfully</td></tr>"
    $report += "<tr><td><img src=`"data:image/jpeg;base64,$($img.AsBase64EncodedString)`" width=""800"" height=""600""></td></tr>"
    $Screenshot = [OpenQA.Selenium.Support.Extensions.WebDriverExtensions]::TakeScreenshot($dd)
    $Screenshot.SaveAsFile("$($execlog)\loginform.jpeg", $ImageFormat)
}
$finallogin.Click()

if($dd.Url -like "*action_page.html"){
    Write-Output "Page successfully redirected to $($dd.Url)"
}else{
    Write-Error "Login page redirection failure!!!!"
}


#if([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath("/html/body/h1")))

$msg = $dd.FindElementByXPath("/html/body/h1")
if($msg.Text -eq "Logged in successfully"){
    Write-Output "Page logged in successfully"
    $img = $dd.GetScreenshot()
    $report += "<tr><td>$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss'): Page logged in successfully</td></tr>"
    $report += "<tr><td><img src=`"data:image/jpeg;base64,$($img.AsBase64EncodedString)`" width=""800"" height=""600""></td></tr>"
    $Screenshot = [OpenQA.Selenium.Support.Extensions.WebDriverExtensions]::TakeScreenshot($dd)
    $Screenshot.SaveAsFile("$($execlog)\loginsuccess.jpeg", $ImageFormat)
}
else{
    Write-Error "Login page loaded failure after login!!!!"
}


$dd.Close()

Stop-Process $iEProcess.Id -Force

Compress-Archive -Path "$($execlog)\*" -DestinationPath "$($execlog).zip"
if(Test-Path -Path "$($execlog).zip"){
    Remove-Item -Path $execlog -Recurse
}

$htmltemplate = @"
<html>
<body>
<style>table { border-collapse: collapse; }tr { border: solid thin; }</style>
<h1>Selenium Test</h1>
<table>
@{tabledata}
</table>
</body></html>

"@

"<html><body><table>$($report)</table></body></html>" > test.html

#Copy-Item -Path ""




