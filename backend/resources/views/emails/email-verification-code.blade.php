<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Verify your Josi email address</title>
</head>
<body style="font-family: Arial, sans-serif; color: #1f2933; line-height: 1.5;">
    <p>Hello {{ $name }},</p>

    <p>Use this 6-digit code to verify your email address and finish setting up your Josi account:</p>

    <p style="font-size: 24px; font-weight: 700; letter-spacing: 4px;">{{ $code }}</p>

    <p>{{ $expiryNotice }}</p>
    <p><strong>Expiry time:</strong> {{ $expiresAt }}</p>

    <p>If you did not create a Josi account, ignore this email.</p>
</body>
</html>
