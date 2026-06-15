<?php

namespace App\Support\Filament;

use App\Models\Fleet;
use App\Models\Payment;
use App\Models\RiderCashLedger;
use App\Models\RiderDocument;
use App\Models\RiderProfile;
use App\Models\User;
use App\Models\Vehicle;
use App\Services\CashLedgerService;
use App\Services\DocumentVerificationService;
use App\Services\DriverApprovalService;
use App\Services\FleetApprovalService;
use App\Services\PaymentService;
use App\Services\VehicleVerificationService;
use Filament\Actions\Action;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;
use Throwable;

class ResourceActions
{
    /**
     * @return array<int, Action>
     */
    public static function driverWorkflow(): array
    {
        return [
            Action::make('approve')
                ->label('Approve')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn (RiderProfile $record): bool => self::isStaff() && self::status($record->application_status) !== 'approved')
                ->action(fn (RiderProfile $record): mixed => self::call(fn () => app(DriverApprovalService::class)->approve($record, self::actor()), 'Application approved')),
            Action::make('reject')
                ->label('Reject')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->form([Textarea::make('reason')->label('Rejection reason')->required()->maxLength(1000)])
                ->visible(fn (RiderProfile $record): bool => self::isStaff() && self::status($record->application_status) !== 'rejected')
                ->action(fn (RiderProfile $record, array $data): mixed => self::call(fn () => app(DriverApprovalService::class)->reject($record, self::actor(), $data['reason']), 'Application rejected')),
            Action::make('under_review')
                ->label('Mark under review')
                ->icon('heroicon-o-eye')
                ->color('warning')
                ->visible(fn (RiderProfile $record): bool => self::isStaff() && self::status($record->application_status) !== 'under_review')
                ->action(fn (RiderProfile $record): mixed => self::call(fn () => app(DriverApprovalService::class)->markUnderReview($record, self::actor()), 'Application moved to review')),
            Action::make('suspend')
                ->label('Suspend')
                ->icon('heroicon-o-no-symbol')
                ->color('danger')
                ->form([Textarea::make('reason')->label('Suspension reason')->required()->maxLength(1000)])
                ->visible(fn (RiderProfile $record): bool => self::isStaff() && self::status($record->application_status) !== 'suspended')
                ->action(fn (RiderProfile $record, array $data): mixed => self::call(fn () => app(DriverApprovalService::class)->suspend($record, self::actor(), $data['reason']), 'Profile suspended')),
            Action::make('reactivate')
                ->label('Reactivate')
                ->icon('heroicon-o-arrow-path')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn (RiderProfile $record): bool => self::isStaff() && self::status($record->application_status) === 'suspended')
                ->action(fn (RiderProfile $record): mixed => self::call(fn () => app(DriverApprovalService::class)->reactivate($record, self::actor()), 'Profile reactivated')),
        ];
    }

    /**
     * @return array<int, Action>
     */
    public static function fleetWorkflow(): array
    {
        return [
            Action::make('approve')
                ->label('Approve')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn (Fleet $record): bool => self::isStaff() && self::status($record->application_status) !== 'approved')
                ->action(fn (Fleet $record): mixed => self::call(fn () => app(FleetApprovalService::class)->approve($record, self::actor()), 'Fleet approved')),
            Action::make('reject')
                ->label('Reject')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->form([Textarea::make('reason')->label('Rejection reason')->required()->maxLength(1000)])
                ->visible(fn (Fleet $record): bool => self::isStaff() && self::status($record->application_status) !== 'rejected')
                ->action(fn (Fleet $record, array $data): mixed => self::call(fn () => app(FleetApprovalService::class)->reject($record, self::actor(), $data['reason']), 'Fleet rejected')),
            Action::make('under_review')
                ->label('Mark under review')
                ->icon('heroicon-o-eye')
                ->color('warning')
                ->visible(fn (Fleet $record): bool => self::isStaff() && self::status($record->application_status) !== 'under_review')
                ->action(fn (Fleet $record): mixed => self::call(fn () => app(FleetApprovalService::class)->markUnderReview($record, self::actor()), 'Fleet moved to review')),
            Action::make('suspend')
                ->label('Suspend')
                ->icon('heroicon-o-no-symbol')
                ->color('danger')
                ->form([Textarea::make('reason')->label('Suspension reason')->required()->maxLength(1000)])
                ->visible(fn (Fleet $record): bool => self::isStaff() && self::status($record->application_status) !== 'suspended')
                ->action(fn (Fleet $record, array $data): mixed => self::call(fn () => app(FleetApprovalService::class)->suspend($record, self::actor(), $data['reason']), 'Fleet suspended')),
            Action::make('reactivate')
                ->label('Reactivate')
                ->icon('heroicon-o-arrow-path')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn (Fleet $record): bool => self::isStaff() && self::status($record->application_status) === 'suspended')
                ->action(fn (Fleet $record): mixed => self::call(fn () => app(FleetApprovalService::class)->reactivate($record, self::actor()), 'Fleet reactivated')),
        ];
    }

    /**
     * @return array<int, Action>
     */
    public static function documentWorkflow(): array
    {
        return [
            Action::make('verify')
                ->label('Verify')
                ->icon('heroicon-o-document-check')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn (Model $record): bool => self::isStaff() && self::status($record->verification_status) !== 'verified')
                ->action(fn (Model $record): mixed => self::call(fn () => app(DocumentVerificationService::class)->verify($record, self::actor()), 'Document verified')),
            Action::make('reject')
                ->label('Reject')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->form([Textarea::make('reason')->label('Rejection reason')->required()->maxLength(1000)])
                ->visible(fn (Model $record): bool => self::isStaff() && self::status($record->verification_status) !== 'rejected')
                ->action(fn (Model $record, array $data): mixed => self::call(fn () => app(DocumentVerificationService::class)->reject($record, self::actor(), $data['reason']), 'Document rejected')),
        ];
    }

    /**
     * @return array<int, Action>
     */
    public static function vehicleWorkflow(): array
    {
        return [
            Action::make('verify')
                ->label('Verify')
                ->icon('heroicon-o-check-badge')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn (Vehicle $record): bool => self::isStaff() && self::status($record->verification_status) !== 'verified')
                ->action(fn (Vehicle $record): mixed => self::call(fn () => app(VehicleVerificationService::class)->verify($record, self::actor()), 'Vehicle verified')),
            Action::make('reject')
                ->label('Reject')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->form([Textarea::make('reason')->label('Rejection reason')->required()->maxLength(1000)])
                ->visible(fn (Vehicle $record): bool => self::isStaff() && self::status($record->verification_status) !== 'rejected')
                ->action(fn (Vehicle $record, array $data): mixed => self::call(fn () => app(VehicleVerificationService::class)->reject($record, self::actor(), $data['reason']), 'Vehicle rejected')),
            Action::make('suspend')
                ->label('Suspend')
                ->icon('heroicon-o-no-symbol')
                ->color('danger')
                ->form([Textarea::make('reason')->label('Suspension reason')->required()->maxLength(1000)])
                ->visible(fn (Vehicle $record): bool => self::isStaff() && self::status($record->vehicle_status) !== 'suspended')
                ->action(fn (Vehicle $record, array $data): mixed => self::call(fn () => app(VehicleVerificationService::class)->suspend($record, self::actor(), $data['reason']), 'Vehicle suspended')),
            Action::make('mark_active')
                ->label('Mark active')
                ->icon('heroicon-o-bolt')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn (Vehicle $record): bool => self::isStaff() && self::status($record->vehicle_status) !== 'active')
                ->action(fn (Vehicle $record): mixed => self::call(fn () => app(VehicleVerificationService::class)->markActive($record, self::actor()), 'Vehicle marked active')),
        ];
    }

    /**
     * @return array<int, Action>
     */
    public static function paymentWorkflow(): array
    {
        return [
            Action::make('verify_payment')
                ->label('Verify payment')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->form([
                    TextInput::make('payment_reference')->label('Payment reference')->required()->maxLength(255),
                    TextInput::make('gateway')->label('Gateway')->maxLength(100),
                ])
                ->visible(fn (Payment $record): bool => self::isStaff() && self::status($record->payment_method) !== 'cash')
                ->action(fn (Payment $record, array $data): mixed => self::call(fn () => app(PaymentService::class)->markVerifiedPaid($record, self::actor(), $data['payment_reference'], $data['gateway'] ?? null), 'Payment verified')),
            Action::make('mark_failed')
                ->label('Mark failed')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->form([Textarea::make('gateway_response')->label('Gateway note')->maxLength(1000)])
                ->visible(fn (Payment $record): bool => self::isStaff() && self::status($record->payment_status) !== 'failed')
                ->action(fn (Payment $record, array $data): mixed => self::call(fn () => app(PaymentService::class)->recordFailedPayment($record, self::actor(), ['admin_note' => $data['gateway_response'] ?? null]), 'Payment marked failed')),
        ];
    }

    /**
     * @return array<int, Action>
     */
    public static function cashLedgerWorkflow(): array
    {
        return [
            Action::make('partial_remittance')
                ->label('Record remittance')
                ->icon('heroicon-o-banknotes')
                ->color('success')
                ->form([
                    TextInput::make('amount')->label('Amount remitted')->numeric()->required()->prefix('NGN'),
                    Textarea::make('notes')->label('Admin note')->maxLength(1000),
                ])
                ->visible(fn (): bool => self::isStaff())
                ->action(fn (RiderCashLedger $record, array $data): mixed => self::call(fn () => app(CashLedgerService::class)->recordRemittance($record, self::actor(), (float) $data['amount'], $data['notes'] ?? null), 'Remittance recorded')),
            Action::make('fully_remitted')
                ->label('Mark fully remitted')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->form([Textarea::make('notes')->label('Admin note')->maxLength(1000)])
                ->visible(fn (): bool => self::isStaff())
                ->action(fn (RiderCashLedger $record, array $data): mixed => self::call(fn () => app(CashLedgerService::class)->markFullyRemitted($record, self::actor(), $data['notes'] ?? null), 'Ledger fully remitted')),
            Action::make('disputed')
                ->label('Mark disputed')
                ->icon('heroicon-o-exclamation-triangle')
                ->color('danger')
                ->form([Textarea::make('notes')->label('Dispute note')->required()->maxLength(1000)])
                ->visible(fn (): bool => self::isStaff())
                ->action(fn (RiderCashLedger $record, array $data): mixed => self::call(fn () => app(CashLedgerService::class)->markDisputed($record, self::actor(), $data['notes']), 'Ledger marked disputed')),
            Action::make('admin_note')
                ->label('Add note')
                ->icon('heroicon-o-pencil-square')
                ->color('gray')
                ->form([Textarea::make('notes')->label('Admin note')->required()->maxLength(1000)])
                ->visible(fn (): bool => self::isStaff())
                ->action(fn (RiderCashLedger $record, array $data): mixed => self::call(fn () => app(CashLedgerService::class)->addAdminNote($record, self::actor(), $data['notes']), 'Ledger note saved')),
        ];
    }

    private static function actor(): User
    {
        /** @var User $user */
        $user = Auth::user();

        return $user;
    }

    private static function isStaff(): bool
    {
        return DashboardAccess::isStaff(Auth::user());
    }

    private static function status(mixed $status): string
    {
        return $status instanceof \BackedEnum ? $status->value : (string) $status;
    }

    private static function call(callable $callback, string $successTitle): mixed
    {
        try {
            $result = $callback();

            Notification::make()
                ->success()
                ->title($successTitle)
                ->send();

            return $result;
        } catch (Throwable $exception) {
            Notification::make()
                ->danger()
                ->title('Action failed')
                ->body($exception->getMessage())
                ->send();

            throw $exception;
        }
    }
}
