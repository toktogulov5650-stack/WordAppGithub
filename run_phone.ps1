$javaHome = "C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot"
$deviceId = "5200d85a425ac5a5"

# If Google sign-in is configured, paste the IDs here once.
$googleWebClientId = "204077634716-56jbenjk4g3r7cb726qmlchnrg2ms1gf.apps.googleusercontent.com"
$googleServerClientId = "204077634716-56jbenjk4g3r7cb726qmlchnrg2ms1gf.apps.googleusercontent.com"

$env:JAVA_HOME = $javaHome
$env:Path = "$env:JAVA_HOME\bin;" + (($env:Path -split ';' | Where-Object {
    $_ -and $_ -notlike '*PyCharm 2025.2.4\jbr\bin*'
}) -join ';')

$flutterArgs = @("run", "-d", $deviceId)

if ($googleWebClientId) {
    $flutterArgs += "--dart-define=GOOGLE_WEB_CLIENT_ID=$googleWebClientId"
}

if ($googleServerClientId) {
    $flutterArgs += "--dart-define=GOOGLE_SERVER_CLIENT_ID=$googleServerClientId"
}

if (-not $googleWebClientId -and -not $googleServerClientId) {
    Write-Host "Google Client ID is not set. Regular login/register will work, but Google sign-in will show a config error." -ForegroundColor Yellow
}

flutter @flutterArgs
