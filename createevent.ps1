# Look up the application id

# Create the event based on the application id

#Controller hostname
$hostname = ""

$endpoint_create_event = "/controller/rest/applications/<application_id>/events?"

#Filter on applications that existed in the last week, return in json format
$endpoint_get_applications = "/controller/rest/applications?output=json&time-range-type=BEFORE_NOW&duration-in-mins=10080"

$businessApplicationName = ""


$url = $hostname+$endpoint_get_applications

Write-Host "Connecting to URL: $url"

$token = "ASecretToken"

$user = "aUser@controllerName"
$pass= "aSecretPassword"

$pair = "${user}:${pass}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"


$header = @{
	Accept = 'application/json'
	Authorization = $basicAuthValue
	ContentType = 'application/json'
}

$params = @{
	Uri = $url
	Headers = $header
	Method = 'GET'
#	Body = $body
#	ContentType = 'application/json'
#	Accept = 'application/json'
}


write-host "Make the call"
$applicationObjects = Invoke-RestMethod @params #  -OutFile response1.txt

$targetApplication = $applicationObjects | where { $_.Name -eq $businessApplicationName }
$targetApplicationID = $targetApplication.id


# Update the URL to reference the correct application
$endpoint_create_event = $endpoint_create_event -replace "<application_id>", "${targetApplicationID}"
$endpoint_create_event | Out-Host



$body = @{
#	$summary = "<ENVIRONMENT>-<Build Number>-<Deployment Number>"
	summary = "Event Details"
	severity = 'INFO'
	eventType = "CUSTOM"
	customeventtype = "APPLICATION_DEPLOYMENT"
}

$summary = "Event Details"
$severity = "INFO"
$eventType = "APPLICATION_DEPLOYMENT"
$customeventtype = "APPLICATION_DEPLOYMENT"

$endpoint_create_event = "${endpoint_create_event}summary=${summary}"
$endpoint_create_event = "${endpoint_create_event}&severity=${severity}"
$endpoint_create_event = "${endpoint_create_event}&eventType=${eventType}"
$endpoint_create_event = "${endpoint_create_event}&customeventtype=${customeventtype}"

$endpoint_create_event | Out-Host

$url = $hostname+$endpoint_create_event

$params = @{
	Uri = $url
	Headers = $header
	Method = 'POST'
#	Body = $body
#	ContentType = 'application/json'
#	Accept = 'application/json'
}

try
{
    $applicationObjects = Invoke-RestMethod @params
}
catch
{
    # Dig into the exception to get the Response details.
    # Note that value__ is not a typo.
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
}
