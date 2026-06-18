<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Your Josi password reset code</title>
</head>
<body style="font-family: Arial, sans-serif; color: #1f2933; line-height: 1.5;">
    <p>Hello {{ $name }},</p>

    <p>Use this 6-digit code to reset your password:</p>

    <p style="font-size: 24px; font-weight: 700; letter-spacing: 4px;">{{ $code }}</p>

    <p>{{ $expiryNotice }}</p>
    <p><strong>Expiry time:</strong> {{ $expiresAt }}</p>

    <p>If you did not request this code, ignore this email and keep your account secure.</p>
</body>
</html>
