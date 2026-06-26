<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\RemittanceStatus;
use App\Enums\TripStatus;
use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\RiderCashLedger;
use App\Models\Trip;
use Illuminate\Http\Request;

class DriverWalletController extends Controller
{
    public function __invoke(Request $request)
    {
        $profile = $request->user()->riderProfile;
        if (! $profile) {
            return ApiResponse::error('Rider profile was not found for this account.', [], 404);
        }

        $completedTrips = $profile
            ->trips()
            ->with(['riderCashLedger'])
            ->where('trip_status', TripStatus::Completed->value)
            ->latest('completed_at')
            ->limit(100)
            ->get();

        $ledgers = $profile
            ->riderCashLedgers()
            ->with('trip')
            ->latest()
            ->limit(100)
            ->get();

        $totalEarnings = round($completedTrips->sum(
            fn (Trip $trip): float => $this->tripEarning($trip)
        ), 2);
        $todayEarnings = round($completedTrips
            ->filter(fn (Trip $trip): bool => $trip->completed_at?->isToday() ?? false)
            ->sum(fn (Trip $trip): float => $this->tripEarning($trip)), 2);
        $pendingRemittance = round($ledgers->sum(
            fn (RiderCashLedger $ledger): float => $this->pendingRemittance($ledger)
        ), 2);

        return ApiResponse::success('Driver wallet fetched successfully', [
            'summary' => [
                'balance' => $totalEarnings,
                'available_balance' => $totalEarnings,
                'total_earnings' => $totalEarnings,
                'pending_remittance' => $pendingRemittance,
                'today_earnings' => $todayEarnings,
            ],
            'transactions' => $completedTrips
                ->map(fn (Trip $trip): array => $this->transactionPayload($trip))
                ->values()
                ->all(),
        ]);
    }

    private function transactionPayload(Trip $trip): array
    {
        return [
            'title' => 'Trip earning',
            'subtitle' => 'CRN : #'.$trip->getKey(),
            'amount' => $this->tripEarning($trip),
            'is_credit' => true,
            'status' => $this->label($this->enumValue($trip->payment_status) ?? TripStatus::Completed->value),
            'occurred_at' => $trip->completed_at?->toISOString(),
        ];
    }

    private function tripEarning(Trip $trip): float
    {
        if ($trip->riderCashLedger) {
            return round((float) $trip->riderCashLedger->rider_share, 2);
        }

        return round((float) $trip->amount, 2);
    }

    private function pendingRemittance(RiderCashLedger $ledger): float
    {
        $status = $this->enumValue($ledger->remittance_status);
        if (in_array($status, [RemittanceStatus::Remitted->value, RemittanceStatus::Waived->value], true)) {
            return 0;
        }

        return max(0, round((float) $ledger->amount_to_remit - (float) $ledger->amount_remitted, 2));
    }

    private function label(?string $value): string
    {
        if ($value === null || trim($value) === '') {
            return 'Completed';
        }

        return ucwords(str_replace('_', ' ', $value));
    }

    private function enumValue(mixed $value): ?string
    {
        if ($value instanceof \BackedEnum) {
            return $value->value;
        }

        return $value === null ? null : (string) $value;
    }
}
