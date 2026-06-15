<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $title }} | Josi</title>
    <style>
        :root {
            color: #111111;
            font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: #f6f7f8;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-width: 320px;
        }

        a {
            color: inherit;
        }

        .shell {
            display: grid;
            min-height: 100vh;
            grid-template-columns: 17rem 1fr;
        }

        .sidebar {
            background: #050505;
            color: #ffffff;
            padding: 1.5rem;
        }

        .brand {
            align-items: center;
            display: flex;
            gap: 0.75rem;
            font-size: 1.45rem;
            font-weight: 800;
        }

        .brand-mark {
            background: #ec111a;
            border-radius: 0.5rem;
            display: grid;
            height: 2.4rem;
            place-items: center;
            width: 2.4rem;
        }

        .nav {
            display: grid;
            gap: 0.5rem;
            margin-top: 2.25rem;
        }

        .nav span {
            border-radius: 0.5rem;
            color: rgba(255, 255, 255, 0.72);
            display: block;
            font-weight: 700;
            padding: 0.85rem 1rem;
        }

        .nav span:first-child {
            background: #ec111a;
            color: #ffffff;
        }

        .main {
            padding: 2rem;
        }

        .topbar {
            align-items: flex-start;
            display: flex;
            gap: 1.5rem;
            justify-content: space-between;
        }

        h1 {
            font-size: clamp(2rem, 5vw, 3.5rem);
            letter-spacing: 0;
            line-height: 1;
            margin: 0.5rem 0 0;
        }

        .eyebrow {
            color: #ec111a;
            font-size: 0.8rem;
            font-weight: 900;
            letter-spacing: 0.08em;
            margin: 0;
            text-transform: uppercase;
        }

        .muted {
            color: #666666;
            font-weight: 600;
            line-height: 1.55;
        }

        .panel {
            background: #ffffff;
            border: 1px solid #e6e6e6;
            border-radius: 0.5rem;
            box-shadow: 0 18px 50px rgba(0, 0, 0, 0.08);
            padding: 1.25rem;
        }

        .account {
            display: grid;
            gap: 1rem;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            margin-top: 1.5rem;
        }

        .label {
            color: #666666;
            font-size: 0.75rem;
            font-weight: 900;
            margin: 0 0 0.4rem;
            text-transform: uppercase;
        }

        .value {
            font-size: 1rem;
            font-weight: 800;
            margin: 0;
            overflow-wrap: anywhere;
        }

        .grid {
            display: grid;
            gap: 1rem;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            margin-top: 1.5rem;
        }

        .card {
            background: #ffffff;
            border: 1px solid #e6e6e6;
            border-radius: 0.5rem;
            padding: 1.25rem;
        }

        .card strong {
            display: block;
            font-size: 1.8rem;
            line-height: 1.1;
            margin-top: 0.6rem;
        }

        .button {
            background: #ec111a;
            border-radius: 999px;
            color: #ffffff;
            display: inline-flex;
            font-weight: 900;
            padding: 0.85rem 1.25rem;
            text-decoration: none;
        }

        @media (max-width: 820px) {
            .shell {
                grid-template-columns: 1fr;
            }

            .sidebar {
                position: static;
            }

            .account,
            .grid {
                grid-template-columns: 1fr;
            }

            .topbar {
                display: grid;
            }
        }
    </style>
</head>
<body>
    <div class="shell">
        <aside class="sidebar">
            <div class="brand">
                <span class="brand-mark">J</span>
                <span>Josi</span>
            </div>
            <nav class="nav" aria-label="Dashboard navigation">
                <span>Dashboard</span>
                <span>Users</span>
                <span>Vehicles</span>
                <span>Applications</span>
                <span>Reports</span>
            </nav>
        </aside>

        <main class="main">
            @if ($status === 'unauthenticated')
                <section class="panel">
                    <p class="eyebrow">Secure dashboard</p>
                    <h1>Sign in required</h1>
                    <p class="muted">Use the Josi web login to access the Laravel dashboard.</p>
                    <a class="button" href="{{ $loginUrl }}">Go to login</a>
                </section>
            @elseif ($status === 'forbidden')
                <section class="panel">
                    <p class="eyebrow">Access denied</p>
                    <h1>Unauthorized</h1>
                    <p class="muted">This dashboard is available to super admins, admins, and pack owners only.</p>
                    <a class="button" href="{{ $loginUrl }}">Use another account</a>
                </section>
            @else
                <section class="panel">
                    <div class="topbar">
                        <div>
                            <p class="eyebrow">Filament-ready scaffold</p>
                            <h1>{{ $title }}</h1>
                            <p class="muted">Welcome, {{ $user->name }}. This Laravel-side dashboard is ready for future Filament resources and panels.</p>
                        </div>
                        <a class="button" href="{{ $loginUrl }}">Switch account</a>
                    </div>

                    <div class="account">
                        <div>
                            <p class="label">Email</p>
                            <p class="value">{{ $user->email }}</p>
                        </div>
                        <div>
                            <p class="label">Phone</p>
                            <p class="value">{{ $user->phone }}</p>
                        </div>
                        <div>
                            <p class="label">Role</p>
                            <p class="value">{{ str_replace('_', ' ', $user->role instanceof \BackedEnum ? $user->role->value : $user->role) }}</p>
                        </div>
                    </div>
                </section>

                <section class="grid" aria-label="Dashboard summary">
                    @foreach ($cards as $card)
                        <article class="card">
                            <p class="label">{{ $card['label'] }}</p>
                            <strong>{{ $card['value'] }}</strong>
                            <p class="muted">{{ $card['description'] }}</p>
                        </article>
                    @endforeach
                </section>
            @endif
        </main>
    </div>
</body>
</html>
