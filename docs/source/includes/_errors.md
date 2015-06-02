# Errors

## HTTP Errors

The SmartContract API uses the following standard HTTP error codes:

Error Code | Meaning
---------- | -------
400 | Bad Request -- the request payload is structured incorrectly, or validation has failed
401 | Unauthorized -- incorrect API key
403 | Forbidden -- you do not have access to the requested resource
404 | Not Found -- resource could not be found
405 | Method Not Allowed -- You tried to access the API with an invalid method
406 | Not Acceptable -- You requested a format that isn't JSON
410 | Gone -- The requested resource has been removed from our servers
418 | --
429 | Too Many Requests -- Your request rate is too high
500 | Internal Server Error -- We had a problem with our server. Try again later.
503 | Service Unavailable -- We're temporarily offline for maintenance. Please try again later.

<aside class="notice"></aside>

## Validation Errors
