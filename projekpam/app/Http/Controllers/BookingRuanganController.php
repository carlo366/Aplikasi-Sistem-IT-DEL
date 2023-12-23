<?php

namespace App\Http\Controllers;

use App\Models\booking_ruangan;
use Illuminate\Http\Request;
use App\Models\BookingRuangan;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Models\User;

class BookingRuanganController extends Controller
{
    public function index()
    {
        // Mendapatkan pengguna yang sedang login
        $user = Auth::user();

        // Mengambil data booking ruangan sesuai dengan user yang login
        $bookingData = booking_ruangan::where('user_id', $user->id)
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
    public function bookRoom(Request $request)
    {
        // Validasi input form booking ruangan
        $validator = Validator::make($request->all(), [
            'room_id' => 'required|exists:ruangan,id',
            'reason' => 'required',
            'start_time' => 'required|date',
            'end_time' => 'required|date',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        // Cek apakah ruangan tersedia pada waktu yang diminta
        if ($this->isRoomAvailable($request->input('room_id'), $request->input('start_time'), $request->input('end_time'))) {
            // Buat booking ruangan baru
            booking_ruangan::create([
                'user_id' => Auth::id(),
                'room_id' => $request->input('room_id'),
                'reason' => $request->input('reason'),
                'start_time' => $request->input('start_time'),
                'end_time' => $request->input('end_time'),
                // Tambahkan field lain sesuai kebutuhan
            ]);

            return response()->json(['message' => 'Booking ruangan berhasil!'], 200);
        } else {
            return response()->json(['error' => 'Ruangan telah di-booking pada waktu tersebut.'], 422);
        }
    }


    // Method untuk mengecek ketersediaan ruangan pada waktu tertentu
    private function isRoomAvailable($roomId, $startTime, $endTime)
    {
        $existingBookings = booking_ruangan::where('room_id', $roomId)
            ->where(function ($query) use ($startTime, $endTime) {
                $query->whereBetween('start_time', [$startTime, $endTime])
                    ->orWhereBetween('end_time', [$startTime, $endTime]);
            })
            ->count();

        return $existingBookings === 0;
    }

    public function destroy($id){
        $RequestIzinBermalam= booking_ruangan::find($id);
        if(!$RequestIzinBermalam){
         return response([
             'message' => 'Request Izin Keluar Tidak Ditemukan',
         ], 403);
        }
        if($RequestIzinBermalam->user_id !=auth()->user()->id){
         return response([
             'message' => 'Akun Anda Tidak mengakses Ini',
         ], 403);
        }
        $RequestIzinBermalam->delete();
        return response([
            'message' => 'Request Izin Keluar Telah Dihapus',
            'RequestIzinBermalam'=>$RequestIzinBermalam
        ], 200);
       }
       public function RoomAvailable(Request $request)
       {
           // Ensure you have the 'use' statement for the Request class at the top of your file
           // use Illuminate\Http\Request;

           $validator = Validator::make($request->all(), [
               'room_id' => 'required|exists:ruangan,id',
               'start_time' => 'required',
               'end_time' => 'required', // Make sure end_time is after start_time
           ]);

           // Check if validation fails
           if ($validator->fails()) {
               return response()->json(['error' => $validator->errors()], 422);
           }

           $roomId = $request->input('room_id');
           $startTime = $request->input('start_time');
           $endTime = $request->input('end_time');

           $existingBookings = booking_ruangan::where('room_id', $roomId)
               ->where(function ($query) use ($startTime, $endTime) {
                   $query->whereBetween('start_time', [$startTime, $endTime])
                       ->orWhereBetween('end_time', [$startTime, $endTime]);
               })
               ->count();

           // Return response based on room availability
           if ($existingBookings === 0) {
               return response()->json(['message' => 'Room is available for booking'], 200);
           } else {
               return response()->json(['error' => 'Room is not available for the selected time range'], 422);
           }
       }

}
