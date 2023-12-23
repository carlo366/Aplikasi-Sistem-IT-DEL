<?php

namespace App\Http\Controllers;

use App\Models\booking_ruangan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\BookingRuangan;


class AdminBookingRuanganController extends Controller
{
    public function index()
    {
        // Mendapatkan pengguna yang sedang login
        $user = Auth::user();

        // Mengambil data booking ruangan sesuai dengan user yang login
        $bookingData = booking_ruangan::where('status', 'pending')
    ->orderBy('created_at', 'desc')
    ->get(['id', 'approver_id', 'reason', 'start_time', 'end_time', 'status', 'user_id', 'room_id', 'created_at', 'updated_at'])
    ->map(function ($booking) {
        $booking['start_date'] = $booking['start_date'] ? $booking['start_date']->format('Y-m-d H:i:s') : null;
        $booking['end_date'] = $booking['end_date'] ? $booking['end_date']->format('Y-m-d H:i:s') : null;
        $booking['ruangan_name'] = $booking->ruangan_name;
        return $booking;
    });

        return response()->json(['bookingData' => $bookingData], 200);
    }
    public function indexsemua()
    {
        // Mendapatkan pengguna yang sedang login
        $user = Auth::user();

        // Mengambil semua data booking ruangan dengan status 'rejected' atau 'approved'
        $bookingData = booking_ruangan::whereIn('status', ['rejected', 'approved'])
            ->orderBy('created_at', 'desc')
            ->get(['id', 'approver_id', 'reason', 'start_time', 'end_time', 'status', 'user_id', 'room_id', 'created_at', 'updated_at'])
            ->map(function ($booking) {
                $booking['start_date'] = $booking['start_date'] ? $booking['start_date']->format('Y-m-d H:i:s') : null;
                $booking['end_date'] = $booking['end_date'] ? $booking['end_date']->format('Y-m-d H:i:s') : null;
                $booking['ruangan_name'] = $booking->ruangan_name;
                return $booking;
            });

        return response()->json(['bookingData' => $bookingData], 200);
    }


    public function show($id)
    {
        return response([
            'BookingData' => booking_ruangan::where('id', $id)->get()
        ], 200);
    }


    public function approve($id)
    {
        // Retrieve the leave request by its ID
        $requestIzinKeluar = booking_ruangan::find($id);

        // Check if the leave request exists
        if (!$requestIzinKeluar) {
            return response([
                'message' => 'Leave request not found.',
            ], 404);
        }
        // Update the status to 'approved'
        $requestIzinKeluar->update([
            'status' => 'approved',
            'approver_id' => Auth::user()->id,
        ]);

        return response([
            'message' => 'Leave request approved successfully.',
            'BookingData' => $requestIzinKeluar,
        ], 200);
    }
    public function rejected($id)
    {
        // Retrieve the leave request by its ID
        $requestIzinKeluar = booking_ruangan::find($id);

        // Check if the leave request exists
        if (!$requestIzinKeluar) {
            return response([
                'message' => 'Leave request not found.',
            ], 404);
        }
        // Update the status to 'approved'
        $requestIzinKeluar->update([
            'status' => 'rejected',
            'approver_id' => Auth::user()->id,
        ]);

        return response([
            'message' => 'Leave request approved successfully.',
            'BookingData' => $requestIzinKeluar,
        ], 200);
    }
}
