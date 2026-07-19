<?php

namespace App\Providers\Filament;

use App\Filament\Admin\Pages\AdminDashboard;
use App\Filament\Admin\Widgets\AdminDashboardHero;
use App\Filament\Admin\Widgets\AdminOverviewStats;
use App\Filament\Admin\Widgets\ApplicationStatusChart;
use App\Filament\Admin\Widgets\CashRemittanceSummary;
use App\Filament\Admin\Widgets\RecentPayments;
use App\Filament\Admin\Widgets\RecentRegistrations;
use App\Filament\Admin\Widgets\RecentTrips;
use App\Support\Filament\DashboardAccess;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Navigation\NavigationGroup;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Support\Enums\Width;
use Filament\View\PanelsRenderHook;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id(DashboardAccess::ADMIN_PANEL)
            ->path('admin')
            ->login()
            ->brandName('Josi Admin')
            ->brandLogo(asset('images/josi-logo.png'))
            ->brandLogoHeight('2.25rem')
            ->favicon(asset('images/josi-logo.png'))
            ->font('Inter')
            ->colors([
                'primary' => Color::Red,
                'gray' => Color::Slate,
                'success' => Color::Green,
                'warning' => Color::Amber,
                'danger' => Color::Red,
                'info' => Color::Blue,
            ])
            ->maxContentWidth(Width::Full)
            ->sidebarCollapsibleOnDesktop()
            ->unsavedChangesAlerts()
            ->profile()
            ->renderHook(
                PanelsRenderHook::BODY_START,
                fn () => view('filament.partials.panel-loader')->render(),
            )
            ->navigationGroups([
                NavigationGroup::make('Overview'),
                NavigationGroup::make('User Management'),
                NavigationGroup::make('Applications'),
                NavigationGroup::make('Fleet & Vehicles'),
                NavigationGroup::make('KYC Documents'),
                NavigationGroup::make('Operations'),
                NavigationGroup::make('Payments'),
                NavigationGroup::make('Reports'),
                NavigationGroup::make('System'),
            ])
            ->discoverResources(in: app_path('Filament/Admin/Resources'), for: 'App\\Filament\\Admin\\Resources')
            ->discoverPages(in: app_path('Filament/Admin/Pages'), for: 'App\\Filament\\Admin\\Pages')
            ->pages([
                AdminDashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Admin/Widgets'), for: 'App\\Filament\\Admin\\Widgets')
            ->widgets([
                AdminDashboardHero::class,
                AdminOverviewStats::class,
                ApplicationStatusChart::class,
                CashRemittanceSummary::class,
                RecentRegistrations::class,
                RecentTrips::class,
                RecentPayments::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
