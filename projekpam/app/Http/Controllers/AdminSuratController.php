<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\RequestSurat;

class AdminSuratController extends Controller
{
    public function index()
    {
        // Mendapatkan pengguna yang sedang login
        $user = Auth::user();

        // Mengambil data RequestIzinKeluar sesuai dengan user yang login
        $izinKeluarData = RequestSurat::where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->get();

        return response([
            'RequestSurat' => $izinKeluarData
        ], 200);
    }
    public function indexsemua()
    {
        // Mendapatkan pengguna yang sedang login
        $user = Auth::user();

        // Mengambil data RequestIzinKeluar sesuai dengan user yang login
        $izinKeluarData = RequestSurat::where(function ($query) {
            $query->where('status', 'rejected')
                ->orWhere('status', 'approved');
        })
        ->orderBy('created_at', 'desc')
        ->get();

        return response([
            'RequestSurat' => $izinKeluarData
        ], 200);
    }

    public function show($id)
    {
        return response([
            'RequestSurat' => RequestSurat::where('id', $id)->get()
        ], 200);
    }


    public function approve($id)
    {
        // Retrieve the leave request by its ID
        $requestIzinKeluar = RequestSurat::find($id);

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
            'RequestSurat' => $requestIzinKeluar,
        ], 200);
    }
    public function rejected($id)
    {
        // Retrieve the leave request by its ID
        $requestIzinKeluar = RequestSurat::find($id);

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
            'RequestSurat' => $requestIzinKeluar,
        ], 200);
    }
}
