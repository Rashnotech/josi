<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\CustomerSavedAddress;
use Illuminate\Http\Request;

class CustomerAddressController extends Controller
{
    public function index(Request $request)
    {
        $addresses = $request->user()
            ->savedAddresses()
            ->latest()
            ->get()
            ->map(fn (CustomerSavedAddress $address): array => $this->addressPayload($address))
            ->all();

        return ApiResponse::success('Customer saved addresses fetched successfully', [
            'addresses' => $addresses,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'label' => ['required', 'string', 'max:80'],
            'address' => ['required', 'string', 'max:1000'],
            'floor' => ['sometimes', 'nullable', 'string', 'max:80'],
            'landmark' => ['sometimes', 'nullable', 'string', 'max:255'],
            'latitude' => ['sometimes', 'nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['sometimes', 'nullable', 'numeric', 'between:-180,180'],
            'is_default' => ['sometimes', 'boolean'],
        ]);

        $address = $request->user()->savedAddresses()->create($data);

        return ApiResponse::success('Customer saved address created successfully', [
            'address' => $this->addressPayload($address),
        ], 201);
    }

    private function addressPayload(CustomerSavedAddress $address): array
    {
        return [
            'id' => $address->getKey(),
            'label' => $address->label,
            'address' => $address->address,
            'floor' => $address->floor,
            'landmark' => $address->landmark,
            'latitude' => $address->latitude,
            'longitude' => $address->longitude,
            'is_default' => $address->is_default,
            'created_at' => $address->created_at?->toISOString(),
        ];
    }
}
