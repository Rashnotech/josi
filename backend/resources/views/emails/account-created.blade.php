<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Your Josi account has been created</title>
</head>
<body style="font-family: Arial, sans-serif; color: #1f2933; line-height: 1.5;">
    <p>Hello {{ $name }},</p>

    <p>Your Josi account was created successfully.</p>

    <p><strong>{{ $accountRoleLabel }}</strong> {{ $accountType }}</p>

    <p>{{ $nextStep }}</p>

    @if ($applicationStatus)
        <p><strong>Application status:</strong> {{ $applicationStatus }}</p>
    @endif

    <p>If you did not create this account, contact Josi support immediately.</p>
</body>
</html>
